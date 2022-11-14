locals {
  # change the GCP project ID with your own
  project_id       = "mon-premier-projet-365408"
  # use the default network
  network          = "default"
  # ubuntu image provided by GCP
  image            = "ubuntu-2004-focal-v20211212"
  ssh_user         = "ansible"
  # path of the generated private key
  private_key_path = "~/.ssh/ansible_ed25519"
}

# contains resources we can use to create VMs
provider "google" {
  project = local.project_id
  credentials = "./credentials.json"
  region  = "europe-west9"
}

# service account
resource "google_service_account" "nginx" {
  account_id = "nginx-demo"
}

# firewall
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

# create our VM instance
resource "google_compute_instance" "nginx" {
  name         = "nginx"
  machine_type = "e2-micro"
  zone         = "europe-west9-a"

  # use ubuntu as a boot disk 
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

  # before run ansible playbook make sure VM is running
  provisioner "remote-exec" {
    inline = ["echo 'Wait until SSH is ready'"]

    # establish SSH connection
    connection {
      type        = "ssh"
      user        = local.ssh_user
      private_key = file(local.private_key_path)
      host        = google_compute_instance.nginx.network_interface.0.access_config.0.nat_ip
    }
  }

  # use a local provisioner to run ansible
  provisioner "local-exec" {
    command = "ansible-playbook  -i ${google_compute_instance.nginx.network_interface.0.access_config.0.nat_ip}, --private-key ${local.private_key_path} nginx.yaml"
  }

}

# output the ip-address to the console
output "nginx_ip" {
  value = google_compute_instance.nginx.network_interface.0.access_config.0.nat_ip
}
