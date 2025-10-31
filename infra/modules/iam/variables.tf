variable "nombre_proyecto" {
  description = "Nombre del proyecto para etiquetas y nombres"
  type        = string
}

variable "etiquetas_comunes" {
  description = "Mapa de etiquetas comunes"
  type        = map(string)
  default     = {}
}

variable "s3_bucket_arn" {
  description = "ARN del bucket S3 al que la instancia leerá objetos"
  type        = string
}

variable "secrets_path_arn" {
  description = "ARN o prefijo de ARN en Secrets Manager permitido (ej. arn:aws:secretsmanager:REGION:ACCOUNT:secret:proyecto-iac/*)"
  type        = string
}

variable "ssm_parameter_path" {
  description = "Ruta base en Parameter Store permitida (ej. /proyecto-iac/)"
  type        = string
}
