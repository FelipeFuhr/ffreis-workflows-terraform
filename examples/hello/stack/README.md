# hello/stack

A minimal Terraform module using the `local` provider — no cloud credentials required.

Writes a greeting text file to demonstrate fmt, validate, lint, docs, and security scanning.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | ~> 2.5 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_local"></a> [local](#provider\_local) | ~> 2.5 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [local_file.greeting](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Name to include in the greeting. | `string` | `"world"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_greeting_content"></a> [greeting\_content](#output\_greeting\_content) | Content written to the greeting file. |
| <a name="output_greeting_path"></a> [greeting\_path](#output\_greeting\_path) | Absolute path of the generated greeting file. |
<!-- END_TF_DOCS -->
