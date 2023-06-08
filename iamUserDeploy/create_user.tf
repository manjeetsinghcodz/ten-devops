####Create users and Assign required permissions
#
resource "aws_iam_user" "user" {
  force_destroy = true
  count = "${length(var.username)}"
  name = "${var.username[count.index]}"
}

resource "aws_iam_user_policy_attachment" "policy_iac" {
  depends_on = [ aws_iam_user.user ]
  user  = "ten-mse-iac"
  count = "${length(var.arn_policy_iac)}"
  policy_arn = "${element(var.arn_policy_iac,count.index)}"
}

resource "aws_iam_user_policy_attachment" "policy_cicd" {
  depends_on = [ aws_iam_user.user ]
  user  = "ten-mse-cicd"
  count = "${length(var.arn_policy_cicd)}"
  policy_arn = "${element(var.arn_policy_cicd,count.index)}"
}

####Do not out secret on terminal or github workflow runner
/*
resource "aws_iam_access_key" "access_keys" {
  count = "${length(var.username)}"
  user = "${var.username[count.index]}"
}
output "aws_iam_smtp_password_v4" {
  value = [
    aws_iam_access_key.access_key_iac.ses_smtp_password_v4,
    aws_iam_access_key.access_key_cicd.ses_smtp_password_v4
  ]
  value = [
    for users in aws_iam_access_key.access_keys : users.ses_smtp_password_v4
  ]
  sensitive = true
}
*/