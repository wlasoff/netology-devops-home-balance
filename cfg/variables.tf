variable "cloud_id" {
  type        = string
  description = "ID облака Yandex Cloud"
}

variable "folder_id" {
  type        = string
  description = "ID каталога Yandex Cloud"
}

variable "default_zone" {
  type        = string
  description = "Зона доступности по умолчанию"
  default     = "ru-central1-a"
}

# Переменные для SSH-ключей (пути к файлам на диске)
variable "bastion_ssh_pub_key" {
  type        = string
  description = "Путь к публичному SSH-ключу для Bastion-хоста"
  default     = "~/.ssh/id_rsa.pub"
}

variable "nat_ssh_pub_key" {
  type        = string
  description = "Путь к публичному SSH-ключу для NAT-инстанса"
  default     = "~/.ssh/id_rsa.pub"
}

variable "private_vm_ssh_pub_key" {
  type        = string
  description = "Путь к публичному SSH-ключу для приватных ВМ"
  default     = "~/.ssh/id_rsa.pub"
}

# Идентификатор сервисного аккаунта для управления бакетами
variable "service_account_id" {
  type        = string
  description = "ID сервисного аккаунта для Object Storage"
}

# Название сети VPC
variable "vpc_name" {
  type        = string
  description = "Имя виртуальной сети VPC"
  default     = "netology-vpc"
}

# Семейство образа для ВМ (LAMP)
variable "vm_image_family" {
  type        = string
  description = "Семейство образа для виртуальных машин"
  default     = "lamp-lemp-stack-8"
}

# Имя бакета Object Storage
variable "bucket_name" {
  type        = string
  description = "Уникальное имя бакета Object Storage"
}

# CIDR блоки для подсетей
variable "public_subnet_cidr" {
  type        = list(string)
  description = "CIDR блок для публичной подсети"
  default     = ["10.0.1.0/24"]
}

variable "private_subnet_cidr" {
  type        = list(string)
  description = "CIDR блок для приватной подсети"
  default     = ["10.0.2.0/24"]
}
# Образ для Instance Group (LAMP)
variable "lamp_image_id" {
  type        = string
  description = "ID образа LAMP для Instance Group (из ТЗ)"
  default     = "fd827b91d99psvq5fjit"
}

# Размер Instance Group
variable "ig_size" {
  type        = number
  description = "Количество ВМ в группе"
  default     = 3
}

# Образ для NAT-инстанса
variable "nat_image_id" {
  type        = string
  description = "ID образа для NAT-инстанса (Ubuntu)"
  default     = "fd8ap71r7h02n534v2nd" # Стандартный образ Ubuntu 22.04 LTS
}
