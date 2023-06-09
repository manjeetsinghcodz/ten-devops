###Create the CloudWatch resource to be attached with lambaFunction
resource "aws_cloudwatch_log_group" "log_group" {
  name = "/aws/lamba/${aws_lambda_function.function.function_name}"
  retention_in_days = 1
  lifecycle {
    prevent_destroy = false
  }
}
resource "aws_iam_policy" "log_policy" {
  name = "${var.resource_name}-log"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Action : [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect : "Allow",
        Resource : "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy_role" {
  role   = aws_iam_role.function_role.id
  policy_arn = aws_iam_policy.log_policy.arn
}