################################################################################
# General
################################################################################

variable "name" {
  description = "Name to be used as an identifier for all resources"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

################################################################################
# Instance
################################################################################

variable "ami_id" {
  description = "AMI ID to use for the instance. If not provided, the latest Amazon Linux 2023 AMI will be used"
  type        = string
  default     = ""
}

variable "instance_type" {
  description = "The type of instance to start"
  type        = string
  default     = "t3.micro"
}

variable "subnet_id" {
  description = "The VPC subnet ID to launch the instance in"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID where the instance will be launched"
  type        = string
}

variable "key_name" {
  description = "Key name of the Key Pair to use for the instance"
  type        = string
  default     = null
}

variable "user_data" {
  description = "User data to provide when launching the instance. Conflicts with user_data_base64"
  type        = string
  default     = null
}

variable "user_data_base64" {
  description = "Base64-encoded user data to provide when launching the instance. Conflicts with user_data"
  type        = string
  default     = null
}

variable "enable_monitoring" {
  description = "If true, the launched EC2 instance will have detailed monitoring enabled"
  type        = bool
  default     = true
}

variable "ebs_optimized" {
  description = "If true, the launched EC2 instance will be EBS-optimized"
  type        = bool
  default     = true
}

variable "private_ip" {
  description = "Private IP address to associate with the instance in a VPC"
  type        = string
  default     = null
}

variable "availability_zone" {
  description = "AZ to start the instance in"
  type        = string
  default     = null
}

variable "placement_group" {
  description = "The placement group to start the instance in"
  type        = string
  default     = null
}

variable "tenancy" {
  description = "The tenancy of the instance (default, dedicated, or host)"
  type        = string
  default     = "default"

  validation {
    condition     = contains(["default", "dedicated", "host"], var.tenancy)
    error_message = "Tenancy must be one of: default, dedicated, host."
  }
}

################################################################################
# IAM Instance Profile
################################################################################

variable "iam_instance_profile_name" {
  description = "The name of an existing IAM instance profile to attach. Used when create_iam_instance_profile is false"
  type        = string
  default     = null
}

variable "create_iam_instance_profile" {
  description = "Whether to create an IAM instance profile for the instance"
  type        = bool
  default     = true
}

variable "iam_policies" {
  description = "List of IAM policy ARNs to attach to the instance role"
  type        = list(string)
  default     = []
}

variable "enable_ssm" {
  description = "Whether to attach the AmazonSSMManagedInstanceCore policy for SSM access"
  type        = bool
  default     = true
}

################################################################################
# Root Block Device
################################################################################

variable "root_block_device" {
  description = "Configuration block for the root block device of the instance"
  type = object({
    volume_type           = optional(string, "gp3")
    volume_size           = optional(number, 20)
    iops                  = optional(number, null)
    throughput            = optional(number, null)
    encrypted             = optional(bool, true)
    kms_key_id            = optional(string, null)
    delete_on_termination = optional(bool, true)
  })
  default = {
    volume_type           = "gp3"
    volume_size           = 20
    encrypted             = true
    delete_on_termination = true
  }
}

################################################################################
# Additional EBS Volumes
################################################################################

variable "additional_ebs_volumes" {
  description = "List of additional EBS volumes to create and attach to the instance"
  type = list(object({
    device_name           = string
    volume_type           = optional(string, "gp3")
    volume_size           = number
    iops                  = optional(number, null)
    throughput            = optional(number, null)
    encrypted             = optional(bool, true)
    kms_key_id            = optional(string, null)
    delete_on_termination = optional(bool, true)
  }))
  default = []
}

################################################################################
# Security Group
################################################################################

variable "security_group_ids" {
  description = "A list of existing security group IDs to associate with the instance"
  type        = list(string)
  default     = []
}

variable "create_security_group" {
  description = "Whether to create a security group for the instance"
  type        = bool
  default     = true
}

variable "ingress_rules" {
  description = "List of ingress rules for the security group"
  type = list(object({
    description = optional(string, "")
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = optional(list(string), [])
    security_groups = optional(list(string), [])
  }))
  default = []
}

################################################################################
# Network
################################################################################

variable "associate_public_ip" {
  description = "Whether to associate a public IP address with the instance"
  type        = bool
  default     = false
}

################################################################################
# Metadata / IMDSv2
################################################################################

variable "metadata_http_tokens" {
  description = "Whether the metadata service requires session tokens (IMDSv2). Set to 'required' to enforce IMDSv2"
  type        = string
  default     = "required"

  validation {
    condition     = contains(["optional", "required"], var.metadata_http_tokens)
    error_message = "metadata_http_tokens must be either 'optional' or 'required'."
  }
}

variable "metadata_hop_limit" {
  description = "The desired HTTP PUT response hop limit for instance metadata requests"
  type        = number
  default     = 1
}
