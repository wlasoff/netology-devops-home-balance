resource "yandex_lb_target_group" "lamp" {
  name = "lamp-tg"

  dynamic "target" {
    for_each = yandex_compute_instance_group.lamp.instances
    content {
      subnet_id = yandex_vpc_subnet.public.id
      address   = target.value.network_interface[0].ip_address
    }
  }
}

resource "yandex_lb_network_load_balancer" "main" {
  name = "lamp-lb"

  listener {
    name        = "http-listener"
    port        = 80
    target_port = 80
    protocol    = "tcp"
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.lamp.id

    healthcheck {
      name = "http-health"
      tcp_options {
        port = 80
      }
      interval            = 5
      timeout             = 3
      healthy_threshold   = 3
      unhealthy_threshold = 3
    }
  }
}
