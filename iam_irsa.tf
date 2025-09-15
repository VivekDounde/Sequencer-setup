# create a policy to allow reading specified Secrets Manager ARNs (replace with actual ARNs or use wildcard carefully)
data "aws_iam_policy_document" "external_secrets" {
  statement {
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]
    resources = ["*"] # Restrict in prod to specific secrets ARNs
  }
}

resource "aws_iam_policy" "external_secrets_policy" {
  name   = "${var.cluster_name}-external-secrets-policy"
  policy = data.aws_iam_policy_document.external_secrets.json
}

resource "aws_iam_role" "external_secrets_irsa" {
  name = "${var.cluster_name}-extsecrets-irsa"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = module.eks.oidc_provider_arn
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
          "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub" = "system:serviceaccount:${var.chart_namespace}:external-secrets"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_ext" {
  role       = aws_iam_role.external_secrets_irsa.name
  policy_arn = aws_iam_policy.external_secrets_policy.arn
}
