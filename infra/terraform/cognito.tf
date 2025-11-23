# Cognito User Pool
# -------------------------------
resource "aws_cognito_user_pool" "party_with_me_users" {
  name = "party-with-me-userpool"

  # Optional: email verification
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
    name                = "username"
    attribute_data_type = "String"
    required            = true
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

# -------------------------------
# Cognito User Pool Client
# -------------------------------
resource "aws_cognito_user_pool_client" "party_with_me_client" {
  name            = "party-with-me-client"
  user_pool_id    = aws_cognito_user_pool.party_with_me_users.id
  generate_secret = false

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]

  prevent_user_existence_errors = "ENABLED"

  # Optional: configure callback URLs for hosted UI
  callback_urls = [
    "http://party-with-me-frontend.s3-website-us-east-1.amazonaws.com/members_home.html",
  ]

  logout_urls = [
    "http://party-with-me-frontend.s3-website-us-east-1.amazonaws.com/index.html",
  ]
}

# -------------------------------
# Optional: Cognito Domain
# -------------------------------
resource "aws_cognito_user_pool_domain" "party_with_me_domain" {
  domain       = "party-with-me-auth" # must be globally unique
  user_pool_id = aws_cognito_user_pool.party_with_me_users.id
}