output "acr_id" {
  value = azurerm_container_registry.this.id
}

output "acr_login_server" {
  value = azurerm_container_registry.this.login_server
}

# Same shape as the old ECR output, so root outputs.tf keeps working for now
output "repository_urls" {
  value = {
    for repo in var.repositories :
    repo => "${azurerm_container_registry.this.login_server}/${repo}"
  }
}
