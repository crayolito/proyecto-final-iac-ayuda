# Este archivo crea la red virtual donde viviran nuestros recursos :
# 1 VPC, 1 subred publica, 1 subred privada, un Internet Gateway y las tablas de ruteo necesarias.

locals {
  # merge -> combina dos mapas en uno solo y agrega las etiquetas comunes
  etiquetas = merge(var.etiquetas_comunes, {
    Name = "red-principal-${var.nombre_proyecto}"
    Tipo = "red-virtual"
  })
}

resource "aws_vpc" "red_principal" {
  cidr_block = var.cidr_vpc
  # Habilita DNS para que las máquinas virtuales puedan resolver nombres de dominio (por ejemplo, dominios públicos y privados) 
  enable_dns_support = true
  # Permite que las instancias reciban nombres DNS dentro de la VPC (y públicos si tienen IP pública)
  enable_dns_hostnames = true

  tags = merge(local.etiquetas, {
    Descripcion = "VPC principal del proyecto con CIDR ${var.cidr_vpc}"
  })
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.red_principal.id

  tags = merge(local.etiquetas, {
    Name = "igw-${var.nombre_proyecto}"
    Tipo = "internet-gateway"
  })
}

resource "aws_subnet" "subred_publica" {
  vpc_id     = aws_vpc.red_principal.id
  cidr_block = var.cidr_subred_publica

  # Habilita la asignacion de IP pública a las instancias al arrancar
  map_public_ip_on_launch = true

  tags = merge(local.etiquetas, {
    Name = "subred-publica-${var.nombre_proyecto}"
    Tipo = "subred-publica"
  })
}

resource "aws_subnet" "subred_privada" {
  vpc_id     = aws_vpc.red_principal.id
  cidr_block = var.cidr_subred_privada

  # Deshabilita la asignacion de IP pública a las instancias al arrancar
  map_public_ip_on_launch = false

  tags = merge(local.etiquetas, {
    Name = "subred-privada-${var.nombre_proyecto}"
    Tipo = "subred-privada"
  })
}


resource "aws_route_table" "rt_publica" {
  vpc_id = aws_vpc.red_principal.id

  # Ruta para el tráfico entrante desde Internet
  route {
    # Cualquier IP puede entrar a la red
    cidr_block = "0.0.0.0/0"
    # La red se conecta a través del Internet Gateway
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(local.etiquetas, {
    Name = "rt-publica-${var.nombre_proyecto}"
    Tipo = "tabla-rutas-publica"
  })
}

# Asocia la subred publica a la tabla de rutas publica
resource "aws_route_table_association" "asoc_publica" {
  # ID de la subred publica
  subnet_id = aws_subnet.subred_publica.id
  # ID de la tabla de rutas publica
  route_table_id = aws_route_table.rt_publica.id
}

resource "aws_route_table" "rt_privada" {
  vpc_id = aws_vpc.red_principal.id

  // Sin ruta a internet por defecto para mantenerla privada

  tags = merge(local.etiquetas, {
    Name = "rt-privada-${var.nombre_proyecto}"
    Tipo = "tabla-rutas-privada"
  })
}

# Asocia la subred privada a la tabla de rutas privada
resource "aws_route_table_association" "asoc_privada" {
  # ID de la subred privada
  subnet_id = aws_subnet.subred_privada.id
  # ID de la tabla de rutas privada
  route_table_id = aws_route_table.rt_privada.id
}
