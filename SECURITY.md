# Security Policy

The security of **ShortLink** is taken seriously. This document outlines supported versions, reporting procedures, and security practices followed by the project.

---

## Supported Versions

Security updates are provided for the following versions:

| Version        | Supported |
| -------------- | --------- |
| `main`         | ✅ Yes     |
| Older releases | ❌ No      |

Only the latest version on the default branch receives security fixes.

---

## Reporting a Vulnerability

If you discover a security vulnerability, please report it responsibly.

**Do not open a public GitHub issue.**

Instead:

1. Email the maintainer directly with details of the issue
2. Include clear steps to reproduce, potential impact, and any relevant logs
3. Allow reasonable time for investigation and remediation before public disclosure

Contact:

```
fajlur939@proton.me
```

---

## Disclosure Process

Once a vulnerability is reported:

* The issue will be acknowledged within a reasonable timeframe
* A fix will be developed and reviewed
* A patch will be released as soon as possible
* Public disclosure will occur after users have had time to update

---

## Security Practices

ShortLink follows these baseline security practices:

* No secrets or credentials are committed to the repository
* Environment variables are used for sensitive configuration
* Input validation is enforced on all external inputs
* Rate limiting is applied to prevent abuse
* Dependencies are kept up to date
* Infrastructure is defined as code and version-controlled

---

## Dependency Management

* Dependencies are pinned via lockfiles
* Automated dependency updates are encouraged
* Security advisories should be addressed promptly

---

## Infrastructure Security

* Production deployments should enforce HTTPS
* Access to infrastructure should follow the principle of least privilege
* Cloud credentials must be rotated regularly
* Logs and metrics should be monitored for suspicious activity

---

## Acknowledgements

Responsible disclosure helps keep the ecosystem safe. Thank you for taking the time to report security issues.
