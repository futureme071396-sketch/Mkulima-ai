import api from './api'

export const authService = {
  // Login user
  login: async (email, password) => {
    try {
      // For demo purposes, we'll use a mock login
      // In production, this would call your actual backend
      if (email === 'admin@mkulima.ai' && password === 'admin') {
        const mockUser = {
          id: 1,
          name: 'Admin User',
          email: 'admin@mkulima.ai',
          role: 'Administrator',
          permissions: ['read', 'write', 'admin']
        }
        
        const mockToken = 'mock-jwt-token-for-demo'
        localStorage.setItem('auth_token', mockToken)
        localStorage.setItem('user', JSON.stringify(mockUser))
        
        return {
          success: true,
          user: mockUser,
          token: mockToken
        }
      } else {
        throw new Error('Invalid credentials')
      }
    } catch (error) {
      throw error
    }
  },

  // Logout user
  logout: () => {
    localStorage.removeItem('auth_token')
    localStorage.removeItem('user')
  },

  // Get current user
  getCurrentUser: () => {
    try {
      const userStr = localStorage.getItem('user')
      return userStr ? JSON.parse(userStr) : null
    } catch (error) {
      console.error('Error getting current user:', error)
      return null
    }
  },

  // Check if user is authenticated
  isAuthenticated: () => {
    return !!localStorage.getItem('auth_token')
  },

  // Verify token (mock implementation)
  verifyToken: async () => {
    // In production, this would verify the token with your backend
    return new Promise((resolve) => {
      setTimeout(() => {
        resolve(!!localStorage.getItem('auth_token'))
      }, 1000)
    })
  },

  // Refresh token
  refreshToken: async () => {
    // Mock implementation
    return new Promise((resolve) => {
      setTimeout(() => {
        const newToken = 'refreshed-mock-token'
        localStorage.setItem('auth_token', newToken)
        resolve(newToken)
      }, 1000)
    })
  },

  // Check user permissions
  hasPermission: (permission) => {
    const user = authService.getCurrentUser()
    return user?.permissions?.includes(permission) || false
  },

  // Check if user is admin
  isAdmin: () => {
    const user = authService.getCurrentUser()
    return user?.role === 'Administrator'
  }
}

export default authService
