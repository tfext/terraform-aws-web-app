data "aws_route53_zone" "root" {
  count = var.manage_dns ? 1 : 0

  name         = local.root_domain
  private_zone = false
}

resource "aws_route53_record" "app" {
  count = var.manage_dns ? 1 : 0

  zone_id = data.aws_route53_zone.root[0].zone_id
  name    = var.domain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.app.domain_name
    zone_id                = aws_cloudfront_distribution.app.hosted_zone_id
    evaluate_target_health = false
  }
}
