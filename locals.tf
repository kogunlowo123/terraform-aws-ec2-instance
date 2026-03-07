locals {
  name = var.name

  ami_id = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux.id

  iam_instance_profile_name = var.create_iam_instance_profile ? aws_iam_instance_profile.this[0].name : var.iam_instance_profile_name

  security_group_ids = var.create_security_group ? concat(
    [aws_security_group.this[0].id],
    var.security_group_ids
  ) : var.security_group_ids

  tags = merge(
    var.tags,
    {
      Name      = local.name
      ManagedBy = "terraform"
    }
  )
}
