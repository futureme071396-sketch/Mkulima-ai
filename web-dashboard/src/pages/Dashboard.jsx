'use client'
import { useState } from 'react'
import Header from '../components/Common/Header'
import Sidebar from '../components/Common/Sidebar'
import StatsCards from '../components/Dashboard/StatsCards'
import DiseaseMap from '../components/Dashboard/DiseaseMap'
import AnalyticsChart from '../components/Dashboard/AnalyticsChart'
import AddDisease from '../components/Forms/AddDisease'

export default function Dashboard() {
  const [sidebarOpen, setSidebarOpen] = useState(false)

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Sidebar */}
      <Sidebar 
        isOpen={sidebarOpen} 
        onClose={() => setSidebarOpen(false)} 
      />
      
      {/* Main Content */}
      <div className="lg:ml-64">
        {/* Header */}
        <Header onMenuToggle={() => setSidebarOpen(!sidebarOpen)} />
        
        {/* Page Content */}
        <main className="p-6">
          {/* Header Actions */}
          <div className="flex items-center justify-between mb-6">
            <div>
              <h2 className="text-2xl font-bold text-gray-900">Dashboard Overview</h2>
              <p className="text-gray-600 mt-1">
                Welcome to your Mkulima AI admin dashboard
              </p>
            </div>
            <AddDisease />
          </div>

          {/* Stats Cards */}
          <div className="mb-8">
            <StatsCards />
          </div>

          {/* Charts Grid */}
          <div className="grid grid-cols-1 xl:grid-cols-2 gap-6 mb-8">
            <AnalyticsChart />
            <DiseaseMap />
          </div>

          {/* Recent Activity */}
          <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">Recent Activity</h3>
            <div className="space-y-3">
              {[
                'John Kamau detected Maize Lethal Necrosis with 85% confidence',
                'New user registered from Central region',
                'System update completed successfully',
                'Mary Wanjiku successfully treated Coffee Leaf Rust'
              ].map((activity, index) => (
                <div key={index} className="flex items-center space-x-3 text-sm">
                  <div className="w-2 h-2 bg-primary-500 rounded-full"></div>
                  <span className="text-gray-600">{activity}</span>
                  <span className="text-gray-400 ml-auto">2 hours ago</span>
                </div>
              ))}
            </div>
          </div>
        </main>
      </div>
    </div>
  )
}
