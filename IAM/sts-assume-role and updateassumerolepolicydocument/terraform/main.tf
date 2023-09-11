provider "aws" {
  region = "us-east-1" # Change this to your desired AWS region
}

# Step 1: Create engineer-user-policy
resource "aws_iam_policy" "engineer_user_policy" {
  name        = "engineer-user-policy"
  description = "Policy for engineer user"
  policy      = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = [
        "iam:ListAttachedUserPolicies",
        "iam:GetPolicy",
        "iam:GetPolicyVersion",
        "iam:ListUsers",
        "iam:GetUserPolicy",
        "iam:GetUser",
        "iam:ListRoles",
        "iam:GetRole",
        "iam:GetRolePolicy",
        "iam:ListAttachedRolePolicies",
        "iam:ListUserPolicies"
      ],
      Resource = ["*"]
    }]
  })
}

# Step 2: Create admin-role-policy
resource "aws_iam_policy" "admin_role_policy" {
  name        = "admin-role-policy"
  description = "Policy for admin role"
  policy      = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = "*",
      Resource = "*"
    }]
  })
}

# Step 3: Create victim-role-policy
resource "aws_iam_policy" "victim_role_policy" {
  name        = "victim-role-policy"
  description = "Policy for victim role"
  policy      = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Action   = ["iam:UpdateAssumeRolePolicy", "sts:AssumeRole"],
        Effect   = "Allow",
        Resource = ["*"]
      }
    ]
  })
}

# Step 4: Create IAM user engineer
resource "aws_iam_user" "engineer_user" {
  name = "engineer"
}

# Step 5: Attach engineer-user-policy to engineer user
resource "aws_iam_user_policy_attachment" "engineer_policy_attachment" {
  user       = aws_iam_user.engineer_user.name
  policy_arn = aws_iam_policy.engineer_user_policy.arn
}

# Step 6: Create inline user policy for engineer user
resource "aws_iam_user_policy" "sts_assume_role_inline_policy" {
  name       = "sts-assume-role-inline-policy"
  user       = aws_iam_user.engineer_user.name
  policy     = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = "sts:AssumeRole",
      Resource = ["*"]
    }]
  })
}

# Step 7: Create IAM user iam-moderator
resource "aws_iam_user" "iam_moderator_user" {
  name = "iam-moderator"
}

# Step 8: Create IAM role admin-role
resource "aws_iam_role" "admin_role" {
  name = "admin-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = { AWS = aws_iam_user.iam_moderator_user.arn },
        Action    = "sts:AssumeRole",
      }
    ]
  })
}

# Step 9: Attach admin-role-policy to admin-role
resource "aws_iam_policy_attachment" "admin_role_policy_attachment" {
  name       = "admin-role-policy-attachment"
  policy_arn = aws_iam_policy.admin_role_policy.arn
  roles      = [aws_iam_role.admin_role.name]
}

# Step 10: Create iam-moderator-assume-admin-role policy
resource "aws_iam_policy" "iam_moderator_assume_admin_role_policy" {
  name        = "iam-moderator-assume-admin-role"
  description = "Policy to assume admin role"
  policy      = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "sts:AssumeRole",
        Resource = aws_iam_role.admin_role.arn,
      }
    ]
  })
}

# Step 11: Attach iam-moderator-assume-admin-role policy to iam-moderator user
resource "aws_iam_user_policy_attachment" "iam_moderator_assume_admin_role_attachment" {
  user       = aws_iam_user.iam_moderator_user.name
  policy_arn = aws_iam_policy.iam_moderator_assume_admin_role_policy.arn
}

# Step 12: Create IAM role victim-role
resource "aws_iam_role" "victim_role" {
  name = "victim-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = { AWS = aws_iam_user.engineer_user.arn },
        Action    = "sts:AssumeRole",
      }
    ]
  })
}

# Step 13: Attach victim-role-policy to victim-role
resource "aws_iam_policy_attachment" "victim_role_policy_attachment" {
  name       = "victim-role-policy-attachment"
  policy_arn = aws_iam_policy.victim_role_policy.arn
  roles      = [aws_iam_role.victim_role.name]
}

# Step 14: Create access keys for the engineer user
resource "aws_iam_access_key" "engineer_access_key" {
  user = aws_iam_user.engineer_user.name
}

output "engineer_access_key" {
  value = {
    UserName  = aws_iam_user.engineer_user.name,
    AccessKey = aws_iam_access_key.engineer_access_key.id,
    SecretKey = aws_iam_access_key.engineer_access_key.secret,
    arn       = aws_iam_user.engineer_user.arn,
  }
  sensitive = true
}
