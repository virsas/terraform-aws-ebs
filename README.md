# Terraform AWS EBS Module

A Terraform module for managing an [Amazon EBS volume](https://docs.aws.amazon.com/ebs/latest/userguide/ebs-volumes.html) together with its attachments to EC2 instances. The module can create an empty or snapshot restored volume, tune its type, IOPS and throughput, encrypt it with a customer managed KMS key, and optionally manage the account level [EBS encryption by default](https://docs.aws.amazon.com/ebs/latest/userguide/encryption-by-default.html) setting, which replaces the separate `terraform-aws-ebs-global` module.

## Features

- **Volume Creation**: Creates an EBS volume in a single Availability Zone, either empty or restored from a snapshot.
- **Volume Types**: Supports `gp2`, `gp3`, `io1`, `io2`, `st1`, `sc1` and `standard`, with provisioned IOPS applied only to the types that accept them and throughput applied only to `gp3`.
- **Multi-Attach**: Enables Multi-Attach for `io1` and `io2` volumes so the same volume can be attached to several instances at once.
- **KMS Encryption**: Encrypts the volume at rest by default and supports a customer managed KMS key.
- **Final Snapshot**: Optionally takes a snapshot of the volume before it is deleted.
- **Attachments**: Attaches the volume to a list of instances with a configurable device name, force detach and stop before detach behaviour.
- **Account Wide Guardrail**: Optionally turns EBS encryption by default on or off for the account in the region the provider is configured with.

---

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

---

## Usage Examples

### Basic Example

Create an encrypted `gp3` volume and attach it to a single instance:

```hcl
module "ebs" {
  source = "git::https://github.com/virsas/terraform-aws-ebs.git?ref=v1.0"

  name              = "vss-application-data"
  availability_zone = "eu-west-1a"

  size = 100

  instances = ["i-0abc123def4567890"]
}
```

### Advanced Example (Provisioned IOPS and Multi-Attach)

Create an `io2` volume with provisioned IOPS, encrypt it with a customer managed KMS key, attach it to two instances and keep a snapshot when it is deleted:

```hcl
module "ebs_shared" {
  source = "git::https://github.com/virsas/terraform-aws-ebs.git?ref=v1.0"

  name              = "vss-application-shared"
  availability_zone = "eu-west-1a"

  size = 500

  type         = "io2"
  iops         = 8000
  multi_attach = true

  encrypted  = true
  kms_key_id = "arn:aws:kms:eu-west-1:123456789012:key/12345678-1234-1234-1234-123456789012"

  final_snapshot = true

  instances   = ["i-0abc123def4567890", "i-0def456abc7890123"]
  device_name = "/dev/sdf"

  stop_instance_before_detaching = true
}
```

### Snapshot Restore Example

Restore a volume from an existing snapshot without attaching it to an instance:

```hcl
module "ebs_restore" {
  source = "git::https://github.com/virsas/terraform-aws-ebs.git?ref=v1.0"

  name              = "vss-application-restore"
  availability_zone = "eu-west-1b"

  snapshot_id = "snap-0abc123def4567890"

  attach = false
}
```

### Encryption By Default Example

Manage only the account level encryption setting, as a replacement for the `terraform-aws-ebs-global` module:

```hcl
module "ebs_global" {
  source = "git::https://github.com/virsas/terraform-aws-ebs.git?ref=v1.0"

  create_ebs        = false
  create_ebs_global = true

  ebs_encryption_enabled = true
}
```

---

## Resources

| Name | Type |
|------|------|
| [aws_ebs_volume.vss](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_volume) | resource |
| [aws_volume_attachment.vss](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/volume_attachment) | resource |
| [aws_ebs_encryption_by_default.vss](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_encryption_by_default) | resource |

---

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_ebs"></a> [create\_ebs](#input\_create\_ebs) | Controls whether the EBS volume and its attachments are created. | `bool` | `true` | no |
| <a name="input_create_ebs_global"></a> [create\_ebs\_global](#input\_create\_ebs\_global) | Controls whether the account level EBS encryption by default setting is managed. | `bool` | `false` | no |
| <a name="input_ebs_encryption_enabled"></a> [ebs\_encryption\_enabled](#input\_ebs\_encryption\_enabled) | Whether EBS encryption by default is enabled for the account in the current region. Ignored unless `create_ebs_global` is `true`. | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | The name tag applied to the EBS volume. Required when `create_ebs` is `true`. | `string` | `null` | no |
| <a name="input_availability_zone"></a> [availability\_zone](#input\_availability\_zone) | Availability Zone where the volume is created (e.g. `"eu-west-1a"`). Must match the Availability Zone of the instances it is attached to. | `string` | `"eu-west-1a"` | no |
| <a name="input_size"></a> [size](#input\_size) | The size of the volume in GiB. Required unless `snapshot_id` is set. | `number` | `null` | no |
| <a name="input_snapshot_id"></a> [snapshot\_id](#input\_snapshot\_id) | ID of the snapshot the volume is restored from. Leave empty to create an empty volume. | `string` | `null` | no |
| <a name="input_type"></a> [type](#input\_type) | The volume type. Allowed values: `gp2`, `gp3`, `io1`, `io2`, `st1`, `sc1` or `standard`. | `string` | `"gp3"` | no |
| <a name="input_iops"></a> [iops](#input\_iops) | Amount of IOPS provisioned for the volume. Only used when `type` is `io1`, `io2` or `gp3`. | `number` | `null` | no |
| <a name="input_throughput"></a> [throughput](#input\_throughput) | Throughput of the volume in MiB/s. Only used when `type` is `gp3`. | `number` | `null` | no |
| <a name="input_multi_attach"></a> [multi\_attach](#input\_multi\_attach) | Whether Multi-Attach is enabled. Only used when `type` is `io1` or `io2`. | `bool` | `false` | no |
| <a name="input_encrypted"></a> [encrypted](#input\_encrypted) | Whether the volume is encrypted at rest. Ignored when `snapshot_id` is set. | `bool` | `true` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | ARN or ID of the KMS key used to encrypt the volume. Leave empty to use the AWS managed EBS key. | `string` | `null` | no |
| <a name="input_final_snapshot"></a> [final\_snapshot](#input\_final\_snapshot) | Whether a snapshot of the volume is taken before it is deleted. | `bool` | `false` | no |
| <a name="input_attach"></a> [attach](#input\_attach) | Controls whether the volume is attached to the instances listed in `instances`. | `bool` | `true` | no |
| <a name="input_instances"></a> [instances](#input\_instances) | List of EC2 instance IDs the volume is attached to. More than one instance requires `multi_attach` and an `io1` or `io2` volume. | `list(string)` | `[]` | no |
| <a name="input_device_name"></a> [device\_name](#input\_device\_name) | The device name exposed to the instances (e.g. `"/dev/sdh"`). | `string` | `"/dev/sdh"` | no |
| <a name="input_force_detach"></a> [force\_detach](#input\_force\_detach) | Whether to force detach the volume from the instances. Can cause data loss. | `bool` | `false` | no |
| <a name="input_stop_instance_before_detaching"></a> [stop\_instance\_before\_detaching](#input\_stop\_instance\_before\_detaching) | Whether to stop the instances before the volume is detached from them. | `bool` | `false` | no |

---

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The ID of the EBS volume. |
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the EBS volume. |
| <a name="output_size"></a> [size](#output\_size) | The size of the EBS volume in GiB. |
| <a name="output_type"></a> [type](#output\_type) | The type of the EBS volume. |
| <a name="output_iops"></a> [iops](#output\_iops) | The amount of IOPS provisioned for the EBS volume. |
| <a name="output_throughput"></a> [throughput](#output\_throughput) | The throughput of the EBS volume in MiB/s. |
| <a name="output_availability_zone"></a> [availability\_zone](#output\_availability\_zone) | The Availability Zone of the EBS volume. |
| <a name="output_encrypted"></a> [encrypted](#output\_encrypted) | Whether the EBS volume is encrypted at rest. |
| <a name="output_kms_key_id"></a> [kms\_key\_id](#output\_kms\_key\_id) | The ARN of the KMS key used to encrypt the EBS volume. |
| <a name="output_attachment_ids"></a> [attachment\_ids](#output\_attachment\_ids) | The IDs of the volume attachments created by the module. |
| <a name="output_device_names"></a> [device\_names](#output\_device\_names) | The device names the volume is exposed as on the instances. |

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
