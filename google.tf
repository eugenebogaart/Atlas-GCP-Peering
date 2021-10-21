

provider "google" {
  # Which Environement variable does the provider requires?
  # AWS_SECURITY_GROUPS
  region  = local.google_region
  project = local.google_project
  zone    = local.google_zone
}

resource "google_compute_instance" "web" {
  name            = local.google_vm_name
  machine_type    = local.google_vm_size

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral public IP
    }
  }

  metadata = {
    OwnerContact = "eugene@mongodb.com"
    Name = "scratch-vm"
    provisioner = "Terraform"
    owner = "eugene.bogaart"
    expire-on = "2020-11-11"
    purpose = "opportunity"
    sshKeys = "${local.admin_username}:${var.ssh_keys_data}"
  }

  #  Timing seems to be an issue. When able to login 
  #  some commands fail, therefor, sleep 10.
  provisioner "remote-exec" {
    inline = concat(local.python, local.mongodb)
  }
  
  connection {
    type        = "ssh"
    host        = self.network_interface[0].access_config[0].nat_ip
    private_key = file(var.private_key_path)
    user        = local.admin_username  
    agent       = true
    timeout     = "100s"
  }
}

output "public_ip" {
  value = google_compute_instance.web.network_interface[0].access_config[0].nat_ip
}