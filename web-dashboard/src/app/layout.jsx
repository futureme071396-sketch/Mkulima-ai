'use client';

import '../styles/globals.css';
import { AuthProvider } from '../context/AuthContext';

export const metadata = {
  title: 'Mkulima AI Dashboard',
  description: 'Admin dashboard for plant disease detection platform',
};

export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <body className="bg-gray-50">
        <AuthProvider>
          {children}
        </AuthProvider>
      </body>
    </html>
  );
}
