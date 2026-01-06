# API Documentation

This document defines the **public HTTP API contract** for ShortLink. It describes how clients interact with the service, including authentication, headers, request/response formats, and rate limits. Internal implementation details are intentionally excluded.

---

## Base URL

```
https://<your-domain>
```

Local development:

```
http://localhost:3000
```

---

## Authentication & Identity Model

ShortLink uses a **two-layer identity model**:

1. **Device Identification**

   * Each client is identified using a `deviceId` cookie
   * The cookie is issued automatically on the first request

2. **API Token Authentication**

   * API tokens are generated per device
   * Tokens are required for protected endpoints
   * Tokens are sent via the `x-api-key` request header

Both layers are required for full API access.

---

## Common Headers

| Header                           | Description              | Required            |
| -------------------------------- | ------------------------ | ------------------- |
| `Content-Type: application/json` | JSON request body        | For POST requests   |
| `Cookie: deviceId=...`           | Device identification    | Most endpoints      |
| `x-api-key`                      | API authentication token | Protected endpoints |

---

## Endpoints

### 1. Health Check & Device Bootstrap

```http
GET /
```

Checks service availability and issues a `deviceId` cookie if one does not already exist.

**Response**

```
200 OK
```

```text
Welcome to ShortLink.
```

---

### 2. Generate API Token

```http
POST /generate-key
```

Generates a new API token for the current device.

**Required Headers**

* `Cookie: deviceId=...`

**Response**

```
201 Created
```

```json
{
  "token": "32-character-hex-token"
}
```

---

### 3. Get Active API Token

```http
GET /get-key
```

Returns the active API token associated with the current device.

**Required Headers**

* `Cookie: deviceId=...`

**Response**

```
200 OK
```

```json
{
  "token": "your-active-token"
}
```

---

### 4. Token Usage Statistics

```http
GET /usage
```

Returns usage information for the active API token.

**Required Headers**

* `x-api-key: <token>`
* `Cookie: deviceId=...`

**Response**

```
200 OK
```

```json
{
  "usage": 5,
  "limit": 10,
  "remaining": 5
}
```

---

### 5. Shorten URL

```http
POST /shorten
```

Creates a shortened URL.

**Required Headers**

* `x-api-key: <token>`
* `Cookie: deviceId=...`
* `Content-Type: application/json`

**Request Body**

```json
{
  "url": "https://example.com/very/long/url"
}
```

**Response**

```
201 Created
```

```json
{
  "shortUrl": "https://<your-domain>/abc12345"
}
```

---

### 6. Redirect to Original URL

```http
GET /:id
```

Redirects the client to the original long URL associated with the short identifier.

**Response**

```
302 Found
```

* The `Location` header contains the original URL
* Clients are redirected automatically

---

## Rate Limiting

ShortLink enforces multiple layers of rate limiting:

* **Global IP limits** to prevent abuse
* **Device-based limits** using cookies
* **Token-based limits** for API usage

Examples of enforced limits include:

* Token generation limits per device and per IP
* Daily URL creation limits per token
* Burst protection on sensitive endpoints

Exact thresholds are operational details and may change without notice.

---

## Error Responses

Errors follow a consistent JSON structure:

```json
{
  "error": "Human-readable error message"
}
```

Common status codes:

* `400 Bad Request` – Invalid input
* `401 Unauthorized` – Missing or invalid token
* `403 Forbidden` – Token/device mismatch
* `404 Not Found` – Resource does not exist
* `429 Too Many Requests` – Rate limit exceeded
* `500 Internal Server Error` – Unexpected failure

---

## Idempotency & Safety

* `POST /generate-key` and `POST /shorten` are **not idempotent**
* `GET` endpoints are safe and idempotent

Clients should not assume retries on write operations are safe.

---

## Security Notes

* HTTPS is required in production
* Tokens must be kept secret
* All inputs are validated server-side

For vulnerability reporting, see [SECURITY.md](../SECURITY.md).

---
