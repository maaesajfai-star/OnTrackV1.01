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
