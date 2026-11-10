resource "yandex_compute_instance_group" "lamp" {
  name                = "netology-lamp-group"
  service_account_id  = var.service_account_id
  folder_id           = var.folder_id
  deletion_protection = false

  instance_template {
    platform_id = "standard-v3"
    name        = "netology-{instance.index}"


    resources {
      cores         = 2
      memory        = 2
      core_fraction = 20
    }

    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id = var.lamp_image_id
        size     = 4
        type     = "network-hdd"
      }
    }

    network_interface {
      subnet_ids = [yandex_vpc_subnet.public.id]
      nat        = true
    }

    metadata = {
      ssh-keys  = "ubuntu:${local.nat_ssh_key}"
      user-data = <<-EOT
        #cloud-config
        users:
          - name: ubuntu
            shell: /bin/bash
            sudo: ['ALL=(ALL) NOPASSWD:ALL']
            ssh-authorized-keys:
              - ${local.nat_ssh_key}
        write_files:
          - path: /var/www/html/index.html
            content: |
              <!DOCTYPE html>
              <html>
              <head><title>LAMP Server</title></head>
              <body>
              <h1>LAMP Instance Group</h1>
              <img src="https://${yandex_storage_bucket.main.bucket}.storage.yandexcloud.net/Vladimir_Vlasov.jpg" alt="Picture">
              </body>
              </html>
        runcmd:
          - systemctl restart apache2
      EOT
    }

    metadata_options {
      aws_v1_http_endpoint = 1
      aws_v1_http_token    = 2
    }
  }

  scale_policy {
    fixed_scale {
      size = var.ig_size
    }
  }

  allocation_policy {
    zones = [var.default_zone]
  }

  deploy_policy {
    max_unavailable  = 2
    max_creating     = 2
    max_expansion    = 2
    max_deleting     = 2
    startup_duration = 120
  }

  health_check {
    interval            = 5
    timeout             = 4 #  таймаут должен быть меньше интервала (5 сек)
    healthy_threshold   = 3 #  здесь три проверки что все окей работает
    unhealthy_threshold = 2 #  проверка на неработу, недоступность по 80 порту
    tcp_options {
      port = 80
    }
  }

  depends_on = [yandex_storage_object.picture]
}
