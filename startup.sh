#!/bin/bash
set -euo pipefail

LOG=/var/log/playerhub-startup.log
exec > >(tee -a "$LOG") 2>&1
echo "[$(date)] Starting Playerhub DB bootstrap"

# Wait for Docker to be ready
until docker info >/dev/null 2>&1; do
  echo "Waiting for Docker..."
  sleep 2
done

# Fetch OAuth token from metadata server (works because VM has SA attached)
TOKEN=$(curl -s -H "Metadata-Flavor: Google" \
  "http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token" \
  | sed -nE 's/.*"access_token"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/p')

if [ -z "$TOKEN" ]; then
  echo "ERROR: could not obtain access token from metadata server"
  exit 1
fi

fetch_secret() {
  local name=$1
  curl -s -H "Authorization: Bearer $TOKEN" \
    "https://secretmanager.googleapis.com/v1/projects/${project_id}/secrets/$name/versions/latest:access" \
    | sed -nE 's/.*"data"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/p' \
    | base64 -d
}

PG_PASSWORD=$(fetch_secret playerhub-pg-password)
MONGO_PASSWORD=$(fetch_secret playerhub-mongo-password)

if [ -z "$PG_PASSWORD" ] || [ -z "$MONGO_PASSWORD" ]; then
  echo "ERROR: failed to fetch secrets from Secret Manager"
  exit 1
fi

# Prepare persistent data directories on the boot disk
mkdir -p /var/lib/playerhub/pg /var/lib/playerhub/mongo
chmod 700 /var/lib/playerhub/pg /var/lib/playerhub/mongo

# --- PostgreSQL ---
docker pull postgres:16-alpine
docker rm -f playerhub-postgres 2>/dev/null || true
docker run -d \
  --name playerhub-postgres \
  --restart always \
  -p 5432:5432 \
  -v /var/lib/playerhub/pg:/var/lib/postgresql/data \
  -e POSTGRES_DB=playerhub \
  -e POSTGRES_USER=playerhub \
  -e POSTGRES_PASSWORD="$PG_PASSWORD" \
  postgres:16-alpine \
  postgres -c shared_buffers=64MB -c work_mem=2MB -c max_connections=20

# --- MongoDB ---
docker pull mongo:7
docker rm -f playerhub-mongo 2>/dev/null || true
docker run -d \
  --name playerhub-mongo \
  --restart always \
  -p 27017:27017 \
  -v /var/lib/playerhub/mongo:/data/db \
  -e MONGO_INITDB_ROOT_USERNAME=playerhub \
  -e MONGO_INITDB_ROOT_PASSWORD="$MONGO_PASSWORD" \
  mongo:7 \
  --wiredTigerCacheSizeGB=0.25 --bind_ip_all

echo "[$(date)] Bootstrap complete"
docker ps
