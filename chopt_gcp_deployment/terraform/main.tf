provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_container_cluster" "chopt_cluster" {
  name     = "chopt-gke"
  location = var.region
  remove_default_node_pool = true
  initial_node_count       = 1
}

resource "google_container_node_pool" "chopt_nodes" {
  name     = "chopt-pool"
  cluster  = google_container_cluster.chopt_cluster.name
  location = var.region

  node_config {
    machine_type = "n1-standard-4"
    accelerators {
      type  = "nvidia-tesla-k80"
      count = 1
    }
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
    tags = ["chopt"]
  }

  autoscaling {
    min_node_count = 1
    max_node_count = 5
  }
}

resource "google_storage_bucket" "chopt_bucket" {
  name     = "chopt-model-artifacts-${var.project_id}"
  location = var.region
  force_destroy = true
}
