<!-- BEGIN_TF_DOCS -->
# ecr-repo-lambda

This module manages AWS Lambda which creates private ECR repositories
whenever an attempt to push to a non-existing repository is logged in
CloudTrail. Since `docker push` attempt five times, the repository will
be created before all retry attempts exhaused, if lambda is working
correctly 😉.

## Usage

For example:

```hcl
module "lambda" {
  source = "tradeparadigm/aws/ecr-repo-lambda"

  managed_repo_prefixes = [
    "backend/",
    "frontend/"
  ]
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.1 |
| <a name="requirement_archive"></a> [archive](#requirement_archive) | >= 2.2 |
| <a name="requirement_aws"></a> [aws](#requirement_aws) | >= 4.22 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider_archive) | >= 2.2 |
| <a name="provider_aws"></a> [aws](#provider_aws) | >= 4.22 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_lambda_function.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_function_event_invoke_config.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function_event_invoke_config) | resource |
| [aws_lambda_permission.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [archive_file.this](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_image_tag_mutability"></a> [image_tag_mutability](#input_image_tag_mutability) | ECR repo image tag mutability setting set on every repo Lambda creates. One of `MUTABLE` or `IMMUTABLE`. | `string` | `"MUTABLE"` | no |
| <a name="input_lambda_concurrency"></a> [lambda_concurrency](#input_lambda_concurrency) | AWS Lambda concurrency reservation. | `number` | `1` | no |
| <a name="input_log_retention_days"></a> [log_retention_days](#input_log_retention_days) | Number of days to retain AWS Lambda logs. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0. If you select 0, the events in the log group are always retained and never expire. | `number` | `14` | no |
| <a name="input_managed_repo_prefixes"></a> [managed_repo_prefixes](#input_managed_repo_prefixes) | List of managed ECR repo prefixes Lambda can create repos for. | `list(string)` | `[]` | no |
| <a name="input_name"></a> [name](#input_name) | AWS Lambda name. Region will be appended as suffix: `<name>-<aws_region>`. | `string` | `"create-ecr-repo"` | no |
| <a name="input_repo_lifecycle_policy"></a> [repo_lifecycle_policy](#input_repo_lifecycle_policy) | ECR repository policy added to every repo Lambda creates. | `string` | `"{\n  \"rules\": [\n    {\n      \"rulePriority\": 10,\n      \"description\": \"Only keep 20 most recent untagged images.\",\n      \"selection\": {\n        \"tagStatus\": \"untagged\",\n        \"countType\": \"imageCountMoreThan\",\n        \"countNumber\": 20\n      },\n      \"action\": {\n        \"type\": \"expire\"\n      }\n    }\n}\n"` | no |
| <a name="input_repo_scan_on_push"></a> [repo_scan_on_push](#input_repo_scan_on_push) | Toggles Scan on push on repos Lambda creates. | `bool` | `true` | no |
| <a name="input_repo_tags"></a> [repo_tags](#input_repo_tags) | ECR repo tags added to every repo Lambda creates. | `map(string)` | `{}` | no |
| <a name="input_tags"></a> [tags](#input_tags) | Tags to apply to created AWS resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output_arn) | The Lambda ARN. |
| <a name="output_invoke_arn"></a> [invoke_arn](#output_invoke_arn) | The Lambda API Gateway invoke ARN. |

## Updates to README

This file is generated with [terraform-docs](https://github.com/terraform-docs/terraform-docs):

```sh
terraform-docs .
```
<!-- END_TF_DOCS -->
