#!/usr/bin/env bash
# =============================================================================
# Gateway API CRDs - must be applied BEFORE Cilium is installed with
# gatewayAPI.enabled=true. Cilium does not ship these.
#
# The CRD version is coupled to the Cilium minor version:
#   Cilium 1.20.x  ->  Gateway API v1.6.1
# =============================================================================
set -euo pipefail
GWAPI_VERSION="v1.6.1"
BASE="https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/${GWAPI_VERSION}/config/crd/standard"
for r in gatewayclasses gateways httproutes grpcroutes \
         referencegrants tlsroutes backendtlspolicies; do
  kubectl apply -f "${BASE}/gateway.networking.k8s.io_${r}.yaml"
done
# Verify Cilium registered its own GatewayClass (ACCEPTED must be True):
#   kubectl get gatewayclass
#   NAME     CONTROLLER                     ACCEPTED
#   cilium   io.cilium/gateway-controller   True
