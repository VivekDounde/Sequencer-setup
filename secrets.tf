resource "aws_kms_key" "secrets" {
  description = "KMS key for encrypting Arbitrum secrets"
  deletion_window_in_days = 30
  enable_key_rotation = true
}

resource "aws_secretsmanager_secret" "batch_poster_key" {
  name = "${var.cluster_name}/batch-poster-key"
  kms_key_id = aws_kms_key.secrets.id
  description = "Private key for Arbitrum batch poster"
}

resource "aws_secretsmanager_secret_version" "batch_poster_key_value" {
  secret_id     = aws_secretsmanager_secret.batch_poster_key.id
  secret_string = var.batch_poster_private_key  # provide via tfvars or env
}
