################################################################################
# Instance
################################################################################

output "instance_id" {
  description = "The ID of the EC2 instance."
  value       = aws_instance.this.id
}

output "private_ip" {
  description = "The private IP address assigned to the instance."
  value       = aws_instance.this.private_ip
}

output "public_ip" {
  description = "The public IP address assigned to the instance, if applicable."
  value       = aws_instance.this.public_ip
}

################################################################################
# Security Group
################################################################################

output "security_group_id" {
  description = "The ID of the security group created for the instance."
  value       = try(aws_security_group.this[0].id, null)
}

################################################################################
# IAM
################################################################################

output "iam_role_arn" {
  description = "The ARN of the IAM role created for the instance."
  value       = try(aws_iam_role.this[0].arn, null)
}

output "iam_role_name" {
  description = "The name of the IAM role created for the instance."
  value       = try(aws_iam_role.this[0].name, null)
}

output "iam_instance_profile_name" {
  description = "The name of the IAM instance profile."
  value       = try(aws_iam_instance_profile.this[0].name, null)
}

output "launch_template_id" {
  description = "The ID of the launch template."
  value       = aws_launch_template.this.id
}

output "launch_template_latest_version" {
  description = "The latest version of the launch template."
  value       = aws_launch_template.this.latest_version
}
