'use client'
import { 
  LayoutDashboard, 
  Users, 
  BarChart3, 
  Leaf, 
  MapPin,
  Settings 
} from 'lucide-react'
import { useRouter, usePathname } from 'next/navigation'

const navigation = [
  { name: 'Dashboard', href: '/', icon: LayoutDashboard },
  { name: 'Users', href: '/users', icon: Users },
  { name: 'Analytics', href: '/analytics', icon: BarChart3 },
  { name: 'Diseases', href: '/diseases', icon: Leaf },
  { name: 'Regional Data', href: '/regional', icon: MapPin },
  { name: 'Settings', href: '/settings', icon: Settings },
]

export default function Sidebar({ isOpen, onClose }) {
  const router = useRouter()
  const pathname = usePathname()

  const handleNavigation = (href) => {
    router.push(href)
    if (window.innerWidth < 1024) {
      onClose?.()
    }
  }

  return (
    <>
      {/* Overlay for mobile */}
      {isOpen && (
        <div 
          className="fixed inset-0 bg-black bg-opacity-50 z-40 lg:hidden"
          onClick={onClose}
        />
      )}

      {/* Sidebar */}
      <aside className={`
        fixed inset-y-0 left-0 z-50 w-64 bg-white shadow-lg transform transition-transform duration-200 ease-in-out lg:translate-x-0 lg:static lg:inset-0
        ${isOpen ? 'translate-x-0' : '-translate-x-full'}
      `}>
        {/* Logo */}
        <div className="flex items-center justify-center h-16 border-b border-gray-200">
          <div className="flex items-center space-x-2">
            <div className="w-8 h-8 bg-primary-500 rounded-lg flex items-center justify-center">
              <Leaf className="w-5 h-5 text-white" />
            </div>
            <span className="text-xl font-bold text-gray-900">Mkulima AI</span>
          </div>
        </div>

        {/* Navigation */}
        <nav className="mt-8 px-4">
          <ul className="space-y-2">
            {navigation.map((item) => {
              const isActive = pathname === item.href
              const Icon = item.icon
              
              return (
                <li key={item.name}>
                  <button
                    onClick={() => handleNavigation(item.href)}
                    className={`
                      flex items-center space-x-3 w-full px-3 py-3 rounded-lg text-sm font-medium transition-colors duration-200
                      ${isActive 
                        ? 'bg-primary-50 text-primary-700 border-r-2 border-primary-500' 
                        : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'
                      }
                    `}
                  >
                    <Icon className="w-5 h-5" />
                    <span>{item.name}</span>
                  </button>
                </li>
              )
            })}
          </ul>
        </nav>

        {/* Stats Summary */}
        <div className="absolute bottom-6 left-4 right-4">
          <div className="bg-primary-50 rounded-lg p-4 border border-primary-100">
            <p className="text-xs text-primary-600 font-medium">Platform Status</p>
            <p className="text-sm text-primary-800 mt-1">All systems operational</p>
          </div>
        </div>
      </aside>
    </>
  )
}
