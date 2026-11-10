# ===== Bastion VM (публичная) =====
resource "yandex_compute_instance" "public_vm" {
  name        = "public-vm"
  hostname    = "public-vm"
  platform_id = "standard-v3"
  zone        = var.default_zone

  resources {
    cores         = 2
    memory        = 1
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = var.lamp_image_id
      size     = 4
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public.id
    nat                = false
    security_group_ids = [yandex_vpc_security_group.nat_sg.id]
  }

  metadata = {
    ssh-keys  = "ubuntu:${local.bastion_ssh_key}"
    user-data = local.cloud_init_config
  }

  scheduling_policy {
    preemptible = true
  }
}
