provider "aws" {
  region = "us-east-1"
}

resource "aws_iam_user" "seasides_victim_02" {
  name = "seasides-victim-02"
}

resource "aws_iam_policy" "seasides_victimuser_policy" {
  name        = "seasides-victimuser"
  description = "Policy for seasides-victim user"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "iam:ListAttachedUserPolicies",
          "iam:GetPolicy",
          "iam:GetPolicyVersion",
          "iam:ListAttachedGroupPolicies",
          "iam:ListGroups",
          "iam:AddUserToGroup",
          "iam:GetGroupPolicy",
          "iam:GetGroup",
        ],
        Resource = "*",
      },
    ],
  })
}

resource "aws_iam_user_policy_attachment" "seasides_victimuser_attachment" {
  user       = aws_iam_user.seasides_victim_02.name
  policy_arn = aws_iam_policy.seasides_victimuser_policy.arn
}

resource "aws_iam_user" "s3_prod_user" {
  name = "s3-prod-user"
}

resource "aws_iam_user" "lambda_dev_user" {
  name = "lambda-dev-user"
}

resource "aws_iam_group" "seasides_group_01" {
  name = "seasides-group-01"
}

resource "aws_iam_group" "seasides_group_02" {
  name = "seasides-group-02"
}

resource "aws_iam_group_membership" "lambda_dev_user_membership" {
  name  = "lambda-dev-user-membership"
  group = aws_iam_group.seasides_group_01.name
  users = [aws_iam_user.lambda_dev_user.name]
}

resource "aws_iam_group_membership" "s3_prod_user_membership" {
  name  = "s3-prod-user-membership"
  group = aws_iam_group.seasides_group_02.name
  users = [aws_iam_user.s3_prod_user.name]
}

resource "aws_iam_policy" "dev_group_policy" {
  name        = "dev-group-policy"
  description = "Policy for lambda-dev-user group"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "lambda:ListFunctions",
        ],
        Resource = "*",
      },
    ],
  })
}

resource "aws_iam_policy_attachment" "dev_group_policy_attachment" {
  name       = "dev-group-policy-attachment"
  policy_arn = aws_iam_policy.dev_group_policy.arn
  groups     = [aws_iam_group.seasides_group_01.name]
}

resource "aws_iam_policy" "prod_group_access" {
  name        = "prod-group-access"
  description = "Policy for s3-prod-user group"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "s3:Get*",
          "s3:List*",
        ],
        Resource = [
          "arn:aws:s3:::*",
          "arn:aws:s3:::*/*",
        ],
      },
      {
        Effect   = "Allow",
        Action   = "iam:PutGroupPolicy",
        Resource = "*",
      },
    ],
  })
}

resource "aws_iam_policy_attachment" "prod_group_access_attachment" {
  name       = "prod-group-access-attachment"
  policy_arn = aws_iam_policy.prod_group_access.arn
  groups     = [aws_iam_group.seasides_group_02.name]
  depends_on = [aws_iam_group_membership.s3_prod_user_membership] # Ensure the group membership is removed first
}

resource "aws_iam_access_key" "seasides_victim_access_keys" {
  user = aws_iam_user.seasides_victim_02.name
}

output "seasides_victim_access_keys" {
  value = {
    UserName  = aws_iam_user.seasides_victim_02.name,
    AccessKey = aws_iam_access_key.seasides_victim_access_keys.id,
    SecretKey = aws_iam_access_key.seasides_victim_access_keys.secret,
    arn       = aws_iam_user.seasides_victim_02.arn,
  }
  sensitive = true
}
