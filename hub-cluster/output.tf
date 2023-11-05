output "resource_group_name" {
  value = azurerm_resource_group.hub-cluster.name
}

output "client_certificate" {
  value     = azurerm_kubernetes_cluster.hub-cluster.kube_config.0.client_certificate
  sensitive = true
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.hub-cluster.kube_config_raw
  sensitive = true
}

output "hub_cluster_name" {
  value = azurerm_kubernetes_cluster.hub-cluster.name
}

output "argocd_url" {
  value = "http://${data.external.argocd_url.result.ip}/"
}

output "argocd_password" {
  value = data.external.argocd_password.result.password
}