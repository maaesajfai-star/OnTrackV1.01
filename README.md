# OnTrack - Unified Enterprise Management System

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Node.js](https://img.shields.io/badge/Node.js-20.x-green.svg)](https://nodejs.org/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.3-blue.svg)](https://www.typescriptlang.org/)
[![NestJS](https://img.shields.io/badge/NestJS-10.x-red.svg)](https://nestjs.com/)
[![Next.js](https://img.shields.io/badge/Next.js-14.x-black.svg)](https://nextjs.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-blue.svg)](https://www.postgresql.org/)

> **Enterprise-grade management platform combining CRM, HRM, and Document Management with NextCloud integration**

## Overview

OnTrack is a comprehensive, production-ready enterprise management system that unifies customer relationship management, human resource management, and document management capabilities into a single, cohesive platform. Built with modern technologies and enterprise best practices, OnTrack provides a scalable, secure, and user-friendly solution for organizations of all sizes.

## Key Features

### Mini-CRM Module
- **Contact Management**: Complete CRUD operations for contacts with advanced search and filtering
- **Organization Database**: Hierarchical organization structure with parent/child relationships
- **Activity Logging**: Track calls, emails, meetings, and notes with timestamps
- **Deal Pipeline**: Kanban-style pipeline (New → Qualified → Negotiation → Won/Lost)
- **Analytics Dashboard**: Visual insights into sales performance and pipeline health

### HRM Module
- **Employee Profiles**: Comprehensive employee data management with role-based access
- **Job Postings**: Create and manage job openings with detailed descriptions
- **Applicant Tracking System (ATS)**: Kanban pipeline (Applied → Screening → Interview → Offer → Hired)
- **CV Parsing**: Automatic extraction of name, email, and phone from PDF resumes
- **Candidate Scoring**: Rate and track candidates with scoring system (1-10)
- **Department Management**: Organize employees by department with filtering

### Document Management System (DMS)
- **NextCloud Integration**: Seamless integration with NextCloud for enterprise file storage
- **Auto-Provisioning**: Automatic user creation in NextCloud when UEMS user is created
- **Folder Auto-Creation**: Automatically create structured folders (`/Clients/{Name}`, `/HR/{EmployeeID}`)
- **Embedded View**: Access NextCloud files directly within UEMS interface
- **Single Sign-On (SSO)**: Unified authentication across UEMS and NextCloud
- **WebDAV Support**: Full WebDAV protocol support for file operations

## Technology Stack

### Backend
- **Framework**: NestJS 10.x (Node.js/TypeScript)
- **Database**: PostgreSQL 16 with TypeORM
- **Authentication**: JWT with refresh tokens
- **Authorization**: Role-Based Access Control (RBAC)
- **Security**: bcrypt password hashing, TLS 1.2+, Helmet.js
- **API Documentation**: Swagger/OpenAPI 3.0
- **File Processing**: pdf-parse for CV parsing
- **Rate Limiting**: Built-in throttling

### Frontend
- **Framework**: Next.js 14 (React 18) with App Router
- **Styling**: Tailwind CSS 3.4
- **UI Components**: Custom component library with shadcn/ui patterns
- **State Management**: Zustand + React Query
- **Form Handling**: React Hook Form + Zod validation
- **HTTP Client**: Axios with interceptors
- **Drag & Drop**: react-beautiful-dnd for Kanban boards

### Infrastructure
- **Containerization**: Docker & Docker Compose
- **Reverse Proxy**: Nginx
- **File Storage**: NextCloud 28 (Apache)
- **Monitoring**: Health check endpoints
- **Logging**: Winston (backend), structured logging

### Database
- **Primary DB**: PostgreSQL 16 (OnTrack data)
- **Secondary DB**: PostgreSQL 16 (NextCloud data)
- **ORM**: TypeORM with migrations
- **Connection Pooling**: Optimized pool configuration
- **Indexing**: Strategic indexes on frequently queried fields

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         Nginx (Port 80)                      │
│                    Reverse Proxy & Load Balancer             │
└─────────────────────────────────────────────────────────────┘
           │                    │                    │
           ▼                    ▼                    ▼
    ┌──────────┐        ┌──────────┐        ┌──────────┐
    │ Frontend │        │  Backend │        │NextCloud │
    │ Next.js  │        │  NestJS  │        │  Apache  │
    │ Port 3000│        │ Port 3001│        │  Port 80 │
    └──────────┘        └──────────┘        └──────────┘
                               │                    │
                               ▼                    ▼
                        ┌──────────┐        ┌──────────┐
                        │PostgreSQL│        │PostgreSQL│
                        │OnTrack DB│        │NC DB     │
                        │ Port 5432│        │ Port 5432│
                        └──────────┘        └──────────┘
```

## Quick Start

### Prerequisites
- Docker 24.x or higher
- Docker Compose 2.x or higher
- 4GB RAM minimum (8GB recommended)
- 20GB available disk space

### Installation (3 Steps)

After cloning this repository, run these 3 commands:

```bash
# 1. Generate .env file with secure secrets
./setup-env.sh

# 2. Start the application
docker compose up -d

# 3. Verify it's running
curl http://localhost/health
```

**Done!** Access the application at:
- **Frontend**: http://localhost
- **API Documentation**: http://localhost/api/docs
- **NextCloud**: http://localhost/nextcloud

📖 **For detailed setup instructions**, see [FIRST_TIME_SETUP.md](FIRST_TIME_SETUP.md)

### Default Credentials

| Role | Username | Email | Password |
|------|----------|-------|----------|
| Admin | Admin | admin@ontrack.local | AdminAdmin@123 |

⚠️ **IMPORTANT**: Change the admin password immediately after first login!

## Project Structure

```
claude-Version1/
├── backend/                 # NestJS Backend API
│   ├── src/
│   │   ├── modules/        # Feature modules (auth, crm, hrm, dms, users)
│   │   ├── common/         # Shared utilities (guards, filters, interceptors)
│   │   ├── config/         # Configuration files
│   │   └── database/       # Migrations and seeds
│   ├── test/               # Test files
│   ├── Dockerfile          # Multi-stage Docker build
│   └── package.json
├── frontend/               # Next.js Frontend
│   ├── src/
│   │   ├── app/           # Next.js app router pages
│   │   ├── components/    # React components
│   │   ├── lib/           # Utilities and API client
│   │   ├── hooks/         # Custom React hooks
│   │   └── types/         # TypeScript definitions
│   ├── public/            # Static assets
│   ├── Dockerfile         # Multi-stage Docker build
│   └── package.json
├── nginx/                 # Nginx configuration
│   ├── nginx.conf
│   └── conf.d/
├── docs/                  # Documentation
│   ├── INSTALLATION.md
│   ├── API_DOCUMENTATION.md
│   ├── ARCHITECTURE.md
│   ├── DEPLOYMENT.md
│   ├── USER_GUIDE.md
│   ├── DEVELOPER_GUIDE.md
│   └── NEXTCLOUD_INTEGRATION.md
├── docker-compose.yml     # Development compose file
├── docker-compose.prod.yml # Production compose file
└── .env.example           # Environment template
```

## API Endpoints

### Authentication
- `POST /api/v1/auth/login` - User login
- `POST /api/v1/auth/register` - User registration
- `POST /api/v1/auth/refresh` - Refresh access token
- `POST /api/v1/auth/logout` - User logout

### CRM
- `GET/POST /api/v1/crm/contacts` - Contact management
- `GET/POST /api/v1/crm/organizations` - Organization management
- `GET/POST /api/v1/crm/deals` - Deal pipeline management
- `GET/POST /api/v1/crm/activities` - Activity logging

### HRM
- `GET/POST /api/v1/hrm/employees` - Employee management
- `GET/POST /api/v1/hrm/job-postings` - Job posting management
- `GET/POST /api/v1/hrm/candidates` - Candidate tracking
- `POST /api/v1/hrm/candidates/upload-cv` - CV upload and parsing

### DMS
- `GET /api/v1/dms/files` - List NextCloud files
- `POST /api/v1/dms/upload` - Upload file to NextCloud
- `DELETE /api/v1/dms/files` - Delete file from NextCloud
- `POST /api/v1/dms/provision` - Provision NextCloud user

## Security Features

- JWT-based authentication with refresh tokens
- Role-Based Access Control (RBAC): Admin, HR Manager, Sales User, User
- bcrypt password hashing (12 rounds)
- TLS 1.2+ encryption (production)
- CORS protection
- Rate limiting (100 requests/minute)
- SQL injection prevention via parameterized queries
- XSS protection via Helmet.js
- Environment variable security
- Docker security best practices

## Performance Optimizations

- API response time: < 200ms (target)
- Database connection pooling (2-10 connections)
- Strategic database indexing
- Next.js static optimization
- Nginx caching and compression
- Docker multi-stage builds for smaller images
- Lazy loading of frontend components

## Documentation

- **[Installation Guide](docs/INSTALLATION.md)** - Detailed setup instructions
- **[API Documentation](docs/API_DOCUMENTATION.md)** - Complete API reference
- **[Architecture Guide](docs/ARCHITECTURE.md)** - System architecture details
- **[Deployment Guide](docs/DEPLOYMENT.md)** - Production deployment
- **[User Guide](docs/USER_GUIDE.md)** - End-user documentation
- **[Developer Guide](docs/DEVELOPER_GUIDE.md)** - Development workflows
- **[NextCloud Integration](docs/NEXTCLOUD_INTEGRATION.md)** - DMS integration details

## Development

### Local Development Setup

```bash
# Backend
cd backend
npm install
npm run start:dev

# Frontend
cd frontend
npm install
npm run dev
```

### Running Tests

```bash
# Backend tests
cd backend
npm run test
npm run test:e2e
npm run test:cov

# Frontend tests
cd frontend
npm run test
```

### Database Migrations

```bash
# Generate migration
npm run migration:generate -- src/database/migrations/MigrationName

# Run migrations
npm run migration:run

# Revert migration
npm run migration:revert
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

- **Documentation**: See `/docs` folder
- **Issues**: GitHub Issues
- **Email**: support@ontrack.com (replace with actual support email)

## Roadmap

### Version 1.1 (Q2 2025)
- Email notifications
- Advanced analytics dashboard
- Mobile responsive improvements
- Bulk import/export functionality

### Version 1.2 (Q3 2025)
- Multi-language support
- Advanced reporting
- Custom fields
- Workflow automation

### Version 2.0 (Q4 2025)
- Microservices architecture
- Real-time collaboration
- Advanced AI features
- Mobile applications

## Acknowledgments

- NestJS team for the excellent framework
- Next.js team for the powerful React framework
- NextCloud community for the document management platform
- All open-source contributors

---

**Built with ❤️ for Enterprise Teams**

*For detailed setup instructions, see [INSTALLATION.md](docs/INSTALLATION.md)*
