# DevOps & Infrastructure

![Docker](https://img.shields.io/badge/docker-2496ED.svg?style=flat\&logo=docker\&logoColor=white)
![NGINX](https://img.shields.io/badge/nginx-009639.svg?style=flat\&logo=nginx\&logoColor=white)
![Terraform](https://img.shields.io/badge/terraform-7B42BC.svg?style=flat\&logo=terraform\&logoColor=white)
![AWS](https://img.shields.io/badge/aws-232F3E.svg?style=flat\&logo=amazon-aws\&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/github%20actions-2088FF.svg?style=flat\&logo=github-actions\&logoColor=white)

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

## Reverse Proxy & Networking

![High-Level Architecture](images/architecture-overview.png)

### NGINX

NGINX acts as the front-facing reverse proxy:

* Terminates incoming HTTP traffic
* Forwards requests to the Node.js service
* Handles basic request filtering and buffering
* Provides a single stable entry point

This design decouples external traffic concerns from application logic.

---

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

![Grafana](https://img.shields.io/badge/grafana-F46800.svg?style=flat\&logo=grafana\&logoColor=white)
![Prometheus](https://img.shields.io/badge/prometheus-E6522C.svg?style=flat\&logo=prometheus\&logoColor=white)
![Amazon CloudWatch](https://img.shields.io/badge/amazon%20cloudwatch-FF4F8B.svg?style=flat\&logo=amazon-cloudwatch\&logoColor=white)

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

Prometheus is used for **application-level metrics**:

* HTTP request rates and latencies
* Error ratios
* Rate limiting counters
* Internal service signals

Metrics are scraped from the application and stored in a time-series model optimized for analysis.

### Grafana

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
