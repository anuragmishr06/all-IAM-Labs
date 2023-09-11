provider "aws" {
    region = "us-east-1"
}

resource "aws_iam_user" "seasides_victim_05" {
  name = "seasides-victim-05"
}

resource "aws_iam_policy" "seasides_victimuser05_policy" {
  name        = "seasides-victimuser-05policy"
  description = "Policy for seasides-victim-05 user"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "iam:ListAttachedUserPolicies",
          "iam:GetPolicy",
          "iam:GetPolicyVersion",
          "iam:CreatePolicyVersion",
        ],
        Resource = "*",
      },
    ],
  })
}

resource "aws_iam_user_policy_attachment" "seasides_victim05_attachment" {
  user       = aws_iam_user.seasides_victim_05.name
  policy_arn = aws_iam_policy.seasides_victimuser05_policy.arn
}

resource "aws_iam_access_key" "seasides_victim_05_access_keys" {
  user = aws_iam_user.seasides_victim_05.name
}

output "seasides_victim_05_access_keys" {
  value = {
    UserName  = aws_iam_user.seasides_victim_05.name,
    AccessKey = aws_iam_access_key.seasides_victim_05_access_keys.id,
    SecretKey = aws_iam_access_key.seasides_victim_05_access_keys.secret,
    ARN       = aws_iam_user.seasides_victim_05.arn,
  }
  sensitive = true
}
