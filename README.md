# ShortLink 🔗

A powerful and scalable URL shortener service built with Node.js, Express, and Redis. ShortLink provides fast URL shortening with API token-based rate limiting, device tracking, and production-ready deployment options.

## ✨ Features

- **URL Shortening**: Generate short, unique URLs that expire after 48 hours
- **Token-Based Authentication**: Secure API access with token generation and validation
- **Rate Limiting**: Multi-layer rate limiting (IP-based, device-based, and token-based)
- **Device Tracking**: Cookie-based device identification for usage limits
- **Redis Backend**: Fast, in-memory data storage with automatic expiration
- **Production Ready**: Docker, Nginx, and AWS infrastructure support (Terraform)
- **Logging**: Structured logging with Winston
- **Tested**: Jest-based test suite

## 🛠️ Technology Stack

- **Backend**: Node.js (ES Modules), Express 5
- **Database**: Redis 7
- **Rate Limiting**: express-rate-limit
- **ID Generation**: nanoid
- **Logging**: Winston
- **Testing**: Jest, Supertest
- **Containerization**: Docker, Docker Compose
- **Web Server**: Nginx (reverse proxy)
- **Infrastructure**: Terraform (AWS ALB, ASG, Route53, ACM)

## 📋 Prerequisites

- Node.js 24+ (Alpine recommended)
- Redis 7+
- Docker & Docker Compose (for containerized deployment)
- AWS account (for production deployment with Terraform)

## 🚀 Installation

### Local Development

1. **Clone the repository**
   ```bash
   git clone https://github.com/fajlur79/ShortLink.git
   cd ShortLink
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Configure environment variables**
   
   Create a `.env` file in the root directory:
   ```env
   PORT=3000
   REDIS_URL=redis://localhost:6379
   BASE_URL=http://localhost:3000
   NODE_ENV=development
   ```

4. **Start Redis** (if not already running)
   ```bash
   # Using Docker
   docker run -d -p 6379:6379 redis:7-alpine
   
   # Or using local Redis installation
   redis-server
   ```

5. **Run the application**
   ```bash
   # Development mode with auto-reload
   npm run dev
   
   # Production mode
   npm start
   ```

The service will be available locally at `http://localhost:3000`.

For production, the app is hosted at `https://shorts.codes`.

### Docker Deployment

1. **Using Docker Compose** (Recommended)
   ```bash
   # Create environment file
   cp .env.example .env  # Configure your environment variables
   
   # Start all services (app, Redis, Nginx)
   docker-compose up -d
   ```

   Services:
   - App: Running on port 3000 (internal)
   - Redis: Data storage with persistence
   - Nginx: Reverse proxy on port 80

2. **Using Docker image from GitHub Container Registry**
   ```bash
   docker pull ghcr.io/fajlur79/shortlink:latest
   docker run -d -p 3000:3000 \
     -e REDIS_URL=redis://redis:6379 \
     -e BASE_URL=shorts.codes \
     ghcr.io/fajlur79/shortlink:latest
   ```

## 🔧 Environment Variables

| Variable | Description | Default                | Required |
|----------|-------------|------------------------|----------|
| `PORT`   | Server port | `3000`                 | Yes      |
| `REDIS_URL` | Redis connection URL | `redis://localhost:6379` or `redis://redis:6379` | Yes |
| `BASE_URL`  | Base URL for short links | `http://localhost:3000` or `https://shorts.codes` | Yes |
| `NODE_ENV`  | Environment mode | `development`         | No      |

## 📚 API Endpoints

### 1. Health Check
```http
GET /
```
Checks if the server is running and returns a cookie for further requests.

**Response:**
```
Welcome to ShortLink.
```

**Curl Examples:**
- For local setup:
  ```bash
  curl --include http://localhost:3000
  ```
- For production:
  ```bash
  curl --include https://shorts.codes
  ```

---

### 2. Generate API Token
```http
POST /generate-key
```
Generates a new API token for the device identified by the cookie.

**Request Headers:**
- Include the `deviceId` cookie in the header.

**Response:**
```json
{
  "token": "32-character-hex-token"
}
```

**Curl Examples:**
- For local setup:
  ```bash
  curl --include --request POST \
    --header "Cookie: deviceId=abc123" \
    http://localhost:3000/generate-key
  ```
- For production:
  ```bash
  curl --include --request POST \
    --header "Cookie: deviceId=abc123" \
    https://shorts.codes/generate-key
  ```

---

### 3. Get Active Token
```http
GET /get-key
```
Retrieves the active API token for the current device based on the cookie.

**Request Headers:**
- Include the `deviceId` cookie in the header.

**Response:**
```json
{
  "token": "your-active-token"
}
```

**Curl Examples:**
- For local setup:
  ```bash
  curl --include --request GET \
    --header "Cookie: deviceId=abc123" \
    http://localhost:3000/get-key
  ```
- For production:
  ```bash
  curl --include --request GET \
    --header "Cookie: deviceId=abc123" \
    https://shorts.codes/get-key
  ```

---

### 4. Check Token Usage
```http
GET /usage
```
Returns the current usage statistics for the active token.

**Request Headers:**
- `x-api-key`: Your API token
- `Cookie`: The `deviceId` cookie

**Response:**
```json
{
  "usage": 5,
  "limit": 10,
  "remaining": 5
}
```

**Curl Examples:**
- For local setup:
  ```bash
  curl --include --request GET \
    --header "x-api-key: your-token-here" \
    --header "Cookie: deviceId=abc123" \
    http://localhost:3000/usage
  ```
- For production:
  ```bash
  curl --include --request GET \
    --header "x-api-key: your-token-here" \
    --header "Cookie: deviceId=abc123" \
    https://shorts.codes/usage
  ```

---

### 5. Shorten URL
```http
POST /shorten
```
Shortens a long URL to a unique short URL.

**Request Headers:**
- `x-api-key`: Your API token
- `Cookie`: The `deviceId` cookie

**Request Body:**
```json
{
  "url": "https://example.com/very/long/url"
}
```

**Response:**
```json
{
  "shortUrl": "http://localhost:3000/abc12345" # Local
  "shortUrl": "https://shorts.codes/abc12345" # Production
}
```

**Curl Examples:**
- For local setup:
  ```bash
  curl --include --request POST \
    --header "x-api-key: your-token-here" \
    --header "Cookie: deviceId=abc123" \
    --header "Content-Type: application/json" \
    --data '{"url": "https://example.com/very/long/url"}' \
    http://localhost:3000/shorten
  ```
- For production:
  ```bash
  curl --include --request POST \
    --header "x-api-key: your-token-here" \
    --header "Cookie: deviceId=abc123" \
    --header "Content-Type: application/json" \
    --data '{"url": "https://example.com/very/long/url"}' \
    https://shorts.codes/shorten
  ```

---

### 6. Redirect to Original URL
```http
GET /:id
```
Redirects to the long URL associated with the short URL ID.

**Examples:**
- For local:
  ```bash
  curl --include http://localhost:3000/abc12345
  ```
- For production:
  ```bash
  curl --include https://shorts.codes/abc12345
  ```

## 🧪 Testing

Run the test suite:
```bash
npm test
```

The project uses Jest with ES Module support and Supertest for API testing.

## 📦 Project Structure

```
ShortLink/
├── app.js                 # Main application entry point
├── routes/
│   ├── index.js          # Route aggregator
│   ├── token/            # Token management routes
│   │   ├── generate.js   # Generate new token
│   │   ├── getKey.js     # Get active token
│   │   └── usage.js      # Check token usage
│   └── urls/             # URL shortening routes
│       ├── shorten.js    # Create short URL
│       └── redirect.js   # Redirect handler
├── middleware/
│   ├── device.js         # Device cookie management
│   ├── rateLimit.js      # Rate limiting logic
│   └── validateUrl.js    # URL validation
├── services/
│   └── redisClient.js    # Redis connection
├── utils/
│   ├── logger.js         # Winston logger
│   └── dateKey.js        # Date key generation
├── test/
│   └── app.test.js       # API tests
├── terraform/            # AWS infrastructure
├── nginx/                # Nginx configuration
├── Dockerfile            # Container image
├── docker-compose.yml    # Multi-container setup
└── package.json          # Dependencies
```

## 🏗️ Production Deployment

### AWS (with Terraform)

The repository includes Terraform configurations for AWS deployment:

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

Infrastructure includes:
- Application Load Balancer (ALB)
- Auto Scaling Group (ASG)
- Route53 DNS configuration
- ACM SSL certificates
- ElastiCache for Redis 

## ☁️ Cloud Architecture

The following diagram illustrates the AWS infrastructure provisioned by Terraform.

```mermaid
graph TD
    User([User])
    
    subgraph AWS [AWS Cloud Region]
        style AWS fill:#f9f9f9,stroke:#232f3e,stroke-width:2px
        
        ALB[Application Load Balancer]
        style ALB fill:#FF9900,stroke:#232f3e,color:white
        
        subgraph VPC [VPC]
            style VPC fill:#ffffff,stroke:#8c8c8c,stroke-dasharray: 5 5
            
            subgraph ASG [Auto Scaling Group]
                style ASG fill:#e6f7ff,stroke:#1890ff
                EC2[EC2 Instance]
                Docker[Node.js App Container]
            end
            
            Redis[(ElastiCache Redis)]
            style Redis fill:#fff1f0,stroke:#D93025,color:black
        end
    end
    
    User -- "HTTPS (443)" --> ALB
    ALB -- "Traffic Forwarding" --> EC2
    EC2 -- "Port 3000" --> Docker
    Docker -- "Cache/Store (6379)" --> Redis
    
    %% CI/CD Flow
    GH[GitHub Actions] -.->|SSM Deploy Command| EC2
    style GH fill:#24292e,stroke:#ffffff,color:white
```

## 🔒 Rate Limiting

ShortLink implements multiple layers of rate limiting:

1. **IP-based Global Limit**: 100 requests per 15 minutes per IP
2. **Token Generation Limits**:
   - 5 tokens per device per day
   - 100 tokens per IP per day
   - 5 tokens per IP per 2 minutes (burst protection)
3. **URL Shortening Limit**: 10 URLs per token per day

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

Copyright (c) 2025 Fajlur R Chowdhury

## 👤 Author

**Fajlur**
- Email: fajlur939@proton.me
- GitHub: [@fajlur79](https://github.com/fajlur79)

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the [issues page](https://github.com/fajlur79/ShortLink/issues).

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Acknowledgments

- Built with Express.js and Redis
- ID generation powered by nanoid
- Rate limiting by express-rate-limit
- Logging by Winston