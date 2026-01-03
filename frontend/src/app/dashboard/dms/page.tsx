'use client'

import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import Link from 'next/link'
import { Button } from '@/components/ui/button'

export default function DMSPage() {
  const router = useRouter()
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const token = localStorage.getItem('accessToken')
    if (!token) {
      router.push('/login')
      return
    }
    setLoading(false)
  }, [router])

  if (loading) {
    return (
      <div className="flex min-h-screen items-center justify-center">
        <div className="text-xl">Loading...</div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gray-100">
      <header className="bg-white shadow">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4 flex justify-between items-center">
          <div className="flex items-center gap-4">
            <Link href="/dashboard" className="text-gray-500 hover:text-gray-700">
              ← Back
            </Link>
            <h1 className="text-2xl font-bold text-gray-900">Document Management</h1>
          </div>
        </div>
      </header>

      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Navigation Tabs */}
        <div className="bg-white rounded-lg shadow mb-6">
          <nav className="flex border-b">
            <Link href="/dashboard/dms" className="px-6 py-4 text-blue-600 border-b-2 border-blue-600 font-medium">
              Overview
            </Link>
            <Link href="/dashboard/dms/files" className="px-6 py-4 text-gray-500 hover:text-gray-700">
              Files
            </Link>
            <Link href="/dashboard/dms/folders" className="px-6 py-4 text-gray-500 hover:text-gray-700">
              Folders
            </Link>
            <Link href="/dashboard/dms/shared" className="px-6 py-4 text-gray-500 hover:text-gray-700">
              Shared
            </Link>
          </nav>
        </div>

        {/* Stats */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
          <div className="bg-white rounded-lg shadow p-6">
            <h3 className="text-sm font-medium text-gray-500">Total Files</h3>
            <p className="text-3xl font-bold text-gray-900 mt-2">0</p>
          </div>
          <div className="bg-white rounded-lg shadow p-6">
            <h3 className="text-sm font-medium text-gray-500">Folders</h3>
            <p className="text-3xl font-bold text-gray-900 mt-2">0</p>
          </div>
          <div className="bg-white rounded-lg shadow p-6">
            <h3 className="text-sm font-medium text-gray-500">Storage Used</h3>
            <p className="text-3xl font-bold text-gray-900 mt-2">0 MB</p>
          </div>
          <div className="bg-white rounded-lg shadow p-6">
            <h3 className="text-sm font-medium text-gray-500">Shared Items</h3>
            <p className="text-3xl font-bold text-gray-900 mt-2">0</p>
          </div>
        </div>

        {/* NextCloud Integration */}
        <div className="bg-white rounded-lg shadow p-6 mb-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">NextCloud Integration</h2>
          <p className="text-gray-600 mb-4">
            Documents are stored and managed through NextCloud. Access your files directly or use the integration below.
          </p>
          <div className="flex gap-4">
            <a href="/nextcloud" target="_blank" rel="noopener noreferrer">
              <Button>Open NextCloud</Button>
            </a>
            <Button variant="outline">Sync Files</Button>
          </div>
        </div>

        {/* Quick Actions */}
        <div className="bg-white rounded-lg shadow p-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">Quick Actions</h2>
          <div className="flex flex-wrap gap-4">
            <Button>+ Upload File</Button>
            <Button variant="outline">+ New Folder</Button>
            <Button variant="outline">Share Document</Button>
          </div>
        </div>

        {/* Recent Documents */}
        <div className="bg-white rounded-lg shadow p-6 mt-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">Recent Documents</h2>
          <p className="text-gray-500">No recent documents to display.</p>
        </div>
      </main>
    </div>
  )
}
