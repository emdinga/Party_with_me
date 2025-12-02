# ------------------------------
# CloudFront Distribution
# ------------------------------
resource "aws_cloudfront_distribution" "frontend_cf" {
  enabled             = true
  default_root_object = "index.html"

  # S3 frontend origin (existing)
  origin {
    domain_name = "${aws_s3_bucket.frontend_bucket.bucket}.s3.amazonaws.com"
    origin_id   = "s3-party-with-me-frontend"
  }

  # New API Gateway origin
  origin {
    domain_name = "<api-gateway-id>.execute-api.us-east-1.amazonaws.com"
    origin_id   = "APIGatewayOrigin"

    custom_origin_config {
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  # Default cache behavior for S3
  default_cache_behavior {
    target_origin_id       = "s3-party-with-me-frontend"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  # Ordered cache behavior for /login
  ordered_cache_behavior {
    path_pattern           = "/login*"
    target_origin_id       = "APIGatewayOrigin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods  = ["GET", "HEAD"]

    cache_policy_id         = "658327ea-f89d-4fab-a63d-7e88639e58f6" # CACHING_DISABLED
    origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3" # ALL_VIEWER
  }

  # Ordered cache behavior for /signup
  ordered_cache_behavior {
    path_pattern           = "/signup*"
    target_origin_id       = "APIGatewayOrigin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods  = ["GET", "HEAD"]

    cache_policy_id         = "658327ea-f89d-4fab-a63d-7e88639e58f6" # CACHING_DISABLED
    origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3" # ALL_VIEWER
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