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
