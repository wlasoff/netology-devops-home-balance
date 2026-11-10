# ===== Private VM (без публичного IP) =====
resource "yandex_compute_instance" "private_vm" {
  count       = 0 #отключаем для 4-ого пункта задания
  name        = "private-vm"
  hostname    = "private-vm"
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
    subnet_id          = yandex_vpc_subnet.private.id
    ip_address         = "172.16.2.10"
    nat                = false
    security_group_ids = [yandex_vpc_security_group.nat_sg.id]
  }

  metadata = {
    ssh-keys  = "ubuntu:${local.private_vm_ssh_key}"
    user-data = local.cloud_init_config
  }

  scheduling_policy {
    preemptible = true
  }

  depends_on = [yandex_compute_instance.nat_instance]
}
