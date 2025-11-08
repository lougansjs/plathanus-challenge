// app/stores/auth.ts
import { ref, computed } from 'vue'
import { useHttp } from '../services/http'
import { toMessage } from '../services/error'

export const useAuthStore = defineStore('auth', () => {
  const token = ref<string | null>(null)
  const loading = ref(false)
  const error = ref<string | null>(null)

  // Verificar se está autenticado
  const isAuthenticated = computed(() => !!token.value)

  // Inicializar token do localStorage
  function init() {
    if (process.client) {
      const storedToken = localStorage.getItem('auth_token')
      if (storedToken) {
        token.value = storedToken
      }
    }
  }

  // Login
  async function login(email: string, password: string) {
    loading.value = true
    error.value = null
    
    try {
      const api = useHttp()
      const { data } = await api.post('/auth/login', { email, password })
      
      if (data.token) {
        token.value = data.token
        if (process.client) {
          localStorage.setItem('auth_token', data.token)
        }
        return { success: true }
      } else {
        error.value = 'Token não recebido do servidor'
        return { success: false, error: error.value }
      }
    } catch (e: any) {
      error.value = e.response?.data?.error || toMessage(e, 'Erro ao fazer login')
      return { success: false, error: error.value }
    } finally {
      loading.value = false
    }
  }

  // Logout
  function logout() {
    token.value = null
    if (process.client) {
      localStorage.removeItem('auth_token')
    }
  }

  // Verificar se token é válido
  async function verifyToken() {
    if (!token.value) return false

    try {
      const api = useHttp()
      await api.get('/auth/verify')
      return true
    } catch {
      logout()
      return false
    }
  }

  // Obter token para usar em headers
  function getToken() {
    return token.value
  }

  return {
    token,
    loading,
    error,
    isAuthenticated,
    init,
    login,
    logout,
    verifyToken,
    getToken
  }
})

