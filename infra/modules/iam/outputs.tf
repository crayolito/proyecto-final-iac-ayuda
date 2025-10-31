output "instance_profile_name" {
  description = "Nombre del Instance Profile para EC2"
  value       = aws_iam_instance_profile.perfil_ec2.name
}

output "role_arn" {
  description = "ARN del rol IAM asignado a la EC2"
  value       = aws_iam_role.rol_ec2.arn
}
