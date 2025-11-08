<!-- app/components/properties/PropertyForm.vue -->
<script setup lang="ts">
import { reactive, ref, onMounted, computed, watch } from 'vue'
import { usePropertiesStore } from '../../stores/properties'
import { useCategoriesStore } from '../../stores/categories'
import { toMessage } from '../../services/error'
import { useRuntimeConfig } from 'nuxt/app'

// @ts-ignore - defineProps is auto-imported by Nuxt
const props = defineProps<{
  initial?: Record<string, any> | null
  mode: 'create' | 'edit'
  id?: string | number
}>()

// @ts-ignore - defineEmits is auto-imported by Nuxt
const emit = defineEmits<{
  success: []
  cancel: []
}>()

const propsStore = usePropertiesStore()
const catStore = useCategoriesStore()

const error = ref<string | null>(null)
const activeTab = ref('basico')
const loading = ref(false)
const latitudeError = ref<string | null>(null)
const longitudeError = ref<string | null>(null)
const addressInputRef = ref<HTMLInputElement | null>(null)

// Form data
const form = reactive<any>(props.initial || {
  category_id: '',
  status: 'available',
  name: '',
  description: '',
  address: {
    street: '',
    neighborhood: '',
    city: '',
    state: '',
    zipcode: '',
    country: 'Brasil',
    latitude: null,
    longitude: null
  },
  available_from: '',
  rooms: 1,
  bathrooms: 1,
  area: 0,
  parking_slots: 0,
  price: null,
  promotional_price: null,
  furnished: false,
  contract_type: 'rent',
  photos: [] as File[],
  rooms_list: [] as Array<{ name: string; type: string; description: string }>,
  // Comodidades do apartamento/casa
  wifi: false,
  smart_tv: false,
  air_conditioning: false,
  oven: false,
  microwave: false,
  stove: false,
  linen_towels: false,
  pool: false,
  kitchen: false,
  balcony: false,
  washer_dryer: false,
  // Características do prédio
  parking: false,
  pets_allowed: false,
  gym: false,
  gated_building: false,
  breakfast: false,
  sauna: false,
  elevator: false,
  doorman: false,
  coworking: false
})


// Room inputs
const roomName = ref('')
const roomType = ref('')
const roomDescription = ref('')

// Computed
const selectedCategory = computed(() => {
  return catStore.list.find(c => c.id === form.category_id)
})

const isApartment = computed(() => {
  const categoryName = selectedCategory.value?.name?.toLowerCase() || ''
  return categoryName.includes('apt') || categoryName.includes('apartamento') || categoryName.includes('studio') || categoryName.includes('loft')
})

const isHouse = computed(() => {
  const categoryName = selectedCategory.value?.name?.toLowerCase() || ''
  return categoryName.includes('casa')
})

// Existing photos from backend (when editing)
const existingPhotos = ref<Array<{ url: string; thumb_url: string; signed_id?: string }>>([])

// Photo previews for new uploaded files
const photoPreviews = computed(() => {
  return form.photos.map((photo: File) => {
    if (typeof window !== 'undefined' && photo instanceof File) {
      return window.URL.createObjectURL(photo)
    }
    return ''
  })
})

// All photos (existing + new) for display
const allPhotos = computed(() => {
  const existing = existingPhotos.value.map(photo => ({
    type: 'existing',
    url: photo.thumb_url,
    thumb_url: photo.thumb_url,
    signed_id: photo.signed_id
  }))
  const newFiles = photoPreviews.value.map((preview: string, index: number) => ({
    type: 'new',
    url: preview,
    thumb_url: preview,
    file: form.photos[index]
  }))
  return [...existing, ...newFiles]
})


// Sugestões de autocomplete
const autocompleteSuggestions = ref<any[]>([])
const showSuggestions = ref(false)

// Busca sugestões de endereço usando Places API (New) via HTTP REST
async function searchAddress(query: string) {
  if (!query || query.length < 3) {
    autocompleteSuggestions.value = []
    showSuggestions.value = false
    return
  }

  const config = useRuntimeConfig()
  const apiKey = (config.public.googleMapsApiKey as string) || ''

  if (!apiKey) {
    console.warn('Google Maps API key não configurada para autocomplete')
    return
  }

  try {
    // Usa a nova Places API (New) via HTTP REST
    const response = await fetch(
      'https://places.googleapis.com/v1/places:autocomplete',
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': apiKey,
          'X-Goog-FieldMask': 'suggestions.placePrediction.placeId,suggestions.placePrediction.text'
        },
        body: JSON.stringify({
          input: query,
          includedRegionCodes: ['BR']
        })
      }
    )

    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}))
      console.error('Erro na API Places:', response.status, errorData)
      autocompleteSuggestions.value = []
      showSuggestions.value = false
      return
    }

    const data = await response.json()
    autocompleteSuggestions.value = data.suggestions || []
    showSuggestions.value = autocompleteSuggestions.value.length > 0
  } catch (error) {
    console.error('Erro ao buscar sugestões:', error)
    autocompleteSuggestions.value = []
    showSuggestions.value = false
  }
}

// Obtém detalhes completos do lugar selecionado usando Places API (New)
async function selectPlace(placeId: string, text: string) {
  const config = useRuntimeConfig()
  const apiKey = (config.public.googleMapsApiKey as string) || ''

  if (!apiKey) {
    return
  }

  try {
    // Busca detalhes do lugar usando Places API (New) via HTTP REST
    const response = await fetch(
      `https://places.googleapis.com/v1/places/${placeId}`,
      {
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': apiKey,
          'X-Goog-FieldMask': 'id,displayName,formattedAddress,addressComponents,location'
        }
      }
    )

    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}))
      console.error('Erro ao buscar detalhes do lugar:', response.status, errorData)
      return
    }

    const place = await response.json()

    // Preenche o endereço completo
    form.address.street = place.formattedAddress || text || form.address.street

    // Extrai componentes do endereço
    const addressComponents = place.addressComponents || []
    
    const getComponent = (types: string[]) => {
      const component = addressComponents.find((comp: any) =>
        types.some(type => comp.types.includes(type))
      )
      return component?.longText || component?.shortText || ''
    }

    // Preenche os campos
    form.address.neighborhood = getComponent(['neighborhood', 'sublocality', 'sublocality_level_1']) || ''
    form.address.city = getComponent(['locality', 'administrative_area_level_2']) || ''
    form.address.state = getComponent(['administrative_area_level_1']) || ''
    
    // Preenche coordenadas
    if (place.location && place.location.latitude && place.location.longitude) {
      form.address.latitude = String(place.location.latitude)
      form.address.longitude = String(place.location.longitude)
    }
    
    // Limpa erros e sugestões
    latitudeError.value = null
    longitudeError.value = null
    showSuggestions.value = false
    autocompleteSuggestions.value = []
  } catch (error) {
    console.error('Erro ao buscar detalhes do lugar:', error)
  }
}

// Debounce para evitar muitas requisições
let searchTimeout: ReturnType<typeof setTimeout> | null = null

// Handler para input do endereço
function onAddressInput(e: Event) {
  const input = e.target as HTMLInputElement
  const value = input.value
  form.address.street = value
  
  // Limpa o timeout anterior
  if (searchTimeout) {
    clearTimeout(searchTimeout)
  }
  
  // Aguarda 300ms antes de buscar (debounce)
  searchTimeout = setTimeout(() => {
    searchAddress(value)
  }, 300)
}

// Handler para seleção de sugestão
function onSelectSuggestion(suggestion: any) {
  const placeId = suggestion.placePrediction?.placeId
  const text = suggestion.placePrediction?.text?.text || ''
  
  if (placeId) {
    form.address.street = text
    selectPlace(placeId, text)
  } else {
    form.address.street = text
    showSuggestions.value = false
  }
}

// Fecha sugestões ao clicar fora
function closeSuggestions() {
  setTimeout(() => {
    showSuggestions.value = false
  }, 200)
}

// Load property data if editing
onMounted(async () => {
  if (!catStore.list.length) {
    await catStore.fetchAll()
  }

  // Autocomplete é inicializado via input handler, não precisa de inicialização separada
  
  if (props.mode === 'edit' && props.id) {
    loading.value = true
    try {
      await propsStore.fetchShow(props.id)
      if (propsStore.current) {
        const current = propsStore.current
        // Convert arrays to booleans for form
        const converted = convertArraysToBooleans(current)
        
        form.category_id = converted.category?.id || ''
        form.status = converted.status
        form.name = converted.name
        form.description = converted.description || ''
        form.address = {
          ...(converted.address || { street: '', neighborhood: '', city: '', state: '', zipcode: '', country: 'Brasil' }),
          latitude: converted.address?.latitude ? String(converted.address.latitude) : null,
          longitude: converted.address?.longitude ? String(converted.address.longitude) : null
        }
        form.available_from = converted.available_from || ''
        form.rooms = converted.rooms
        form.bathrooms = converted.bathrooms
        form.area = converted.area
        form.parking_slots = converted.parking_slots || 0
        form.price = converted.price || null
        form.promotional_price = converted.promotional_price || null
        form.furnished = converted.furnished || false
        form.contract_type = converted.contract_type
        form.rooms_list = converted.rooms_list || []
        
        // Comodidades do apartamento/casa (converted from arrays)
        form.wifi = converted.wifi || false
        form.smart_tv = converted.smart_tv || false
        form.air_conditioning = converted.air_conditioning || false
        form.oven = converted.oven || false
        form.microwave = converted.microwave || false
        form.stove = converted.stove || false
        form.linen_towels = converted.linen_towels || false
        form.pool = converted.pool || false
        form.kitchen = converted.kitchen || false
        form.balcony = converted.balcony || false
        form.washer_dryer = converted.washer_dryer || false
        
        // Características do prédio (converted from arrays)
        form.parking = converted.parking || false
        form.pets_allowed = converted.pets_allowed || false
        form.gym = converted.gym || false
        form.gated_building = converted.gated_building || false
        form.breakfast = converted.breakfast || false
        form.sauna = converted.sauna || false
        form.elevator = converted.elevator || false
        form.doorman = converted.doorman || false
        form.coworking = converted.coworking || false
        
        // Load existing photos from backend
        existingPhotos.value = (current.photos || []).map((photo: any) => ({
          url: photo.original_url || photo.card_url || photo.thumb_url,
          thumb_url: photo.thumb_url || photo.card_url || photo.original_url,
          signed_id: photo.signed_id
        }))
        form.photos = []
      }
    } catch (e) {
      error.value = toMessage(e, 'Erro ao carregar imóvel')
    } finally {
      loading.value = false
    }
  }
})

// Add room
function addRoom() {
  if (roomName.value && roomType.value) {
    form.rooms_list.push({
      name: roomName.value,
      type: roomType.value,
      description: roomDescription.value
    })
    roomName.value = ''
    roomType.value = ''
    roomDescription.value = ''
  }
}

function removeRoom(index: number) {
  form.rooms_list.splice(index, 1)
}


// Handle file upload
function onFilesChange(e: Event) {
  const input = e.target as HTMLInputElement
  if (input.files) {
    // Append new files to existing ones (don't replace)
    const newFiles = Array.from(input.files)
    form.photos = [...form.photos, ...newFiles]
  }
}

// Remove photo (existing or new)
async function removePhoto(index: number) {
  const photo = allPhotos.value[index]
  if (photo.type === 'existing' && photo.signed_id && props.id) {
    // Deletar foto existente no backend
    try {
      await propsStore.deletePhoto(props.id, photo.signed_id)
      // Remover da lista local após sucesso
      const existingIndex = allPhotos.value.slice(0, index).filter(p => p.type === 'existing').length
      existingPhotos.value.splice(existingIndex, 1)
    } catch (e) {
      error.value = toMessage(e, 'Erro ao deletar foto')
    }
  } else {
    // Remover foto nova (ainda não enviada)
    const newPhotoIndex = allPhotos.value.slice(0, index).filter(p => p.type === 'new').length
    form.photos.splice(newPhotoIndex, 1)
  }
}

// Validação de latitude (-90 a 90)
function validateLatitude(lat: string | number | null): boolean {
  if (lat === null || lat === '' || lat === undefined) return true // Opcional
  const num = typeof lat === 'string' ? parseFloat(lat) : lat
  return !isNaN(num) && num >= -90 && num <= 90
}

// Validação de longitude (-180 a 180)
function validateLongitude(lng: string | number | null): boolean {
  if (lng === null || lng === '' || lng === undefined) return true // Opcional
  const num = typeof lng === 'string' ? parseFloat(lng) : lng
  return !isNaN(num) && num >= -180 && num <= 180
}

// Formatação de coordenadas (remove espaços e valida formato)
function formatCoordinate(value: string): string {
  return value.trim().replace(/[^\d.-]/g, '')
}

// Handler para latitude
function onLatitudeInput(e: Event) {
  const input = e.target as HTMLInputElement
  const value = formatCoordinate(input.value)
  form.address.latitude = value === '' ? null : value
  
  if (value !== '' && !validateLatitude(value)) {
    latitudeError.value = 'Latitude deve estar entre -90 e 90'
  } else {
    latitudeError.value = null
  }
}

// Handler para longitude
function onLongitudeInput(e: Event) {
  const input = e.target as HTMLInputElement
  const value = formatCoordinate(input.value)
  form.address.longitude = value === '' ? null : value
  
  if (value !== '' && !validateLongitude(value)) {
    longitudeError.value = 'Longitude deve estar entre -180 e 180'
  } else {
    longitudeError.value = null
  }
}

// Convert boolean fields to arrays for backend
function convertBooleansToArrays(formData: any) {
  const apartmentAmenities: string[] = []
  const buildingCharacteristics: string[] = []

  // Comodidades do apartamento/casa
  if (formData.wifi) apartmentAmenities.push('wifi')
  if (formData.smart_tv) apartmentAmenities.push('smart_tv')
  if (formData.air_conditioning) apartmentAmenities.push('air_conditioning')
  if (formData.oven) apartmentAmenities.push('oven')
  if (formData.microwave) apartmentAmenities.push('microwave')
  if (formData.stove) apartmentAmenities.push('stove')
  if (formData.linen_towels) apartmentAmenities.push('linen_towels')
  if (formData.pool) apartmentAmenities.push('pool')
  if (formData.kitchen) apartmentAmenities.push('kitchen')
  if (formData.balcony) apartmentAmenities.push('balcony')
  if (formData.washer_dryer) apartmentAmenities.push('washer_dryer')

  // Características do prédio
  if (formData.parking) buildingCharacteristics.push('parking')
  if (formData.pets_allowed) buildingCharacteristics.push('pets_allowed')
  if (formData.gym) buildingCharacteristics.push('gym')
  if (formData.gated_building) buildingCharacteristics.push('gated_building')
  if (formData.breakfast) buildingCharacteristics.push('breakfast')
  if (formData.sauna) buildingCharacteristics.push('sauna')
  if (formData.elevator) buildingCharacteristics.push('elevator')
  if (formData.doorman) buildingCharacteristics.push('doorman')
  if (formData.coworking) buildingCharacteristics.push('coworking')

  // Remove boolean fields and add arrays
  const { wifi, smart_tv, air_conditioning, oven, microwave, stove, linen_towels,
          pool, kitchen, balcony, washer_dryer, parking, pets_allowed, gym,
          gated_building, breakfast, sauna, elevator, doorman, coworking, ...rest } = formData

  return {
    ...rest,
    apartment_amenities: apartmentAmenities,
    building_characteristics: buildingCharacteristics
  }
}

// Convert arrays to boolean fields from backend
function convertArraysToBooleans(data: any) {
  const apartmentAmenities = data.apartment_amenities || []
  const buildingCharacteristics = data.building_characteristics || []

  return {
    ...data,
    wifi: apartmentAmenities.includes('wifi'),
    smart_tv: apartmentAmenities.includes('smart_tv'),
    air_conditioning: apartmentAmenities.includes('air_conditioning'),
    oven: apartmentAmenities.includes('oven'),
    microwave: apartmentAmenities.includes('microwave'),
    stove: apartmentAmenities.includes('stove'),
    linen_towels: apartmentAmenities.includes('linen_towels'),
    pool: apartmentAmenities.includes('pool'),
    kitchen: apartmentAmenities.includes('kitchen'),
    balcony: apartmentAmenities.includes('balcony'),
    washer_dryer: apartmentAmenities.includes('washer_dryer'),
    parking: buildingCharacteristics.includes('parking'),
    pets_allowed: buildingCharacteristics.includes('pets_allowed'),
    gym: buildingCharacteristics.includes('gym'),
    gated_building: buildingCharacteristics.includes('gated_building'),
    breakfast: buildingCharacteristics.includes('breakfast'),
    sauna: buildingCharacteristics.includes('sauna'),
    elevator: buildingCharacteristics.includes('elevator'),
    doorman: buildingCharacteristics.includes('doorman'),
    coworking: buildingCharacteristics.includes('coworking')
  }
}

// Submit
async function submit() {
  error.value = null
  latitudeError.value = null
  longitudeError.value = null
  loading.value = true

  // Validation
  if (!form.name || !form.category_id) {
    error.value = 'Preencha os campos obrigatórios (Título, Categoria)'
    loading.value = false
    return
  }

  // Validar coordenadas se preenchidas
  if (form.address.latitude !== null && form.address.latitude !== '') {
    if (!validateLatitude(form.address.latitude)) {
      error.value = 'Latitude inválida. Deve estar entre -90 e 90'
      latitudeError.value = 'Latitude inválida'
      loading.value = false
      return
    }
  }

  if (form.address.longitude !== null && form.address.longitude !== '') {
    if (!validateLongitude(form.address.longitude)) {
      error.value = 'Longitude inválida. Deve estar entre -180 e 180'
      longitudeError.value = 'Longitude inválida'
      loading.value = false
      return
    }
  }

  if (props.mode === 'create' && (!form.photos || form.photos.length === 0)) {
    error.value = 'Adicione pelo menos uma imagem'
    loading.value = false
    return
  }

  try {
    // Convert boolean fields to arrays before sending
    const formData = convertBooleansToArrays(form)
    
    // Converter coordenadas de string para number (se preenchidas)
    const address = { ...formData.address }
    if (address.latitude && address.latitude !== '') {
      address.latitude = parseFloat(address.latitude as string)
    } else {
      address.latitude = null
    }
    if (address.longitude && address.longitude !== '') {
      address.longitude = parseFloat(address.longitude as string)
    } else {
      address.longitude = null
    }
    
    const payload = {
      ...formData,
      address,
      name: form.name,
      available_from: form.available_from || null
    }

    if (props.mode === 'create') {
      await propsStore.create(payload)
    } else {
      await propsStore.update(props.id!, payload)
    }

    emit('success')
  } catch (e) {
    error.value = toMessage(e, 'Erro ao salvar')
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="space-y-6">
    <div v-if="error" class="p-4 bg-red-50 border border-red-200 rounded-lg text-red-800">
      {{ error }}
    </div>

    <!-- Tabs -->
    <div class="border-b">
      <nav class="flex gap-1">
        <button
          @click="activeTab = 'basico'"
          :class="[
            'px-4 py-2 text-sm font-medium rounded-t-lg transition-colors',
            activeTab === 'basico' ? 'bg-green-50 text-green-700 border-b-2 border-green-600' : 'text-gray-600 hover:text-gray-900'
          ]"
        >
          Básico
        </button>
        <button
          @click="activeTab = 'detalhes'"
          :class="[
            'px-4 py-2 text-sm font-medium rounded-t-lg transition-colors',
            activeTab === 'detalhes' ? 'bg-green-50 text-green-700 border-b-2 border-green-600' : 'text-gray-600 hover:text-gray-900'
          ]"
        >
          Detalhes
        </button>
        <button
          @click="activeTab = 'imagens'"
          :class="[
            'px-4 py-2 text-sm font-medium rounded-t-lg transition-colors',
            activeTab === 'imagens' ? 'bg-green-50 text-green-700 border-b-2 border-green-600' : 'text-gray-600 hover:text-gray-900'
          ]"
        >
          Imagens
        </button>
        <button
          @click="activeTab = 'comodos'"
          :class="[
            'px-4 py-2 text-sm font-medium rounded-t-lg transition-colors',
            activeTab === 'comodos' ? 'bg-green-50 text-green-700 border-b-2 border-green-600' : 'text-gray-600 hover:text-gray-900'
          ]"
        >
          Cômodos
        </button>
      </nav>
    </div>

    <form @submit.prevent="submit" class="space-y-6">
      <!-- Tab: Básico -->
      <div v-show="activeTab === 'basico'" class="space-y-4">

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Título*</label>
          <input
            v-model="form.name"
            type="text"
            placeholder="Ex: Apartamento exclusivo no Parque da Cidade"
            class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-green-500"
            required
          />
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Descrição</label>
          <textarea
            v-model="form.description"
            rows="4"
            placeholder="Descrição detalhada do imóvel..."
            class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-green-500"
          />
        </div>

        <div class="grid grid-cols-2 gap-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Categoria*</label>
            <select
              v-model="form.category_id"
              class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-green-500"
              required
            >
              <option disabled value="">Selecione uma categoria</option>
              <option v-for="c in catStore.list" :key="c.id" :value="c.id">{{ c.name }}</option>
            </select>
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Status</label>
            <select
              v-model="form.status"
              class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-green-500"
            >
              <option value="available">Disponível</option>
              <option value="unavailable">Indisponível</option>
              <option value="rented">Alugado</option>
              <option value="maintenance">Manutenção</option>
              <option value="archived">Arquivado</option>
            </select>
          </div>
        </div>

        <div class="grid grid-cols-2 gap-4">
          <div class="relative">
            <label class="block text-sm font-medium text-gray-700 mb-1">Endereço*</label>
            <input
              ref="addressInputRef"
              :value="form.address.street"
              @input="onAddressInput"
              @blur="closeSuggestions"
              type="text"
              placeholder="Ex: Avenida das Nações Unidas, 14401"
              class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-green-500"
              autocomplete="off"
            />
            <p class="mt-1 text-xs text-gray-500">Digite o endereço e selecione uma opção do autocompletar</p>
            
            <!-- Dropdown de sugestões -->
            <div
              v-if="showSuggestions && autocompleteSuggestions.length > 0"
              class="absolute z-50 w-full mt-1 bg-white border border-gray-300 rounded-lg shadow-lg max-h-60 overflow-y-auto"
            >
              <div
                v-for="(suggestion, index) in autocompleteSuggestions"
                :key="index"
                @mousedown.prevent="onSelectSuggestion(suggestion)"
                class="px-4 py-2 hover:bg-gray-100 cursor-pointer border-b border-gray-100 last:border-b-0"
              >
                <p class="text-sm text-gray-900">
                  {{ suggestion.placePrediction?.text?.text }}
                </p>
              </div>
            </div>
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Cidade*</label>
            <input
              v-model="form.address.city"
              type="text"
              placeholder="Ex: São Paulo"
              class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-green-500"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Bairro*</label>
            <input
              v-model="form.address.neighborhood"
              type="text"
              placeholder="Ex: Parque da Cidade"
              class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-green-500"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Estado</label>
            <input
              v-model="form.address.state"
              type="text"
              placeholder="Ex: SP"
              class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-green-500"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">CEP</label>
            <input
              v-model="form.address.zipcode"
              type="text"
              placeholder="00000-000"
              class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-green-500"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Disponível a partir de</label>
            <input
              v-model="form.available_from"
              type="date"
              class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-green-500"
            />
          </div>
        </div>
      </div>

      <!-- Tab: Detalhes -->
      <div v-show="activeTab === 'detalhes'" class="space-y-4">
        <div class="grid grid-cols-2 gap-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Quartos</label>
            <input
              v-model.number="form.rooms"
              type="number"
              min="0"
              class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-green-500"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Banheiros</label>
            <input
              v-model.number="form.bathrooms"
              type="number"
              min="0"
              class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-green-500"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Área (m²)</label>
            <input
              v-model.number="form.area"
              type="number"
              min="0"
              class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-green-500"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Vagas de Garagem</label>
            <input
              v-model.number="form.parking_slots"
              type="number"
              min="0"
              class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-green-500"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Preço por Mês (R$)</label>
            <input
              v-model.number="form.price"
              type="number"
              step="0.01"
              min="0"
              class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-green-500"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Preço Promoção (R$)</label>
            <input
              v-model.number="form.promotional_price"
              type="number"
              step="0.01"
              min="0"
              placeholder="Opcional"
              class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-green-500"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Latitude</label>
            <input
              :value="form.address.latitude"
              @input="onLatitudeInput"
              type="text"
              placeholder="-23.5505"
              class="w-full border rounded-lg px-3 py-2 focus:outline-none focus:ring-2"
              :class="latitudeError ? 'border-red-500 focus:ring-red-500' : 'border-gray-300 focus:ring-green-500'"
            />
            <p v-if="latitudeError" class="mt-1 text-sm text-red-600">{{ latitudeError }}</p>
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Longitude</label>
            <input
              :value="form.address.longitude"
              @input="onLongitudeInput"
              type="text"
              placeholder="-46.6333"
              class="w-full border rounded-lg px-3 py-2 focus:outline-none focus:ring-2"
              :class="longitudeError ? 'border-red-500 focus:ring-red-500' : 'border-gray-300 focus:ring-green-500'"
            />
            <p v-if="longitudeError" class="mt-1 text-sm text-red-600">{{ longitudeError }}</p>
          </div>
        </div>

        <!-- Comodidades e Características -->
        <div class="space-y-4">
          <div>
            <h3 class="text-sm font-semibold text-gray-900 mb-3">Comodidades do Apartamento/Casa</h3>
            <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-3">
          <label class="flex items-center gap-2 cursor-pointer">
            <input
                  v-model="form.wifi"
              type="checkbox"
              class="w-4 h-4 text-green-600 border-gray-300 rounded focus:ring-green-500"
            />
                <span class="text-sm text-gray-700">Wi-Fi</span>
              </label>
              <label class="flex items-center gap-2 cursor-pointer">
                <input
                  v-model="form.smart_tv"
                  type="checkbox"
                  class="w-4 h-4 text-green-600 border-gray-300 rounded focus:ring-green-500"
                />
                <span class="text-sm text-gray-700">Smart TV</span>
              </label>
              <label class="flex items-center gap-2 cursor-pointer">
                <input
                  v-model="form.air_conditioning"
                  type="checkbox"
                  class="w-4 h-4 text-green-600 border-gray-300 rounded focus:ring-green-500"
                />
                <span class="text-sm text-gray-700">Ar Condicionado</span>
              </label>
              <label class="flex items-center gap-2 cursor-pointer">
                <input
                  v-model="form.oven"
                  type="checkbox"
                  class="w-4 h-4 text-green-600 border-gray-300 rounded focus:ring-green-500"
                />
                <span class="text-sm text-gray-700">Forno</span>
              </label>
              <label class="flex items-center gap-2 cursor-pointer">
                <input
                  v-model="form.microwave"
                  type="checkbox"
                  class="w-4 h-4 text-green-600 border-gray-300 rounded focus:ring-green-500"
                />
                <span class="text-sm text-gray-700">Micro-ondas</span>
              </label>
              <label class="flex items-center gap-2 cursor-pointer">
                <input
                  v-model="form.stove"
                  type="checkbox"
                  class="w-4 h-4 text-green-600 border-gray-300 rounded focus:ring-green-500"
                />
                <span class="text-sm text-gray-700">Fogão</span>
              </label>
              <label class="flex items-center gap-2 cursor-pointer">
                <input
                  v-model="form.kitchen"
                  type="checkbox"
                  class="w-4 h-4 text-green-600 border-gray-300 rounded focus:ring-green-500"
                />
                <span class="text-sm text-gray-700">Equipado para Cozinhar</span>
              </label>
              <label class="flex items-center gap-2 cursor-pointer">
                <input
                  v-model="form.linen_towels"
                  type="checkbox"
                  class="w-4 h-4 text-green-600 border-gray-300 rounded focus:ring-green-500"
                />
                <span class="text-sm text-gray-700">Roupa de Cama e Toalhas</span>
              </label>
              <label class="flex items-center gap-2 cursor-pointer">
                <input
                  v-model="form.balcony"
                  type="checkbox"
                  class="w-4 h-4 text-green-600 border-gray-300 rounded focus:ring-green-500"
                />
                <span class="text-sm text-gray-700">Varanda</span>
              </label>
              <label class="flex items-center gap-2 cursor-pointer">
                <input
                  v-model="form.washer_dryer"
                  type="checkbox"
                  class="w-4 h-4 text-green-600 border-gray-300 rounded focus:ring-green-500"
                />
                <span class="text-sm text-gray-700">Lavadora e Secadora</span>
              </label>
            </div>
          </div>

          <div>
            <h3 class="text-sm font-semibold text-gray-900 mb-3">Características do Prédio</h3>
            <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-3">
              <label class="flex items-center gap-2 cursor-pointer">
                <input
                  v-model="form.pool"
                  type="checkbox"
                  class="w-4 h-4 text-green-600 border-gray-300 rounded focus:ring-green-500"
                />
                <span class="text-sm text-gray-700">Piscina</span>
              </label>
              <label class="flex items-center gap-2 cursor-pointer">
                <input
                  v-model="form.gym"
                  type="checkbox"
                  class="w-4 h-4 text-green-600 border-gray-300 rounded focus:ring-green-500"
                />
                <span class="text-sm text-gray-700">Academia</span>
              </label>
              <label class="flex items-center gap-2 cursor-pointer">
                <input
                  v-model="form.gated_building"
                  type="checkbox"
                  class="w-4 h-4 text-green-600 border-gray-300 rounded focus:ring-green-500"
                />
                <span class="text-sm text-gray-700">Prédio Fechado</span>
              </label>
              <label class="flex items-center gap-2 cursor-pointer">
                <input
                  v-model="form.breakfast"
                  type="checkbox"
                  class="w-4 h-4 text-green-600 border-gray-300 rounded focus:ring-green-500"
                />
                <span class="text-sm text-gray-700">Café da Manhã</span>
              </label>
              <label class="flex items-center gap-2 cursor-pointer">
                <input
                  v-model="form.sauna"
                  type="checkbox"
                  class="w-4 h-4 text-green-600 border-gray-300 rounded focus:ring-green-500"
                />
                <span class="text-sm text-gray-700">Sauna</span>
              </label>
              <label class="flex items-center gap-2 cursor-pointer">
                <input
                  v-model="form.elevator"
                  type="checkbox"
                  class="w-4 h-4 text-green-600 border-gray-300 rounded focus:ring-green-500"
                />
                <span class="text-sm text-gray-700">Elevador</span>
              </label>
              <label class="flex items-center gap-2 cursor-pointer">
                <input
                  v-model="form.doorman"
                  type="checkbox"
                  class="w-4 h-4 text-green-600 border-gray-300 rounded focus:ring-green-500"
                />
                <span class="text-sm text-gray-700">Portaria 24h</span>
              </label>
              <label class="flex items-center gap-2 cursor-pointer">
                <input
                  v-model="form.parking"
                  type="checkbox"
                  class="w-4 h-4 text-green-600 border-gray-300 rounded focus:ring-green-500"
                />
                <span class="text-sm text-gray-700">Estacionamento</span>
          </label>
          <label class="flex items-center gap-2 cursor-pointer">
            <input
              v-model="form.pets_allowed"
              type="checkbox"
              class="w-4 h-4 text-green-600 border-gray-300 rounded focus:ring-green-500"
            />
            <span class="text-sm text-gray-700">Aceita Pets</span>
          </label>
              <label class="flex items-center gap-2 cursor-pointer">
                <input
                  v-model="form.coworking"
                  type="checkbox"
                  class="w-4 h-4 text-green-600 border-gray-300 rounded focus:ring-green-500"
                />
                <span class="text-sm text-gray-700">Coworking</span>
              </label>
              <label class="flex items-center gap-2 cursor-pointer">
                <input
                  v-model="form.furnished"
                  type="checkbox"
                  class="w-4 h-4 text-green-600 border-gray-300 rounded focus:ring-green-500"
                />
                <span class="text-sm text-gray-700">Mobiliado</span>
          </label>
            </div>
          </div>
        </div>
      </div>

      <!-- Tab: Imagens -->
      <div v-show="activeTab === 'imagens'" class="space-y-4">
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">Fotos do Imóvel</label>
          <input
            type="file"
            multiple
            accept="image/*"
            @change="onFilesChange"
            class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-green-500"
          />
          <p class="mt-2 text-sm text-gray-500">
            {{ existingPhotos.length }} foto{{ existingPhotos.length !== 1 ? 's' : '' }} existente{{ existingPhotos.length !== 1 ? 's' : '' }}
            <span v-if="form.photos.length > 0">
              • {{ form.photos.length }} nova{{ form.photos.length !== 1 ? 's' : '' }}
            </span>
          </p>
        </div>

        <div v-if="allPhotos.length === 0" class="border-2 border-dashed border-gray-300 rounded-lg p-12 text-center">
          <svg class="w-16 h-16 text-gray-400 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
          </svg>
          <p class="text-gray-500">Nenhuma imagem adicionada</p>
        </div>

        <div v-else class="grid grid-cols-3 gap-4">
          <div
            v-for="(photo, index) in allPhotos"
            :key="`${photo.type}-${index}`"
            class="relative group"
          >
            <img
              :src="photo.thumb_url"
              class="w-full h-32 object-cover rounded-lg"
              :alt="photo.type === 'existing' ? 'Foto existente' : 'Nova foto'"
            />
            <div
              v-if="photo.type === 'existing'"
              class="absolute top-2 left-2 bg-blue-500 text-white text-xs px-2 py-1 rounded"
            >
              Existente
            </div>
            <button
              type="button"
              @click="removePhoto(index)"
              class="absolute top-2 right-2 bg-red-500 text-white rounded-full p-1 opacity-0 group-hover:opacity-100 transition-opacity"
            >
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>
        </div>
      </div>

      <!-- Tab: Cômodos -->
      <div v-show="activeTab === 'comodos'" class="space-y-6">
        <div>
          <h3 class="text-lg font-semibold text-gray-900 mb-4">Adicionar Cômodo</h3>
          <div class="grid grid-cols-3 gap-4 mb-4">
            <input
              v-model="roomName"
              type="text"
              placeholder="Nome (Ex: Quarto Principal)"
              class="border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-green-500"
            />
            <input
              v-model="roomType"
              type="text"
              placeholder="Tipo (Ex: bedroom, living, kitchen)"
              class="border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-green-500"
            />
            <input
              v-model="roomDescription"
              type="text"
              placeholder="Descrição (Ex: Cama King-size / Home office)"
              class="border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-green-500"
            />
          </div>
          <button
            type="button"
            @click="addRoom"
            class="flex items-center gap-2 bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700"
          >
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
            </svg>
            Adicionar Cômodo
          </button>
        </div>

        <div v-if="form.rooms_list.length > 0" class="space-y-2">
          <div
            v-for="(room, index) in form.rooms_list"
            :key="index"
            class="bg-gray-50 rounded-lg p-4 flex items-center justify-between"
          >
            <div>
              <p class="font-medium text-gray-900">{{ room.name }}</p>
              <p class="text-sm text-gray-600">{{ room.type }} • {{ room.description }}</p>
            </div>
            <button
              type="button"
              @click="removeRoom(index)"
              class="text-red-600 hover:text-red-800"
            >
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>
        </div>
      </div>


      <!-- Action Buttons -->
      <div class="flex items-center justify-between pt-4 border-t">
        <button
          type="button"
          @click="emit('cancel')"
          class="px-6 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50"
        >
          Cancelar
        </button>
        <button
          type="submit"
          :disabled="loading"
          class="px-6 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {{ loading ? 'Salvando...' : (mode === 'create' ? 'Criar Imóvel' : 'Atualizar Imóvel') }}
        </button>
      </div>
    </form>
  </div>
</template>
