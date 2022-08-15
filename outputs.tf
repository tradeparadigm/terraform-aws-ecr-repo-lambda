output "arn" {
  value       = aws_lambda_function.this.arn
  description = "The Lambda ARN."
}

output "invoke_arn" {
  value       = aws_lambda_function.this.invoke_arn
  description = "The Lambda API Gateway invoke ARN."
}
