variable "name" {
  description = "Name to be used as an identifier for all resources"
  type        = string
}

variable "ami_id" {
  description = "AMI ID to use for the spot instance"
  type        = string
}

variable "instance_type" {
  description = "The type of instance to request as spot"
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

variable "security_group_ids" {
  description = "A list of security group IDs to associate with the instance"
  type        = list(string)
  default     = []
}

variable "iam_instance_profile_name" {
  description = "The name of an IAM instance profile to attach"
  type        = string
  default     = null
}

variable "spot_price" {
  description = "The maximum price to request on the spot market. Defaults to on-demand price"
  type        = string
  default     = null
}

variable "spot_type" {
  description = "The Spot Instance request type. Can be 'one-time' or 'persistent'"
  type        = string
  default     = "one-time"

  validation {
    condition     = contains(["one-time", "persistent"], var.spot_type)
    error_message = "spot_type must be either 'one-time' or 'persistent'."
  }
}

variable "instance_interruption_behavior" {
  description = "The behavior when a Spot Instance is interrupted. Can be 'hibernate', 'stop', or 'terminate'"
  type        = string
  default     = "terminate"

  validation {
    condition     = contains(["hibernate", "stop", "terminate"], var.instance_interruption_behavior)
    error_message = "instance_interruption_behavior must be one of: hibernate, stop, terminate."
  }
}

variable "wait_for_fulfillment" {
  description = "Whether to wait for the Spot Request to be fulfilled"
  type        = bool
  default     = true
}

variable "block_duration_minutes" {
  description = "The required duration for the Spot instances, in minutes (60, 120, 180, 240, 300, or 360)"
  type        = number
  default     = null
}

variable "launch_group" {
  description = "A launch group is a group of spot instances that launch together and terminate together"
  type        = string
  default     = null
}

variable "user_data" {
  description = "User data to provide when launching the instance"
  type        = string
  default     = null
}

variable "root_volume_size" {
  description = "Size of the root volume in GB"
  type        = number
  default     = 20
}

variable "root_volume_type" {
  description = "Type of the root volume"
  type        = string
  default     = "gp3"
}

variable "metadata_http_tokens" {
  description = "Whether the metadata service requires session tokens (IMDSv2)"
  type        = string
  default     = "required"
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

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
