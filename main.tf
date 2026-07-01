resource "google_compute_network" "vpc_network" {
  name                    = "custom-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "custom_subnet" {
  name          = "custom-subnet"
  ip_cidr_range = "10.10.0.0/16"
  region        = var.region
  network       = google_compute_network.vpc_network.id

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "192.168.0.0/16"
  }
}

resource "google_compute_firewall" "allow_internal" {
  name    = "allow-internal"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "all"
  }

  source_ranges = ["10.10.0.0/16"]
}

resource "google_compute_firewall" "allow_external" {
  name    = "external-firewall"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "3389"]
  }

  source_ranges = ["0.0.0.0/0"]

}

resource "google_compute_firewall" "allow_gke" {
  name    = "gke-firewall"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["443", "10250", "15017"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_project_service" "container" {
  project            = var.project_id
  service            = "container.googleapis.com"
  disable_on_destroy = false
}

#GKE Cluster
resource "google_container_cluster" "primary" {
  depends_on         = [google_project_service.container]
  project            = var.project_id
  name               = "gke-cluster"
  location           = var.zone # region for control plane
  initial_node_count = 1

  network                  = google_compute_network.vpc_network.id
  subnetwork               = google_compute_subnetwork.custom_subnet.id
  min_master_version       = var.K8s_version
  deletion_protection      = false
  remove_default_node_pool = true

  ip_allocation_policy {
    cluster_secondary_range_name = "pods"
  }
}


resource "google_container_node_pool" "primary_nodes" {
  project        = var.project_id
  name           = "primary-node-pool"
  location       = var.zone # region : eg : us-central1
  cluster        = google_container_cluster.primary.name
  version        = var.K8s_version
  node_locations = [var.zone] # use to pick specific zone within region for node pool
  node_count     = var.node_count

  node_config {
    image_type   = "UBUNTU_CONTAINERD"
    disk_size_gb = 20
    disk_type    = "pd-standard"
    machine_type = "e2-medium"

  }

  autoscaling {
    min_node_count = 1
    max_node_count = 3
  }

  management {
    auto_upgrade = true
    auto_repair  = true
  }

}
