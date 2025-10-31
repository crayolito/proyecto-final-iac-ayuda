# Configuración de Terraform
# Sin esto fallaria, es como decir que version de un app necesitas.
terraform {
  # Le decimos que necesitamos version 1.5.0 o superior
  required_version = ">= 1.5.0"
  # Aqui se define que plugins necesitaremos para funcionar
  required_providers {
    # Plugin para AWS
    aws = {
      # Le dice de donde descargar el "plugin" (Hashicorp es la empresa que hizo Terraform) 
      source = "hashicorp/aws"
      # Usa version 5.50 o similar (version compatible)
      version = "~> 5.50"
    }
  }
}

# Configuracion del proveedor AWS
# Le dice a Terraform que va usar AWS 
provider "aws" {
  # Define en que region geografica de Amazon crear las cosas
  region = var.region
}

# Variables locales (variables que solo se usan en este archivo)
locals {
  # Etiquetas comunes para todos los recursos del proyecto
  etiquetas_comunes = {
    Proyecto   = "proyecto-final-iac"
    Ambiente   = "desarrollo"
    Creado_con = "Terraform"
  }

  # Script que se ejecutar al arranchar 
  user_data = <<-EOT
    #!/bin/bash
    # Le decimos que use el interprete de bash 

    # Configuracion para el script para que se detenga si hay un error
    set -euxo pipefail

    # Actualiza el sistema operativo
    dnf update -y
    
    # Instala Docker
    dnf install -y docker
    
    # Hace que Docker se inicie automaticamente al arranchar la maquina
    systemctl enable docker
    
    # Inicia Docker
    systemctl start docker

    # Le da permisos al usuario para usar docker
    # Agrega el usuario ec2-user al grupo docker
    usermod -aG docker ec2-user
  EOT
}

# Buscar la imagen de sistema operativo
# Si no se pone esto no tendra sistema operativo para instalar la maquina virtual.
data "aws_ami" "al2023" {
  # Busca la imagen mas reciente
  most_recent = true
  # Solo busca imagenes oficiales de Amazon (ID de Amazon)
  owners = ["137112412989"]

  # Aplicar filtros para encontrar exactamente lo que se requiere
  filter {
    name = "name"
    # Busca Amazon Linux 2023 con kernel 6.1 y arquitectura x86_64
    values = ["al2023-ami-*-kernel-6.1-x86_64"]
  }
}

# Crea un par de llaves para conectarse de forma segura (SSH = Secure Shell)
# Sin esto no se podra conectar de forma segura a la maquina virtual.
resource "aws_key_pair" "this" {
  # Le pone nombre a la llave usando el nombre del proyecto
  key_name = "${var.nombre_proyecto}-key"
  # Define cual es la llave publica (como dar tu direccion para que te envien las cartas)
  public_key = var.public_ssh_key
}

# data "aws_secretsmanager_secret_version" "db_password" {
#   secret_id = var.secret_db_password_name
# }

# data "aws_ssm_parameter" "app_env" {
#   name            = "${var.param_app_config_path}env"
#   with_decryption = true
# }

# Lamada al modulo de red
# Este modulo crea toda la infraestructura de red : VPC, subredes, Internet Gateway y tablas de rutas
module "network" {
  source = "./modules/network"

  # Pasamos el nombre del proyecto al modulo
  nombre_proyecto = var.nombre_proyecto

  # Pasamos las etiquetas comunes para que todos los recursos las tengan
  etiquetas_comunes = local.etiquetas_comunes

  # Los valores por defecto del modulo  (CIRD 10.0.0.0/16, etc) ya estan bien
  # cidr_vpc = "10.0.0.0/16"
  # cidr_subred_publica = "10.0.1.0/24"
  # cidr_subred_privada = "10.0.2.0/24"
}

module "compute" {
  source = "./modules/compute"

  nombre_proyecto   = var.nombre_proyecto
  etiquetas_comunes = local.etiquetas_comunes

  ami_id               = data.aws_ami.al2023.id
  instance_type        = "t3.micro"
  key_name             = aws_key_pair.this.key_name
  vpc_id               = module.network.vpc_id
  subnet_id            = module.network.subred_publica_id
  security_group_ids   = []
  ips_permitidas       = var.ips_permitidas
  private_key_path     = var.private_key_path
  user_data            = local.user_data
  iam_instance_profile = module.iam.instance_profile_name
}

module "storage" {
  source = "./modules/storage"

  nombre_proyecto   = var.nombre_proyecto
  etiquetas_comunes = local.etiquetas_comunes

  # Opcional: personaliza el prefijo o fuerza destrucción en dev
  bucket_prefix = "proyecto-iac"
  force_destroy = true
}

module "iam" {
  source = "./modules/iam"

  nombre_proyecto   = var.nombre_proyecto
  etiquetas_comunes = local.etiquetas_comunes

  s3_bucket_arn      = module.storage.bucket_arn
  secrets_path_arn   = "arn:aws:secretsmanager:${var.region}:*:secret:proyecto-iac/*"
  ssm_parameter_path = "/proyecto-iac/"
}
