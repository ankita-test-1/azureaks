#!/usr/bin/env bash
# =============================================================================
# Runs AS ROOT ON AN AKS NODE, delivered by `az vmss run-command invoke`.
#
# The pipeline prepends two variables before this body:
#   KUBECONFIG_B64='...'   # admin kubeconfig, fetched via ARM on the runner
#   VALUES_B64='...'       # cilium-values.yaml
#
# Why this works when nothing else does:
#   - Run Command reaches the VM through the Azure control plane and the VM
#     agent. No SSH, no inbound NSG rule, no pod scheduling.
#   - The node is NotReady (no CNI) but the VM is fully booted and kubelet is
#     already talking to the API server - so the network path exists.
#   - The node is in the VNet, so the privatelink FQDN resolves.
# =============================================================================
set -euo pipefail
WORK=/opt/cilium-bootstrap
mkdir -p "$WORK" && cd "$WORK"
echo "$KUBECONFIG_B64" | base64 -d > kubeconfig
echo "$VALUES_B64"     | base64 -d > cilium-values.yaml
chmod 600 kubeconfig
export KUBECONFIG="$WORK/kubeconfig"
# --- tooling (AKS nodes ship neither kubectl nor helm in PATH) --------------
# Needs egress to dl.k8s.io and get.helm.sh. You have a NAT Gateway, so fine.
KUBECTL_VER="v1.34.0"
HELM_VER="v3.16.2"
if ! command -v kubectl >/dev/null; then
  curl -sSLo /usr/local/bin/kubectl \
    "https://dl.k8s.io/release/${KUBECTL_VER}/bin/linux/amd64/kubectl"
  chmod +x /usr/local/bin/kubectl
fi
if ! command -v helm >/dev/null; then
  curl -sSL "https://get.helm.sh/helm-${HELM_VER}-linux-amd64.tar.gz" | tar xz -C /tmp
  install /tmp/linux-amd64/helm /usr/local/bin/helm
fi
# --- prove we can reach the private API server before doing anything --------
echo "== API server reachability =="
kubectl version --request-timeout=30s
kubectl get nodes -o wide || true   # expect NotReady - that is the point
# --- Gateway API CRDs (must precede gatewayAPI.enabled=true) ----------------
GWAPI="v1.6.1"
BASE="https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/${GWAPI}/config/crd/standard"
for r in gatewayclasses gateways httproutes grpcroutes \
         referencegrants tlsroutes backendtlspolicies; do
  kubectl apply -f "${BASE}/gateway.networking.k8s.io_${r}.yaml"
done
# --- Cilium -----------------------------------------------------------------
helm repo add cilium https://helm.cilium.io/
helm repo update
helm upgrade --install cilium cilium/cilium \
  --version 1.20.2 \
  --namespace kube-system \
  -f "$WORK/cilium-values.yaml" \
  --wait --timeout 10m
# --- verify -----------------------------------------------------------------
kubectl -n kube-system rollout status ds/cilium --timeout=5m
kubectl wait --for=condition=Ready nodes --all --timeout=5m
kubectl get gatewayclass cilium
# Do not leave an admin kubeconfig sitting on a node.
shred -u "$WORK/kubeconfig" 2>/dev/null || rm -f "$WORK/kubeconfig"
echo "DONE: Cilium installed, nodes Ready, GatewayClass registered."
