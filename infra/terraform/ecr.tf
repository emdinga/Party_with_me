#------------------
adding ECR 
#-----------------

resource "aws_ecr_repository" "auth_service" {
  name                 = "party-with-me-auth"
  image_tag_mutability = "MUTABLE"
}