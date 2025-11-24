'use client'
import { AuthProvider } from '../context/AuthContext'
import Dashboard from '../pages/Dashboard'

export default function Home() {
  return (
    <AuthProvider>
      <Dashboard />
    </AuthProvider>
  )
}
