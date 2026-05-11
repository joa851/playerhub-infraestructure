terraform {
  backend "gcs" {
    bucket = "joa851-proyecto2026-tfstate"
    prefix = "infra"
  }
}
