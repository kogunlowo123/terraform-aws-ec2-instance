output "instance_id" {
  description = "The ID of the spot instance"
  value       = aws_instance.spot.id
}

output "private_ip" {
  description = "The private IP address of the spot instance"
  value       = aws_instance.spot.private_ip
}

output "public_ip" {
  description = "The public IP address of the spot instance, if applicable"
  value       = aws_instance.spot.public_ip
}

output "launch_template_id" {
  description = "The ID of the spot launch template"
  value       = aws_launch_template.spot.id
}
