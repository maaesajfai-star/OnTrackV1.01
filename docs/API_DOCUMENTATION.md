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
