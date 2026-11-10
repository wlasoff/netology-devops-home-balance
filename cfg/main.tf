# ===== VPC и сеть =====
resource "yandex_vpc_network" "vpc_nat" {
  name        = var.vpc_name
  description = "VPC for NAT testing with public and private subnets"
}

# ===== Группа безопасности =====
resource "yandex_vpc_security_group" "nat_sg" {
  name        = "nat-security-group"
  network_id  = yandex_vpc_network.vpc_nat.id
  description = "Security group for NAT network"

  # Входящие правила
  ingress {
    protocol       = "TCP"
    description    = "SSH"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  ingress {
    protocol       = "TCP"
    description    = "HTTP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol       = "TCP"
    description    = "HTTPS"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }

  ingress {
    protocol       = "ICMP"
    description    = "Ping"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    description    = "Internal network"
    v4_cidr_blocks = ["172.16.0.0/16"]
    from_port      = 0
    to_port        = 65535
  }

  ingress {
    protocol       = "UDP"
    description    = "Internal network UDP"
    v4_cidr_blocks = ["172.16.0.0/16"]
    from_port      = 0
    to_port        = 65535
  }

  # Исходящие правила
  egress {
    protocol       = "TCP"
    description    = "Allow all outgoing TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }

  egress {
    protocol       = "UDP"
    description    = "Allow all outgoing UDP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }

  egress {
    protocol       = "ICMP"
    description    = "Allow all outgoing ICMP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# ===== Публичная подсеть =====
resource "yandex_vpc_subnet" "public" {
  name           = "cloud-public"
  zone           = var.default_zone
  network_id     = yandex_vpc_network.vpc_nat.id
  v4_cidr_blocks = var.public_subnet_cidr
  description    = "Public subnet - 172.16.3.0/24"
}

# ===== Приватная подсеть =====
resource "yandex_vpc_subnet" "private" {
  name           = "cloud-private"
  zone           = var.default_zone
  network_id     = yandex_vpc_network.vpc_nat.id
  v4_cidr_blocks = var.private_subnet_cidr
  route_table_id = yandex_vpc_route_table.nat_route.id
  description    = "Private subnet - 172.16.2.0/24"
}

# ===== Таблица маршрутизации для приватной сети =====
resource "yandex_vpc_route_table" "nat_route" {
  name       = "nat-route-table"
  network_id = yandex_vpc_network.vpc_nat.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = "172.16.3.254"
  }
}
