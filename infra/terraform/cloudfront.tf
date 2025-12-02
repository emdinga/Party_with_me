resource "aws_cloudfront_distribution" "frontend_cf" {
  enabled             = true
  default_root_object = "index.html"

  # S3 ORIGIN
  origin {
    domain_name = "${aws_s3_bucket.frontend_bucket.bucket}.s3.amazonaws.com"
    origin_id   = "s3-party-with-me-frontend"

    s3_origin_config {
      origin_access_identity = ""
    }
  }

  # API ORIGIN
  origin {
    domain_name = "2og2qwei66.execute-api.us-east-1.amazonaws.com"
    origin_id   = "APIGatewayOrigin"

    origin_path = "/prod"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  # DEFAULT BEHAVIOR → S3
  default_cache_behavior {
    target_origin_id       = "s3-party-with-me-frontend"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    # Must REMOVE forwarded_values entirely
    cache_policy_id          = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3"
  }

  # API BEHAVIOR
  ordered_cache_behavior {
    path_pattern           = "/api/*"
    target_origin_id       = "APIGatewayOrigin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods  = ["GET", "HEAD"]

    cache_policy_id          = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name = "Party With Me CloudFront"
  }
}