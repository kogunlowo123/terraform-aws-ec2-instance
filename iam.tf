################################################################################
# IAM Role
################################################################################

data "aws_iam_policy_document" "assume_role" {
  count = var.create_iam_instance_profile ? 1 : 0

  statement {
    sid     = "EC2AssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  count = var.create_iam_instance_profile ? 1 : 0

  name_prefix        = "${local.name}-"
  assume_role_policy = data.aws_iam_policy_document.assume_role[0].json
  description        = "IAM role for ${local.name} EC2 instance"

  tags = local.tags
}

################################################################################
# IAM Instance Profile
################################################################################

resource "aws_iam_instance_profile" "this" {
  count = var.create_iam_instance_profile ? 1 : 0

  name_prefix = "${local.name}-"
  role        = aws_iam_role.this[0].name

  tags = local.tags
}

################################################################################
# SSM Policy Attachment
################################################################################

resource "aws_iam_role_policy_attachment" "ssm" {
  count = var.create_iam_instance_profile && var.enable_ssm ? 1 : 0

  role       = aws_iam_role.this[0].name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

################################################################################
# CloudWatch Policy Attachment
################################################################################

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  count = var.create_iam_instance_profile ? 1 : 0

  role       = aws_iam_role.this[0].name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/CloudWatchAgentServerPolicy"
}

################################################################################
# Additional IAM Policy Attachments
################################################################################

resource "aws_iam_role_policy_attachment" "additional" {
  for_each = var.create_iam_instance_profile ? toset(var.iam_policies) : toset([])

  role       = aws_iam_role.this[0].name
  policy_arn = each.value
}
