# DevOps + AIOps Series

> A full end-to-end DevOps project with AIOps integration — so you can connect the dots between how AI is helping automate DevOps tasks today.

This project runs a 7-service microservices application on a **private Azure Kubernetes Service (AKS) cluster**, using **Cilium** for networking and the **Kubernetes Gateway API** for ingress, delivered through GitOps with ArgoCD.

> **Note:** This repository was originally built for AWS EKS and has been migrated to Azure AKS. Some assets (e.g. the AIOps assistant) may still reference AWS services. See [Migration Notes](#migration-notes-eks--aks).

## Architecture Overview

```
Internet
   │
   ▼
Azure Public IP / Load Balancer
   │
   ▼
Gateway API (Gateway + HTTPRoute)          <-- replaces Ingress / ALB
   │
   ▼
Private AKS Cluster (API server on private endpoint)
 ├── Cilium (CNI, network policies, eBPF dataplane)
 ├── boutique-microservices (7 services)
 ├── ArgoCD (GitOps)
 └── Prometheus + Grafana
   │
   ▼
Azure ACR (private, via Private Endpoint) · Azure Key Vault · Log Analytics
```

Key design points:

- **Private cluster** – the Kubernetes API server is exposed only via a private endpoint inside your VNet. `kubectl`, ArgoCD and CI runners must reach the VNet (jump box, Bastion, VPN/ExpressRoute, self-hosted runner, or `az aks command invoke`).
- **Cilium** – used as the CNI and dataplane (Azure CNI Powered by Cilium), providing eBPF-based networking, `CiliumNetworkPolicy` / `NetworkPolicy` enforcement, and optional Hubble observability.
- **Gateway API** – `GatewayClass`, `Gateway` and `HTTPRoute` resources replace the AWS ALB / Ingress setup for north-south traffic.

## Repository Structure

```
DevOps-Practice-Guide/
├── docs/
│   ├── part1-system-design.md     # System design foundations (Part 1)
│   ├── part2-workflow.md          # Full workflow with AIOps (Part 2)
│   └── claude-setup.md            # Claude Code + MCP server setup
├── projects/
│   ├── README.md                  # Private AKS deployment guide (Part 3)
│   ├── boutique-microservices/    # The application (7 services)
│   ├── Infrastructure/            # Terraform: VNet, private AKS, ACR, Cilium
│   └── aiops-assistant/           # AIOps agent — Kira (Part 4)
├── gitops/
│   ├── argo-cd.yml                # ArgoCD Application manifest
│   ├── kustomization.yml          # Kustomize entry point
│   └── k8s/                       # Kubernetes manifests (incl. Gateway API resources)
└── .github/
    └── workflows/ci.yml           # GitHub Actions CI pipeline
```

---

## Prerequisites

- An Azure subscription with permission to create resource groups, VNets, AKS, ACR and role assignments
- Azure CLI (`az`) 2.50+ and `kubectl`
- Terraform 1.5+
- Network access to the private cluster (VPN, jump box, Azure Bastion, or a self-hosted runner in the VNet)
- Gateway API CRDs installed (see `projects/README.md`)

---

## Series Structure

### Claude Setup — AI Assistant Configuration

[`docs/claude-setup.md`](https://github.com/ankita-test-1/azureaks/blob/main/docs/claude-setup.md)

Before jumping into the project, this step walks through how Claude Code is configured as the AI assistant throughout this series.

Three things are set up:

**CLAUDE.md** — a project instruction file at the repo root that Claude reads automatically at the start of every session. It puts Claude in safe execution mode: explain what you're about to do and why before taking any action. This is important when working with live Azure infrastructure where silent commands can have real consequences.

**MCP Servers** — background processes that extend Claude's built-in capabilities. Servers are configured in `~/.claude/settings.json`:

| Server                | What it unlocks                                                         |
| --------------------- | ----------------------------------------------------------------------- |
| Azure MCP server      | Query Azure resources, AKS clusters, ACR, Monitor and Log Analytics     |
| Kubernetes MCP server | Inspect pods, stream logs, apply manifests, check Gateway/HTTPRoute status |
| Terraform MCP server  | Run Terraform commands, search provider docs, run security scans        |

> Update this table to match the MCP servers you actually have configured.

**Skills** — domain-specific knowledge packs that improve how Claude reasons about certain topics. The `terraform-skill` is installed, giving Claude deeper context for Terraform module patterns, testing strategies, security scanning, and CI/CD workflows specific to infrastructure-as-code.

---

### Part 1 — System Design Foundations

[`docs/part1-system-design.md`](https://github.com/ankita-test-1/azureaks/blob/main/docs/part1-system-design.md)

We start with system design concepts specifically for cloud and DevOps. This is important whether you're a beginner, intermediate, or senior engineer — because companies don't choose tools randomly. They think about architecture patterns, deployment strategies, scalability, reliability, and cost tradeoffs.

We cover 12 core system design pillars used in modern DevOps architectures, and connect each one directly to something running in this project.

---

### Part 2 — Understanding the Workflow

[`docs/part2-workflow.md`](https://github.com/ankita-test-1/azureaks/blob/main/docs/part2-workflow.md)

Before writing any code or deployment configs, you need to understand how the entire system flows:

- What services we're building and how they communicate
- How the pipeline works
- How code moves from developer → CI → deployment → production → AIOps

This is where the full picture comes together — including how AI fits into the workflow.

---

### Part 3 — DevOps Project Implementation

[`projects/README.md`](https://github.com/ankita-test-1/azureaks/blob/main/projects/README.md)

Then we actually build the project. You'll see:

- Docker containers and Docker Compose
- A **private AKS cluster** provisioned with Terraform (VNet, subnets, private endpoint, ACR)
- **Cilium** as the CNI with network policies and optional Hubble observability
- **Gateway API** (`Gateway` + `HTTPRoute`) for routing external traffic to the services
- CI/CD pipelines with GitHub Actions
- GitOps automation with ArgoCD
- Observability with Prometheus and Grafana

---

### Part 4 — AIOps Integration

[`projects/aiops-assistant/README.md`](https://github.com/ankita-test-1/azureaks/blob/main/projects/aiops-assistant/README.md)

Finally, we explore how AI helps with:

- Monitoring and anomaly detection
- Log analysis at scale
- Incident response automation
- DevOps troubleshooting

Because modern DevOps is no longer just automation — it's **automation + intelligence**.

---

## Migration Notes (EKS → AKS)

| Area              | Before (AWS)                      | Now (Azure)                                      |
| ----------------- | --------------------------------- | ------------------------------------------------ |
| Cluster           | EKS                               | Private AKS                                      |
| CNI / networking  | AWS VPC CNI                       | Cilium (Azure CNI Powered by Cilium)             |
| Ingress / routing | ALB Ingress Controller            | Kubernetes Gateway API (`Gateway`, `HTTPRoute`)  |
| Container registry| ECR                               | Azure Container Registry (private endpoint)      |
| Secrets           | AWS Secrets Manager / IRSA        | Azure Key Vault + Workload Identity              |
| Pod identity      | IRSA                              | Microsoft Entra Workload Identity                |
| Logs              | AWS Fluent Bit → CloudWatch       | Fluent Bit / Azure Monitor → Log Analytics       |
| Terraform provider| `aws`                             | `azurerm`                                        |

> Adjust any row that does not match your implementation.


## Tech Stack

| Layer           | Technology                                          |
| --------------- | --------------------------------------------------- |
| Application     | React, Node.js, PostgreSQL                          |
| Containers      | Docker, Docker Compose                              |
| Orchestration   | Kubernetes (Azure AKS, private cluster)             |
| Networking      | Cilium (CNI + network policies)                     |
| Ingress         | Kubernetes Gateway API                              |
| Infrastructure  | Terraform (azurerm)                                 |
| Registry        | Azure Container Registry                            |
| CI/CD           | GitHub Actions                                      |
| GitOps          | ArgoCD + Kustomize                                  |
| Monitoring      | Prometheus + Grafana                                |
| Log Forwarding  | Fluent Bit → Azure Log Analytics                    |
| AIOps           | Kira agent (update if still on AWS Bedrock)         |
| AI Assistant    | Claude Code + MCP Servers                           |
