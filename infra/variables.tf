variable "nombre_proyecto" {
  description = "Nombre del proyecto para las etiquetas de AWS"
  type        = string
  default     = "cicd-crayolito"
}

variable "region" {
  description = "Region de AWS donde se va a crear la infraestructura"
  type        = string
  default     = "us-east-1"
}

variable "private_key_path" {
  description = "Ruta a la llave privada SSH para el provisioner"
  type        = string
  default     = ""
  sensitive   = true
}

# Bloque CIDR autorizado para SSH
# CIDR -> Classless Inter-Domain Routing
# Es una forma de representar un rango de IP que se pueden conectar a la red
variable "admin_cidr_ssh" {
  description = "Bloque CIDR autorizado para SSH"
  type        = string
  default     = "0.0.0.0/0"
}

variable "public_ssh_key" {
  description = "Contenido de la llave publica de SSH"
  type        = string
}

variable "ips_permitidas" {
  description = "IPs permitidas para HTTP (formato x.x.x.x/32)"
  type        = list(string)
  default = [
    "190.171.228.246/32"
  ]
}

variable "secret_db_password_name" {
  description = "Nombre del secreto en AWS Secrets Manager"
  type        = string
  default     = "proyecto-iac/database/password"
}

variable "param_app_config_path" {
  description = "Ruta base en SSM Parameter Store"
  type        = string
  default     = "/proyecto-iac/app/"
}
