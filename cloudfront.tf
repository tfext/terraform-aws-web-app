data "aws_acm_certificate" "app" {
  provider = aws.east

  domain   = "*.${local.root_domain}"
  statuses = ["ISSUED"]
}

resource "aws_cloudfront_origin_access_control" "app" {
  name                              = var.name
  description                       = "Managed by Terraform"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_function" "single_page_handler" {
  name    = "${var.name}_spa_routing"
  runtime = "cloudfront-js-2.0"
  comment = "CloudFront Function for SPA routing"
  publish = true
  code    = replace(file("${path.module}/single_page_handler.js"), "\n", "\r\n")
}

resource "aws_cloudfront_distribution" "app" {
  aliases             = [var.domain]
  default_root_object = "index.html"
  enabled             = true
  http_version        = "http2"
  is_ipv6_enabled     = false
  price_class         = "PriceClass_100"
  wait_for_deployment = true

  origin {
    domain_name              = aws_s3_bucket.app.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.app.id
    origin_id                = "default"
    origin_path              = "/app"
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    default_ttl            = 900
    max_ttl                = 900
    min_ttl                = 300
    target_origin_id       = "default"
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = true

      cookies {
        forward = "none"
      }
    }

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.single_page_handler.arn
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = data.aws_acm_certificate.app.arn
    minimum_protocol_version = "TLSv1"
    ssl_support_method       = "sni-only"
  }
}
