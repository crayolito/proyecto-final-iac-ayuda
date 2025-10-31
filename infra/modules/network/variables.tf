variable "nombre_proyecto" {
  description = "Nombre del proyecto para etiquetar recursos"
  type        = string
}

variable "etiquetas_comunes" {
  description = "Mapa de etiquetas comunes a aplicar en todos los recursos"
  type        = map(string)
  default = {
    Proyecto   = "proyecto-iac-educativo"
    Ambiente   = "desarrollo"
    Equipo     = "estudiantes-iac"
    Creado_con = "Terraform"
  }
}

variable "cidr_vpc" {
  description = "Rango de IPs de la VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "cidr_subred_publica" {
  description = "Rango de IPs para la subred publica"
  type        = string
  default     = "10.0.1.0/24"
}

variable "cidr_subred_privada" {
  description = "Rango de IPs para la subred privada"
  type        = string
  default     = "10.0.2.0/24"
}
