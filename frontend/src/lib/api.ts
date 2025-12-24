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
