## Module Toggles

variable "create_ebs" {
  description = "Controls whether the EBS volume and its attachments are created. Set to false to use the module only for the account wide encryption setting."
  type        = bool
  default     = true
}

variable "create_ebs_global" {
  description = "Controls whether the account level EBS encryption by default setting is managed. Set to true to manage it in the region the provider is configured with."
  type        = bool
  default     = false
}

## EBS Global Variables

variable "ebs_encryption_enabled" {
  description = "Whether EBS encryption by default is enabled for the account in the current region. Ignored unless 'create_ebs_global' is true."
  type        = bool
  default     = true
}

## EBS Volume Variables

variable "name" {
  description = "The name tag applied to the EBS volume. Required when 'create_ebs' is true."
  type        = string
  default     = null

  validation {
    condition     = !var.create_ebs || var.name != null
    error_message = "The 'name' variable is required when 'create_ebs' is true."
  }
}

variable "availability_zone" {
  description = "The Availability Zone where the EBS volume is created (e.g. 'eu-west-1a'). It must match the Availability Zone of the instances it is attached to."
  type        = string
  default     = "eu-west-1a"
}

variable "size" {
  description = "The size of the volume in GiB. Required unless 'snapshot_id' is set, in which case it defaults to the size of the snapshot."
  type        = number
  default     = null

  validation {
    condition     = !var.create_ebs || var.size != null || var.snapshot_id != null
    error_message = "Either 'size' or 'snapshot_id' must be set when 'create_ebs' is true."
  }
}

variable "snapshot_id" {
  description = "The ID of the snapshot the volume is restored from. Leave empty to create an empty volume."
  type        = string
  default     = null
}

variable "type" {
  description = "The volume type. Allowed values: 'gp2', 'gp3', 'io1', 'io2', 'st1', 'sc1' or 'standard'."
  type        = string
  default     = "gp3"

  validation {
    condition     = contains(["gp2", "gp3", "io1", "io2", "st1", "sc1", "standard"], var.type)
    error_message = "Expected values: gp2, gp3, io1, io2, st1, sc1, standard."
  }
}

variable "iops" {
  description = "The amount of IOPS provisioned for the volume. Only used when 'type' is 'io1', 'io2' or 'gp3' and ignored otherwise."
  type        = number
  default     = null
}

variable "throughput" {
  description = "The throughput of the volume in MiB/s. Only used when 'type' is 'gp3' and ignored otherwise."
  type        = number
  default     = null
}

variable "multi_attach" {
  description = "Whether Multi-Attach is enabled, allowing the volume to be attached to several instances at once. Only used when 'type' is 'io1' or 'io2' and ignored otherwise."
  type        = bool
  default     = false
}

variable "encrypted" {
  description = "Whether the volume is encrypted at rest. Ignored when 'snapshot_id' is set, because the volume inherits the encryption of the snapshot."
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "The ARN or ID of the AWS KMS key used to encrypt the volume. Leave empty to use the AWS managed EBS key."
  type        = string
  default     = null
}

variable "final_snapshot" {
  description = "Whether a snapshot of the volume is taken before it is deleted."
  type        = bool
  default     = false
}

## Volume Attachment Variables

variable "attach" {
  description = "Controls whether the volume is attached to the instances listed in 'instances'."
  type        = bool
  default     = true
}

variable "instances" {
  description = "A list of EC2 instance IDs the volume is attached to. More than one instance requires 'multi_attach' and an 'io1' or 'io2' volume."
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.instances) < 2 || var.multi_attach
    error_message = "Attaching the volume to more than one instance requires 'multi_attach' to be true."
  }
}

variable "device_name" {
  description = "The device name exposed to the instances (e.g. '/dev/sdh')."
  type        = string
  default     = "/dev/sdh"
}

variable "force_detach" {
  description = "Whether to force detach the volume from the instances. Can cause data loss and should only be used as a last resort."
  type        = bool
  default     = false
}

variable "stop_instance_before_detaching" {
  description = "Whether to stop the instances before the volume is detached from them."
  type        = bool
  default     = false
}
