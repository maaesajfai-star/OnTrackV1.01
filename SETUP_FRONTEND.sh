#!/bin/bash

# UEMS Frontend Setup Script

set -e
ROOT="/home/mahmoud/AI/Projects/claude-Version1"
cd "$ROOT"

echo "Creating Frontend Application..."

# Create globals.css
cat > frontend/src/app/globals.css << 'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  :root {
    --background: 0 0% 100%;
    --foreground: 222.2 84% 4.9%;
    --card: 0 0% 100%;
    --card-foreground: 222.2 84% 4.9%;
    --popover: 0 0% 100%;
    --popover-foreground: 222.2 84% 4.9%;
    --primary: 221.2 83.2% 53.3%;
    --primary-foreground: 210 40% 98%;
    --secondary: 45 100% 51%;
    --secondary-foreground: 222.2 47.4% 11.2%;
    --muted: 210 40% 96.1%;
    --muted-foreground: 215.4 16.3% 46.9%;
    --accent: 210 40% 96.1%;
    --accent-foreground: 222.2 47.4% 11.2%;
    --destructive: 0 84.2% 60.2%;
    --destructive-foreground: 210 40% 98%;
    --border: 214.3 31.8% 91.4%;
    --input: 214.3 31.8% 91.4%;
    --ring: 221.2 83.2% 53.3%;
    --radius: 0.5rem;
  }
}

@layer base {
  * {
    @apply border-border;
  }
  body {
    @apply bg-background text-foreground;
  }
}
EOF

# Create layout
cat > frontend/src/app/layout.tsx << 'EOF'
import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import './globals.css'

const inter = Inter({ subsets: ['latin'] })

export const metadata: Metadata = {
  title: 'UEMS - Unified Enterprise Management System',
  description: 'Enterprise-grade CRM, HRM, and DMS solution',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body className={inter.className}>{children}</body>
    </html>
  )
}
EOF

# Create home page
cat > frontend/src/app/page.tsx << 'EOF'
import Link from 'next/link'
import { Button } from '@/components/ui/button'

export default function Home() {
  return (
    <div className="flex min-h-screen flex-col items-center justify-center p-24">
      <div className="text-center space-y-6">
        <h1 className="text-6xl font-bold bg-gradient-to-r from-blue-600 to-blue-400 bg-clip-text text-transparent">
          UEMS
        </h1>
        <p className="text-2xl text-gray-600">
          Unified Enterprise Management System
        </p>
        <p className="text-lg text-gray-500 max-w-2xl">
          A comprehensive platform for CRM, HRM, and Document Management
        </p>
        <div className="flex gap-4 justify-center pt-8">
          <Link href="/login">
            <Button size="lg">Login</Button>
          </Link>
          <Link href="/dashboard">
            <Button size="lg" variant="outline">Dashboard</Button>
          </Link>
        </div>
        <div className="grid grid-cols-3 gap-8 pt-12 max-w-4xl">
          <div className="p-6 border rounded-lg">
            <h3 className="text-xl font-semibold mb-2">Mini-CRM</h3>
            <p className="text-gray-600">Contact & organization management, deal pipeline, activity tracking</p>
          </div>
          <div className="p-6 border rounded-lg">
            <h3 className="text-xl font-semibold mb-2">HRM</h3>
            <p className="text-gray-600">Employee profiles, job postings, ATS pipeline, CV parsing</p>
          </div>
          <div className="p-6 border rounded-lg">
            <h3 className="text-xl font-semibold mb-2">DMS</h3>
            <p className="text-gray-600">NextCloud integration, document management, auto-provisioning</p>
          </div>
        </div>
      </div>
    </div>
  )
}
EOF

# Create API client
mkdir -p frontend/src/lib
cat > frontend/src/lib/api.ts << 'EOF'
import axios from 'axios';

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001/api/v1';

export const api = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor to add auth token
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('accessToken');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// Response interceptor for token refresh
api.interceptors.response.use(
  (response) => response,
  async (error) => {
    const originalRequest = error.config;

    if (error.response?.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true;

      try {
        const refreshToken = localStorage.getItem('refreshToken');
        const response = await axios.post(`${API_URL}/auth/refresh`, {
          refreshToken,
        });

        const { accessToken } = response.data.data;
        localStorage.setItem('accessToken', accessToken);

        originalRequest.headers.Authorization = `Bearer ${accessToken}`;
        return api(originalRequest);
      } catch (refreshError) {
        localStorage.removeItem('accessToken');
        localStorage.removeItem('refreshToken');
        window.location.href = '/login';
        return Promise.reject(refreshError);
      }
    }

    return Promise.reject(error);
  }
);

// Auth API
export const authApi = {
  login: (email: string, password: string) =>
    api.post('/auth/login', { email, password }),
  register: (data: any) => api.post('/auth/register', data),
  logout: () => api.post('/auth/logout'),
};

// CRM API
export const crmApi = {
  contacts: {
    getAll: () => api.get('/crm/contacts'),
    getOne: (id: string) => api.get(`/crm/contacts/${id}`),
    create: (data: any) => api.post('/crm/contacts', data),
    update: (id: string, data: any) => api.patch(`/crm/contacts/${id}`, data),
    delete: (id: string) => api.delete(`/crm/contacts/${id}`),
  },
  organizations: {
    getAll: () => api.get('/crm/organizations'),
    getOne: (id: string) => api.get(`/crm/organizations/${id}`),
    create: (data: any) => api.post('/crm/organizations', data),
    update: (id: string, data: any) => api.patch(`/crm/organizations/${id}`, data),
    delete: (id: string) => api.delete(`/crm/organizations/${id}`),
  },
  deals: {
    getAll: (stage?: string) => api.get('/crm/deals', { params: { stage } }),
    getOne: (id: string) => api.get(`/crm/deals/${id}`),
    create: (data: any) => api.post('/crm/deals', data),
    update: (id: string, data: any) => api.patch(`/crm/deals/${id}`, data),
    delete: (id: string) => api.delete(`/crm/deals/${id}`),
  },
  activities: {
    getAll: (contactId?: string) => api.get('/crm/activities', { params: { contactId } }),
    getOne: (id: string) => api.get(`/crm/activities/${id}`),
    create: (data: any) => api.post('/crm/activities', data),
    update: (id: string, data: any) => api.patch(`/crm/activities/${id}`, data),
    delete: (id: string) => api.delete(`/crm/activities/${id}`),
  },
};

// HRM API
export const hrmApi = {
  employees: {
    getAll: () => api.get('/hrm/employees'),
    getOne: (id: string) => api.get(`/hrm/employees/${id}`),
    create: (data: any) => api.post('/hrm/employees', data),
    update: (id: string, data: any) => api.patch(`/hrm/employees/${id}`, data),
    delete: (id: string) => api.delete(`/hrm/employees/${id}`),
  },
  jobPostings: {
    getAll: () => api.get('/hrm/job-postings'),
    getOne: (id: string) => api.get(`/hrm/job-postings/${id}`),
    create: (data: any) => api.post('/hrm/job-postings', data),
    update: (id: string, data: any) => api.patch(`/hrm/job-postings/${id}`, data),
    delete: (id: string) => api.delete(`/hrm/job-postings/${id}`),
  },
  candidates: {
    getAll: (params?: any) => api.get('/hrm/candidates', { params }),
    getOne: (id: string) => api.get(`/hrm/candidates/${id}`),
    create: (data: any) => api.post('/hrm/candidates', data),
    update: (id: string, data: any) => api.patch(`/hrm/candidates/${id}`, data),
    delete: (id: string) => api.delete(`/hrm/candidates/${id}`),
    uploadCV: (formData: FormData) => api.post('/hrm/candidates/upload-cv', formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    }),
  },
};

// DMS API
export const dmsApi = {
  listFiles: (path?: string) => api.get('/dms/files', { params: { path } }),
  uploadFile: (formData: FormData, path: string) =>
    api.post(`/dms/upload?path=${path}`, formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    }),
  deleteFile: (path: string) => api.delete(`/dms/files?path=${path}`),
  provision: (data: any) => api.post('/dms/provision', data),
};
EOF

# Create UI components (Button)
mkdir -p frontend/src/components/ui
cat > frontend/src/components/ui/button.tsx << 'EOF'
import * as React from "react"
import { cn } from "@/lib/utils"

export interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'default' | 'destructive' | 'outline' | 'secondary' | 'ghost' | 'link'
  size?: 'default' | 'sm' | 'lg' | 'icon'
}

const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant = 'default', size = 'default', ...props }, ref) => {
    const baseStyles = "inline-flex items-center justify-center whitespace-nowrap rounded-md text-sm font-medium ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50"

    const variants = {
      default: "bg-primary text-primary-foreground hover:bg-primary/90",
      destructive: "bg-destructive text-destructive-foreground hover:bg-destructive/90",
      outline: "border border-input bg-background hover:bg-accent hover:text-accent-foreground",
      secondary: "bg-secondary text-secondary-foreground hover:bg-secondary/80",
      ghost: "hover:bg-accent hover:text-accent-foreground",
      link: "text-primary underline-offset-4 hover:underline",
    }

    const sizes = {
      default: "h-10 px-4 py-2",
      sm: "h-9 rounded-md px-3",
      lg: "h-11 rounded-md px-8",
      icon: "h-10 w-10",
    }

    return (
      <button
        className={cn(baseStyles, variants[variant], sizes[size], className)}
        ref={ref}
        {...props}
      />
    )
  }
)
Button.displayName = "Button"

export { Button }
EOF

# Create utils
cat > frontend/src/lib/utils.ts << 'EOF'
import { type ClassValue, clsx } from "clsx"
import { twMerge } from "tailwind-merge"

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}
EOF

# Create types
mkdir -p frontend/src/types
cat > frontend/src/types/index.ts << 'EOF'
export interface User {
  id: string;
  email: string;
  firstName: string;
  lastName: string;
  role: string;
}

export interface Contact {
  id: string;
  firstName: string;
  lastName: string;
  email: string;
  phone?: string;
  role?: string;
  organizationId?: string;
  organization?: Organization;
  notes?: string;
  createdAt: string;
}

export interface Organization {
  id: string;
  name: string;
  website?: string;
  industry?: string;
  phone?: string;
  address?: string;
  parentOrganizationId?: string;
  notes?: string;
  createdAt: string;
}

export interface Deal {
  id: string;
  title: string;
  value: number;
  stage: 'new' | 'qualified' | 'negotiation' | 'won' | 'lost';
  contactId: string;
  contact?: Contact;
  organizationId?: string;
  organization?: Organization;
  expectedCloseDate?: string;
  description?: string;
  probability: number;
  createdAt: string;
}

export interface Activity {
  id: string;
  type: 'call' | 'email' | 'meeting' | 'note';
  subject: string;
  description?: string;
  contactId: string;
  contact?: Contact;
  activityDate: string;
  durationMinutes?: number;
  createdAt: string;
}

export interface Employee {
  id: string;
  employeeId: string;
  firstName: string;
  lastName: string;
  email: string;
  phoneNumber?: string;
  jobTitle: string;
  department: string;
  startDate: string;
  endDate?: string;
  salary?: number;
  emergencyContactName?: string;
  emergencyContactPhone?: string;
  address?: string;
  dateOfBirth?: string;
  isActive: boolean;
  notes?: string;
  createdAt: string;
}

export interface JobPosting {
  id: string;
  title: string;
  department: string;
  location?: string;
  status: 'draft' | 'open' | 'closed' | 'on_hold';
  description: string;
  requirements?: string;
  salaryMin?: number;
  salaryMax?: number;
  applicationDeadline?: string;
  numberOfOpenings: number;
  createdAt: string;
}

export interface Candidate {
  id: string;
  firstName: string;
  lastName: string;
  email: string;
  phoneNumber?: string;
  jobPostingId: string;
  jobPosting?: JobPosting;
  stage: 'applied' | 'screening' | 'interview' | 'offer' | 'hired' | 'rejected';
  score?: number;
  notes?: string;
  cvFilePath?: string;
  linkedinUrl?: string;
  parsedCvData?: string;
  appliedDate?: string;
  createdAt: string;
}
EOF

echo "✓ Frontend application structure created successfully!"
echo "========================================="
