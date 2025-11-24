import '../styles/globals.css'

export const metadata = {
  title: 'Mkulima AI Dashboard',
  description: 'Admin dashboard for plant disease detection platform',
}

export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <body className="bg-gray-50">
        {children}
      </body>
    </html>
  )
}
