'use client'

import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import Link from 'next/link'
import { Button } from '@/components/ui/button'

interface User {
  id: string
  email: string
  firstName: string
  lastName: string
  role: string
}

export default function DashboardPage() {
  const router = useRouter()
  const [user, setUser] = useState<User | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const storedUser = localStorage.getItem('user')
    const token = localStorage.getItem('accessToken')

    if (!token || !storedUser) {
      router.push('/login')
      return
    }

    try {
      setUser(JSON.parse(storedUser))
    } catch {
      router.push('/login')
    }
    setLoading(false)
  }, [router])

  const handleLogout = () => {
    localStorage.removeItem('accessToken')
    localStorage.removeItem('refreshToken')
    localStorage.removeItem('user')
    router.push('/login')
  }

  if (loading) {
    return (
      <div className="flex min-h-screen items-center justify-center">
        <div className="text-xl">Loading...</div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gray-100">
      {/* Header */}
      <header className="bg-white shadow">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4 flex justify-between items-center">
          <h1 className="text-2xl font-bold text-gray-900">OnTrack Dashboard</h1>
          <div className="flex items-center gap-4">
            <span className="text-gray-600">
              Welcome, {user?.firstName} {user?.lastName}
            </span>
            <Button variant="outline" onClick={handleLogout}>
              Logout
            </Button>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Stats Cards */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
          <div className="bg-white rounded-lg shadow p-6">
            <h3 className="text-sm font-medium text-gray-500">Total Contacts</h3>
            <p className="text-3xl font-bold text-gray-900 mt-2">0</p>
          </div>
          <div className="bg-white rounded-lg shadow p-6">
            <h3 className="text-sm font-medium text-gray-500">Active Deals</h3>
            <p className="text-3xl font-bold text-gray-900 mt-2">0</p>
          </div>
          <div className="bg-white rounded-lg shadow p-6">
            <h3 className="text-sm font-medium text-gray-500">Employees</h3>
            <p className="text-3xl font-bold text-gray-900 mt-2">0</p>
          </div>
          <div className="bg-white rounded-lg shadow p-6">
            <h3 className="text-sm font-medium text-gray-500">Documents</h3>
            <p className="text-3xl font-bold text-gray-900 mt-2">0</p>
          </div>
        </div>

        {/* Module Cards */}
        <h2 className="text-xl font-semibold text-gray-900 mb-4">Modules</h2>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {/* CRM Module */}
          <div className="bg-white rounded-lg shadow p-6">
            <div className="flex items-center mb-4">
              <div className="w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center">
                <svg className="w-6 h-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
                </svg>
              </div>
              <h3 className="text-lg font-semibold text-gray-900 ml-4">Mini-CRM</h3>
            </div>
            <p className="text-gray-600 mb-4">Manage contacts, organizations, deals, and activities.</p>
            <Link href="/dashboard/crm">
              <Button className="w-full">Open CRM</Button>
            </Link>
          </div>

          {/* HRM Module */}
          <div className="bg-white rounded-lg shadow p-6">
            <div className="flex items-center mb-4">
              <div className="w-12 h-12 bg-green-100 rounded-lg flex items-center justify-center">
                <svg className="w-6 h-6 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 13.255A23.931 23.931 0 0112 15c-3.183 0-6.22-.62-9-1.745M16 6V4a2 2 0 00-2-2h-4a2 2 0 00-2 2v2m4 6h.01M5 20h14a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
                </svg>
              </div>
              <h3 className="text-lg font-semibold text-gray-900 ml-4">HRM</h3>
            </div>
            <p className="text-gray-600 mb-4">Employee management, job postings, and recruitment.</p>
            <Link href="/dashboard/hrm">
              <Button className="w-full" variant="outline">Open HRM</Button>
            </Link>
          </div>

          {/* DMS Module */}
          <div className="bg-white rounded-lg shadow p-6">
            <div className="flex items-center mb-4">
              <div className="w-12 h-12 bg-purple-100 rounded-lg flex items-center justify-center">
                <svg className="w-6 h-6 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                </svg>
              </div>
              <h3 className="text-lg font-semibold text-gray-900 ml-4">DMS</h3>
            </div>
            <p className="text-gray-600 mb-4">Document management with NextCloud integration.</p>
            <Link href="/dashboard/dms">
              <Button className="w-full" variant="outline">Open DMS</Button>
            </Link>
          </div>
        </div>

        {/* Quick Actions */}
        <h2 className="text-xl font-semibold text-gray-900 mt-8 mb-4">Quick Actions</h2>
        <div className="bg-white rounded-lg shadow p-6">
          <div className="flex flex-wrap gap-4">
            <Link href="/dashboard/crm/contacts/new">
              <Button variant="outline">+ New Contact</Button>
            </Link>
            <Link href="/dashboard/crm/deals/new">
              <Button variant="outline">+ New Deal</Button>
            </Link>
            <Link href="/dashboard/hrm/employees/new">
              <Button variant="outline">+ New Employee</Button>
            </Link>
            <Link href="/dashboard/hrm/jobs/new">
              <Button variant="outline">+ New Job Posting</Button>
            </Link>
          </div>
        </div>
      </main>
    </div>
  )
}
