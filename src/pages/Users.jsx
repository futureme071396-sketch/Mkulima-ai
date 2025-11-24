'use client'
import { useState } from 'react'
import UserManagement from '../components/Forms/UserManagement'

export default function Users() {
  return (
    <div className="min-h-screen bg-gray-50">
      <div className="p-6">
        {/* Header */}
        <div className="mb-6">
          <h2 className="text-2xl font-bold text-gray-900">User Management</h2>
          <p className="text-gray-600 mt-1">
            Manage farmers and monitor their activities
          </p>
        </div>

        {/* User Management Component */}
        <UserManagement />
      </div>
    </div>
  )
}
