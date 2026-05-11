output "project_id" {
  description = "ID del proyecto GCP"
  value       = var.project_id
}

output "region" {
  description = "Región principal"
  value       = var.region
}

output "artifact_registry_url" {
  description = "URL base del registry; cuelga de aquí cada imagen del proyecto"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.playerhub.repository_id}"
}

output "deployer_service_account" {
  description = "Email de la service account que impersonan los workflows de GitHub"
  value       = google_service_account.github_deployer.email
}

output "cloudrun_runtime_service_account" {
  description = "Email de la service account de runtime de Cloud Run"
  value       = google_service_account.cloudrun_runtime.email
}

output "workload_identity_provider" {
  description = "Recurso completo del WIF provider, a configurar como secret en GitHub"
  value       = google_iam_workload_identity_pool_provider.github.name
}
