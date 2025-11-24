'use client'
import { useEffect, useState } from 'react'
import { 
  LineChart, 
  Line, 
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
  Cell
} from 'recharts'
import { analyticsService } from '../../services/api'

const COLORS = ['#0088FE', '#00C49F', '#FFBB28', '#FF8042', '#8884D8']

export default function AnalyticsChart() {
  const [trendData, setTrendData] = useState([])
  const [diseaseData, setDiseaseData] = useState([])
  const [activeTab, setActiveTab] = useState('trends')
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const fetchData = async () => {
      try {
        const [trendsResponse, overviewResponse] = await Promise.all([
          analyticsService.getDiseaseTrends(),
          analyticsService.getOverview()
        ])

        setTrendData(trendsResponse.trends || [])
        
        // Transform disease data for pie chart
        const diseases = overviewResponse.overview?.common_diseases || []
        setDiseaseData(diseases)
      } catch (error) {
        console.error('Failed to fetch analytics data:', error)
        // Fallback data
        setTrendData(generateMockTrends())
        setDiseaseData([
          { disease: 'Maize Lethal Necrosis', count: 2340 },
          { disease: 'Coffee Leaf Rust', count: 1876 },
          { disease: 'Tomato Late Blight', count: 1567 },
          { disease: 'Banana Sigatoka', count: 1234 },
          { disease: 'Other', count: 1903 }
        ])
      } finally {
        setLoading(false)
      }
    }

    fetchData()
  }, [])

  const generateMockTrends = () => {
    const trends = []
    for (let i = 0; i < 30; i++) {
      trends.push({
        date: `2024-01-${String(i + 1).padStart(2, '0')}`,
        maize_diseases: 50 + Math.floor(Math.random() * 20),
        coffee_diseases: 30 + Math.floor(Math.random() * 15),
        tomato_diseases: 25 + Math.floor(Math.random() * 10),
        banana_diseases: 20 + Math.floor(Math.random() * 8)
      })
    }
    return trends
  }

  if (loading) {
    return (
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <div className="h-64 bg-gray-200 rounded animate-pulse"></div>
      </div>
    )
  }

  return (
    <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
      <div className="flex items-center justify-between mb-6">
        <h3 className="text-lg font-semibold text-gray-900">Analytics Overview</h3>
        <div className="flex space-x-2">
          <button
            onClick={() => setActiveTab('trends')}
            className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
              activeTab === 'trends'
                ? 'bg-primary-500 text-white'
                : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
            }`}
          >
            Trends
          </button>
          <button
            onClick={() => setActiveTab('diseases')}
            className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
              activeTab === 'diseases'
                ? 'bg-primary-500 text-white'
                : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
            }`}
          >
            Diseases
          </button>
        </div>
      </div>

      <div className="h-80">
        <ResponsiveContainer width="100%" height="100%">
          {activeTab === 'trends' ? (
            <LineChart data={trendData}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis 
                dataKey="date" 
                tickFormatter={(value) => new Date(value).getDate()}
              />
              <YAxis />
              <Tooltip />
              <Legend />
              <Line 
                type="monotone" 
                dataKey="maize_diseases" 
                stroke="#0088FE" 
                name="Maize Diseases"
                strokeWidth={2}
              />
              <Line 
                type="monotone" 
                dataKey="coffee_diseases" 
                stroke="#00C49F" 
                name="Coffee Diseases"
                strokeWidth={2}
              />
              <Line 
                type="monotone" 
                dataKey="tomato_diseases" 
                stroke="#FFBB28" 
                name="Tomato Diseases"
                strokeWidth={2}
              />
              <Line 
                type="monotone" 
                dataKey="banana_diseases" 
                stroke="#FF8042" 
                name="Banana Diseases"
                strokeWidth={2}
              />
            </LineChart>
          ) : (
            <PieChart>
              <Pie
                data={diseaseData}
                cx="50%"
                cy="50%"
                labelLine={false}
                label={({ disease, percent }) => `${disease}: ${(percent * 100).toFixed(0)}%`}
                outerRadius={80}
                fill="#8884d8"
                dataKey="count"
              >
                {diseaseData.map((entry, index) => (
                  <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                ))}
              </Pie>
              <Tooltip />
              <Legend />
            </PieChart>
          )}
        </ResponsiveContainer>
      </div>
    </div>
  )
}
