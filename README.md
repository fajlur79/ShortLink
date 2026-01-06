# ShortLink

![Node.js](https://img.shields.io/badge/node.js-339933.svg?style=flat\&logo=node.js\&logoColor=white)
![Express.js](https://img.shields.io/badge/express.js-%23404d59.svg?style=flat\&logo=express\&logoColor=white)
![Redis](https://img.shields.io/badge/redis-DC382D.svg?style=flat\&logo=redis\&logoColor=white)
![Docker](https://img.shields.io/badge/docker-2496ED.svg?style=flat\&logo=docker\&logoColor=white)
![NGINX](https://img.shields.io/badge/nginx-009639.svg?style=flat\&logo=nginx\&logoColor=white)
![Terraform](https://img.shields.io/badge/terraform-7B42BC.svg?style=flat\&logo=terraform\&logoColor=white)
![AWS](https://img.shields.io/badge/aws-232F3E.svg?style=flat\&logo=amazon-aws\&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/github%20actions-2088FF.svg?style=flat\&logo=github-actions\&logoColor=white)

---

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
2. **NGINX** acts as the edge reverse proxy
3. **Express (Node.js)** handles API logic and redirects
4. **Redis** provides low-latency storage for URL mappings and rate limits
5. **Docker** packages services consistently across environments
6. **AWS (via Terraform)** provisions production infrastructure

This separation ensures each layer can scale, fail, or evolve independently.

---

## Tech Stack

### Application Layer

![Node.js](https://img.shields.io/badge/node.js-339933.svg?style=flat\&logo=node.js\&logoColor=white)
![Express.js](https://img.shields.io/badge/express.js-%23404d59.svg?style=flat\&logo=express\&logoColor=white)

* Node.js runtime
* Express.js web framework

### Caching & Data

![Redis](https://img.shields.io/badge/redis-DC382D.svg?style=flat\&logo=redis\&logoColor=white)

* Redis for URL storage and rate limiting

### Containerization & Networking

![Docker](https://img.shields.io/badge/docker-2496ED.svg?style=flat\&logo=docker\&logoColor=white)
![NGINX](https://img.shields.io/badge/nginx-009639.svg?style=flat\&logo=nginx\&logoColor=white)

* Docker for reproducible environments
* NGINX as reverse proxy and traffic gatekeeper

### Infrastructure & Automation

![Terraform](https://img.shields.io/badge/terraform-7B42BC.svg?style=flat\&logo=terraform\&logoColor=white)
![AWS](https://img.shields.io/badge/aws-232F3E.svg?style=flat\&logo=amazon-aws\&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/github%20actions-2088FF.svg?style=flat\&logo=github-actions\&logoColor=white)

* Terraform for Infrastructure-as-Code
* AWS as the cloud provider
* GitHub Actions for CI/CD pipelines

---

## Quick Start

### Local Development (Node.js)

```bash
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

```bash
# Build and start all services
docker compose up --build
```

This starts:

* Express application
* Redis
* NGINX reverse proxy

All services are wired together using Docker networking.

---

## Documentation Index

Detailed documentation is split by responsibility:

* [DevOps & Infrastructure](docs/Devops.md)
* [How It Works](docs/HowItWorks.md)
* [API Documentation](docs/API.md)
* [Contributing Guide](CONTRIBUTING.md)
* [Security Policy](SECURITY.md)

---

## License

This project is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for details.

