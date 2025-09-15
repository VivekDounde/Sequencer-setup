# Arbitrum Sequencer HA Deployment on AWS EKS (Terraform)

This repository provisions a production-grade, highly-available, and cost-efficient Arbitrum Sequencer deployment on Amazon EKS using **Terraform**.

---

## 🚀 Features

* VPC across 3 Availability Zones
* EKS cluster with On-Demand (stateful) and Spot (stateless) node groups
* IAM OIDC provider for IRSA (pods assume IAM roles)
* ElastiCache Redis (Multi-AZ with automatic failover)
* KMS key + Secrets Manager for private keys
* Optional Helm release examples for Nitro / Relay deployment

---

## 📂 Repo Structure

```
terraform/
├─ main.tf
├─ versions.tf
├─ providers.tf
├─ variables.tf
├─ vpc.tf
├─ eks.tf
├─ elasticache.tf
├─ iam_irsa.tf
├─ secrets.tf
├─ helm.tf             # optional Helm release examples
├─ outputs.tf
└─ README.md           # this file
```

---

## 🛠️ Prerequisites

* AWS CLI v2 (`aws --version`)
* Terraform >= 1.4.0 (`terraform -version`)
* kubectl (`kubectl version --client`)
* helm (`helm version`)
* AWS account with sufficient permissions

> Ensure you have configured AWS CLI with credentials:

```bash
aws configure
```

---

## ⚙️ Deployment Steps

### 1. Initialize Terraform

```bash
cd terraform
terraform init
```

### 2. Plan Infrastructure

```bash
terraform plan -out plan.tfplan
```

### 3. Apply Infrastructure

```bash
terraform apply "plan.tfplan"
```

### 4. Configure kubeconfig for kubectl

```bash
aws eks update-kubeconfig --name $(terraform output -raw cluster_name) --region <your-region>

# verify cluster access
kubectl get nodes -o wide
```

### 5. Install External Secrets Operator

Used for syncing AWS Secrets Manager → Kubernetes secrets.

```bash
helm repo add external-secrets https://charts.external-secrets.io
helm repo update
helm install external-secrets external-secrets/external-secrets \
  -n external-secrets --create-namespace
```

### 6. Deploy Arbitrum Helm Charts

Add Offchain Labs charts and deploy sequencer, relays, batch-poster, etc.

```bash
helm repo add offchainlabs https://charts.arbitrum.io
helm repo update

# example
helm upgrade --install nitro offchainlabs/nitro -n arbitrum -f helm-values/nitro.values.yaml
```

---

## 🔑 Secrets Management

* Store all private keys (batch-poster, sequencer, staker, etc) in **AWS Secrets Manager**.
* Use IRSA + External Secrets to mount them into pods as Kubernetes secrets.

Example:

```bash
aws secretsmanager create-secret --name "arbitrum/batch-poster/key" --secret-string "<PRIVATE_KEY>"
```

Then create an `ExternalSecret` manifest to sync into Kubernetes.

---

## 📡 Outputs

Run after `terraform apply`:

```bash
terraform output
```

Example outputs:

* `kubeconfig_command` — update kubeconfig for kubectl
* `redis_primary_endpoint` — ElastiCache Redis endpoint for sequencer coordinator
* `oidc_provider_arn` — ARN for IRSA role trust

---

## 🧪 Verification

* Check nodes:

```bash
kubectl get nodes -o wide
```

* Check pods:

```bash
kubectl get pods -A
```

* Test RPC endpoint:

```bash
curl -X POST -H "Content-Type: application/json" \
--data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
http://<rpc-endpoint>
```

---

## 💸 Cost Optimization

* Run sequencer/full nodes on On-Demand
* Run relays/stateless services on Spot
* Use gp3 volumes instead of gp2
* Enable cluster autoscaler

---

## 🛑 Destroy Infrastructure

To tear down everything:

```bash
terraform destroy
```

---

## 📚 References

* [Terraform AWS EKS Module](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws)
* [Terraform AWS ElastiCache Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_replication_group)
* [Arbitrum Node Docs](https://docs.arbitrum.io/run-arbitrum-node)
* [Offchain Labs Helm Charts](https://github.com/OffchainLabs/arbitrum-helm)
