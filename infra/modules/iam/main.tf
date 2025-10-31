locals {
  etiquetas = merge(var.etiquetas_comunes, {
    Nombre = "role-ec2-${var.nombre_proyecto}"
    Tipo   = "iam-role-ec2"
  })
}

# Documento de politica de confianza para la role EC2
# Sirve: Para permitir que la role EC2 se asume en el servicio de AWS
# Si no se pone esto : La role EC2 no podra asumirse en el servicio de AWS
# assume_role = asumir role -> Asumir la role EC2 en el servicio de AWS
data "aws_iam_policy_document" "asumir_role" {
  # Statement = declaracion -> Declaracion de la politica de confianza
  statement {
    # Allow = permitir -> Permitir que la role EC2 se asume en el servicio de AWS
    effect = "Allow"
    # sts = security token service -> Servicio de seguridad de tokens
    # AssumeRole = asumir role -> Asumir la role EC2 en el servicio de AWS
    actions = ["sts:AssumeRole"]
    # Principales de la politica de confianza
    principals {
      type = "Service"
      # ec2.amazonaws.com = servicio de AWS para instancias EC2
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "rol_ec2" {
  name = "rol-ec2-${var.nombre_proyecto}"
  # Politica de confianza para la role EC2
  assume_role_policy = data.aws_iam_policy_document.asumir_role.json
  tags               = local.etiquetas
}

# Politicas administradas necesarias para SSM (gestion segura, sin abrir SSH si no quieres)
resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.rol_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Politica minima personalizada: S3 lectura limitada + Secrets/SSM lectura por ruta
data "aws_iam_policy_document" "politica_minima" {
  # Declaracion de la politica minima
  statement {
    # S3ReadBucket = leer bucket S3 -> Leer el bucket S3
    # Allow = permitir -> Permitir que la role EC2 lea el bucket S3
    # GetObject = obtener objeto -> Obtener un objeto del bucket S3
    # ListBucket = listar bucket -> Listar el contenido del bucket S3
    # resources = recursos -> Recursos del bucket S3
    # var.s3_bucket_arn = ARN del bucket S3
    # "${var.s3_bucket_arn}/*" = ARN del bucket S3 y todos los objetos del bucket S3
    sid       = "S3ReadBucket"
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:ListBucket"]
    resources = [var.s3_bucket_arn, "${var.s3_bucket_arn}/*"]
  }

  statement {
    # SecretsReadByPath = leer secrets por ruta -> Leer los secrets por ruta
    # GetSecretValue = obtener secret -> Obtener el valor del secret
    # DescribeSecret = describir secret -> Describir el secret
    # resources = recursos -> Recursos del secret
    # var.secrets_path_arn = ARN del secret
    sid       = "SecretsReadByPath"
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
    resources = [var.secrets_path_arn]
  }

  statement {
    # SSMParameterReadByPath = leer parametros por ruta -> Leer los parametros por ruta
    # GetParameter = obtener parametro -> Obtener el valor del parametro
    # GetParameters = obtener parametros -> Obtener los valores de los parametros
    # GetParametersByPath = obtener parametros por ruta -> Obtener los valores de los parametros por ruta
    # resources = recursos -> Recursos de los parametros
    # arn:aws:ssm:*:*:parameter${var.ssm_parameter_arn}* = ARN de los parametros
    sid       = "SSMParameterReadByPath"
    effect    = "Allow"
    actions   = ["ssm:GetParameter", "ssm:GetParameters", "ssm:GetParametersByPath"]
    resources = ["arn:aws:ssm:*:*:parameter${var.ssm_parameter_path}*"]
  }
}

# Politica minima personalizada: S3 lectura limitada + Secrets/SSM lectura por ruta
resource "aws_iam_role_policy" "politica_minima" {
  name   = "politica-minima-${var.nombre_proyecto}"
  role   = aws_iam_role.rol_ec2.id
  policy = data.aws_iam_policy_document.politica_minima.json
}

# Adjuntar la politica minima a la role EC2
# attach_minima = adjuntar politica minima -> Adjuntar la politica minima a la role EC2
# resource "aws_iam_role_policy_attachment" "attach_minima" {
#   role       = aws_iam_role.rol_ec2.name
#   policy_arn = aws_iam_role_policy.politica_minima.arn
# }

# Perfil EC2
# Sirve: Para asignar la role EC2 a la instancia EC2
# Si no se pone esto : La instancia EC2 no podra usar la role EC2
# instance_profile = perfil de instancia -> Perfil de instancia de la instancia EC2
resource "aws_iam_instance_profile" "perfil_ec2" {
  name = "perfil-ec2-${var.nombre_proyecto}"
  role = aws_iam_role.rol_ec2.name
  tags = local.etiquetas
}
