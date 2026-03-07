################################################################################
# Spot Launch Template
################################################################################

resource "aws_launch_template" "spot" {
  name_prefix   = "${var.name}-spot-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  ebs_optimized = var.ebs_optimized

  monitoring {
    enabled = var.enable_monitoring
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = var.metadata_http_tokens
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  dynamic "iam_instance_profile" {
    for_each = var.iam_instance_profile_name != null ? [1] : []
    content {
      name = var.iam_instance_profile_name
    }
  }

  instance_market_options {
    market_type = "spot"

    spot_options {
      max_price                      = var.spot_price
      spot_instance_type             = var.spot_type
      instance_interruption_behavior = var.instance_interruption_behavior
    }
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_type           = var.root_volume_type
      volume_size           = var.root_volume_size
      encrypted             = true
      delete_on_termination = true
    }
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = var.security_group_ids
    subnet_id                   = var.subnet_id
    delete_on_termination       = true
  }

  user_data = var.user_data != null ? base64encode(var.user_data) : null

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, {
      Name = "${var.name}-spot"
    })
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(var.tags, {
      Name = "${var.name}-spot"
    })
  }

  tags = merge(var.tags, {
    Name = "${var.name}-spot-lt"
  })

  lifecycle {
    create_before_destroy = true
  }
}

################################################################################
# Spot Instance
################################################################################

resource "aws_instance" "spot" {
  launch_template {
    id      = aws_launch_template.spot.id
    version = "$Latest"
  }

  subnet_id = var.subnet_id

  tags = merge(var.tags, {
    Name = "${var.name}-spot"
  })

  lifecycle {
    ignore_changes = [
      ami,
      user_data,
    ]
  }
}
