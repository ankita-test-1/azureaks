set -euo pipefail
GWAPI_VERSION="v1.6.1"BASE="https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/${GWAPI_VERSION}/config/crd/standard"
for r in gatewayclasses gateways httproutes grpcroutes referencegrants tlsroutes backendtlspolicies; do  kubectl apply -f "${BASE}/gateway.networking.k8s.io_${r}.yaml"done
