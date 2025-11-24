'use client'
import { useState } from 'react'
import { Plus, X } from 'lucide-react'

export default function AddDisease() {
  const [isOpen, setIsOpen] = useState(false)
  const [formData, setFormData] = useState({
    name: '',
    scientificName: '',
    plantType: '',
    severity: 'medium',
    treatments: [''],
    preventions: ['']
  })

  const addTreatment = () => {
    setFormData(prev => ({
      ...prev,
      treatments: [...prev.treatments, '']
    }))
  }

  const removeTreatment = (index) => {
    setFormData(prev => ({
      ...prev,
      treatments: prev.treatments.filter((_, i) => i !== index)
    }))
  }

  const updateTreatment = (index, value) => {
    setFormData(prev => ({
      ...prev,
      treatments: prev.treatments.map((t, i) => i === index ? value : t)
    }))
  }

  const handleSubmit = async (e) => {
    e.preventDefault()
    // TODO: Implement API call
    console.log('Submitting disease:', formData)
    setIsOpen(false)
  }

  return (
    <>
      <button
        onClick={() => setIsOpen(true)}
        className="bg-primary-500 hover:bg-primary-600 text-white px-4 py-2 rounded-lg flex items-center space-x-2"
      >
        <Plus className="w-4 h-4" />
        <span>Add Disease</span>
      </button>

      {isOpen && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 w-full max-w-2xl max-h-[90vh] overflow-y-auto">
            <div className="flex items-center justify-between mb-6">
              <h3 className="text-lg font-semibold">Add New Disease</h3>
              <button
                onClick={() => setIsOpen(false)}
                className="text-gray-400 hover:text-gray-600"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleSubmit} className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Disease Name
                  </label>
                  <input
                    type="text"
                    value={formData.name}
                    onChange={(e) => setFormData(prev => ({ ...prev, name: e.target.value }))}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                    required
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Scientific Name
                  </label>
                  <input
                    type="text"
                    value={formData.scientificName}
                    onChange={(e) => setFormData(prev => ({ ...prev, scientificName: e.target.value }))}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Plant Type
                  </label>
                  <select
                    value={formData.plantType}
                    onChange={(e) => setFormData(prev => ({ ...prev, plantType: e.target.value }))}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                    required
                  >
                    <option value="">Select plant type</option>
                    <option value="maize">Maize</option>
                    <option value="coffee">Coffee</option>
                    <option value="tomato">Tomato</option>
                    <option value="banana">Banana</option>
                    <option value="beans">Beans</option>
                  </select>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Severity
                  </label>
                  <select
                    value={formData.severity}
                    onChange={(e) => setFormData(prev => ({ ...prev, severity: e.target.value }))}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                    required
                  >
                    <option value="low">Low</option>
                    <option value="medium">Medium</option>
                    <option value="high">High</option>
                    <option value="critical">Critical</option>
                  </select>
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Recommended Treatments
                </label>
                <div className="space-y-2">
                  {formData.treatments.map((treatment, index) => (
                    <div key={index} className="flex space-x-2">
                      <input
                        type="text"
                        value={treatment}
                        onChange={(e) => updateTreatment(index, e.target.value)}
                        className="flex-1 px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                        placeholder="Enter treatment recommendation"
                      />
                      {formData.treatments.length > 1 && (
                        <button
                          type="button"
                          onClick={() => removeTreatment(index)}
                          className="px-3 py-2 text-red-600 hover:text-red-800"
                        >
                          <X className="w-4 h-4" />
                        </button>
                      )}
                    </div>
                  ))}
                  <button
                    type="button"
                    onClick={addTreatment}
                    className="text-primary-600 hover:text-primary-800 text-sm flex items-center space-x-1"
                  >
                    <Plus className="w-4 h-4" />
                    <span>Add another treatment</span>
                  </button>
                </div>
              </div>

              <div className="flex justify-end space-x-3 pt-4">
                <button
                  type="button"
                  onClick={() => setIsOpen(false)}
                  className="px-4 py-2 text-gray-600 hover:text-gray-800"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="bg-primary-500 hover:bg-primary-600 text-white px-4 py-2 rounded-lg"
                >
                  Add Disease
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </>
  )
}
