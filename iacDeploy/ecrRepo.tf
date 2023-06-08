####Create ECR
data "aws_ecr_authorization_token" "token" {} ### Get authorisation data for ECR

resource "aws_ecr_repository" "ecr" {
  force_delete = true
  name = "${var.resource_name}"
  image_tag_mutability = "IMMUTABLE" ### Disable committing with the same tag number
  image_scanning_configuration {
    scan_on_push = false
  }
}

### Apply a policy that will keep only the last images just to not pay for the storage price
resource "aws_ecr_lifecycle_policy" "ecr_policy" {
  repository = aws_ecr_repository.ecr.name
  policy     = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep last 1 images",
            "selection": {
                "tagStatus": "tagged",
                "tagPrefixList": ["v"],
                "countType": "imageCountMoreThan",
                "countNumber": 1
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}
####Push a docker image to be used only during the creation of a function, as lambda package_type image required an image during deployment
resource "null_resource" "ecr_image" {
  depends_on = [aws_ecr_repository.ecr]
  provisioner "local-exec" {
    interpreter = ["/bin/bash" ,"-c"]
    command = "echo ${data.aws_ecr_authorization_token.token.password} | sudo docker login --username ${data.aws_ecr_authorization_token.token.user_name} --password-stdin ${data.aws_ecr_authorization_token.token.proxy_endpoint} && sudo docker pull hello-world:latest && sudo docker tag hello-world:latest ${aws_ecr_repository.ecr.repository_url}:latest && sudo docker push ${aws_ecr_repository.ecr.repository_url}:latest"
  }
}