# ===============================
# CloudFront Distribution
# ===============================

resource "aws_cloudfront_distribution" "frontend_cf" {
  enabled             = true
  default_root_object = "index.html"

  # ----------------------------------------
  # ORIGIN: Frontend S3 Bucket
  # ----------------------------------------
  origin {
    domain_name = "${aws_s3_bucket.frontend_bucket.bucket}.s3.amazonaws.com"
    origin_id   = "S3FrontendOrigin"

    s3_origin_config {
      origin_access_identity = ""
    }
  }

  # ----------------------------------------
  # ORIGIN: Backend API via NLB
  # ----------------------------------------
  origin {
    domain_name = aws_lb.internal_nlb.dns_name
    origin_id   = "NLBOrigin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  # ----------------------------------------
  # DEFAULT BEHAVIOR → S3
  # ----------------------------------------
  default_cache_behavior {
    target_origin_id       = "S3FrontendOrigin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"

  }

  # ----------------------------------------
  # BEHAVIOR: API Traffic → NLB
  # ----------------------------------------
  ordered_cache_behavior {
    path_pattern           = "/api/*"
    target_origin_id       = "NLBOrigin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods  = ["GET", "HEAD"]

    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"

    # For APIs, this is correct → allow forwarding headers/body
    origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3"
  }

  # ----------------------------------------
  # GEOGRAPHIC RESTRICTIONS
  # ----------------------------------------
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # ----------------------------------------
  # SSL CERTIFICATE
  # ----------------------------------------
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name = "Party With Me CloudFront"
  }
}