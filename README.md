# Production-Ready AWS VPC Infrastructure with Terraform

[![Terraform](https://img.shields.io/badge/Terraform-%22%3E%3D1.5.0%22-623CE4?logo=terraform)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-VPC-FF9900?logo=amazon-aws)](https://aws.amazon.com/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A production-grade, highly available, and cost-optimized AWS Virtual Private Cloud (VPC) Terraform module. This repository demonstrates Infrastructure as Code (IaC) best practices, featuring dynamic multi-AZ subnets, automated route management, EKS-ready tagging, and configurable NAT Gateway modes.

---

## Architecture Overview

The module provisions an isolated network environment across multiple Availability Zones (`us-east-1a` and `us-east-1b`) with a public/private subnet topology:

- **VPC CIDR:** `10.0.0.0/16`
- **Public Subnets:** `10.0.1.0/24`, `10.0.2.0/24` (Internet-facing via IGW)
- **Private Subnets:** `10.0.10.0/24`, `10.0.20.0/24` (Outbound access via NAT Gateway)
- **High Availability & Cost Control:** Single NAT Gateway deployment mode for development environments to reduce costs, with multi-AZ NAT support for production.
- **Kubernetes Integration:** Standardized subnet tagging for AWS EKS Load Balancers (`kubernetes.io/role/elb` and `kubernetes.io/role/internal-elb`).

---

## AWS Deployment Verification

The following verification snapshots confirm successful infrastructure provisioning from the AWS Management Console:

### 1. VPC Resource Map & Network Topology

Visual representation of the created VPC (`dev-vpc`), subnets, route tables, and connected network gateways.

![VPC Resource Map](docs/screenshots/vpc-resource-map.png)

### 2. Multi-AZ Subnet Allocation

Provisioned subnets correctly distributed across `us-east-1a` and `us-east-1b`.

![Subnets Overview](docs/screenshots/subnets-list.png)

### 3. Internet Gateway Configuration

Internet Gateway attached to `dev-vpc` with default system tags (`Environment`, `Owner`, `Project`, `ManagedBy`).

![Internet Gateway Details](docs/screenshots/internet-gateway.png)

### 4. NAT Gateway Provisioning

Cost-optimized single NAT Gateway attached to a public subnet for private subnet egress traffic.

![NAT Gateway Details](docs/screenshots/nat-gateway.png)

---

## Project Structure

```text
aws-vpc-terraform/
├── docs/
│   └── screenshots/
│       ├── vpc-resource-map.png
│       ├── subnets-list.png
│       ├── internet-gateway.png
│       └── nat-gateway.png
├── modules/
│   └── vpc/
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
├── environments/
│   └── dev/
│       ├── main.tf
│       ├── outputs.tf
│       ├── providers.tf
│       ├── terraform.tfvars
│       └── variables.tf
└── README.md
```

---

## Getting Started

### Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.5.0
- [AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- An AWS account with permissions to create VPC networking resources
- AWS credentials configured locally

Configure AWS CLI:

```bash
aws configure
```

---

## Deployment Steps

### 1. Clone the Repository

```bash
git clone https://github.com/ChaninduImanjith/aws-vpc-terraform.git
cd aws-vpc-terraform/environments/dev
```

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Format & Validate Code

```bash
terraform fmt -recursive
terraform validate
```

### 4. Preview Execution Plan

```bash
terraform plan
```

### 5. Apply Configuration

```bash
terraform apply -auto-approve
```

### 6. Destroy Resources (Cleanup)

```bash
terraform destroy -auto-approve
```

---

## Inputs & Outputs

### Module Inputs

| **Name** | **Description** | **Type** | **Default** | **Required** |
| --- | --- | --- | --- | --- |
| `vpc_cidr` | Base CIDR block for the VPC | `string` | `"10.0.0.0/16"` | Yes |
| `public_subnet_cidrs` | Public subnet CIDR list | `list(string)` | `["10.0.1.0/24", "10.0.2.0/24"]` | Yes |
| `private_subnet_cidrs` | Private subnet CIDR list | `list(string)` | `["10.0.10.0/24", "10.0.20.0/24"]` | Yes |
| `enable_single_nat_gateway` | Enable single NAT Gateway to reduce non-production cost | `bool` | `true` | No |

### Module Outputs

| **Name** | **Description** |
| --- | --- |
| `vpc_id` | ID of the created AWS VPC |
| `public_subnet_ids` | List of public subnet IDs |
| `private_subnet_ids` | List of private subnet IDs |
| `nat_gateway_ips` | Allocated public Elastic IPs for NAT Gateways |

---

## Key Features

- Multi-AZ VPC architecture
- Public and private subnet separation
- Internet Gateway for public subnet internet access
- NAT Gateway for private subnet outbound connectivity
- Configurable single NAT Gateway mode for development environments
- Support for multi-AZ NAT Gateway deployments in production
- Automated route table configuration
- AWS EKS-ready subnet tags
- Reusable Terraform VPC module
- Environment-specific Terraform configuration
- Consistent resource tagging
- Terraform formatting and validation workflow

---

## Security & Networking Notes

- Public subnets route internet-bound traffic through the Internet Gateway.
- Private subnets do not receive direct inbound internet access.
- Private subnet outbound internet traffic is routed through a NAT Gateway.
- NAT Gateway placement should be considered carefully for high availability and cross-AZ data transfer costs.
- Production environments can use one NAT Gateway per Availability Zone for higher availability.

---

## Screenshots

AWS verification images should be stored inside:

```text
docs/screenshots/
```

Expected files:

```text
vpc-resource-map.png
subnets-list.png
internet-gateway.png
nat-gateway.png
```

If these filenames are changed, update the image paths in this README.

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
