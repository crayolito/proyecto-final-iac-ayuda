# Recursos de almacenamiento S3 seguros

locals {
  etiquetas = merge(var.etiquetas_comunes, {
    Nombre = "bucket-s3-${var.nombre_proyecto}"
    Tipo   = "almacenamiento-s3"
  })
}

# Sufijo aletorio para garantizar nombre unico del bucket
resource "random_id" "sufijo" {
  byte_length = 4
}

# Bucket S3 con nombre unico
resource "aws_s3_bucket" "bucket" {
  # Nombre del bucket con sufijo aletorio para garantizar nombre unico
  bucket = lower("${var.bucket_prefix}-${var.nombre_proyecto}-${random_id.sufijo.hex}")
  # Permite destruir el bucket aunque tenga objetos (solo ambientes no productivos)
  force_destroy = var.force_destroy

  tags = merge(local.etiquetas, {
    Descripcion = "Bucket S3 seguro con cifrado y versionado"
  })
}

# Versionado activado 
# Sirve: Para recuperar objetos borrados accidentalmente.
# Si no se pone esto : Si se borra un objeto, se borra para siempre.
# versioning = versionado -> Versionado de los objetos.
resource "aws_s3_bucket_versioning" "versionado" {
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    # Activa el versionado
    status = "Enabled"
  }
}

# Cifrado del lado del servidor (AES-256)
# Sirve: Para proteger los datos en reposo.
# Si no se pone esto : Los datos se almacenan en texto plano.
# sse = server side encryption -> Cifrado del lado del servidor.
resource "aws_s3_bucket_server_side_encryption_configuration" "sse" {
  bucket = aws_s3_bucket.bucket.id
  rule {
    # Aplica el cifrado del lado del servidor
    apply_server_side_encryption_by_default {
      # Algoritmo de cifrado
      sse_algorithm = "AES256"
    }
  }
}

# Bloqueo de acceso publico
# Sirve: Para proteger los datos de acceso publico.
# Si no se pone esto : Cualquier persona puede acceder a los datos.
# block_public_acls = true -> Bloquea el acceso publico.
# block_public_policy = true -> Bloquea la politica de acceso publico.
# ignore_public_acls = true -> Ignora la politica de acceso publico.
# restrict_public_buckets = true -> Restringe el acceso publico.
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Política mínima (opcional) - aquí no exponemos nada público
# Si luego necesitas permisos, se gestionarán vía IAM Roles/Policies
