resource "google_service_account" "database_vm" {
  project      = var.project_id
  account_id   = "database-vm-sa"
  display_name = "Service account de la VM de bases de datos PlayerHub"

  depends_on = [google_project_service.enabled]
}

resource "google_project_iam_member" "database_vm_secret_accessor" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.database_vm.email}"
}

resource "google_project_iam_member" "database_vm_log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.database_vm.email}"
}

resource "google_compute_address" "database_vm" {
  name    = "playerhub-db-ip"
  region  = var.region
  project = var.project_id

  depends_on = [google_project_service.enabled]
}

resource "google_compute_instance" "database_vm" {
  name         = "playerhub-db"
  machine_type = "e2-micro"
  zone         = "${var.region}-a"
  project      = var.project_id

  tags = ["playerhub-db"]

  boot_disk {
    initialize_params {
      image = "cos-cloud/cos-stable"
      size  = 30
      type  = "pd-standard"
    }
  }

  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.database_vm.address
    }
  }

  service_account {
    email  = google_service_account.database_vm.email
    scopes = ["cloud-platform"]
  }

  metadata = {
    enable-oslogin         = "TRUE"
    google-logging-enabled = "true"
    startup-script = templatefile("${path.module}/startup.sh", {
      project_id = var.project_id
    })
  }

  depends_on = [
    google_project_service.enabled,
    google_secret_manager_secret_version.pg_password,
    google_secret_manager_secret_version.mongo_password,
    google_project_iam_member.database_vm_secret_accessor,
  ]
}
