# =============================================================================
# Disable the AKS-managed kube-proxy DaemonSet.
#
# WHY: Cilium Gateway API requires kubeProxyReplacement=true. Running Cilium's
# eBPF kube-proxy replacement alongside a live kube-proxy DaemonSet means two
# independent NAT implementations that are unaware of each other - Cilium's
# docs call this out explicitly as a source of broken connections.
#
# Disabling kube-proxy is ONLY permitted on BYO CNI clusters. On an Azure CNI
# cluster the API rejects it with KubeProxyConfigDisabledBYOCNIOnly.
#
# PREREQS (one-time, per subscription):
#   az extension add --name aks-preview
#   az feature register --namespace Microsoft.ContainerService \
#       --name KubeProxyConfigurationPreview
#   az provider register -n Microsoft.ContainerService
#
# This is still a preview surface. If you are not comfortable taking a preview
# dependency in prod, see the fallback at the bottom of this file.
# =============================================================================

resource "azapi_update_resource" "disable_kube_proxy" {
  type        = "Microsoft.ContainerService/managedClusters@2025-09-02-preview"
  resource_id = azurerm_kubernetes_cluster.aks.id

  body = {
    properties = {
      networkProfile = {
        kubeProxyConfig = {
          enabled = false
        }
      }
    }
  }

  depends_on = [azurerm_kubernetes_cluster.aks]
}

# Tell azurerm to stop fighting azapi over this field.
# Add to the azurerm_kubernetes_cluster lifecycle block if you see perpetual diffs:
#   ignore_changes = [network_profile[0].kube_proxy_config]

# -----------------------------------------------------------------------------
# FALLBACK - if you cannot register the preview feature
# -----------------------------------------------------------------------------
# Leave kube-proxy running and install Cilium with:
#     kubeProxyReplacement: false
#     nodePort.enabled: true
#     l7Proxy: true
# Cilium's Gateway API docs accept nodePort.enabled=true in place of full
# kube-proxy replacement. You lose the eBPF service load-balancing benefits and
# you keep the iptables ruleset, but the Gateway API controller works and you
# avoid the dual-NAT hazard entirely. This is the lower-risk path for a first
# production rollout.
# -----------------------------------------------------------------------------
