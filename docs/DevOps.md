# DevOps & Infrastructure

![Docker](https://img.shields.io/badge/docker-2496ED.svg?style=for-the-badge&\&logo=docker\&logoColor=white)
![NGINX](https://img.shields.io/badge/nginx-009639.svg?style=for-the-badge&\&logo=nginx\&logoColor=white)
![Terraform](https://img.shields.io/badge/terraform-7B42BC.svg?style=for-the-badge&\&logo=terraform\&logoColor=white)
![AWS](https://img.shields.io/badge/aws-232F3E.svg?style=for-the-badge&\&logo=amazon-aws&color=FF9900\&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/github%20actions-2088FF.svg?style=for-the-badge&\&logo=github-actions\&logoColor=white)


---

## Purpose

This document describes the **DevOps, infrastructure, and operational design** of ShortLink. It focuses on how the system is built, deployed, and operated across environments, without diving into application-level logic.

The goal is reproducibility, scalability, and safe automation.

---

## Environment Strategy

ShortLink is designed to run consistently across three environments:

* **Local** – Developer workstation using Docker Compose
* **Staging** – Cloud environment for validation
* **Production** – Hardened AWS deployment

Each environment shares the same container images and configuration patterns, differing only in scale and credentials.

---

## Containerization

### Docker

All services are containerized to ensure parity between local and production environments.

* Application runs as a Node.js container
* Redis runs as an isolated service container
* NGINX runs as an edge container

Images are built with minimal base layers to reduce attack surface and startup time.

---

### Docker Compose

Docker Compose is used for:

* Local development
* Service orchestration
* Network isolation
* Environment variable injection

This allows the full stack to be brought up with a single command while closely mirroring production topology.

---
## Redis: Local vs Production

ShortLink relies on Redis for URL mappings, rate limiting, token usage,
and request counters. Redis is a shared state dependency and must be
centralized in production.

### Local Development

For local development, Redis runs as a Docker container defined in
`docker-compose.local.yml`. This allows developers to run the full system
without external cloud dependencies.

```yaml
redis:
  image: redis:7-alpine
  container_name: shortlink_redis
  restart: always
  volumes:
    - redis_data:/data

volumes:
  redis_data:
```
---

## Traffic Entry & Networking

ShortLink uses a layered traffic entry model designed for security,
scalability, and fault isolation.

### AWS Application Load Balancer (ALB)

The AWS Application Load Balancer is the **only internet-facing
component** of the system.

Responsibilities:
- Terminates HTTPS (TLS)
- Performs health checks
- Distributes traffic across EC2 instances in an Auto Scaling Group
- Prevents direct internet access to application instances

### NGINX (Instance-Level Reverse Proxy)

NGINX runs **inside each EC2 instance**, in front of the Node.js
application.

Responsibilities:
- Acts as a security and isolation layer
- Normalizes incoming requests
- Proxies traffic to the application server



## Infrastructure as Code

### Terraform

![AWS Infrastructure Topology](images/aws-infrastructure.png)

All cloud infrastructure is provisioned using Terraform.

Key principles:

* Declarative infrastructure definitions
* Version-controlled changes
* Idempotent deployments
* Environment-specific variables

Terraform manages compute resources, networking, and supporting services on AWS.

---

### AWS

AWS is used as the cloud provider for production deployments.

The infrastructure is designed to:

* Scale horizontally
* Isolate services using networking boundaries
* Support rolling updates
* Recover cleanly from failures

Exact resource definitions are intentionally abstracted in this document and covered at the configuration level.

---

## CI/CD Pipeline

### GitHub Actions

![CI/CD Pipeline](images/cicd-pipeline.png)

GitHub Actions is used to automate:

* Code validation
* Container image builds
* Registry publishing
* Deployment triggers

Pipelines are designed to fail fast and surface errors early, before infrastructure or runtime impact occurs.

---

## Secrets & Configuration

* Secrets are **never committed** to the repository
* Environment variables are injected at runtime
* Local development uses `.env` files
* Cloud environments rely on secure secret storage mechanisms

Configuration is treated as code but secrets are treated as runtime concerns.

---

## Observability & Monitoring

![Grafana](https://img.shields.io/badge/grafana-F46800.svg?style=for-the-badge&labelColor=101418&logo=grafana)
![Prometheus](https://img.shields.io/badge/prometheus-E6522C.svg?style=for-the-badge\&logo=prometheus\&logoColor=white)
![Amazon CloudWatch](https://img.shields.io/badge/amazon%20cloudwatch-FF4F8B.svg?style=for-the-badge\&logo=amazon-cloudwatch\&logoColor=white)

![Observability Flow](images/observability-flow.png)

ShortLink follows a layered observability model to ensure system health can be understood at every level, from infrastructure to application behavior.

### CloudWatch

CloudWatch is responsible for **infrastructure-level observability**:

* Compute and network health
* Load balancer metrics
* Resource saturation signals
* Native AWS alerting

It acts as the first line of defense against platform-level failures.

### Prometheus
![promethuus](/docs/images/prometheus.png)

Prometheus is used for **application-level metrics**:

* HTTP request rates and latencies
* Error ratios
* Rate limiting counters
* Internal service signals

Metrics are scraped from the application and stored in a time-series model optimized for analysis.

### Grafana
![grafana](/docs/images/grafana.png)

Grafana serves as the **visualization and analysis layer**:

* Aggregates metrics from Prometheus and CloudWatch
* Presents unified dashboards
* Enables fast human diagnosis

Grafana is intentionally read-focused, reinforcing separation between measurement and action.

---

## Operational Principles

* Immutable infrastructure
* Stateless application containers
* Externalized state (Redis)
* Observability through logs and metrics
* Rollback-first mindset

These principles ensure the system remains understandable under failure conditions.

---
---

## ☁️ The "Serverless vs. Containers" Strategy

While the primary goal of this project was to demonstrate **infrastructure-as-code** (Terraform/AWS), maintaining a $80/month cluster for a portfolio project is fiscally inefficient.

To solve this, I implemented a **Dual-Branch Strategy**:
1.  **`main` Branch (AWS):** The full enterprise-grade implementation with Docker, NGINX, and Auto Scaling. This serves as the "Proof of Concept" for large-scale deployments.
2.  **`Alt-deployment/Vercel` Branch (Serverless):** An adapted version of the codebase optimized for Vercel's edge network.

### Why this matters
This approach demonstrates the ability to:
* **Adapt Architecture:** Refactoring a stateful Node.js app to run in a stateless serverless environment.
* **Optimize Costs:** Reducing holding costs from ~$1,000/year to **$0/year** without sacrificing performance.
* **Manage Complexity:** Using Git branches to maintain two deployment targets from a shared codebase.

---

## 💰 Cloud Cost Analysis (AWS Production)

This architecture prioritizes **High Availability (HA)** and **Scalability**. Below is the monthly estimate for running this architecture in AWS (`ap-south-1` region).

| Resource | Spec | Est. Cost / Mo | Justification |
| :--- | :--- | :--- | :--- |
| **NAT Gateway** | Managed NAT | ~$33.00 | **Critical:** Allows private instances to fetch updates/packages securely. |
| **App Load Balancer** | ALB | ~$16.00 | **Critical:** Handles TLS termination and health checks. |
| **Compute (EC2)** | 2x `t3.micro` | ~$16.00 | Minimum 2 instances for redundancy (AZ failover). |
| **Cache (ElastiCache)** | `cache.t3.micro` | ~$12.00 | Managed Redis for shared state/sessions. |
| **DNS & Security** | **Cloudflare** | **$0.00** | **Optimization:** Replaces Route53 ($0.50/mo) & AWS WAF (Expensive) for free. |
| **Storage & Transfer** | EBS + Data Transfer | ~$5.00 | Logs, container images, and traffic out. |
| **Total** | | **~$82.00** | *Enterprise-grade baseline.* |

---

## 🔄 Architecture Evolution & Alternatives

During the development of ShortLink, several architectural approaches were implemented and evaluated. The code for these alternative patterns is preserved in [`terraform/alternatives/`](/terraform/alternatives) for reference.

### 1. Manual Load Balancing (vs. ALB)
* **Initial Approach:** A single EC2 instance running NGINX (`diy_lb.tf`) with a custom IAM role and S3 bucket (`s3_iam.tf`) to manage SSL certificates manually.
* **Decision to Change:** This setup required complex IAM permission management and manual certificate rotation. Migrating to an **AWS Application Load Balancer (ALB)** + **Cloudflare** offloaded all SSL/TLS complexity and provided native Auto Scaling integration.

### 2. Self-Hosted Redis (vs. ElastiCache)
* **Initial Approach:** Redis running directly on an EC2 instance as Centralized Redis (`redis.tf`).
* **Decision to Change:** Managing persistence, backups, and high availability for a stateful database distracted from feature development. Switching to **AWS ElastiCache** provided a fully managed, multi-AZ compatible datastore.

### 3. Route53 DNS (vs. Cloudflare)
* **Initial Approach:** Using AWS Route53 for DNS management (`dns.tf`).
* **Decision to Change:** Cloudflare was selected to replace Route53 to leverage its **Free Tier CDN** and **DDoS Protection**, reducing the monthly operational overhead by ~$15 (WAF + Hosted Zone costs).