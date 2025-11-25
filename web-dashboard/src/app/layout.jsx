'use client' // Must be client because we use AuthProvider

import '../styles/globals.css'
import { AuthProvider } from '../context/AuthContext'

export default function RootLayout({ children }) {
  return (
    <AuthProvider>
      <html lang="en">
        <body className="bg-gray-50">
          {children}
        </body>
      </html>
    </AuthProvider>
  )
}
