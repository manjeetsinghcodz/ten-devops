###Variables for IAM username and Policy
variable "username" {
  description = "List of users to be created"
  type = list(string)
  default = [
    "ten-mse-iac",
  ]
}
variable "arn_policy_iac" {
  description = "Assign IAC policies to user to perform IAC tasks"
  type = list
  default = [
    "arn:aws:iam::aws:policy/AdministratorAccess",
  ]
}
variable "arn_policy_cicd" {
  description = "Assign CI policies to user to perform CI tasks"
  type = list
  default = [
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess",
    "arn:aws:iam::976201004822:policy/AssumePolicy",
    "arn:aws:iam::aws:policy/AWSLambda_FullAccess",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]
}
