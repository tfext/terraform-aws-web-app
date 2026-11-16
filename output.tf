output "distribution_id" {
  value       = aws_cloudfront_distribution.app.id
  description = "CloudFront distribution ID"
}

output "distribution_domain_name" {
  value       = aws_cloudfront_distribution.app.domain_name
  description = "CloudFront distribution domain name, the target for a CNAME when DNS is hosted elsewhere"
}

output "distribution_arn" {
  value       = aws_cloudfront_distribution.app.arn
  description = "CloudFront distribution ARN"
}

output "bucket" {
  value       = aws_s3_bucket.app.id
  description = "Name of the S3 bucket that stores the application files"
}
