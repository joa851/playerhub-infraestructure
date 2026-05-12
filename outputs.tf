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

output "database_vm_ip" {
  description = "IP estática externa de la VM de bases de datos (apuntar el DNS aquí)"
  value       = google_compute_address.database_vm.address
}

output "database_vm_postgres_jdbc" {
  description = "URL JDBC de Postgres (password se inyecta vía Secret Manager)"
  value       = "jdbc:postgresql://${google_compute_address.database_vm.address}:5432/playerhub"
}

output "database_vm_mongo_uri_template" {
  description = "Template de URI de Mongo (sustituir <password> por el valor del secret)"
  value       = "mongodb://playerhub:<password>@${google_compute_address.database_vm.address}:27017/playerhub?authSource=admin"
}

output "pg_password_secret_id" {
  description = "ID del secret de Postgres en Secret Manager"
  value       = google_secret_manager_secret.pg_password.secret_id
}

output "mongo_password_secret_id" {
  description = "ID del secret de Mongo en Secret Manager"
  value       = google_secret_manager_secret.mongo_password.secret_id
}
