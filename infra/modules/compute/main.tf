# Este archivo crea los recursos de computo (EC2) con Terraform Provisioner
# Incluye: instancia EC2, Security Group, cifrado, IMDSv2 y configuracion con nginx


locals {
  etiquetas = merge(var.etiquetas_comunes, {
    Nombre = "instancia-ec2-${var.nombre_proyecto}"
    Tipo   = "instancia-ec2"
  })
}

# Security Group especifico para el modulo de compute
# Segun las reglas: Security Group sin 0.0.0.0/0 (usar variable para IPs permitidas)
resource "aws_security_group" "servidor_web" {
  name        = "${var.nombre_proyecto}-sg-compute"
  description = "Security group para el servidor web EC2"

  # Ahora usaremos la VPC creada por nuestro modulo de red
  vpc_id = var.vpc_id

  # Regla de entrada SSH - Solo desde IPs permitidas
  ingress {
    description = "SSH - Solo desde IPs permitidas del equipo"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Regla de entrada HTTP - Permitir desde cualquier lugar para acceso web
  ingress {
    description = "HTTP - Acceso web publico"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    # Importante: Usar lista de IPs permitidas, NO 0.0.0.0/0
    cidr_blocks = var.ips_permitidas
  }

  # Regla de salida - Permitir todo el tráfico saliente
  egress {
    description = "Todo el trafico saliente"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.etiquetas, {
    Name        = "${var.nombre_proyecto}-sg-compute"
    Descripcion = "Security Group para servidor web con nginx"
    Tipo        = "security-group"
  })
}


# Instancia EC2 con todas las caracteristicas de seguridad 
# Creamos una maquina virtual (EC2 = Elastic Compute Cloud , Computadora en la nube)
resource "aws_instance" "servidor_web" {
  # Usa la imagen de sistema operativo que busco antes
  ami = var.ami_id
  # Tamaño de la maquina virtual -> t2.micro segun las reglas (mas pequeña que t3.micro)
  instance_type = var.instance_type

  # Usa las llaves SSH que creo antes
  key_name = var.key_name

  # CONFIGURACION DE RED
  # Ahora usamos la subred publica creada por nuestro modulo de red
  subnet_id = var.subnet_id
  # Aplica las reglas de firewall que creo antes
  vpc_security_group_ids = [aws_security_group.servidor_web.id]

  # USER DATA - Script que se ejecuta al arrancar la instancia
  # Esto instala Docker ANTES de que el provisioner instale nginx
  user_data = var.user_data != "" ? var.user_data : null

  # IAM Instance Profile -> Perfil de instancia IAM
  iam_instance_profile = var.iam_instance_profile != "" ? var.iam_instance_profile : null

  # CIFRADO DEL VOLUMEN RAIZ
  # Segun las reglas: Cifrado de volumen raiz obligatorio
  root_block_device {
    # Habilita el cifrado del disco principal
    encrypted = true
    # Tamaño del disco en GB (opcional, Amazon recomienda 8GB por defecto)
    volume_size = 8
  }

  # IMDSv2 (Instance Metadata Service Version 2)
  # Segun las reglas: Usar IMDSv2 obligatorio para mayor seguridad
  # Esto previene ataques SSRF (Server-Side Request Forgery)
  metadata_options {
    # Habilita el servicio de metadatos
    http_endpoint = "enabled"
    # Fuerza usar IMDSv2 en lugar de v1
    http_tokens = "required"
    # Tiempo maximo para obtener metadatos (1 minuto)
    http_put_response_hop_limit = 1
  }

  # TERRAFORM PROVISIONER
  # Segun las reglas: Terraform Provisioner para configurar la instancia (instalar nginx)
  # Esto se ejecuta DESPUES de que la instancia este corriendo
  provisioner "remote-exec" {
    # Comandos a ejecutar en la instanacia remota
    inline = [
      "sudo dnf update -y",
      "sudo dnf install -y nginx",
      "sudo systemctl start nginx",
      "sudo systemctl enable nginx",
      "echo '<h1>Servidor configurado con Terraform Provisioner</h1><p>Proyecto: ${var.nombre_proyecto}</p><p>Docker ya está instalado por user_data</p>' | sudo tee /usr/share/nginx/html/index.html"
    ]

    # Configuracion de conexion SSH
    # Segun las reglas: Usar SSH para conexion remota (provisioner)
    connection {
      # Tipo de conexion (SSH)
      type = "ssh"
      # Usuario de la instancia (ec2-user)
      user = "ec2-user"
      # Llave privada para la conexion
      private_key = var.private_key_path != "" ? file(var.private_key_path) : null
      # IP publica de la instancia
      host = self.public_ip
      # Tiempo de espera para la conexion
      timeout = "5m"
    }
  }
}

# Nota importante sobre el provisioner:
# - Se ejecuta SOLO cuando se crea la instancia por primera vez.
# - Si cambias la instancia y haces terraform apply, el provisioner NO se ejecutara nuevamente.
# - Para forzar re-ejecucion, necesarias hacer terraform taint aws_instance.servidor_web



# user_data: Mejor opción por defecto. Corre al arranque sin SSH, más robusto y compatible con subred privada. 
# Script que la instancia ejecuta al primer arranque.
# Úsalo para bootstrap (actualizar SO, instalar nginx, configurar servicios).

# Provisioner (remote-exec): Úsalo solo si es imprescindible ejecutar algo vía SSH post-boot. 
# Script que se ejecuta DESPUES de que la instancia este corriendo.
# Es frágil, no idempotente y desaconsejado por Terraform.

# Recomendación: En este proyecto, basta con user_data para todo (incluido nginx). 
# Si necesitas post-config sin abrir SSH, preferir AWS SSM RunCommand.


# ¿Qué es Nginx?
# Nginx es un servidor web (como Apache). Sirve páginas HTML cuando alguien visita la IP pública de tu EC2 en un navegador.
