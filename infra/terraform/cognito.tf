resource "aws_cognito_user_pool" "party_with_me_users" {
  name = "party-with-me-userpool"

  auto_verified_attributes = ["email"]

  password_policy {
    minimum_length    = 8
    require_uppercase = true
    require_lowercase = true
    require_numbers   = true
    require_symbols   = false
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  schema {
    name                = "email"
    attribute_data_type = "String"
    required            = true
  }

  admin_create_user_config {
    allow_admin_create_user_only = false
  }
}

# Cognito User Pool Client
resource "aws_cognito_user_pool_client" "party_with_me_client" {
  name         = "party-with-me-client"
  user_pool_id = aws_cognito_user_pool.party_with_me_users.id

  # Public clients (web, SPA) should NOT have secrets
  generate_secret = false

  # Allow common auth flows
  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
  ]

  # Prevent user enumeration vulnerabilities
  prevent_user_existence_errors = "ENABLED"

  # MUST match exactly your actual frontend URL(s)
  callback_urls = [
    ""https://${aws_cloudfront_distribution.frontend_cf.domain_name}/members_home.html",
  ]

  logout_urls = [
    "https://${aws_cloudfront_distribution.frontend_cf.domain_name}/index.html",
  ]

  supported_identity_providers = ["COGNITO"]
}