# Variables de entrada del módulo de almacenamiento

variable "nombre_proyecto" {
  description = "Nombre del proyecto para etiquetar y nombrar el bucket"
  type        = string
}

variable "etiquetas_comunes" {
  description = "Mapa de etiquetas comunes a aplicar en todos los recursos"
  type        = map(string)
  default     = {}
}

variable "bucket_prefix" {
  description = "Prefijo del bucket para garantizar nombres únicos y legibles"
  type        = string
  default     = "proyecto-iac"
}

variable "force_destroy" {
  description = "Permite destruir el bucket aunque tenga objetos (solo ambientes no productivos)"
  type        = bool
  default     = false
}
