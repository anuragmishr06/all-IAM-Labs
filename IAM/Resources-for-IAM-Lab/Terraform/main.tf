provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "production_server" {
  ami           = "ami-08a52ddb321b32a8c" # Replace with the actual AMI ID
  instance_type = "t2.micro"
  tags = {
    Name = "production-server"
  }
}

resource "aws_instance" "staging_server" {
  ami           = "ami-08a52ddb321b32a8c" # Replace with the actual AMI ID
  instance_type = "t2.micro"
  tags = {
    Name = "staging-server"
  }
}

resource "random_string" "random_name" {
  length  = 10
  special = false
  upper   = false
}

resource "aws_s3_bucket" "seasides_prod_bucket" {
  bucket = "seasides-prod-${random_string.random_name.result}"
  acl    = "private"
}

resource "aws_s3_bucket" "seasides_dev_bucket" {
  bucket = "seasides-dev-${random_string.random_name.result}"
  acl    = "private"
}

resource "aws_s3_bucket" "seasides_staging_bucket" {
  bucket = "seasides-staging-${random_string.random_name.result}"
  acl    = "private"
}

resource "aws_s3_bucket_object" "prod_db_secret" {
  bucket = aws_s3_bucket.seasides_prod_bucket.id
  key    = "prod-db-secret.txt"
  content = <<-EOT
    username: mysqladmin
    password: r0OtkiLl3r@132#$
  EOT
}

resource "aws_s3_bucket_object" "dev_blog" {
  bucket = aws_s3_bucket.seasides_dev_bucket.id
  key    = "aws-blog.html"
  content = <<-EOT
<!DOCTYPE html>
<!-- Rest of the HTML content as described -->
  EOT
}

resource "aws_s3_bucket_object" "staging_model" {
  bucket = aws_s3_bucket.seasides_staging_bucket.id
  key    = "shared-responsibility-model.html"
  content = <<-EOT
<!DOCTYPE html>
<!-- Rest of the HTML content as described -->
  EOT
}

resource "aws_db_instance" "prod_mysql_db" {
  allocated_storage    = 20
  storage_type        = "gp2"
  engine              = "mysql"
  engine_version      = "5.7"
  instance_class      = "db.t2.micro"
  identifier          = "seasides-corp-prod-db" # Updated database name
  username            = "admin"
  password            = "MySuperSecretPassword"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot = true

  tags = {
    Name = "seasides-corp-prod-db", # Updated database name in tags
    Environment = "Production",
    Application = "MyApp",
    // Add other relevant tags as needed
  }
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_lambda_function" "prod_lambda_instance" {
  function_name    = "prod-lambda-instance"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "index.handler"
  runtime          = "nodejs14.x"
  filename         = data.archive_file.lambda_function_code.output_path
  source_code_hash = data.archive_file.lambda_function_code.output_base64sha256
}

data "archive_file" "lambda_function_code" {
  type        = "zip"
  source_file = "lambda_function_payload.js" # Update with actual filename
  output_path = "lambda_function_payload.zip"
}

output "lambda_function_payload" {
  value = data.archive_file.lambda_function_code.output_path
}
