<!-- app/pages/imoveis.vue -->
<script setup lang="ts">
import { onMounted, ref, computed, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { usePropertiesStore } from '../stores/properties'
// @ts-ignore - Vue components
import PropertyCard from '../components/properties/PropertyCard.vue'
// @ts-ignore - Vue components
import PropertiesMap from '../components/properties/PropertiesMap.vue'

const route = useRoute()
const router = useRouter()
const propertiesStore = usePropertiesStore()

// Filtros
const searchQuery = ref(route.query.search as string || '')
const city = ref(route.query.city as string || '')
const selectedRooms = ref<number[]>([])
const selectedBathrooms = ref<number[]>([])
const selectedParkingSlots = ref<number[]>([])
const selectedAmenities = ref<string[]>([])
const selectedCharacteristics = ref<string[]>([])
const priceMin = ref<number | null>(null)
const priceMax = ref<number | null>(null)
const showFilters = ref(false)

// Opções disponíveis
const roomsOptions = [1, 2, 3, 4]
const bathroomsOptions = [1, 2, 3]
const parkingOptions = [0, 1, 2, 3]

const apartmentAmenitiesOptions = [
  { value: 'wifi', label: 'Wi-Fi' },
  { value: 'smart_tv', label: 'Smart TV' },
  { value: 'air_conditioning', label: 'Ar Condicionado' },
  { value: 'oven', label: 'Forno' },
  { value: 'microwave', label: 'Micro-ondas' },
  { value: 'stove', label: 'Fogão' },
  { value: 'linen_towels', label: 'Roupa de Cama e Toalhas' },
  { value: 'kitchen', label: 'Cozinha Equipada' },
  { value: 'balcony', label: 'Varanda' },
  { value: 'washer_dryer', label: 'Lavadora e Secadora' }
]

const buildingCharacteristicsOptions = [
  { value: 'parking', label: 'Estacionamento' },
  { value: 'pets_allowed', label: 'Aceita Pets' },
  { value: 'gym', label: 'Academia' },
  { value: 'gated_building', label: 'Prédio Fechado' },
  { value: 'breakfast', label: 'Café da Manhã' },
  { value: 'sauna', label: 'Sauna' },
  { value: 'elevator', label: 'Elevador' },
  { value: 'doorman', label: 'Portaria 24h' },
  { value: 'coworking', label: 'Coworking' },
  { value: 'pool', label: 'Piscina' }
]

// Computed
const propertiesCount = computed(() => propertiesStore.list.length)

// Lista de cidades conhecidas (pode ser expandida)
const cities = ref<string[]>([
  'Florianópolis',
  'Joinville',
  'Blumenau',
  'Curitiba',
  'Londrina',
  'Maringá',
  'São Paulo',
  'Campinas',
  'Santos'
])

// Atualiza lista de cidades baseado nos imóveis carregados
watch(() => propertiesStore.list, (newList) => {
  const citySet = new Set<string>(cities.value)
  newList.forEach(prop => {
    if (prop.address?.city) citySet.add(prop.address.city)
  })
  cities.value = Array.from(citySet).sort()
}, { immediate: true })

// Aplica filtros
function applyFilters() {
  const params: Record<string, any> = {
    order: 'recent',
    page: 1,
    per_page: 100 // Buscar mais para o mapa
  }

  if (searchQuery.value) params.search = searchQuery.value
  if (city.value) params.city = city.value
  if (selectedRooms.value.length > 0) params.rooms = selectedRooms.value
  if (selectedBathrooms.value.length > 0) params.bathrooms = selectedBathrooms.value
  if (selectedParkingSlots.value.length > 0) params.parking_slots = selectedParkingSlots.value
  if (selectedAmenities.value.length > 0) params.apartment_amenities = selectedAmenities.value
  if (selectedCharacteristics.value.length > 0) params.building_characteristics = selectedCharacteristics.value
  if (priceMin.value) params.price_min = priceMin.value
  if (priceMax.value) params.price_max = priceMax.value

  propertiesStore.fetchIndex(params)
}

// Limpa filtros
function clearFilters() {
  searchQuery.value = ''
  city.value = ''
  selectedRooms.value = []
  selectedBathrooms.value = []
  selectedParkingSlots.value = []
  selectedAmenities.value = []
  selectedCharacteristics.value = []
  priceMin.value = null
  priceMax.value = null
  router.push({ path: '/imoveis' })
  applyFilters()
}

// Toggle checkbox arrays
function toggleArrayItem(array: any[], item: any) {
  const index = array.indexOf(item)
  if (index > -1) {
    array.splice(index, 1)
  } else {
    array.push(item)
  }
  applyFilters()
}

// Watch para aplicar filtros quando valores mudarem
watch([searchQuery, city, selectedRooms, selectedBathrooms, selectedParkingSlots, selectedAmenities, selectedCharacteristics, priceMin, priceMax], () => {
  applyFilters()
}, { deep: true })

onMounted(async () => {
  // Busca inicial sem filtros para obter todas as cidades
  await propertiesStore.fetchIndex({ per_page: 100 })
  applyFilters()
})
</script>

<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Header com Filtros -->
    <div class="bg-white border-b sticky top-0 z-40">
      <div class="max-w-7xl mx-auto px-4 py-4">
        <div class="flex items-center justify-between mb-4">
          <div>
            <h1 class="text-2xl font-bold text-gray-900">Encontre seu Imóvel</h1>
            <p class="text-sm text-gray-600 mt-1">
              {{ propertiesCount }} imóve{{ propertiesCount !== 1 ? 'is' : 'l' }} encontrado{{ propertiesCount !== 1 ? 's' : '' }}
            </p>
          </div>
          <button
            @click="showFilters = !showFilters"
            class="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50 flex items-center gap-2"
          >
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2.586a1 1 0 01-.293.707l-6.414 6.414a1 1 0 00-.293.707V17l-4 4v-6.586a1 1 0 00-.293-.707L3.293 7.293A1 1 0 013 6.586V4z" />
            </svg>
            Filtros
          </button>
        </div>

        <!-- Barra de Filtros Rápida -->
        <div class="flex flex-wrap gap-3">
          <!-- Busca -->
          <div class="flex-1 min-w-[200px]">
            <input
              v-model="searchQuery"
              type="text"
              placeholder="Buscar por palavra-chave..."
              class="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-green-500"
            />
          </div>

          <!-- Cidade -->
          <div class="min-w-[180px]">
            <select
              v-model="city"
              class="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-green-500"
            >
              <option value="">Todas as cidades</option>
              <option v-for="c in cities" :key="c" :value="c">{{ c }}</option>
            </select>
          </div>

          <!-- Botão Limpar -->
          <button
            @click="clearFilters"
            class="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50 text-sm"
          >
            Limpar
          </button>
        </div>

        <!-- Painel de Filtros Expandido -->
        <div v-if="showFilters" class="mt-4 pt-4 border-t">
          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
            <!-- Quartos -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Quartos</label>
              <div class="space-y-2">
                <label
                  v-for="room in roomsOptions"
                  :key="room"
                  class="flex items-center gap-2 cursor-pointer"
                >
                  <input
                    type="checkbox"
                    :checked="selectedRooms.includes(room)"
                    @change="toggleArrayItem(selectedRooms, room)"
                    class="w-4 h-4 text-green-600 border-gray-300 rounded focus:ring-green-500"
                  />
                  <span class="text-sm text-gray-700">{{ room }} {{ room === 1 ? 'quarto' : 'quartos' }}</span>
                </label>
              </div>
            </div>

            <!-- Banheiros -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Banheiros</label>
              <div class="space-y-2">
                <label
                  v-for="bath in bathroomsOptions"
                  :key="bath"
                  class="flex items-center gap-2 cursor-pointer"
                >
                  <input
                    type="checkbox"
                    :checked="selectedBathrooms.includes(bath)"
                    @change="toggleArrayItem(selectedBathrooms, bath)"
                    class="w-4 h-4 text-green-600 border-gray-300 rounded focus:ring-green-500"
                  />
                  <span class="text-sm text-gray-700">{{ bath }} {{ bath === 1 ? 'banheiro' : 'banheiros' }}</span>
                </label>
              </div>
            </div>

            <!-- Vagas de Garagem -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Vagas de Garagem</label>
              <div class="space-y-2">
                <label
                  v-for="parking in parkingOptions"
                  :key="parking"
                  class="flex items-center gap-2 cursor-pointer"
                >
                  <input
                    type="checkbox"
                    :checked="selectedParkingSlots.includes(parking)"
                    @change="toggleArrayItem(selectedParkingSlots, parking)"
                    class="w-4 h-4 text-green-600 border-gray-300 rounded focus:ring-green-500"
                  />
                  <span class="text-sm text-gray-700">{{ parking === 0 ? 'Sem vaga' : `${parking} ${parking === 1 ? 'vaga' : 'vagas'}` }}</span>
                </label>
              </div>
            </div>

            <!-- Range de Preço -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Faixa de Preço</label>
              <div class="space-y-2">
                <input
                  v-model.number="priceMin"
                  type="number"
                  placeholder="Mínimo (R$)"
                  class="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-green-500"
                />
                <input
                  v-model.number="priceMax"
                  type="number"
                  placeholder="Máximo (R$)"
                  class="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-green-500"
                />
              </div>
            </div>
          </div>

          <!-- Amenities e Características -->
          <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mt-4">
            <!-- Comodidades do Apartamento -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Comodidades do Apartamento</label>
              <div class="space-y-2 max-h-48 overflow-y-auto">
                <label
                  v-for="amenity in apartmentAmenitiesOptions"
                  :key="amenity.value"
                  class="flex items-center gap-2 cursor-pointer"
                >
                  <input
                    type="checkbox"
                    :checked="selectedAmenities.includes(amenity.value)"
                    @change="toggleArrayItem(selectedAmenities, amenity.value)"
                    class="w-4 h-4 text-green-600 border-gray-300 rounded focus:ring-green-500"
                  />
                  <span class="text-sm text-gray-700">{{ amenity.label }}</span>
                </label>
              </div>
            </div>

            <!-- Características do Prédio -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Características do Prédio</label>
              <div class="space-y-2 max-h-48 overflow-y-auto">
                <label
                  v-for="char in buildingCharacteristicsOptions"
                  :key="char.value"
                  class="flex items-center gap-2 cursor-pointer"
                >
                  <input
                    type="checkbox"
                    :checked="selectedCharacteristics.includes(char.value)"
                    @change="toggleArrayItem(selectedCharacteristics, char.value)"
                    class="w-4 h-4 text-green-600 border-gray-300 rounded focus:ring-green-500"
                  />
                  <span class="text-sm text-gray-700">{{ char.label }}</span>
                </label>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Conteúdo Principal: Cards à Esquerda, Mapa à Direita -->
    <div class="max-w-7xl mx-auto px-4 py-6">
      <div class="flex gap-6 h-[calc(100vh-300px)]">
        <!-- Cards de Imóveis (Esquerda) -->
        <div class="flex-1 overflow-y-auto pr-4">
          <!-- Loading State -->
          <div v-if="propertiesStore.loading" class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div v-for="i in 6" :key="i" class="bg-gray-200 animate-pulse rounded-lg h-64"></div>
          </div>

          <!-- Empty State -->
          <div v-else-if="propertiesStore.list.length === 0" class="flex flex-col items-center justify-center py-20">
            <div class="w-24 h-24 bg-gray-100 rounded-full flex items-center justify-center mb-6">
              <svg class="w-12 h-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
              </svg>
            </div>
            <h3 class="text-xl font-semibold text-gray-900 mb-2">Nenhum imóvel encontrado</h3>
            <p class="text-gray-600 mb-6">Tente ajustar seus filtros ou buscar por outros termos</p>
            <button
              @click="clearFilters"
              class="border border-gray-300 rounded-lg px-6 py-2 text-gray-700 hover:bg-gray-50"
            >
              Limpar Filtros
            </button>
          </div>

          <!-- Properties Grid (2 colunas) -->
          <div v-else class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <PropertyCard v-for="p in propertiesStore.list" :key="p.id" :item="p" />
          </div>
        </div>

        <!-- Mapa (Direita) -->
        <div class="w-1/2 flex-shrink-0">
          <div class="sticky top-24 h-full">
            <PropertiesMap
              :properties="propertiesStore.list"
              :selected-city="city"
            />
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
