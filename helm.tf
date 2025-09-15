resource "helm_release" "nitro" {
  name       = "nitro"
  repository = "https://charts.arbitrum.io"
  chart      = "nitro"
  namespace  = var.chart_namespace
  create_namespace = true

  values = [
    file("${path.module}/helm-values/nitro.values.yaml")
  ]

  depends_on = [module.eks]
}
