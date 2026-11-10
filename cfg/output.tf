output "vpc_info" {
  description = "VPC Information"
  value = {
    network_id          = yandex_vpc_network.vpc_nat.id
    network_name        = yandex_vpc_network.vpc_nat.name
    public_subnet_cidr  = yandex_vpc_subnet.public.v4_cidr_blocks[0]
    private_subnet_cidr = yandex_vpc_subnet.private.v4_cidr_blocks[0]
    route_table_id      = yandex_vpc_route_table.nat_route.id
  }
}

output "public_vm_info" {
  description = "Public VM Information"
  value = {
    name        = yandex_compute_instance.public_vm.name
    internal_ip = yandex_compute_instance.public_vm.network_interface[0].ip_address
    external_ip = yandex_compute_instance.public_vm.network_interface[0].nat_ip_address
    fqdn        = yandex_compute_instance.public_vm.fqdn
  }
}

output "bucket_url" {
  description = "Public URL of the picture in Object Storage"
  value       = "https://${yandex_storage_bucket.main.bucket}.storage.yandexcloud.net/Vladimir_Vlasov.jpg"
}

output "load_balancer_ip" {
  description = "Network Load Balancer public IP"
  value       = one([for l in yandex_lb_network_load_balancer.main.listener : one(l.external_address_spec).address])
}

output "instance_group_info" {
  description = "Instance Group information"
  value = {
    name      = yandex_compute_instance_group.lamp.name
    status    = yandex_compute_instance_group.lamp.status
    instances = yandex_compute_instance_group.lamp.instances[*].network_interface[0].ip_address
  }
}

output "alb_public_ip" {
  description = "Публичный IP-адрес Application Load Balancer"
  # Извлекаем IP из сложной структуры listener -> endpoint -> address
  value = one(yandex_alb_load_balancer.lamp.listener).endpoint[0].address[0].external_ipv4_address[0].address
}

output "alb_health_status" {
  description = "Статус и лог для понимания состояния ALB"
  value = {
    alb_id   = yandex_alb_load_balancer.lamp.id
    alb_name = yandex_alb_load_balancer.lamp.name
    status   = yandex_alb_load_balancer.lamp.status
    # Выведем ID бэкенд группы для дебага, если что-то пойдет не так
    backend_group_id = yandex_alb_backend_group.lamp.id
  }
}


output "alb_ip" {
  description = "Application Load Balancer public IP"
  value       = yandex_alb_load_balancer.lamp.listener[0].endpoint[0].address[0].external_ipv4_address[0].address
}
