#!/bin/bash

# Create remaining technical documentation

set -e
ROOT="/home/mahmoud/AI/Projects/claude-Version1"
cd "$ROOT"

echo "Creating technical documentation files..."

# API_DOCUMENTATION.md
cat > docs/API_DOCUMENTATION.md << 'EOFFILE'
# UEMS API Documentation

Complete API reference for the UEMS backend.

## Base URL

```
Development: http://localhost:3001/api/v1
Production: https://your-domain.com/api/v1
```

## Authentication

All endpoints except `/auth/login` and `/auth/register` require authentication.

### Authentication Header

```
Authorization: Bearer <access_token>
```

## Authentication Endpoints

### POST /auth/login

Login user and receive JWT tokens.

**Request:**
```json
{
  "email": "admin@uems.com",
  "password": "Admin@123456"
}
```

**Response (200):**
```json
{
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIs...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIs...",
    "user": {
      "id": "uuid",
      "email": "admin@uems.com",
      "firstName": "System",
      "lastName": "Administrator",
      "role": "admin"
    }
  },
  "statusCode": 200,
  "timestamp": "2025-01-15T10:30:00.000Z",
  "path": "/api/v1/auth/login"
}
```

### POST /auth/register

Register a new user.

**Request:**
```json
{
  "email": "newuser@example.com",
  "password": "SecurePass123!",
  "firstName": "John",
  "lastName": "Doe",
  "role": "user"
}
```

### POST /auth/refresh

Refresh access token using refresh token.

**Request:**
```json
{
  "refreshToken": "eyJhbGciOiJIUzI1NiIs..."
}
```

## CRM Endpoints

### Contacts

#### GET /crm/contacts

Get all contacts.

**Response (200):**
```json
{
  "data": [
    {
      "id": "uuid",
      "firstName": "Jane",
      "lastName": "Doe",
      "email": "jane@example.com",
      "phone": "+1234567890",
      "role": "CEO",
      "organizationId": "uuid",
      "organization": {
        "id": "uuid",
        "name": "Acme Corp"
      },
      "notes": "Key decision maker",
      "createdAt": "2025-01-15T10:00:00.000Z"
    }
  ]
}
```

#### POST /crm/contacts

Create a new contact.

**Request:**
```json
{
  "firstName": "Jane",
  "lastName": "Doe",
  "email": "jane@example.com",
  "phone": "+1234567890",
  "role": "CEO",
  "organizationId": "uuid",
  "notes": "Key decision maker"
}
```

#### GET /crm/contacts/:id

Get contact by ID.

#### PATCH /crm/contacts/:id

Update contact.

#### DELETE /crm/contacts/:id

Delete contact.

### Organizations

#### GET /crm/organizations

Get all organizations.

#### POST /crm/organizations

Create organization.

**Request:**
```json
{
  "name": "Acme Corporation",
  "website": "https://acme.com",
  "industry": "Technology",
  "phone": "+1234567890",
  "address": "123 Main St, City, Country",
  "parentOrganizationId": "uuid",
  "notes": "Important client"
}
```

### Deals

#### GET /crm/deals

Get all deals. Supports filtering by stage.

**Query Parameters:**
- `stage` (optional): Filter by deal stage (new, qualified, negotiation, won, lost)

**Example:** `GET /crm/deals?stage=qualified`

#### POST /crm/deals

Create a new deal.

**Request:**
```json
{
  "title": "Enterprise License",
  "value": 50000,
  "stage": "qualified",
  "contactId": "uuid",
  "organizationId": "uuid",
  "expectedCloseDate": "2025-03-31",
  "description": "Annual enterprise license renewal",
  "probability": 75
}
```

### Activities

#### GET /crm/activities

Get all activities. Supports filtering by contact.

**Query Parameters:**
- `contactId` (optional): Filter by contact ID

#### POST /crm/activities

Create activity.

**Request:**
```json
{
  "type": "call",
  "subject": "Follow-up call",
  "description": "Discussed project requirements",
  "contactId": "uuid",
  "activityDate": "2025-01-15T14:00:00Z",
  "durationMinutes": 30
}
```

**Activity Types:** `call`, `email`, `meeting`, `note`

## HRM Endpoints

### Employees

#### GET /hrm/employees

Get all employees. Supports filtering by department.

**Query Parameters:**
- `department` (optional): Filter by department name

#### POST /hrm/employees

Create employee (Admin/HR Manager only).

**Request:**
```json
{
  "employeeId": "EMP001",
  "firstName": "John",
  "lastName": "Smith",
  "email": "john.smith@company.com",
  "phoneNumber": "+1234567890",
  "jobTitle": "Software Engineer",
  "department": "Engineering",
  "startDate": "2025-01-15",
  "salary": 75000,
  "emergencyContactName": "Jane Smith",
  "emergencyContactPhone": "+0987654321",
  "address": "456 Oak Ave",
  "dateOfBirth": "1990-05-15"
}
```

### Job Postings

#### GET /hrm/job-postings

Get all job postings. Supports filtering by status.

**Query Parameters:**
- `status` (optional): Filter by status (draft, open, closed, on_hold)

#### POST /hrm/job-postings

Create job posting (Admin/HR Manager only).

**Request:**
```json
{
  "title": "Senior Software Engineer",
  "department": "Engineering",
  "location": "Remote",
  "status": "open",
  "description": "We are looking for an experienced software engineer...",
  "requirements": "5+ years experience, Node.js, React",
  "salaryMin": 80000,
  "salaryMax": 120000,
  "applicationDeadline": "2025-02-28",
  "numberOfOpenings": 2
}
```

### Candidates

#### GET /hrm/candidates

Get all candidates. Supports filtering.

**Query Parameters:**
- `stage` (optional): Filter by stage
- `jobPostingId` (optional): Filter by job posting

#### POST /hrm/candidates

Create candidate (Admin/HR Manager only).

**Request:**
```json
{
  "firstName": "Alice",
  "lastName": "Johnson",
  "email": "alice@example.com",
  "phoneNumber": "+1234567890",
  "jobPostingId": "uuid",
  "stage": "applied",
  "score": 8,
  "notes": "Strong technical skills",
  "linkedinUrl": "https://linkedin.com/in/alice",
  "appliedDate": "2025-01-15"
}
```

**Candidate Stages:** `applied`, `screening`, `interview`, `offer`, `hired`, `rejected`

#### POST /hrm/candidates/upload-cv

Upload and parse CV (Admin/HR Manager only).

**Request:** `multipart/form-data`
- `file`: PDF file

**Response:**
```json
{
  "data": {
    "filePath": "/uploads/cvs/cv-1234567890.pdf",
    "parsed": {
      "email": "alice@example.com",
      "phone": "+1234567890",
      "name": "Alice Johnson",
      "fullText": "...",
      "extractedAt": "2025-01-15T10:00:00Z"
    }
  }
}
```

## DMS Endpoints

### Files

#### GET /dms/files

List files in NextCloud.

**Query Parameters:**
- `path` (optional): Path to list (default: `/`)

**Response:**
```json
{
  "data": {
    "response": {
      "multistatus": {
        "response": [
          {
            "href": "/remote.php/dav/files/user/Documents/",
            "propstat": {
              "prop": {
                "getlastmodified": "2025-01-15T10:00:00Z",
                "resourcetype": "collection"
              }
            }
          }
        ]
      }
    }
  }
}
```

#### POST /dms/upload

Upload file to NextCloud.

**Query Parameters:**
- `path`: Destination path in NextCloud

**Request:** `multipart/form-data`
- `file`: File to upload

#### DELETE /dms/files

Delete file from NextCloud.

**Query Parameters:**
- `path`: File path to delete

#### POST /dms/provision

Provision NextCloud user with folder structure.

**Request:**
```json
{
  "userId": "user123",
  "password": "SecurePass123!",
  "email": "user@example.com",
  "userType": "client",
  "entityName": "Acme Corp"
}
```

**User Types:** `client`, `employee`

## Error Responses

### 400 Bad Request

```json
{
  "statusCode": 400,
  "timestamp": "2025-01-15T10:00:00.000Z",
  "path": "/api/v1/crm/contacts",
  "error": "Bad Request",
  "message": ["email must be an email", "firstName should not be empty"]
}
```

### 401 Unauthorized

```json
{
  "statusCode": 401,
  "timestamp": "2025-01-15T10:00:00.000Z",
  "path": "/api/v1/crm/contacts",
  "error": "Unauthorized",
  "message": "Invalid or expired token"
}
```

### 403 Forbidden

```json
{
  "statusCode": 403,
  "timestamp": "2025-01-15T10:00:00.000Z",
  "path": "/api/v1/hrm/employees",
  "error": "Forbidden",
  "message": "Insufficient permissions"
}
```

### 404 Not Found

```json
{
  "statusCode": 404,
  "timestamp": "2025-01-15T10:00:00.000Z",
  "path": "/api/v1/crm/contacts/invalid-id",
  "error": "Not Found",
  "message": "Contact #invalid-id not found"
}
```

### 429 Too Many Requests

```json
{
  "statusCode": 429,
  "timestamp": "2025-01-15T10:00:00.000Z",
  "error": "Too Many Requests",
  "message": "ThrottlerException: Too Many Requests"
}
```

### 500 Internal Server Error

```json
{
  "statusCode": 500,
  "timestamp": "2025-01-15T10:00:00.000Z",
  "path": "/api/v1/crm/contacts",
  "error": "Internal Server Error",
  "message": "An unexpected error occurred"
}
```

## Rate Limiting

- **Limit**: 100 requests per minute per IP
- **Headers**:
  - `X-RateLimit-Limit`: Total requests allowed
  - `X-RateLimit-Remaining`: Remaining requests
  - `X-RateLimit-Reset`: Time when limit resets

## Pagination

For endpoints returning lists, pagination will be added in future versions.

## Interactive Documentation

Access Swagger UI at: `http://localhost/api/docs`

## Postman Collection

Import the Postman collection from `/postman/UEMS.postman_collection.json`
EOFFILE

echo "✓ API_DOCUMENTATION.md created"

# Create .github/workflows/ci.yml
mkdir -p .github/workflows
cat > .github/workflows/ci.yml << 'EOFFILE'
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  backend-test:
    name: Backend Tests
    runs-on: ubuntu-latest

    services:
      postgres:
        image: postgres:16-alpine
        env:
          POSTGRES_USER: test_user
          POSTGRES_PASSWORD: test_password
          POSTGRES_DB: test_db
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432

    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '20'
          cache: 'npm'
          cache-dependency-path: backend/package-lock.json

      - name: Install dependencies
        working-directory: ./backend
        run: npm ci

      - name: Run linter
        working-directory: ./backend
        run: npm run lint

      - name: Run tests
        working-directory: ./backend
        run: npm run test:cov
        env:
          POSTGRES_HOST: localhost
          POSTGRES_PORT: 5432
          POSTGRES_USER: test_user
          POSTGRES_PASSWORD: test_password
          POSTGRES_DB: test_db
          JWT_SECRET: test_secret
          JWT_REFRESH_SECRET: test_refresh_secret

      - name: Upload coverage reports
        uses: codecov/codecov-action@v3
        with:
          files: ./backend/coverage/lcov.info
          flags: backend

  frontend-test:
    name: Frontend Tests
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '20'
          cache: 'npm'
          cache-dependency-path: frontend/package-lock.json

      - name: Install dependencies
        working-directory: ./frontend
        run: npm ci

      - name: Run linter
        working-directory: ./frontend
        run: npm run lint

      - name: Type check
        working-directory: ./frontend
        run: npm run type-check

      - name: Build
        working-directory: ./frontend
        run: npm run build
        env:
          NEXT_PUBLIC_API_URL: http://localhost:3001/api/v1

  docker-build:
    name: Docker Build Test
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2

      - name: Build Backend Image
        uses: docker/build-push-action@v4
        with:
          context: ./backend
          push: false
          tags: uems-backend:test
          cache-from: type=gha
          cache-to: type=gha,mode=max

      - name: Build Frontend Image
        uses: docker/build-push-action@v4
        with:
          context: ./frontend
          push: false
          tags: uems-frontend:test
          cache-from: type=gha
          cache-to: type=gha,mode=max

  security-scan:
    name: Security Scan
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          scan-ref: '.'
          format: 'sarif'
          output: 'trivy-results.sarif'

      - name: Upload Trivy results to GitHub Security
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: 'trivy-results.sarif'
EOFFILE

echo "✓ CI/CD workflow created"

# Create .dockerignore files
cat > backend/.dockerignore << 'EOFFILE'
node_modules
npm-debug.log
.env
.env.local
dist
coverage
.git
.gitignore
README.md
.vscode
.idea
*.md
EOFFILE

cat > frontend/.dockerignore << 'EOFFILE'
node_modules
.next
npm-debug.log
.env
.env.local
.git
.gitignore
README.md
.vscode
.idea
*.md
EOFFILE

echo "✓ .dockerignore files created"

# Create .eslintrc.js for backend
cat > backend/.eslintrc.js << 'EOFFILE'
module.exports = {
  parser: '@typescript-eslint/parser',
  parserOptions: {
    project: 'tsconfig.json',
    tsconfigRootDir: __dirname,
    sourceType: 'module',
  },
  plugins: ['@typescript-eslint/eslint-plugin'],
  extends: [
    'plugin:@typescript-eslint/recommended',
    'plugin:prettier/recommended',
  ],
  root: true,
  env: {
    node: true,
    jest: true,
  },
  ignorePatterns: ['.eslintrc.js'],
  rules: {
    '@typescript-eslint/interface-name-prefix': 'off',
    '@typescript-eslint/explicit-function-return-type': 'off',
    '@typescript-eslint/explicit-module-boundary-types': 'off',
    '@typescript-eslint/no-explicit-any': 'warn',
  },
};
EOFFILE

# Create .prettierrc for backend
cat > backend/.prettierrc << 'EOFFILE'
{
  "singleQuote": true,
  "trailingComma": "all",
  "printWidth": 100,
  "tabWidth": 2,
  "semi": true
}
EOFFILE

echo "✓ Linting configuration created"

echo "========================================="
echo "✓ All technical documentation created!"
echo "========================================="
EOFFILE

chmod +x /home/mahmoud/AI/Projects/claude-Version1/CREATE_TECHNICAL_DOCS.sh
cd /home/mahmoud/AI/Projects/claude-Version1
./CREATE_TECHNICAL_DOCS.sh
