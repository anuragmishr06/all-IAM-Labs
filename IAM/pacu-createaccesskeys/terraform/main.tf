provider "aws" {
  region = "us-east-1"  # Use the appropriate AWS region
}

resource "aws_iam_user" "pacu_user" {
  name = "pacu"
}

resource "aws_iam_user" "sqs_read_user" {
  name = "sqs-read-user"
}

resource "aws_iam_user" "configurator_user" {
  name = "configurator"
}

resource "aws_iam_policy" "pacu_user_policy" {
  name        = "pacu-user-policy"
  description = "Policy for pacu user"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = [
        "iam:ListAttachedUserPolicies",
        "iam:GetPolicy",
        "iam:GetPolicyVersion",
        "iam:ListUsers",
        "iam:CreateAccessKey",
        "iam:GetUserPolicy",
        "iam:GetUser",
      ],
      Resource = "*",
    }],
  })
}

resource "aws_iam_policy" "sqs_read_user_policy" {
  name        = "sqs-read-user-policy"
  description = "Policy for sqs-read-user"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = [
        "sqs:GetQueueUrl",
        "sqs:ReceiveMessage",
        "sqs:ListQueues",
      ],
      Resource = "*",
    }],
  })
}

resource "aws_iam_policy" "configurator_policy" {
  name        = "configurator-policy"
  description = "Policy for configurator"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = "*",
      Resource = "*",
    }],
  })
}

resource "aws_iam_user_policy_attachment" "pacu_user_attachment" {
  user       = aws_iam_user.pacu_user.name
  policy_arn = aws_iam_policy.pacu_user_policy.arn
}

resource "aws_iam_user_policy_attachment" "sqs_read_user_attachment" {
  user       = aws_iam_user.sqs_read_user.name
  policy_arn = aws_iam_policy.sqs_read_user_policy.arn
}

resource "aws_iam_user_policy_attachment" "configurator_attachment" {
  user       = aws_iam_user.configurator_user.name
  policy_arn = aws_iam_policy.configurator_policy.arn
}

resource "aws_iam_access_key" "pacu_user_access_key" {
  user = aws_iam_user.pacu_user.name
}

output "pacu_user_access_key" {
  value = {
    UserName  = aws_iam_user.pacu_user.name,
    AccessKey = aws_iam_access_key.pacu_user_access_key.id,
    SecretKey = aws_iam_access_key.pacu_user_access_key.secret,
    arn       = aws_iam_user.pacu_user.arn,
  }
  sensitive = true
}
