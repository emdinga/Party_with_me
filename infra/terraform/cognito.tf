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

  # DO NOT DEFINE username schema!
  # Cognito username is built-in. Do not create a custom attribute.

  schema {
    name                = "email"
    attribute_data_type = "String"
    required            = true
  }

  admin_create_user_config {
    allow_admin_create_user_only = false
  }
}