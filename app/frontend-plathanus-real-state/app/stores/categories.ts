// app/stores/categories.ts
import { ref } from 'vue'
import { useHttp } from '../services/http'
import type { Category } from '../../types/category'
import { toMessage } from '../services/error'

export const useCategoriesStore = defineStore('categories', () => {
  const list = ref<Category[]>([])
  const loading = ref(false)
  const error = ref<string | null>(null)

  async function fetchAll() {
    loading.value = true
    error.value = null
    try {
      const api = useHttp()
      const { data } = await api.get('/categories')
      list.value = Array.isArray(data?.data) ? data.data : data
    } catch (e) {
      error.value = toMessage(e, 'Erro ao carregar categorias')
    } finally {
      loading.value = false
    }
  }

  return {
    list,
    loading,
    error,
    fetchAll
  }
})
