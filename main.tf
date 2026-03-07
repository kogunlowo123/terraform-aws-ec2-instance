################################################################################
# Launch Template
################################################################################

resource "aws_launch_template" "this" {
  name_prefix   = "${local.name}-"
  image_id      = local.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  ebs_optimized = var.ebs_optimized

  monitoring {
    enabled = var.enable_monitoring
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = var.metadata_http_tokens
    http_put_response_hop_limit = var.metadata_hop_limit
    instance_metadata_tags      = "enabled"
  }

  dynamic "iam_instance_profile" {
    for_each = local.iam_instance_profile_name != null ? [1] : []
    content {
      name = local.iam_instance_profile_name
    }
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_type           = var.root_block_device.volume_type
      volume_size           = var.root_block_device.volume_size
      iops                  = var.root_block_device.iops
      throughput            = var.root_block_device.throughput
      encrypted             = var.root_block_device.encrypted
      kms_key_id            = var.root_block_device.kms_key_id
      delete_on_termination = var.root_block_device.delete_on_termination
    }
  }

  network_interfaces {
    associate_public_ip_address = var.associate_public_ip
    security_groups             = local.security_group_ids
    subnet_id                   = var.subnet_id
    delete_on_termination       = true

    dynamic "private_ip_address" {
      for_each = []
      content {}
    }
  }

  user_data = var.user_data_base64 != null ? var.user_data_base64 : (
    var.user_data != null ? base64encode(var.user_data) : null
  )

  tag_specifications {
    resource_type = "instance"
    tags          = local.tags
  }

  tag_specifications {
    resource_type = "volume"
    tags          = local.tags
  }

  tags = local.tags

  lifecycle {
    create_before_destroy = true
  }
}

################################################################################
# EC2 Instance
################################################################################

resource "aws_instance" "this" {
  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  subnet_id         = var.subnet_id
  availability_zone = var.availability_zone
  private_ip        = var.private_ip
  placement_group   = var.placement_group
  tenancy           = var.tenancy

  tags = local.tags

  lifecycle {
    ignore_changes = [
      ami,
      user_data,
      user_data_base64,
    ]
  }
}

################################################################################
# Network Interface (optional additional ENI)
################################################################################

resource "aws_network_interface" "this" {
  count = 0

  subnet_id       = var.subnet_id
  security_groups = local.security_group_ids
  private_ips     = var.private_ip != null ? [var.private_ip] : null

  tags = merge(local.tags, {
    Name = "${local.name}-eni"
  })
}

################################################################################
# Additional EBS Volumes
################################################################################

resource "aws_ebs_volume" "this" {
  for_each = { for idx, vol in var.additional_ebs_volumes : idx => vol }

  availability_zone = aws_instance.this.availability_zone
  type              = each.value.volume_type
  size              = each.value.volume_size
  iops              = each.value.iops
  throughput        = each.value.throughput
  encrypted         = each.value.encrypted
  kms_key_id        = each.value.kms_key_id

  tags = merge(local.tags, {
    Name = "${local.name}-ebs-${each.key}"
  })
}

resource "aws_volume_attachment" "this" {
  for_each = { for idx, vol in var.additional_ebs_volumes : idx => vol }

  device_name = each.value.device_name
  volume_id   = aws_ebs_volume.this[each.key].id
  instance_id = aws_instance.this.id

  force_detach = true
}

################################################################################
# Security Group
################################################################################

resource "aws_security_group" "this" {
  count = var.create_security_group ? 1 : 0

  name_prefix = "${local.name}-"
  description = "Security group for ${local.name} EC2 instance"
  vpc_id      = var.vpc_id

  tags = merge(local.tags, {
    Name = "${local.name}-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "ingress" {
  for_each = var.create_security_group ? { for idx, rule in var.ingress_rules : idx => rule } : {}

  type              = "ingress"
  security_group_id = aws_security_group.this[0].id

  description = each.value.description
  from_port   = each.value.from_port
  to_port     = each.value.to_port
  protocol    = each.value.protocol
  cidr_blocks = length(each.value.cidr_blocks) > 0 ? each.value.cidr_blocks : null

  source_security_group_id = length(each.value.security_groups) > 0 ? each.value.security_groups[0] : null
}

resource "aws_security_group_rule" "egress" {
  count = var.create_security_group ? 1 : 0

  type              = "egress"
  security_group_id = aws_security_group.this[0].id

  description = "Allow all outbound traffic"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}
