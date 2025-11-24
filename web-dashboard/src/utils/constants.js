// API Configuration
export const API_CONFIG = {
  BASE_URL: process.env.NEXT_PUBLIC_API_BASE_URL || 'http://localhost:5000/api/v1',
  TIMEOUT: 30000,
  RETRY_ATTEMPTS: 3
}

// Application Constants
export const APP_CONSTANTS = {
  APP_NAME: 'Mkulima AI Dashboard',
  VERSION: '1.0.0',
  DESCRIPTION: 'Admin dashboard for plant disease detection platform',
  SUPPORT_EMAIL: 'support@mkulima.ai',
  COMPANY: 'Mkulima AI Technologies'
}

// Plant Types
export const PLANT_TYPES = {
  MAIZE: {
    key: 'maize',
    name: 'Maize',
    localName: 'Mahindi',
    scientificName: 'Zea mays',
    color: '#FFD700'
  },
  COFFEE: {
    key: 'coffee',
    name: 'Coffee',
    localName: 'Kahawa',
    scientificName: 'Coffea arabica',
    color: '#8B4513'
  },
  TOMATO: {
    key: 'tomato',
    name: 'Tomato',
    localName: 'Nyanya',
    scientificName: 'Solanum lycopersicum',
    color: '#FF6347'
  },
  BANANA: {
    key: 'banana',
    name: 'Banana',
    localName: 'Ndizi',
    scientificName: 'Musa spp.',
    color: '#FFD700'
  },
  BEANS: {
    key: 'beans',
    name: 'Beans',
    localName: 'Maharage',
    scientificName: 'Phaseolus vulgaris',
    color: '#8B4513'
  }
}

// Disease Severity Levels
export const DISEASE_SEVERITY = {
  LOW: {
    key: 'low',
    label: 'Low',
    color: '#10B981',
    description: 'Minor impact, easily treatable'
  },
  MEDIUM: {
    key: 'medium',
    label: 'Medium',
    color: '#F59E0B',
    description: 'Moderate impact, requires treatment'
  },
  HIGH: {
    key: 'high',
    label: 'High',
    color: '#EF4444',
    description: 'Severe impact, immediate action needed'
  },
  CRITICAL: {
    key: 'critical',
    label: 'Critical',
    color: '#7C2D12',
    description: 'Emergency situation, crop loss likely'
  }
}

// Kenyan Regions
export const KENYAN_REGIONS = [
  'Nairobi',
  'Central',
  'Rift Valley',
  'Eastern',
  'Western',
  'Nyanza',
  'Coast',
  'North Eastern'
]

// User Roles
export const USER_ROLES = {
  ADMIN: 'Administrator',
  OFFICER: 'Agricultural Officer',
  FARMER: 'Farmer',
  VIEWER: 'Viewer'
}

// Chart Colors
export const CHART_COLORS = [
  '#0088FE', '#00C49F', '#FFBB28', '#FF8042', '#8884D8',
  '#82CA9D', '#FFC658', '#8DD1E1', '#FF7C7C', '#A4DE6C'
]

// Local Storage Keys
export const STORAGE_KEYS = {
  AUTH_TOKEN: 'auth_token',
  USER_DATA: 'user',
  THEME_PREFERENCE: 'theme_preference',
  LANGUAGE: 'language'
}

// Feature Flags
export const FEATURE_FLAGS = {
  ADVANCED_ANALYTICS: true,
  REAL_TIME_UPDATES: false,
  MULTI_LANGUAGE: true,
  EXPORT_REPORTS: true,
  BULK_ACTIONS: true
}

// Date Formats
export const DATE_FORMATS = {
  DISPLAY: 'DD MMM YYYY',
  API: 'YYYY-MM-DD',
  DATETIME: 'DD MMM YYYY HH:mm',
  TIME: 'HH:mm'
}

// Pagination
export const PAGINATION = {
  DEFAULT_PAGE_SIZE: 50,
  MAX_PAGE_SIZE: 100,
  PAGE_SIZES: [10, 25, 50, 100]
}

// Export options
export const EXPORT_OPTIONS = {
  FORMATS: ['CSV', 'JSON', 'PDF', 'EXCEL'],
  MAX_RECORDS: 10000
}

export default {
  API_CONFIG,
  APP_CONSTANTS,
  PLANT_TYPES,
  DISEASE_SEVERITY,
  KENYAN_REGIONS,
  USER_ROLES,
  CHART_COLORS,
  STORAGE_KEYS,
  FEATURE_FLAGS,
  DATE_FORMATS,
  PAGINATION,
  EXPORT_OPTIONS
}
