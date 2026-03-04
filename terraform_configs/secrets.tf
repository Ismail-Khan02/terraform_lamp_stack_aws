resource "aws_secretsmanager_secret" "db_credentials" {
  name        = "db_credentials"
  description = "Database credentials for the LAMP stack"

  tags = {
    Name        = "db-credentials"
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret_version" "db_password_val" {
  secret_id     = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    password = var.db_password
  })    
}
