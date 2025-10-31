# Variables de entrada del modulo de computo
variable "nombre_proyecto" {
  description = "Nombre del proyecto para etiquetar recursos"
  type        = string
}

variable "etiquetas_comunes" {
  description = "Mapa de etiquetas comunes a aplicar en todos los recursos"
  type        = map(string)
  default     = {}
}

variable "ami_id" {
  description = "ID  de la AMI (Imagen del sistema operativo) a usar para la instancia EC2"
  type        = string
}

variable "instance_type" {
  description = "Tipo de instancia EC2 (t2.micro, t3.micro, etc)"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Nombre de la llave SSH para acceder a la instancia EC2"
  type        = string
}

variable "vpc_id" {
  description = "ID de la VPC donde se creará el Security Group"
  type        = string
}

variable "subnet_id" {
  description = "ID de la subred donde se creara la instancia EC2"
  type        = string
}

variable "security_group_ids" {
  description = "Lista de IDs de los grupos de seguridad (firewall) a aplicar a la instancia EC2"
  type        = list(string)
}

variable "ips_permitidas" {
  description = "Lista de IPs permitidas para SSH"
  type        = list(string)
}

variable "private_key_path" {
  description = "Ruta al archivo de la llave privada SSH para el privisioner"
  type        = string
  default     = ""
  # Para que no se muestre en los logs de Terraform
  sensitive = true
}

variable "user_data" {
  description = "Script de inicializacion que se ejecuta al arrancar la instancia EC2"
  type        = string
  default     = ""
}

variable "iam_instance_profile" {
  description = "Nombre del Instance Profile a asociar a la instancia EC2"
  type        = string
  default     = ""
}
