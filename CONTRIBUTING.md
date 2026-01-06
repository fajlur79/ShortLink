# Contributing

Thank you for considering contributing to **ShortLink**. This document outlines how to propose changes, report issues, and submit contributions in a way that keeps the project reliable, reviewable, and production-ready.

---

## Scope & Principles

* Contributions should improve correctness, clarity, performance, security, or operability
* Keep changes focused and minimal
* Prefer explicit behavior over clever abstractions
* Documentation and tests are first-class contributions

---

## Getting Started

### Prerequisites

* Node.js (current LTS recommended)
* Redis (local or containerized)
* Docker & Docker Compose (recommended)

### Local Setup

```bash
npm install
redis-server
npm run dev
```

Or using Docker:

```bash
docker compose up --build
```

Ensure the application starts without errors before making changes.

---

## Development Workflow

1. **Fork the repository**
2. **Create a feature branch**

   ```bash
   git checkout -b feature/short-description
   ```
3. **Make your changes**
4. **Run tests and linters**
5. **Commit with a clear message**
6. **Open a pull request**

Keep pull requests small and focused. Large changes should be discussed in an issue first.

---

## Coding Standards

* Use clear, descriptive variable and function names
* Avoid unnecessary abstractions
* Keep modules single-purpose
* Prefer explicit error handling
* Do not introduce breaking API changes without discussion

### JavaScript / Node.js

* Follow modern ES module syntax
* Avoid global state
* Treat configuration as external input
* Handle async errors explicitly

---

## Testing

All changes should be covered by tests when applicable.

Run the test suite:

```bash
npm test
```

Tests are written using Jest and Supertest.

* New features should include new tests
* Bug fixes should include regression tests
* Tests should be deterministic and isolated

---

## Documentation

If your change affects behavior, configuration, or usage:

* Update the relevant documentation file
* Keep README.md high-level
* Put detailed behavior in `docs/`

Documentation changes are reviewed with the same rigor as code.

---

## Infrastructure Changes

Changes involving:

* Docker
* NGINX
* Terraform
* CI/CD workflows

must be:

* Clearly documented
* Backward-compatible where possible
* Reviewed carefully for security and cost implications

Avoid introducing provider-specific assumptions unless necessary.

---

## Commit Messages

Use clear, imperative commit messages:

* `add rate limit for token generation`
* `fix redis connection retry logic`
* `update api documentation`

Avoid vague messages like `fix stuff` or `update code`.

---

## Pull Request Checklist

Before submitting a PR, ensure:

* [ ] Code builds and tests pass
* [ ] No secrets or credentials are committed
* [ ] Documentation is updated if needed
* [ ] Changes are scoped and intentional

---

## Reporting Issues

When reporting a bug, include:

* Expected behavior
* Actual behavior
* Steps to reproduce
* Environment details (Node.js version, OS, Docker, etc.)

Clear reports lead to faster fixes.

---

## Security Issues

If you discover a security vulnerability:

* **Do not** open a public issue
* Follow the instructions in [SECURITY.md](SECURITY.md)

Responsible disclosure helps keep users safe.

---

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for helping improve ShortLink.
