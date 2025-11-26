'use client'
export const dynamic = "force-client";

import { useState } from "react";
import Header from "../components/Common/Header";
import Sidebar from "../components/Common/Sidebar";
import StatsCards from "../components/Dashboard/StatsCards";
import DiseaseMap from "../components/Dashboard/DiseaseMap";
import AnalyticsChart from "../components/Dashboard/AnalyticsChart";
import AddDisease from "../components/Forms/AddDisease";

export default function Dashboard() {
  const [sidebarOpen, setSidebarOpen] = useState(false);

  return (
    <div className="min-h-screen bg-gray-50">
      <Sidebar 
        isOpen={sidebarOpen} 
        onClose={() => setSidebarOpen(false)} 
      />

      <div className="lg:ml-64">
        <Header onMenuToggle={() => setSidebarOpen(!sidebarOpen)} />

        <main className="p-6">
          <div className="flex items-center justify-between mb-6">
            <div>
              <h2 className="text-2xl font-bold text-gray-900">Dashboard Overview</h2>
              <p className="text-gray-600 mt-1">Welcome to your Mkulima AI admin dashboard</p>
            </div>
            <AddDisease />
          </div>

          <div className="mb-8">
            <StatsCards />
          </div>

          <div className="grid grid-cols-1 xl:grid-cols-2 gap-6 mb-8">
            <AnalyticsChart />
            <DiseaseMap />
          </div>

          <div className="bg-white rounded-lg shadow-sm border p-6">
            <h3 className="text-lg font-semibold mb-4">Recent Activity</h3>

            {[
              'John Kamau detected Maize Lethal Necrosis with 85% confidence',
              'New user registered from Central region',
              'System update completed successfully',
              'Mary Wanjiku successfully treated Coffee Leaf Rust'
            ].map((activity, i) => (
              <div key={i} className="flex items-center text-sm space-x-3 mb-2">
                <div className="w-2 h-2 bg-green-500 rounded-full"></div>
                <span className="text-gray-600">{activity}</span>
                <span className="ml-auto text-gray-400">2 hours ago</span>
              </div>
            ))}
          </div>
        </main>
      </div>
    </div>
  );
}
