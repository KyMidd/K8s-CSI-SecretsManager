# create secret
resource "aws_secretsmanager_secret" "app1-super-secret-json" {
  name = "app1-super-secret-json"
}

# create secret map
variable "secret-json" {
  default = {
    app_password   = "cindy1"
    smtp_password  = "cindy2"
    other_password = "cindy3"
  }
  type = map(string)
}

# Populate secret
resource "aws_secretsmanager_secret_version" "app1-super-secret-json" {
  secret_id     = aws_secretsmanager_secret.app1-super-secret-json.id
  secret_string = jsonencode(var.secret-json)
}
