import axios from 'axios'

const API_BASE_URL = process.env.API_BASE_URL || 'http://localhost:5000/api/v1'

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
})

// Add auth token to requests
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('auth_token')
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

export const authService = {
  login: async (email) => {
    const response = await api.post('/login', { email })
    if (response.data.token) {
      localStorage.setItem('auth_token', response.data.token)
    }
    return response.data
  },
  
  logout: () => {
    localStorage.removeItem('auth_token')
  },
  
  getCurrentUser: async () => {
    // For demo, return mock user
    return {
      id: 1,
      name: 'Admin User',
      email: 'admin@mkulima.ai',
      role: 'Administrator'
    }
  }
}

export const analyticsService = {
  getOverview: async () => {
    const response = await api.get('/analytics/overview')
    return response.data
  },
  
  getDiseaseTrends: async (days = 30) => {
    const response = await api.get(`/analytics/disease-trends?days=${days}`)
    return response.data
  },
  
  getRegionalInsights: async () => {
    const response = await api.get('/analytics/regional-insights')
    return response.data
  },
  
  getUserGrowth: async () => {
    const response = await api.get('/analytics/user-growth')
    return response.data
  }
}

export const userService = {
  getUsers: async (limit = 50, offset = 0) => {
    // This would typically come from your API
    // For now, return mock data
    return {
      users: [],
      total: 0,
      limit,
      offset
    }
  },
  
  getUserStats: async (userId) => {
    const response = await api.get(`/users/${userId}/stats`)
    return response.data
  }
}

export default api
