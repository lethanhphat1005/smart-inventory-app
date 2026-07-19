resource "aws_secretsmanager_secret" "lamba" {
  name = "${var.project_name}-secrets"

  tags = merge(var.tags, {
    Name = "${var.project_name}-secrets"
  })
}

resource "aws_secretsmanager_secret_version" "lamba" {
  secret_id = aws_secretsmanager_secret.lamba.id
  secret_string = jsonencode({
    DATABASE_URL              = ""
    SUPABASE_ANON_KEY         = ""
    SUPABASE_SERVICE_ROLE_KEY = ""
    GROQ_API_KEY              = ""
  })
}
