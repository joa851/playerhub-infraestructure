variable "project_id" {
  description = "ID del proyecto GCP donde se crea toda la infraestructura"
  type        = string
}

variable "region" {
  description = "Región principal para Cloud Run y Artifact Registry"
  type        = string
  default     = "us-central1"
}

variable "github_owner" {
  description = "Usuario u organización de GitHub propietaria de los repos"
  type        = string
  default     = "joa851"
}

variable "github_repos" {
  description = "Repos de GitHub autorizados a impersonar al deployer vía WIF"
  type        = list(string)
  default = [
    "playerhub-infraestructure",
    "playerhub-frontend",
    "playerhub-backend-springboot",
    "playerhub-backend-mean",
    "playerhub-corba",
  ]
}

variable "artifact_registry_repo" {
  description = "Nombre del repositorio Docker en Artifact Registry"
  type        = string
  default     = "playerhub"
}
