/**
 * # ecr-repo-lambda
 *
 * This module manages AWS Lambda which creates private ECR repositories
 * whenever an attempt to push to a non-existing repository is logged in
 * CloudTrail. Since `docker push` attempt five times, the repository will
 * be created before all retry attempts exhausted, if lambda is working
 * correctly 😉.
 *
 * ## Usage
 *
 * For example:
 *
 * ```hcl
 * module "lambda" {
 *   source = "tradeparadigm/ecr-repo-lambda/aws"
 *
 *   managed_repo_prefixes = [
 *     "backend/",
 *     "frontend/"
 *   ]
 * }
 * ```
 */

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  common_tags        = merge({ "managed-by" = "terraform" }, var.tags)
  current_region     = data.aws_region.current.name
  current_account_id = data.aws_caller_identity.current.account_id
  full_name          = "${var.name}-${local.current_region}"
  repo_tags          = merge({ "created-by" = local.full_name }, var.repo_tags)
}

data "archive_file" "this" {
  type        = "zip"
  source_dir  = "${path.module}/files/create-ecr-repo/src"
  output_path = "${path.module}/files/create-ecr-repo/out/python.zip"
}

resource "aws_lambda_function" "this" {
  filename         = data.archive_file.this.output_path
  function_name    = local.full_name
  description      = "Creates ECR repo when push failed due to missing repo."
  role             = aws_iam_role.this.arn
  handler          = "handler.run"
  runtime          = "python3.12"
  source_code_hash = data.archive_file.this.output_base64sha256

  reserved_concurrent_executions = var.lambda_concurrency

  environment {
    variables = {
      MANAGED_REPO_PREFIXES = join(",", var.managed_repo_prefixes)
      IMAGE_TAG_MUTABILITY  = var.image_tag_mutability
      REPO_LIFECYCLE_POLICY = var.repo_lifecycle_policy
      REPO_POLICY           = var.repo_policy 
      REPO_TAGS             = jsonencode(local.repo_tags)
      REPO_SCAN_ON_PUSH     = tostring(var.repo_scan_on_push)
    }
  }

  tags = merge({ Name = local.full_name }, local.common_tags)
}

resource "aws_lambda_permission" "this" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.this.arn
  statement_id  = "AllowExecutionFromCloudWatch"
}

resource "aws_lambda_function_event_invoke_config" "this" {
  function_name                = aws_lambda_function.this.function_name
  maximum_event_age_in_seconds = 60
  maximum_retry_attempts       = 0
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${aws_lambda_function.this.function_name}"
  retention_in_days = var.log_retention_days

  tags = merge({ Name = local.full_name }, local.common_tags)
}

resource "aws_cloudwatch_event_rule" "this" {
  name        = "ecr-repo-404-on-push-for-${local.full_name}"
  description = "ECR repo push failed for nonexistent repos."

  event_pattern = <<-EOF
  {
    "source": ["aws.ecr"],
    "detail-type": ["AWS API Call via CloudTrail"],
    "detail": {
      "awsRegion": ["${local.current_region}"],
      "eventSource": ["ecr.amazonaws.com"],
      "eventName": ["InitiateLayerUpload"],
      "errorCode": ["RepositoryNotFoundException"]
    }
  }
  EOF

  tags = merge({ Name = local.full_name }, local.common_tags)
}

resource "aws_cloudwatch_event_target" "this" {
  target_id = aws_lambda_function.this.function_name
  rule      = aws_cloudwatch_event_rule.this.name
  arn       = aws_lambda_function.this.arn

  retry_policy {
    maximum_event_age_in_seconds = 1800
    maximum_retry_attempts       = 1
  }
}
