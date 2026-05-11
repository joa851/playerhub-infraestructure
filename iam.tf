resource "google_service_account" "github_deployer" {
  project      = var.project_id
  account_id   = "github-deployer"
  display_name = "GitHub Actions deployer"
  description  = "Service account impersonada por los workflows de GitHub vía WIF"

  depends_on = [google_project_service.enabled]
}

resource "google_service_account" "cloudrun_runtime" {
  project      = var.project_id
  account_id   = "cloudrun-runtime"
  display_name = "Cloud Run runtime identity"
  description  = "Identidad con la que se ejecutan los servicios Cloud Run de PlayerHub"

  depends_on = [google_project_service.enabled]
}

locals {
  deployer_roles = [
    "roles/run.admin",
    "roles/artifactregistry.writer",
    "roles/iam.serviceAccountUser",
    "roles/storage.objectAdmin",
    "roles/secretmanager.secretAccessor",
  ]
}

resource "google_project_iam_member" "deployer" {
  for_each = toset(local.deployer_roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.github_deployer.email}"
}

resource "google_project_iam_member" "runtime_secret_accessor" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.cloudrun_runtime.email}"
}

resource "google_service_account_iam_member" "deployer_can_act_as_runtime" {
  service_account_id = google_service_account.cloudrun_runtime.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.github_deployer.email}"
}
