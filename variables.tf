variable "name" {
  type        = string
  description = "AWS Lambda name. Region will be appended as suffix: `<name>-<aws_region>`."
  default     = "create-ecr-repo"
  nullable    = false
}

variable "lambda_concurrency" {
  type        = number
  description = "AWS Lambda concurrency reservation."
  default     = 1
  nullable    = false
}

variable "log_retention_days" {
  type        = number
  description = "Number of days to retain AWS Lambda logs. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0. If you select 0, the events in the log group are always retained and never expire."
  default     = 14
  nullable    = false
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to created AWS resources."
  default     = {}
  nullable    = false
}

variable "managed_repo_prefixes" {
  type        = list(string)
  description = "List of managed ECR repo prefixes Lambda can create repos for."
  default     = []
  nullable    = false
}

variable "image_tag_mutability" {
  type        = string
  description = "ECR repo image tag mutability setting set on every repo Lambda creates. One of `MUTABLE` or `IMMUTABLE`."
  default     = "MUTABLE"
  nullable    = false
  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "The image_tag_mutability value must be one of \"MUTABLE\" or \"IMMUTABLE\"."
  }
}

variable "repo_lifecycle_policy" {
  type        = string
  description = "ECR repository lifecycle policy added to every repo Lambda creates."
  default     = <<-DEFAULT
    {
      "rules": [
        {
          "rulePriority": 10,
          "description": "Only keep 20 most recent untagged images.",
          "selection": {
            "tagStatus": "untagged",
            "countType": "imageCountMoreThan",
            "countNumber": 20
          },
          "action": {
            "type": "expire"
          }
        }
      ]
    }
  DEFAULT
  nullable    = true
}

variable "repo_policy" {
  type        = string
  description = "ECR repository policy added to every repo Lambda creates."
  default     = null
  nullable    = true
}

variable "repo_tags" {
  type        = map(string)
  description = "ECR repo tags added to every repo Lambda creates."
  default     = {}
}

variable "repo_scan_on_push" {
  type        = bool
  description = "Toggles Scan on push on repos Lambda creates."
  default     = true
  nullable    = false
}
