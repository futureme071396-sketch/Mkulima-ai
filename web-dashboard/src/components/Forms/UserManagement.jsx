'use client'
import { useState } from 'react'
import { Search, Filter, MoreVertical, Mail, Phone, MapPin } from 'lucide-react'

const mockUsers = [
  {
    id: 1,
    name: 'John Kamau',
    email: 'john@example.com',
    phone: '+254712345678',
    region: 'Central',
    farmSize: 2.5,
    totalScans: 45,
    successRate: 82,
    joinedDate: '2024-01-15'
  },
  {
    id: 2,
    name: 'Mary Wanjiku',
    email: 'mary@example.com',
    phone: '+254723456789',
    region: 'Rift Valley',
    farmSize: 3.2,
    totalScans: 67,
    successRate: 75,
    joinedDate: '2024-01-10'
  },
  {
    id: 3,
    name: 'James Omondi',
    email: 'james@example.com',
    phone: '+254734567890',
    region: 'Eastern',
    farmSize: 1.8,
    totalScans: 23,
    successRate: 91,
    joinedDate: '2024-01-20'
  }
]

export default function UserManagement() {
  const [users] = useState(mockUsers)
  const [searchTerm, setSearchTerm] = useState('')
  const [filterRegion, setFilterRegion] = useState('')

  const filteredUsers = users.filter(user =>
    user.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
    user.email.toLowerCase().includes(searchTerm.toLowerCase())
  ).filter(user =>
    filterRegion ? user.region === filterRegion : true
  )

  const regions = [...new Set(users.map(user => user.region))]

  return (
    <div className="bg-white rounded-lg shadow-sm border border-gray-200">
      {/* Header */}
      <div className="p-6 border-b border-gray-200">
        <div className="flex items-center justify-between">
          <div>
            <h3 className="text-lg font-semibold text-gray-900">User Management</h3>
            <p className="text-sm text-gray-600 mt-1">Manage farmers and their activities</p>
          </div>
          <div className="flex items-center space-x-3">
            <div className="relative">
              <Search className="w-4 h-4 absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" />
              <input
                type="text"
                placeholder="Search users..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
              />
            </div>
            <select
              value={filterRegion}
              onChange={(e) => setFilterRegion(e.target.value)}
              className="px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
            >
              <option value="">All Regions</option>
              {regions.map(region => (
                <option key={region} value={region}>{region}</option>
              ))}
            </select>
          </div>
        </div>
      </div>

      {/* Users Table */}
      <div className="overflow-x-auto">
        <table className="w-full">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                User
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Contact
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Farm Details
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Activity
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Actions
              </th>
            </tr>
          </thead>
          <tbody className="bg-white divide-y divide-gray-200">
            {filteredUsers.map((user) => (
              <tr key={user.id} className="hover:bg-gray-50">
                <td className="px-6 py-4 whitespace-nowrap">
                  <div>
                    <div className="text-sm font-medium text-gray-900">{user.name}</div>
                    <div className="text-sm text-gray-500">Joined {user.joinedDate}</div>
                  </div>
                </td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <div className="flex items-center space-x-2 text-sm text-gray-900">
                    <Mail className="w-4 h-4" />
                    <span>{user.email}</span>
                  </div>
                  <div className="flex items-center space-x-2 text-sm text-gray-500 mt-1">
                    <Phone className="w-4 h-4" />
                    <span>{user.phone}</span>
                  </div>
                </td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <div className="flex items-center space-x-2 text-sm text-gray-900">
                    <MapPin className="w-4 h-4" />
                    <span>{user.region}</span>
                  </div>
                  <div className="text-sm text-gray-500 mt-1">
                    {user.farmSize} acres
                  </div>
                </td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <div className="text-sm text-gray-900">{user.totalScans} scans</div>
                  <div className="text-sm text-gray-500">
                    <span className={`px-2 py-1 rounded-full text-xs ${
                      user.successRate >= 80 
                        ? 'bg-green-100 text-green-800'
                        : user.successRate >= 60
                        ? 'bg-yellow-100 text-yellow-800'
                        : 'bg-red-100 text-red-800'
                    }`}>
                      {user.successRate}% success
                    </span>
                  </div>
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  <button className="text-gray-400 hover:text-gray-600">
                    <MoreVertical className="w-4 h-4" />
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {/* Empty State */}
      {filteredUsers.length === 0 && (
        <div className="text-center py-12">
          <div className="text-gray-400 mb-2">No users found</div>
          <div className="text-sm text-gray-500">
            Try adjusting your search or filter criteria
          </div>
        </div>
      )}
    </div>
  )
}
