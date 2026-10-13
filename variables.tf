# -----------------------------------------------------------------------------
# Input Variables
# -----------------------------------------------------------------------------
# Centralizing configurable values here means you never hardcode things like
# region, instance type, or CIDR blocks directly in resource blocks.

variable "aws_region" {
  description = "AWS region to deploy resources into"
  type        = string
  default     = "ap-south-1" # Mumbai — closest free-tier region to IN
}

variable "project_name" {
  description = "Name prefix used to tag and identify all resources created by this project"
  type        = string
  default     = "mini-project-3"
}

variable "environment" {
  description = "Deployment environment (e.g. dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  description = "Availability zone for the public subnet"
  type        = string
  default     = "ap-south-1a"
}

variable "instance_type" {
  description = "EC2 instance type (kept at t2.micro / t3.micro to stay within AWS Free Tier)"
  type        = string
  default     = "t2.micro"

  validation {
    condition     = contains(["t2.micro", "t3.micro"], var.instance_type)
    error_message = "To stay within AWS Free Tier limits, instance_type must be t2.micro or t3.micro."
  }
}

variable "ssh_allowed_cidr" {
  description = "CIDR block allowed to SSH into the instance. Restrict this to your own IP (e.g. 203.0.113.5/32) rather than leaving it open to the world."
  type        = string
  default     = "0.0.0.0/0" # NOTE: change this to your own IP before applying — see README
}

variable "key_pair_name" {
  description = "Name of an existing EC2 key pair (in your AWS account) to allow SSH access"
  type        = string
}

variable "root_volume_size" {
  description = "Size (GB) of the root EBS volume. Free tier covers up to 30GB."
  type        = number
  default     = 8
}
