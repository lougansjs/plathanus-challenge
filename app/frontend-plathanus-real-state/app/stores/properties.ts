// app/stores/properties.ts
import { ref } from 'vue'
import { useHttp } from '../services/http'
import type { ApiMeta } from '../../types/api'
import type { Property } from '../../types/property'
import { toMessage } from '../services/error'

export const usePropertiesStore = defineStore('properties', () => {
  const list = ref<Property[]>([])
  const meta = ref<ApiMeta | null>(null)
  const current = ref<Property | null>(null)
  const loading = ref(false)
  const error = ref<string | null>(null)

  function toFormData(payload: Record<string, any>) {
    const fd = new FormData()
    Object.entries(payload).forEach(([k, v]) => {
      if (v == null && k !== 'promotional_price') return
      if (k === 'photos' && Array.isArray(v)) {
        v.forEach((f) => {
          if (f instanceof File) {
            fd.append('property[photos][]', f)
          }
        })
      } else if (k === 'address' && typeof v === 'object') {
        Object.entries(v as Record<string, any>).forEach(([ak, av]) =>
          av != null && fd.append(`property[address][${ak}]`, String(av))
        )
      } else if (k === 'rooms_list' && Array.isArray(v)) {
        // Rails entende array de objetos com esta sintaxe
        // SEMPRE envia, mesmo quando vazio, para que o Rails atualize o campo
        if (v.length === 0) {
          // Quando vazio, envia um objeto com campos vazios para que o Rails entenda como array vazio
          fd.append('property[rooms_list][][name]', '')
          fd.append('property[rooms_list][][type]', '')
          fd.append('property[rooms_list][][description]', '')
        } else {
          v.forEach((room) => {
            fd.append('property[rooms_list][][name]', room.name || '')
            fd.append('property[rooms_list][][type]', room.type || '')
            fd.append('property[rooms_list][][description]', room.description || '')
          })
        }
      } else if (k === 'apartment_amenities' && Array.isArray(v)) {
        // Rails entende array com esta sintaxe (sem índice)
        v.forEach((amenity) => {
          fd.append('property[apartment_amenities][]', amenity)
        })
      } else if (k === 'building_characteristics' && Array.isArray(v)) {
        // Rails entende array com esta sintaxe (sem índice)
        v.forEach((char) => {
          fd.append('property[building_characteristics][]', char)
        })
      } else if (k !== 'rooms_list' && k !== 'apartment_amenities' && k !== 'building_characteristics') {
        fd.append(`property[${k}]`, String(v))
      }
    })
    return fd
  }

  async function fetchIndex(params: Record<string, any> = {}) {
    loading.value = true
    error.value = null
    try {
      const api = useHttp()
      const { data } = await api.get('/properties', { params })
      list.value = data?.data ?? data
      meta.value = data?.meta ?? null
    } catch (e) {
      error.value = toMessage(e, 'Erro ao carregar imóveis')
    } finally {
      loading.value = false
    }
  }

  async function fetchShow(id: number | string) {
    loading.value = true
    error.value = null
    try {
      const api = useHttp()
      const { data } = await api.get(`/properties/${id}`)
      current.value = data
    } catch (e) {
      error.value = toMessage(e, 'Erro ao carregar imóvel')
    } finally {
      loading.value = false
    }
  }

  async function create(payload: Record<string, any>) {
    const api = useHttp()
    const fd = toFormData(payload)
    const { data } = await api.post('/properties', fd, {
      headers: { 'Content-Type': 'multipart/form-data' }
    })
    return data as Property
  }

  async function update(id: number | string, payload: Record<string, any>) {
    const api = useHttp()
    const fd = toFormData(payload)
    const { data } = await api.patch(`/properties/${id}`, fd, {
      headers: { 'Content-Type': 'multipart/form-data' }
    })
    return data as Property
  }

  async function destroy(id: number | string) {
    const api = useHttp()
    await api.delete(`/properties/${id}`)
  }

  async function deletePhoto(propertyId: number | string, signedId: string) {
    const api = useHttp()
    await api.delete(`/properties/${propertyId}/delete_photo`, {
      params: { signed_id: signedId }
    })
  }

  return {
    list,
    meta,
    current,
    loading,
    error,
    fetchIndex,
    fetchShow,
    create,
    update,
    destroy,
    deletePhoto,
    toFormData
  }
})
