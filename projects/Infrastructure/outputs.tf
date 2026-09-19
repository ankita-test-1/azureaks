output "cluster_name" {
  value = module.aks.cluster_name
}

# No public endpoint any more — this is a private cluster, reachable only
# from inside the VNet.
output "cluster_private_fqdn" {
  value = module.aks.cluster_private_fqdn
}

output "acr_login_server" {
  value = module.acr.acr_login_server
}

output "acr_urls" {
  value = module.acr.repository_urls
}
