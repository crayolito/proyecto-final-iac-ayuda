# Valores de salida del módulo de cómputo

output "instance_id" {
  description = "ID de la instancia EC2 creada"
  value       = aws_instance.servidor_web.id
}

output "instance_public_ip" {
  description = "IP pública de la instancia EC2"
  value       = aws_instance.servidor_web.public_ip
}

output "instance_public_dns" {
  description = "DNS público de la instancia EC2"
  value       = aws_instance.servidor_web.public_dns
}

output "instance_private_ip" {
  description = "IP privada de la instancia EC2"
  value       = aws_instance.servidor_web.private_ip
}

output "security_group_id" {
  description = "ID del Security Group creado para el servidor web"
  value       = aws_security_group.servidor_web.id
}
