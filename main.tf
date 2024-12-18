terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.8.0"
    }
  }
}

provider "google" {
  project     = var.project
  region      = "asia-southeast1" # Pastikan region sesuai dengan subnet
  zone        = "asia-southeast1-a"
  credentials = file("C:/Users/Hamda/Downloads/testing.json")
}

# Gunakan VPC yang sudah ada
data "google_compute_network" "existing_vpc" {
  name = "default" # Ganti dengan nama VPC yang benar
}

# Gunakan subnet yang sudah ada
data "google_compute_subnetwork" "existing_subnet" {
  name   = "default" # Ganti dengan nama subnet yang benar
  region = "asia-southeast1"
}

resource "google_compute_firewall" "allow_http_ssh" {
  name    = "allow-http-ssh"
  network = data.google_compute_network.existing_vpc.id

  allow {
    protocol = "tcp"
    ports    = ["22", "80"] # SSH dan HTTP
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_instance" "vm_instance" {
  name         = "terraform-testing"
  machine_type = "e2-medium" # 2 vCPU, 2 GB RAM
  zone         = "asia-southeast1-a"
  tags         = ["web", "dev"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts" # Ubuntu 22.04 LTS Live Server
      size  = 30
    }
  }

  network_interface {
    # Referensi subnet yang ada
    subnetwork = data.google_compute_subnetwork.existing_subnet.self_link

    access_config {
      # Mengatur IP ephemeral (dinamis)
      nat_ip = null
    }
  }
}
