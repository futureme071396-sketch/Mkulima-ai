'use client'
import { useEffect, useState } from 'react'
import { analyticsService } from '../../services/api'

const kenyanRegions = {
  'Nairobi': { cases: 450, topDisease: 'Tomato Blight' },
  'Central': { cases: 1250, topDisease: 'Maize Lethal Necrosis' },
  'Rift Valley': { cases: 980, topDisease: 'Maize Rust' },
  'Eastern': { cases: 760, topDisease: 'Coffee Leaf Rust' },
  'Western': { cases: 420, topDisease: 'Banana Sigatoka' },
  'Coast': { cases: 320, topDisease: 'Cassava Mosaic' },
  'Nyanza': { cases: 580, topDisease: 'Maize Lethal Necrosis' }
}

export default function DiseaseMap() {
  const [selectedRegion, setSelectedRegion] = useState(null)
  const [regionalData, setRegionalData] = useState({})

  useEffect(() => {
    const fetchRegionalData = async () => {
      try {
        const data = await analyticsService.getRegionalInsights()
        setRegionalData(data.regional_insights || kenyanRegions)
      } catch (error) {
        console.error('Failed to fetch regional data:', error)
        setRegionalData(kenyanRegions)
      }
    }

    fetchRegionalData()
  }, [])

  const getCaseColor = (cases) => {
    if (cases > 1000) return 'bg-red-500'
    if (cases > 500) return 'bg-orange-500'
    if (cases > 200) return 'bg-yellow-500'
    return 'bg-green-500'
  }

  return (
    <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
      <div className="flex items-center justify-between mb-6">
        <h3 className="text-lg font-semibold text-gray-900">Disease Distribution Map</h3>
        <div className="flex items-center space-x-4 text-sm text-gray-500">
          <div className="flex items-center space-x-2">
            <div className="w-3 h-3 bg-green-500 rounded"></div>
            <span>Low (0-200)</span>
          </div>
          <div className="flex items-center space-x-2">
            <div className="w-3 h-3 bg-yellow-500 rounded"></div>
            <span>Medium (201-500)</span>
          </div>
          <div className="flex items-center space-x-2">
            <div className="w-3 h-3 bg-orange-500 rounded"></div>
            <span>High (501-1000)</span>
          </div>
          <div className="flex items-center space-x-2">
            <div className="w-3 h-3 bg-red-500 rounded"></div>
            <span>Critical (1000+)</span>
          </div>
        </div>
      </div>

      {/* Simplified Kenya Map Representation */}
      <div className="relative bg-gray-50 rounded-lg border border-gray-200 p-8">
        <div className="grid grid-cols-3 gap-4">
          {Object.entries(regionalData).map(([region, data]) => (
            <div
              key={region}
              className={`p-4 rounded-lg border-2 cursor-pointer transition-all duration-200 ${
                selectedRegion === region 
                  ? 'border-primary-500 shadow-md' 
                  : 'border-gray-200 hover:border-gray-300'
              } ${getCaseColor(data.cases || data.total_detections)} bg-opacity-20`}
              onClick={() => setSelectedRegion(region)}
            >
              <div className="text-center">
                <h4 className="font-semibold text-gray-900">{region}</h4>
                <p className="text-2xl font-bold text-gray-900 mt-1">
                  {data.cases || data.total_detections}
                </p>
                <p className="text-sm text-gray-600 mt-1">
                  {data.topDisease || (data.top_diseases?.[0]?.disease || 'No data')}
                </p>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Region Details */}
      {selectedRegion && regionalData[selectedRegion] && (
        <div className="mt-6 p-4 bg-primary-50 rounded-lg border border-primary-200">
          <h4 className="font-semibold text-primary-900 mb-2">
            {selectedRegion} Region Details
          </h4>
          <div className="grid grid-cols-2 gap-4 text-sm">
            <div>
              <p className="text-primary-700">Total Cases</p>
              <p className="font-semibold">
                {regionalData[selectedRegion].cases || regionalData[selectedRegion].total_detections}
              </p>
            </div>
            <div>
              <p className="text-primary-700">Top Disease</p>
              <p className="font-semibold">
                {regionalData[selectedRegion].topDisease || 
                 regionalData[selectedRegion].top_diseases?.[0]?.disease}
              </p>
            </div>
            <div>
              <p className="text-primary-700">Success Rate</p>
              <p className="font-semibold">
                {Math.round((regionalData[selectedRegion].success_rate || 0.75) * 100)}%
              </p>
            </div>
            <div>
              <p className="text-primary-700">Active Users</p>
              <p className="font-semibold">
                {regionalData[selectedRegion].active_users || 'N/A'}
              </p>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
