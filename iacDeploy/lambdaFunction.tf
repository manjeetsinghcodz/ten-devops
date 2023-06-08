####Deploy Lambda function with a dummy image
resource "aws_lambda_function" "function" {
  depends_on = [null_resource.ecr_image, aws_ecr_repository.ecr]
  function_name = "${var.resource_name}"
  role          = aws_iam_role.function_role.arn ### Role containing AssumeRole action that we created below
  package_type  = "Image"
  image_uri = "${aws_ecr_repository.ecr.repository_url}:${var.img_tag}"
}

####Allow Invokation permissions to the function
resource "aws_lambda_permission" "allow_api" {
  statement_id  = "AllowAPIgatewayInvokation"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.function.function_name
  principal     = "apigateway.amazonaws.com"
}
####Create IAM role with permission AssumeRole
resource "aws_iam_role" "function_role" {
  name = "${var.resource_name}"

  assume_role_policy = jsonencode({
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}