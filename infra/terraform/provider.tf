terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.5.0"
    }
  }
}

provider "google" {
  credentials = file(".keyfile.json")

  project = var.project
  region  = var.region
}
