/** @type {import('next').NextConfig} */
const nextConfig = {
  experimental: {
    appDir: true,
  },
  images: {
    domains: ['localhost'],
  },
  env: {
    API_BASE_URL: process.env.API_BASE_URL || 'http://localhost:5000/api/v1',
  }
}

export default nextConfig
