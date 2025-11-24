'use client'
import { useState, useEffect } from 'react'
import { Search, Filter, AlertTriangle, CheckCircle, XCircle } from 'lucide-react'
import AddDisease from '../components/Forms/AddDisease'

const mockDiseases = [
  {
    id: 1,
    name: 'Maize Lethal Necrosis',
    scientificName: 'Maize chlorotic mottle virus',
    plantType: 'maize',
    severity: 'high',
    cases: 2340,
    successRate: 85,
    treatments: ['Use certified seeds', 'Crop rotation', 'Remove infected plants']
  },
  {
    id: 2,
    name: 'Coffee Leaf Rust',
    scientificName: 'Hemileia vastatrix',
    plantType: 'coffee',
    severity: 'medium',
    cases: 1876,
    successRate: 78,
    treatments: ['Copper fungicides', 'Proper pruning', 'Shade management']
  },
  {
    id: 3,
    name: 'Tomato Late Blight',
    scientificName: 'Phytophthora infestans',
    plantType: 'tomato',
    severity: 'high',
    cases: 1567,
    successRate: 82,
    treatments: ['Fungicide application', 'Improve air circulation', 'Avoid overhead watering']
  }
]

export default function Diseases() {
  const [diseases, setDiseases] = useState(mockDiseases)
  const [searchTerm, setSearchTerm] = useState('')
  const [filterPlant, setFilterPlant] = useState('')
  const [filterSeverity, setFilterSeverity] = useState('')

  const filteredDiseases = diseases.filter(disease =>
    disease.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
    disease.scientificName.toLowerCase().includes(searchTerm.toLowerCase())
  ).filter(disease =>
    filterPlant ? disease.plantType === filterPlant : true
  ).filter(disease =>
    filterSeverity ? disease.severity === filterSeverity : true
  )

  const getSeverityIcon = (severity) => {
    switch (severity) {
      case 'high':
        return <AlertTriangle className="w-4 h-4 text-red-500" />
      case 'medium':
        return <XCircle className="w-4 h-4 text-yellow-500" />
      case 'low':
        return <CheckCircle className="w-4 h-4 text-green-500" />
      default:
        return <CheckCircle className="w-4 h-4 text-gray-500" />
    }
  }

  const getSeverityColor = (severity) => {
    switch (severity) {
      case 'high':
        return 'bg-red-100 text-red-800'
      case 'medium':
        return 'bg-yellow-100 text-yellow-800'
      case 'low':
        return 'bg-green-100 text-green-800'
      default:
        return 'bg-gray-100 text-gray-800'
    }
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="p-6">
        {/* Header */}
        <div className="flex items-center justify-between mb-6">
          <div>
            <h2 className="text-2xl font-bold text-gray-900">Disease Management</h2>
            <p className="text-gray-600 mt-1">
              Monitor and manage plant diseases in the system
            </p>
          </div>
          <AddDisease />
        </div>

        {/* Filters */}
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-4 mb-6">
          <div className="flex items-center space-x-4">
            <div className="flex-1 relative">
              <Search className="w-4 h-4 absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" />
              <input
                type="text"
                placeholder="Search diseases..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
              />
            </div>
            <select
              value={filterPlant}
              onChange={(e) => setFilterPlant(e.target.value)}
              className="px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
            >
              <option value="">All Plants</option>
              <option value="maize">Maize</option>
              <option value="coffee">Coffee</option>
              <option value="tomato">Tomato</option>
              <option value="banana">Banana</option>
            </select>
            <select
              value={filterSeverity}
              onChange={(e) => setFilterSeverity(e.target.value)}
              className="px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
            >
              <option value="">All Severities</option>
              <option value="low">Low</option>
              <option value="medium">Medium</option>
              <option value="high">High</option>
            </select>
          </div>
        </div>

        {/* Diseases Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {filteredDiseases.map((disease) => (
            <div key={disease.id} className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
              <div className="flex items-start justify-between mb-4">
                <div>
                  <h3 className="text-lg font-semibold text-gray-900">{disease.name}</h3>
                  <p className="text-sm text-gray-500 italic">{disease.scientificName}</p>
                </div>
                <div className="flex items-center space-x-2">
                  {getSeverityIcon(disease.severity)}
                  <span className={`px-2 py-1 rounded-full text-xs font-medium ${getSeverityColor(disease.severity)}`}>
                    {disease.severity}
                  </span>
                </div>
              </div>

              <div className="space-y-3">
                <div className="flex justify-between text-sm">
                  <span className="text-gray-600">Plant Type:</span>
                  <span className="font-medium capitalize">{disease.plantType}</span>
                </div>
                <div className="flex justify-between text-sm">
                  <span className="text-gray-600">Reported Cases:</span>
                  <span className="font-medium">{disease.cases.toLocaleString()}</span>
                </div>
                <div className="flex justify-between text-sm">
                  <span className="text-gray-600">Success Rate:</span>
                  <span className="font-medium text-green-600">{disease.successRate}%</span>
                </div>
              </div>

              <div className="mt-4 pt-4 border-t border-gray-200">
                <h4 className="text-sm font-medium text-gray-900 mb-2">Recommended Treatments:</h4>
                <ul className="text-sm text-gray-600 space-y-1">
                  {disease.treatments.slice(0, 2).map((treatment, index) => (
                    <li key={index} className="flex items-center">
                      <div className="w-1 h-1 bg-gray-400 rounded-full mr-2"></div>
                      {treatment}
                    </li>
                  ))}
                  {disease.treatments.length > 2 && (
                    <li className="text-primary-600 text-xs">
                      +{disease.treatments.length - 2} more treatments
                    </li>
                  )}
                </ul>
              </div>
            </div>
          ))}
        </div>

        {/* Empty State */}
        {filteredDiseases.length === 0 && (
          <div className="text-center py-12">
            <div className="text-gray-400 mb-2">No diseases found</div>
            <div className="text-sm text-gray-500">
              Try adjusting your search or filter criteria
            </div>
          </div>
        )}
      </div>
    </div>
  )
}
