const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:8080'

export async function uploadAudio(file, ratio = 0.15, subject = '') {
  const formData = new FormData()
  formData.append('file', file)

  const params = new URLSearchParams()
  params.append('ratio', ratio.toString())
  if (subject) {
    params.append('subject', subject)
  }

  const response = await fetch(`${API_BASE_URL}/api/pipeline?${params}`, {
    method: 'POST',
    body: formData,
  })

  if (!response.ok) {
    const error = await response.json().catch(() => ({ detail: 'Unknown error' }))
    throw new Error(error.detail || `HTTP error! status: ${response.status}`)
  }

  return await response.json()
}

export async function healthCheck() {
  const response = await fetch(`${API_BASE_URL}/health`)
  return await response.json()
}