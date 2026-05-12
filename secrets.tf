resource "random_password" "pg_password" {
  length  = 32
  special = false
}

resource "random_password" "mongo_password" {
  length  = 32
  special = false
}

resource "google_secret_manager_secret" "pg_password" {
  project   = var.project_id
  secret_id = "playerhub-pg-password"

  replication {
    auto {}
  }

  depends_on = [google_project_service.enabled]
}

resource "google_secret_manager_secret_version" "pg_password" {
  secret      = google_secret_manager_secret.pg_password.id
  secret_data = random_password.pg_password.result
}

resource "google_secret_manager_secret" "mongo_password" {
  project   = var.project_id
  secret_id = "playerhub-mongo-password"

  replication {
    auto {}
  }

  depends_on = [google_project_service.enabled]
}

resource "google_secret_manager_secret_version" "mongo_password" {
  secret      = google_secret_manager_secret.mongo_password.id
  secret_data = random_password.mongo_password.result
}
