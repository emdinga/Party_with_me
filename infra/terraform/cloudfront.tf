# ------------------------------
# S3 Bucket (Static Website)
# ------------------------------
resource "aws_s3_bucket" "frontend_bucket" {
  bucket = "party-with-me-frontend"

  tags = {
    Name = "Party With Me Frontend"
  }
}

# Enable static website hosting
resource "aws_s3_bucket_website_configuration" "frontend_website" {
  bucket = aws_s3_bucket.frontend_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "404.html"
  }
}

# Allow public read (required for static website hosting)
resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.frontend_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "PublicReadGetObject"
      Effect    = "Allow"
      Principal = "*"
      Action    = ["s3:GetObject"]
      Resource  = "${aws_s3_bucket.frontend_bucket.arn}/*"
    }]
  })
}

# ------------------------------
# CloudFront Distribution
# ------------------------------
resource "aws_cloudfront_distribution" "frontend_cf" {
  enabled             = true
  default_root_object = "index.html"

  origin {
    domain_name = aws_s3_bucket.frontend_bucket.bucket_regional_domain_name
    origin_id   = "s3-party-with-me-frontend"
  }

  default_cache_behavior {
    target_origin_id = "s3-party-with-me-frontend"
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