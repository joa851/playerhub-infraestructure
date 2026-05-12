resource "google_compute_firewall" "database_vm_postgres" {
  name        = "playerhub-db-postgres"
  project     = var.project_id
  network     = "default"
  description = "Allow Postgres traffic to playerhub-db VM"

  allow {
    protocol = "tcp"
    ports    = ["5432"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["playerhub-db"]
}

resource "google_compute_firewall" "database_vm_mongo" {
  name        = "playerhub-db-mongo"
  project     = var.project_id
  network     = "default"
  description = "Allow MongoDB traffic to playerhub-db VM"

  allow {
    protocol = "tcp"
    ports    = ["27017"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["playerhub-db"]
}
