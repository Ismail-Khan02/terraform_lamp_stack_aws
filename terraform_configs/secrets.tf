resource "aws_secretsmanager_secret" "db_credentials" {
  name        = "lamp/db_password"
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
