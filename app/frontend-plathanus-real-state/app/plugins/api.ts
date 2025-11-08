import { defineNuxtPlugin, useRuntimeConfig } from 'nuxt/app'
import axios from 'axios'

export default defineNuxtPlugin(() => {
  const config = useRuntimeConfig()
  const api = axios.create({
    baseURL: (config.public.apiBase as string) || 'http://0.0.0.0:3001/api/v1',
  })

  // Interceptor para adicionar token JWT nas requisições
  api.interceptors.request.use((config) => {
    if (process.client) {
      const token = localStorage.getItem('auth_token')
      if (token) {
        config.headers.Authorization = `Bearer ${token}`
      }
    }
    return config
  })

  // Interceptor para tratar erros 401 (não autorizado)
  api.interceptors.response.use(
    (response) => response,
    (error) => {
      if (error.response?.status === 401) {
        // Token inválido ou expirado
        if (process.client) {
          localStorage.removeItem('auth_token')
          // Redirecionar para login se estiver em rota admin
          if (window.location.pathname.startsWith('/admin')) {
            window.location.reload()
          }
        }
      }
      return Promise.reject(error)
    }
  )

  return { provide: { api } }
})
