output "vpc_id" {
  description = "ID de la VPC principal"
  value       = aws_vpc.red_principal.id
}

output "subred_publica_id" {
  description = "ID de la subred publica"
  value       = aws_subnet.subred_publica.id
}

output "subred_privada_id" {
  description = "ID de la subred privada"
  value       = aws_subnet.subred_privada.id
}

output "igw_id" {
  description = "ID del Internet Gateway"
  value       = aws_internet_gateway.igw.id
}

output "rt_publica_id" {
  description = "ID de la tabla de rutas publica"
  value       = aws_route_table.rt_publica.id
}

output "rt_privada_id" {
  description = "ID de la tabla de rutas privada"
  value       = aws_route_table.rt_privada.id
}

# terraform fmt -> formatea el codigo de manera correcta
# terraform validate -> valida el codigo de manera correcta (sintaxis y configuraciones) antes de plan o apply
