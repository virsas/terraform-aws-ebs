resource "aws_ebs_encryption_by_default" "vss" {
  count = var.create_ebs_global ? 1 : 0

  enabled = var.ebs_encryption_enabled
}

resource "aws_ebs_volume" "vss" {
  count = var.create_ebs ? 1 : 0

  availability_zone = var.availability_zone

  size        = var.size
  snapshot_id = var.snapshot_id

  type       = var.type
  iops       = contains(["io1", "io2", "gp3"], var.type) ? var.iops : null
  throughput = var.type == "gp3" ? var.throughput : null

  multi_attach_enabled = contains(["io1", "io2"], var.type) ? var.multi_attach : false

  encrypted  = var.encrypted
  kms_key_id = var.kms_key_id

  final_snapshot = var.final_snapshot

  tags = {
    Name = var.name
  }
}

resource "aws_volume_attachment" "vss" {
  count = var.create_ebs && var.attach ? length(var.instances) : 0

  instance_id = var.instances[count.index]

  device_name = var.device_name
  volume_id   = aws_ebs_volume.vss[0].id

  force_detach                   = var.force_detach
  stop_instance_before_detaching = var.stop_instance_before_detaching
}
