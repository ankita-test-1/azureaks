output "cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "cluster_id" {
  value = azurerm_kubernetes_cluster.aks.id
}

# Only reachable from inside the VNet (or something peered/VPN'd to it) —
# that's the whole point of a private cluster.
output "cluster_private_fqdn" {
  value = azurerm_kubernetes_cluster.aks.private_fqdn
}

output "kube_config" {
  description = "Structured kube_config for feeding the root kubernetes/helm providers"
  value = {
    host                   = azurerm_kubernetes_cluster.aks.kube_config[0].host
    client_certificate     = azurerm_kubernetes_cluster.aks.kube_config[0].client_certificate
    client_key             = azurerm_kubernetes_cluster.aks.kube_config[0].client_key
    cluster_ca_certificate = azurerm_kubernetes_cluster.aks.kube_config[0].cluster_ca_certificate
  }
  sensitive = true
}

output "kube_config_raw" {
  description = "Full kubeconfig YAML, e.g. for pulling down manually from a bastion"
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}

output "node_resource_group" {
  description = "Auto-created RG holding the VMSS/disks/LBs — Azure's analog to EKS's implicit ASG/ENI resources"
  value       = azurerm_kubernetes_cluster.aks.node_resource_group
}

output "oidc_issuer_url" {
  value = azurerm_kubernetes_cluster.aks.oidc_issuer_url
}
