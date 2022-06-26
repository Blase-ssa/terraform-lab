terraform {
# terraform version
required_version = "~>1.2.0"
}

provider "google" {
  # path to credentials file downloaded from GCP
  credentials = "${file("../../gcp-service-account.json")}"
  # project ID
  project = "terraform-lab-352918"
}

resource "google_compute_firewall" "firewall_http" {
  name = "allow-http-default"
  # name of a network to apply rule
  network = "default"
  # rules
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  # network address range to allow access from
  source_ranges = ["0.0.0.0/0"]
  # this rule will be applyed to targets with same tag
  target_tags = ["http"]
}

# server #1
resource "google_compute_instance" "vm1" {
  name          = "vm1"
  machine_type  = "e2-small"
  zone          = "europe-west1-b"
  tags          = ["http"]

  boot_disk {
    initialize_params {
      image = "ubuntu-2204-jammy-v20220609"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  connection {
    type = "ssh"
    host = self.network_interface[0].access_config[0].nat_ip
    user = "scorpioncore"
    agent = false
    private_key = file("~/.ssh/id_rsa")
  }

  provisioner "remote-exec" {
    script = "scripts/nginx_install.sh"
  }
}

# server #2
resource "google_compute_instance" "vm2" {
  name         = "vm2"
  machine_type = "e2-small"
  zone         = "europe-north1-a"
  
  boot_disk {
    initialize_params {
      image = "ubuntu-2204-jammy-v20220609"
    }    
  }

  network_interface {
    network = "default"
    access_config {}
  }
}
