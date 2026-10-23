output "id" {
  description = "The ID of the EBS volume."
  value       = try(aws_ebs_volume.vss[0].id, null)
}

output "arn" {
  description = "The ARN of the EBS volume."
  value       = try(aws_ebs_volume.vss[0].arn, null)
}

output "size" {
  description = "The size of the EBS volume in GiB."
  value       = try(aws_ebs_volume.vss[0].size, null)
}

output "type" {
  description = "The type of the EBS volume."
  value       = try(aws_ebs_volume.vss[0].type, null)
}

output "iops" {
  description = "The amount of IOPS provisioned for the EBS volume."
  value       = try(aws_ebs_volume.vss[0].iops, null)
}

output "throughput" {
  description = "The throughput of the EBS volume in MiB/s."
  value       = try(aws_ebs_volume.vss[0].throughput, null)
}

output "availability_zone" {
  description = "The Availability Zone of the EBS volume."
  value       = try(aws_ebs_volume.vss[0].availability_zone, null)
}

output "encrypted" {
  description = "Whether the EBS volume is encrypted at rest."
  value       = try(aws_ebs_volume.vss[0].encrypted, null)
}

output "kms_key_id" {
  description = "The ARN of the KMS key used to encrypt the EBS volume."
  value       = try(aws_ebs_volume.vss[0].kms_key_id, null)
}

output "attachment_ids" {
  description = "The IDs of the volume attachments created by the module."
  value       = aws_volume_attachment.vss[*].id
}

output "device_names" {
  description = "The device names the volume is exposed as on the instances."
  value       = aws_volume_attachment.vss[*].device_name
}
