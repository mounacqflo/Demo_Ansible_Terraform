/*provider "google" {
    project = "terraform-demo-368116"
    credentials = "./credentials.json"
    region = "europe-west9"
    zone = "europe-west9-a"
}

//europe-west9-a

resource "google_compute_instance" "my_instance" {
    name = "terraform-instance"
    machine_type = "e2-micro"
    zone = "europe-west9-a"
    allow_stopping_for_update = true

    boot_disk {
        initialize_params {
            //image = "debian-cloud/debian-10"
            image ="ubuntu-2004-focal-v20211212"
        }
    }

    network_interface {
        network = "default"
        access_config {
            //necessary even empty
        }
    }
}*/

locals {
  project_id       = "terraform-demo-368116"
  network          = "default"
  image            = "ubuntu-2004-focal-v20211212"
  ssh_user         = "ansible"
  private_key_path = "~/.ssh/ansible_ed25519"
}

provider "google" {
  project = local.project_id
  credentials = "./credentials.json"
  region  = "europe-west9"
}

resource "google_service_account" "nginx" {
  account_id = "nginx-demo"
}

resource "google_compute_firewall" "web" {
  name    = "web-access"
  network = local.network

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges           = ["0.0.0.0/0"]
  target_service_accounts = [google_service_account.nginx.email]
}

resource "google_compute_instance" "nginx" {
  name         = "nginx"
  machine_type = "e2-micro"
  zone         = "europe-west9-a"

  boot_disk {
    initialize_params {
      image = local.image
    }
  }

  network_interface {
    network = local.network
    access_config {}
  }

  service_account {
    email  = google_service_account.nginx.email
    scopes = ["cloud-platform"]
  }

  provisioner "remote-exec" {
    inline = ["echo 'Wait until SSH is ready'"]

    connection {
      type        = "ssh"
      user        = local.ssh_user
      private_key = file(local.private_key_path)
      host        = google_compute_instance.nginx.network_interface.0.access_config.0.nat_ip
    }
  }

  provisioner "local-exec" {
    command = "ansible-playbook  -i ${google_compute_instance.nginx.network_interface.0.access_config.0.nat_ip}, --private-key ${local.private_key_path} nginx.yaml"
  }
}

output "nginx_ip" {
  value = google_compute_instance.nginx.network_interface.0.access_config.0.nat_ip
}