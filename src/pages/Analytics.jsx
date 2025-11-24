'use client'
import { useState, useEffect } from 'react'
import { 
  BarChart, 
  Bar, 
  XAxis, 
  YAxis, 
  CartesianGrid, 
  Tooltip, 
  Legend, 
  ResponsiveContainer,
  PieChart,
  Pie,
  Cell,
  LineChart,
  Line
} from 'recharts'
import { analyticsService } from '../services/api'

const COLORS = ['#0088FE', '#00C49F', '#FFBB28', '#FF8042', '#8884D8']

export default function Analytics() {
  const [overviewData, setOverviewData] = useState(null)
  const [trendData, setTrendData] = useState([])
  const [regionalData, setRegionalData] = useState({})
  const [loading, setLoading] = useState(true)
  const [activeTab, setActiveTab] = useState('overview')

  useEffect(() => {
    const fetchData = async () => {
      try {
        const [overview, trends, regional] = await Promise.all([
          analyticsService.getOverview(),
          analyticsService.getDiseaseTrends(7),
          analyticsService.getRegionalInsights()
        ])

        setOverviewData(overview.overview)
        setTrendData(trends.trends || [])
        setRegionalData(regional.regional_insights || {})
      } catch (error) {
        console.error('Failed to fetch analytics data:', error)
        // Fallback data
        setOverviewData({
          total_users: 1250,
          total_detections: 8920,
          active_today: 187,
          success_rate: 0.78,
          common_diseases: [
            { disease: 'Maize Lethal Necrosis', count: 2340 },
            { disease: 'Coffee Leaf Rust', count: 1876 },
            { disease: 'Tomato Late Blight', count: 1567 }
          ],
          regional_distribution: {
            'Central': 450,
            'Rift Valley': 320,
            'Eastern': 280
          }
        })
      } finally {
        setLoading(false)
      }
    }

    fetchData()
  }, [])

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 p-6">
        <div className="animate-pulse">
          <div className="h-8 bg-gray-200 rounded w-1/4 mb-4"></div>
          <div className="h-4 bg-gray-200 rounded w-1/2 mb-8"></div>
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
            <div className="h-80 bg-gray-200 rounded"></div>
            <div className="h-80 bg-gray-200 rounded"></div>
          </div>
        </div>
      </div>
    )
  }

  const regionalChartData = Object.entries(regionalData).map(([region, data]) => ({
    name: region,
    cases: data.total_detections || data.cases || 0,
    users: data.active_users || 0
  }))

  const diseaseChartData = overviewData?.common_diseases || []

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="p-6">
        <div className="mb-6">
          <h2 className="text-2xl font-bold text-gray-900">Advanced Analytics</h2>
          <p className="text-gray-600 mt-1">Deep insights into platform performance</p>
        </div>

        <div className="flex space-x-2 mb-6">
          {['overview', 'regional', 'trends', 'diseases'].map((tab) => (
            <button
              key={tab}
              onClick={() => setActiveTab(tab)}
              className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
                activeTab === tab
                  ? 'bg-primary-500 text-white'
                  : 'bg-white text-gray-600 hover:bg-gray-50 border border-gray-200'
              }`}
            >
              {tab.charAt(0).toUpperCase() + tab.slice(1)}
            </button>
          ))}
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {activeTab === 'overview' && (
            <>
              <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
                <h3 className="text-lg font-semibold mb-4">Platform Overview</h3>
                <div className="space-y-4">
                  <div className="flex justify-between">
                    <span className="text-gray-600">Total Users</span>
                    <span className="font-semibold">{overviewData?.total_users?.toLocaleString()}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-gray-600">Total Detections</span>
                    <span className="font-semibold">{overviewData?.total_detections?.toLocaleString()}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-gray-600">Active Today</span>
                    <span className="font-semibold">{overviewData?.active_today}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-gray-600">Success Rate</span>
                    <span className="font-semibold text-green-600">
                      {Math.round((overviewData?.success_rate || 0) * 100)}%
                    </span>
                  </div>
                </div>
              </div>

              <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
                <h3 className="text-lg font-semibold mb-4">Top Diseases</h3>
                <div className="h-64">
                  <ResponsiveContainer width="100%" height="100%">
                    <PieChart>
                      <Pie
                        data={diseaseChartData}
                        cx="50%"
                        cy="50%"
                        labelLine={false}
                        label={({ disease, percent }) => `${disease}: ${(percent * 100).toFixed(0)}%`}
                        outerRadius={80}
                        fill="#8884d8"
                        dataKey="count"
                      >
                        {diseaseChartData.map((entry, index) => (
                          <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                        ))}
                      </Pie>
                      <Tooltip />
                    </PieChart>
                  </ResponsiveContainer>
                </div>
              </div>
            </>
          )}

          {activeTab === 'regional' && (
            <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6 col-span-2">
              <h3 className="text-lg font-semibold mb-4">Regional Distribution</h3>
              <div className="h-80">
                <ResponsiveContainer width="100%" height="100%">
                  <BarChart data={regionalChartData}>
                    <CartesianGrid strokeDasharray="3 3" />
                    <XAxis dataKey="name" />
                    <YAxis />
                    <Tooltip />
                    <Legend />
                    <Bar dataKey="cases" fill="#0088FE" name="Disease Cases" />
                    <Bar dataKey="users" fill="#00C49F" name="Active Users" />
                  </BarChart>
                </ResponsiveContainer>
              </div>
            </div>
          )}

          {activeTab === 'trends' && (
            <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6 col-span-2">
              <h3 className="text-lg font-semibold mb-4">Weekly Trends</h3>
              <div className="h-80">
                <ResponsiveContainer width="100%" height="100%">
                  <LineChart data={trendData}>
                    <CartesianGrid strokeDasharray="3 3" />
                    <XAxis dataKey="date" />
                    <YAxis />
                    <Tooltip />
                    <Legend />
                    <Line type="monotone" dataKey="total_detections" stroke="#0088FE" name="Total Detections" />
                    <Line type="monotone" dataKey="maize_diseases" stroke="#00C49F" name="Maize Diseases" />
                    <Line type="monotone" dataKey="coffee_diseases" stroke="#FFBB28" name="Coffee Diseases" />
                  </LineChart>
                </ResponsiveContainer>
              </div>
            </div>
          )}

          {activeTab === 'diseases' && (
            <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6 col-span-2">
              <h3 className="text-lg font-semibold mb-4">Disease Analysis</h3>
              <div className="h-80">
                <ResponsiveContainer width="100%" height="100%">
                  <BarChart data={diseaseChartData}>
                    <CartesianGrid strokeDasharray="3 3" />
                    <XAxis dataKey="disease" />
                    <YAxis />
                    <Tooltip />
                    <Legend />
                    <Bar dataKey="count" fill="#8884d8" name="Cases Reported" />
                  </BarChart>
                </ResponsiveContainer>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
