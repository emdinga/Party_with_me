resource "aws_route53_zone" "main" {
  name = "partywith.me"
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "www"
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.frontend_cf.domain_name
    zone_id                = aws_cloudfront_distribution.frontend_cf.hosted_zone_id
    evaluate_target_health = true
  }
}
