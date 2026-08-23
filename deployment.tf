action "aws_cloudfront_create_invalidation" "app" {
  config {
    distribution_id = aws_cloudfront_distribution.app.id
    paths           = ["/*"]
  }
}

resource "terraform_data" "deployment" {
  input = local.deployment_hash

  lifecycle {
    action_trigger {
      events  = [before_create, before_update]
      actions = [action.aws_cloudfront_create_invalidation.app]
    }
  }

  depends_on = [aws_s3_object.dist_file]
}
