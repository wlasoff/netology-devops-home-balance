# 1. Target Group: Динамически собираем IP-адреса инстансов из Instance Group
resource "yandex_alb_target_group" "lamp" {
  name = "lamp-alb-tg"

  dynamic "target" {
    for_each = yandex_compute_instance_group.lamp.instances
    content {
      subnet_id  = yandex_vpc_subnet.public.id
      ip_address = target.value.network_interface[0].ip_address
    }
  }
}

# 2. Backend Group: Настраиваем HTTP бэкенд и Health Check
resource "yandex_alb_backend_group" "lamp" {
  name = "lamp-alb-bg"

  http_backend {
    name             = "lamp-http-backend"
    weight           = 100
    port             = 80
    target_group_ids = [yandex_alb_target_group.lamp.id]

    # Настройка режима балансировки (обернуто в load_balancing_config)
    load_balancing_config {
      mode = "ROUND_ROBIN"
    }

    # Настройка HTTP Health Check
    healthcheck {
      timeout  = "1s"
      interval = "3s"
      http_healthcheck {
        path = "/"
      }
    }
  }
}

# 3. HTTP Router: Контейнер для правил маршрутизации
resource "yandex_alb_http_router" "lamp" {
  name = "lamp-alb-router"
}

# 4. Virtual Host: Связываем роутер с бэкендом
resource "yandex_alb_virtual_host" "lamp" {
  name           = "lamp-alb-vh"
  http_router_id = yandex_alb_http_router.lamp.id

  route {
    name = "lamp-route"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.lamp.id
        timeout          = "3s"
      }
    }
  }
}

# 5. ALB Load Balancer: Сам балансировщик с публичным IP
resource "yandex_alb_load_balancer" "lamp" {
  name       = "lamp-alb"
  network_id = yandex_vpc_network.vpc_nat.id

  allocation_policy {
    location {
      zone_id   = var.default_zone
      subnet_id = yandex_vpc_subnet.public.id
    }
  }

  listener {
    name = "http-listener"
    endpoint {
      address {
        external_ipv4_address {
          # Адрес не указываем, YC автоматически выделит публичный IP
        }
      }
      ports = [80]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.lamp.id
      }
    }
  }

  depends_on = [yandex_compute_instance_group.lamp]
}

