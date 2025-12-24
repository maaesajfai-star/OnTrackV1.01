# UEMS Architecture Documentation

## System Overview

UEMS is a modular monolithic application built with microservices-ready architecture, containerized for cloud deployment.

## High-Level Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│                        Client Layer                               │
│  (Web Browsers, Mobile Devices, API Clients)                     │
└──────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────────┐
│                    Nginx Reverse Proxy                            │
│  - Load Balancing                                                 │
│  - SSL Termination                                                │
│  - Request Routing                                                │
│  - Static Asset Serving                                           │
└──────────────────────────────────────────────────────────────────┘
        │                      │                      │
        ▼                      ▼                      ▼
┌──────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Frontend   │    │     Backend      │    │   NextCloud     │
│   Next.js    │    │     NestJS       │    │    Apache       │
│              │    │                  │    │                 │
│  - React 18  │    │  - Auth Module   │    │  - File Storage │
│  - Tailwind  │    │  - CRM Module    │    │  - WebDAV       │
│  - Zustand   │    │  - HRM Module    │    │  - Versioning   │
│  - SSR/SSG   │    │  - DMS Module    │    │                 │
└──────────────┘    │  - Users Module  │    └─────────────────┘
                    └──────────────────┘              │
                              │                       │
                              ▼                       ▼
                    ┌──────────────────┐    ┌─────────────────┐
                    │  PostgreSQL 16   │    │  PostgreSQL 16  │
                    │    (UEMS DB)     │    │ (NextCloud DB)  │
                    │                  │    │                 │
                    │  - Users         │    │  - NC Users     │
                    │  - Contacts      │    │  - NC Files     │
                    │  - Organizations │    │  - NC Shares    │
                    │  - Deals         │    │                 │
                    │  - Employees     │    │                 │
                    │  - Candidates    │    │                 │
                    └──────────────────┘    └─────────────────┘
```

## Component Architecture

### Frontend (Next.js 14)

**Tech Stack:**
- React 18 with Server Components
- Next.js App Router
- Tailwind CSS for styling
- Zustand for state management
- React Query for server state
- Axios for HTTP requests

**Directory Structure:**
```
frontend/src/
├── app/                    # Next.js pages (App Router)
│   ├── (auth)/            # Authentication routes
│   ├── (dashboard)/       # Protected dashboard routes
│   └── api/               # API routes (if needed)
├── components/
│   ├── ui/                # Reusable UI components
│   ├── crm/               # CRM-specific components
│   ├── hrm/               # HRM-specific components
│   ├── dms/               # DMS-specific components
│   └── layout/            # Layout components
├── lib/
│   ├── api.ts             # API client
│   ├── utils.ts           # Utilities
│   └── validations.ts     # Form validations
├── hooks/                 # Custom React hooks
├── types/                 # TypeScript definitions
└── store/                 # Zustand stores
```

**Data Flow:**
1. User interaction triggers component
2. Component calls custom hook or API client
3. API client sends HTTP request to backend
4. Response updates React Query cache
5. UI re-renders with new data

### Backend (NestJS 10)

**Tech Stack:**
- NestJS framework (Node.js/TypeScript)
- TypeORM for database ORM
- PostgreSQL 16 database
- JWT authentication
- Passport.js for auth strategies
- Swagger for API documentation

**Modular Architecture:**

```
backend/src/
├── modules/
│   ├── auth/              # Authentication & Authorization
│   │   ├── auth.controller.ts
│   │   ├── auth.service.ts
│   │   ├── auth.module.ts
│   │   ├── strategies/    # JWT, Local strategies
│   │   └── dto/           # Data Transfer Objects
│   │
│   ├── users/             # User Management
│   │   ├── entities/      # User entity
│   │   ├── users.service.ts
│   │   └── users.controller.ts
│   │
│   ├── crm/               # CRM Module
│   │   ├── entities/      # Contact, Org, Deal, Activity
│   │   ├── services/      # Business logic
│   │   ├── controllers/   # HTTP endpoints
│   │   └── dto/           # Request/Response DTOs
│   │
│   ├── hrm/               # HRM Module
│   │   ├── entities/      # Employee, Job, Candidate
│   │   ├── services/      # Business logic + CV parser
│   │   ├── controllers/   # HTTP endpoints
│   │   └── dto/           # Request/Response DTOs
│   │
│   └── dms/               # Document Management
│       ├── dms.controller.ts
│       └── services/
│           └── nextcloud.service.ts  # NextCloud integration
│
├── common/                # Shared resources
│   ├── decorators/        # Custom decorators
│   ├── guards/            # Auth guards, RBAC
│   ├── interceptors/      # Logging, transformation
│   ├── filters/           # Exception filters
│   └── pipes/             # Validation pipes
│
├── config/                # Configuration
│   └── typeorm.config.ts  # Database configuration
│
└── database/              # Database
    ├── migrations/        # TypeORM migrations
    └── seeds/             # Seed data
```

**Request Lifecycle:**

```
1. HTTP Request → Nginx → Backend
2. Global Guards → Authentication (JWT)
3. Route Guards → Authorization (RBAC)
4. Validation Pipes → DTO Validation
5. Controller → Route Handler
6. Service Layer → Business Logic
7. Repository → Database Query
8. Response Interceptor → Transform Response
9. Exception Filter → Handle Errors
10. HTTP Response → Client
```

### Database Schema

**Core Entities:**

```sql
-- Users (Authentication)
users:
  - id (UUID, PK)
  - email (unique)
  - password (bcrypt hashed)
  - firstName, lastName
  - role (enum: admin, hr_manager, sales_user, user)
  - nextcloudUserId
  - refreshToken
  - isActive
  - timestamps

-- CRM Module
contacts:
  - id (UUID, PK)
  - firstName, lastName, email, phone, role
  - organizationId (FK → organizations)
  - notes, isActive
  - timestamps

organizations:
  - id (UUID, PK)
  - name, website, industry, phone, address
  - parentOrganizationId (FK → organizations, self-referencing)
  - notes, isActive
  - timestamps

deals:
  - id (UUID, PK)
  - title, value, stage (enum), probability
  - contactId (FK → contacts)
  - organizationId (FK → organizations)
  - expectedCloseDate, description
  - timestamps

activities:
  - id (UUID, PK)
  - type (enum: call, email, meeting, note)
  - subject, description
  - contactId (FK → contacts)
  - activityDate, durationMinutes
  - createdAt

-- HRM Module
employees:
  - id (UUID, PK)
  - employeeId (unique)
  - firstName, lastName, email, phoneNumber
  - jobTitle, department
  - startDate, endDate, salary
  - emergencyContact*, address, dateOfBirth
  - isActive, notes
  - timestamps

job_postings:
  - id (UUID, PK)
  - title, department, location
  - status (enum: draft, open, closed, on_hold)
  - description, requirements
  - salaryMin, salaryMax
  - applicationDeadline, numberOfOpenings
  - timestamps

candidates:
  - id (UUID, PK)
  - firstName, lastName, email, phoneNumber
  - jobPostingId (FK → job_postings)
  - stage (enum: applied, screening, interview, offer, hired, rejected)
  - score (1-10), notes
  - cvFilePath, linkedinUrl, parsedCvData
  - appliedDate
  - timestamps
```

**Indexes:**
- email fields (users, contacts, employees, candidates)
- Foreign keys
- Stage/status enums for filtering
- Timestamps for sorting

**Relationships:**
- One-to-Many: Organization → Contacts, JobPosting → Candidates
- Self-Referencing: Organization → Parent Organization
- Many-to-One: Deal → Contact, Contact → Organization

## Security Architecture

### Authentication Flow

```
1. User submits email/password
2. Backend validates credentials
3. If valid:
   a. Generate Access Token (JWT, 15min expiry)
   b. Generate Refresh Token (JWT, 7day expiry)
   c. Store refresh token in database (hashed)
   d. Return both tokens to client
4. Client stores:
   - Access token in memory/local storage
   - Refresh token in httpOnly cookie (if web) or secure storage
5. Subsequent requests include: Authorization: Bearer <access_token>
```

### Token Refresh Flow

```
1. Access token expires
2. Client sends refresh token to /auth/refresh
3. Backend validates refresh token:
   a. Verify JWT signature
   b. Check token exists in database
   c. Verify user is active
4. If valid:
   a. Generate new access token
   b. Return to client
5. Else: Force re-login
```

### Authorization (RBAC)

**Roles:**
- **Admin**: Full system access
- **HR Manager**: Full HRM access, read CRM
- **Sales User**: Full CRM access, read HRM
- **User**: Limited read access

**Implementation:**
```typescript
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.ADMIN, UserRole.HR_MANAGER)
@Post('employees')
createEmployee() { ... }
```

### NextCloud Integration

**User Provisioning:**
```
1. New UEMS user created
2. Trigger NextCloud service:
   a. Create NextCloud user via OCS API
   b. Set password (sync or separate)
   c. Create folder structure:
      - /Clients/{OrganizationName} (for CRM users)
      - /HR/{EmployeeID} (for HRM users)
3. Store nextcloudUserId in UEMS database
```

**SSO Flow:**
```
1. User logs into UEMS (receives JWT)
2. When accessing DMS:
   a. Frontend includes JWT in request
   b. Backend validates JWT
   c. Backend creates WebDAV session for NextCloud
   d. Return WebDAV URL with temporary credentials
3. Frontend loads NextCloud in iframe with credentials
```

## API Design

### RESTful Principles

- **Resources**: Nouns (contacts, deals, employees)
- **HTTP Methods**: GET (read), POST (create), PATCH (update), DELETE (remove)
- **Status Codes**: 200 OK, 201 Created, 400 Bad Request, 401 Unauthorized, 404 Not Found, 500 Server Error

### Endpoint Patterns

```
/api/v1/{module}/{resource}
/api/v1/{module}/{resource}/{id}
/api/v1/{module}/{resource}/{id}/{sub-resource}

Examples:
GET    /api/v1/crm/contacts
POST   /api/v1/crm/contacts
GET    /api/v1/crm/contacts/:id
PATCH  /api/v1/crm/contacts/:id
DELETE /api/v1/crm/contacts/:id
GET    /api/v1/crm/deals?stage=qualified
```

### Response Format

```json
{
  "data": { ... },           // Actual response data
  "statusCode": 200,         // HTTP status code
  "timestamp": "ISO-8601",   // Request timestamp
  "path": "/api/v1/..."      // Request path
}
```

## Performance Considerations

### Database Optimization

- **Connection Pooling**: Min 2, Max 10 connections
- **Indexes**: All foreign keys, frequently queried fields
- **Query Optimization**: Use select specific columns, avoid N+1 queries
- **Pagination**: Implement for large datasets (future)

### Caching Strategy

- **Client-side**: React Query with 5min stale time
- **Server-side**: Redis for session data (future)
- **Database**: PostgreSQL query cache
- **CDN**: Static assets via Nginx or CloudFlare

### Load Handling

- **Horizontal Scaling**: Stateless backend, scale containers
- **Load Balancing**: Nginx upstream with least_conn algorithm
- **Database**: Read replicas for heavy read operations (future)
- **File Storage**: NextCloud can scale independently

## Deployment Architecture

### Docker Containers

```yaml
- nginx:         Reverse proxy, entry point
- frontend:      Next.js app (port 3000)
- backend:       NestJS API (port 3001)
- postgres:      UEMS database (port 5432)
- nextcloud-db:  NextCloud database (port 5432)
- nextcloud:     NextCloud app (port 80)
```

### Networking

- Custom bridge network: `uems-network`
- Internal communication via service names
- Only Nginx exposed to external traffic (port 80/443)

### Volumes

```
postgres-data:       PostgreSQL data persistence
nextcloud-db-data:   NextCloud DB persistence
nextcloud-data:      NextCloud files
nextcloud-apps:      NextCloud apps
nextcloud-config:    NextCloud config
uploads:             CV uploads (backend)
```

## Monitoring & Observability

### Health Checks

- Application: `GET /api/v1/health`
- Database: pg_isready
- NextCloud: /status.php

### Logging

- Backend: Winston (structured JSON logs)
- Frontend: Console + Sentry (production)
- Nginx: Access logs + Error logs
- Database: PostgreSQL logs

### Metrics (Future)

- Request rate, error rate, response time
- Database query performance
- Memory/CPU usage
- Active users

## Future Enhancements

1. **Microservices Migration**: Split modules into independent services
2. **Event-Driven Architecture**: RabbitMQ/Kafka for async operations
3. **Real-time Features**: WebSocket for live updates
4. **Advanced Caching**: Redis for sessions and data
5. **Search**: Elasticsearch for full-text search
6. **Analytics**: Dedicated analytics service
7. **Multi-tenancy**: Separate data per organization

## Technology Decisions

### Why NestJS?
- Enterprise-ready framework
- Built-in dependency injection
- TypeScript-first
- Microservices support
- Excellent documentation

### Why Next.js?
- Server-side rendering
- Static site generation
- Excellent developer experience
- Production-ready
- React 18 features

### Why PostgreSQL?
- ACID compliance
- JSON support
- Excellent performance
- Mature ecosystem
- Free and open-source

### Why Docker?
- Consistency across environments
- Easy deployment
- Isolation
- Scalability
- Industry standard
