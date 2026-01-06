<h1 align=center>ShortLink</h1>

<div align=center>

![Node.js](https://img.shields.io/badge/node.js-339933.svg?style=for-the-badge\&logo=node.js\&logoColor=white)
![Express.js](https://img.shields.io/badge/express.js-%23404d59.svg?style=for-the-badge\&logo=express\&logoColor=white)
![Redis](https://img.shields.io/badge/redis-DC382D.svg?style=for-the-badge\&logo=redis\&logoColor=white)
![Docker](https://img.shields.io/badge/docker-2496ED.svg?style=for-the-badge\&logo=docker\&logoColor=white)
![NGINX](https://img.shields.io/badge/nginx-009639.svg?style=for-the-badge\&logo=nginx\&logoColor=white)
![Terraform](https://img.shields.io/badge/terraform-7B42BC.svg?style=for-the-badge\&logo=terraform\&logoColor=white)
![AWS](https://img.shields.io/badge/aws-232F3E.svg?style=for-the-badge\&logo=amazon-aws\&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/github%20actions-2088FF.svg?style=for-the-badge\&logo=github-actions\&logoColor=white)
</div>

## Overview

**ShortLink** is a production-grade URL shortener designed with scalability, reliability, and operational discipline in mind. It demonstrates how a seemingly simple service can be built using real-world backend and infrastructure practices: caching, reverse proxies, containerization, CI/CD, and cloud provisioning.

The project is intentionally opinionated. It favors clarity, debuggability, and production readiness over minimalism, making it suitable both as a reference architecture and as a foundation for real deployments.

---

## Core Features

* URL shortening with deterministic or generated aliases
* High-performance redirect handling using Redis caching
* Rate limiting and abuse protection
* Reverse proxy setup with NGINX
* Fully containerized local and production environments
* Infrastructure-as-Code for cloud provisioning
* CI/CD-ready repository structure

---

## High-Level Architecture

At a high level, ShortLink follows a layered architecture:

1. **Client** sends requests to shorten or resolve URLs
2. **AWS Application Load Balancer (ALB)** handles incoming HTTPS traffic
3. **NGINX** runs as an instance-level reverse proxy and security layer
4. **Express (Node.js)** handles API logic and redirects
5. **Redis** provides low-latency shared storage for URL mappings and rate limits
6. **Docker** packages services consistently across environments
7. **AWS (via Terraform)** provisions production infrastructure

This separation ensures each layer can scale, fail, or evolve independently.

---

## Tech Stack

### Application Layer

![Node.js](https://img.shields.io/badge/node.js-339933.svg?style=for-the-badge\&logo=node.js\&logoColor=white)
![Express.js](https://img.shields.io/badge/express.js-%23404d59.svg?style=for-the-badge\&logo=express\&logoColor=white)

* Node.js runtime
* Express.js web framework

### Caching & Data

![Redis](https://img.shields.io/badge/redis-DC382D.svg?style=for-the-badge\&logo=redis\&logoColor=white)

* Redis for URL storage and rate limiting

### Containerization & Networking

![Docker](https://img.shields.io/badge/docker-2496ED.svg?style=for-the-badge\&logo=docker\&logoColor=white)
![NGINX](https://img.shields.io/badge/nginx-009639.svg?style=for-the-badge\&logo=nginx\&logoColor=white)

* Docker for reproducible environments
* NGINX as reverse proxy and traffic gatekeeper

### Infrastructure & Automation

![Terraform](https://img.shields.io/badge/terraform-7B42BC.svg?style=for-the-badge\&logo=terraform\&logoColor=white)
![AWS](https://img.shields.io/badge/aws-232F3E.svg?style=for-the-badge\&logo=amazon-aws\&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/github%20actions-2088FF.svg?style=for-the-badge\&logo=github-actions\&logoColor=white)

* Terraform for Infrastructure-as-Code
* AWS as the cloud provider
* GitHub Actions for CI/CD pipelines

---

## Quick Start

### Local Development (Node.js)

```bash
# Clone the repo
git clone https://github.com/fajlur79/ShortLink.git && cd ShortLink
# Install dependencies
npm install

# Start Redis (must be running locally)
redis-server

# Start the application
npm run dev
```

The service will be available at `http://localhost:3000` by default.

---

### Docker (Recommended)

In [`docker-compose.yml`](docker-compose.yml) comment the cloudwatch logging part
```bash
# logging:
#       driver: awslogs
#       options:
#         awslogs-region: ap-south-1
#         awslogs-group: /ecs/shortlink
#         awslogs-create-group: "true"

```
```bash
# Build and start all services
docker compose up --build -d
```

This starts:

* Express application
* Redis
* NGINX reverse proxy

All services are wired together using Docker networking.


***Note on Redis***

For local development, Redis runs as a Docker container via
docker-compose to avoid external cloud dependencies.

In production, Redis is provided by AWS ElastiCache and does not
run on EC2 instances. All application instances connect to the
centralized Redis store using the REDIS_URL environment variable.

for more details [here](docs/DevOps.md#redis-local-vs-production)

---
## Documentation Index

Detailed documentation is split by responsibility:

* [DevOps & Infrastructure](docs/DevOps.md)
* [How It Works](docs/Workflow.md)
* [API Documentation](docs/API.md)
* [Contributing Guide](CONTRIBUTING.md)
* [Security Policy](SECURITY.md)

---

## License

This project is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for details.
---
## 👤 Author

**Fajlur**
- Email: fajlur939@proton.me
- GitHub: [@fajlur79](https://github.com/fajlur79)
- X(twitter): [@Fajlur](https://x.com/fajlur_)
