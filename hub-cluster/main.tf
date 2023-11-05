resource "azurerm_resource_group" "hub-cluster" {
  name = var.hub_cluster_rg_name
  location = var.location
}

resource "azurerm_kubernetes_cluster" "hub-cluster" {
  name                = var.hub_cluster_name
  location            = azurerm_resource_group.hub-cluster.location
  resource_group_name = azurerm_resource_group.hub-cluster.name
  dns_prefix          = var.hub_cluster_name

  default_node_pool {
    name       = "hcnpool"
    node_count = 1
    vm_size    = var.hub_cluster_vm_size
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Development"
  }

  depends_on = [
    azurerm_resource_group.hub-cluster
  ]
}

resource "null_resource" "argocd_install" {
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = <<EOT
      az account set --subscription bfe66dee-22fe-4a78-9c89-4b6f49e70fa2
      az aks get-credentials --overwrite-existing --resource-group ${azurerm_resource_group.hub-cluster.name} --name ${azurerm_kubernetes_cluster.hub-cluster.name}
      kubectl create namespace argocd
      kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
      kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
    EOT
  }

  depends_on = [
    azurerm_kubernetes_cluster.hub-cluster
  ]
}

resource "null_resource" "argocd_ip" {
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = <<EOT
      kubectl get svc argocd-server -n argocd | awk -F' ' '{print $3}' | tail -1
    EOT
  }

  depends_on = [
    null_resource.argocd_install
  ]
}

data "external" "argocd_url" {
  program = ["bash", "-c", 
    <<EOT
      kubectl get svc argocd-server -n argocd | awk -F' ' 'BEGIN { format = "{\"ip\":\"%s\"}\n"} { printf format, $4 }' | tail -1
    EOT
    ]

  depends_on = [
    null_resource.argocd_install
  ]
}

data "external" "argocd_password" {
  program = ["bash", "-c", 
    <<EOT
      kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d | awk -F' ' 'BEGIN { format = "{\"password\":\"%s\"}\n"} { printf format, $0 }' | tail -1
    EOT
    ]

  depends_on = [
    data.external.argocd_url
  ]
}