terraform {
# terraform version
required_version = "~>1.2.0"
}

provider "google" {
  # path to credentials file downloaded from GCP
  credentials = "${file("../akvelon-gcp-service-account.json")}"
  # project ID
  project = "terraform-lab-352918"
}

resource "google_compute_firewall" "firewall_http" {
  name = "allow-puma-default"
  # Название сети, в которой действует правило
  network = "default"
  # Какой доступ разрешить
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  # Каким адресам разрешаем доступ
  source_ranges = ["0.0.0.0/0"]
  # Правило применимо для инстансов с перечисленными тэгами
  target_tags = ["http"]
}

# resource "google_compute_firewall" "firewall_icmp" {
#   name = "allow-icmp-default"
#   network = "default"
#   allow {
#     protocol = "icmp"
#   }
#   source_ranges = ["0.0.0.0/0"]
#   target_tags = ["allow-icmp"]
# }

# # set up ssh key
# # googleapi: Error 403: Required 'iam.serviceAccounts.actAs' permission for 'projects/terraform-lab-352918', forbidden
# resource "google_compute_project_metadata" "ssh-keys" {
#   metadata = {
#     ssh-keys = "blase:${file("../akvelon-gcp-publick-key.key")}"
#   }
#   project = "terraform-lab-352918"
# }

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
    # путь до приватного ключа
    private_key = file("../id_rsa")
  }

  provisioner "remote-exec" {
    script = "scripts/nginx_install.sh"
  }
}

resource "google_compute_instance" "vm2" {
  name         = "vm2"
  machine_type = "e2-small"
  zone         = "europe-north1-a"
  # tags         = ["allow-icmp"]
  
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
