output "vpc_id" {
  description = "ID du VPC créé"
  value       = aws_vpc.portfolio_vpc.id
}

output "subnet_id" {
  description = "ID du Subnet créé"
  value       = aws_subnet.portfolio_subnet.id
}

output "ec2_public_ip" {
  description = "IP publique de l'EC2"
  value       = aws_instance.portfolio_ec2.public_ip
}

output "ec2_instance_id" {
  description = "ID de l'instance EC2"
  value       = aws_instance.portfolio_ec2.id
}
