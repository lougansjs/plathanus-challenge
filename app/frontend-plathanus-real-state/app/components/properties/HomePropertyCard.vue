<!-- app/components/properties/HomePropertyCard.vue -->
<script setup lang="ts">
import type { Property } from '../../../types/property'
import { useMoney } from '../../composables/useMoney'
import { computed } from 'vue'

// @ts-ignore - defineProps is auto-imported by Nuxt
const props = defineProps<{ item: Property }>()
const { brl } = useMoney()

const formatDate = (dateString: string | null | undefined) => {
  if (!dateString) return 'Hoje'
  const date = new Date(dateString)
  const today = new Date()
  const diffTime = date.getTime() - today.getTime()
  const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24))
  
  if (diffDays === 0) return 'Hoje'
  if (diffDays === 1) return 'Amanhã'
  if (diffDays < 0) return 'Disponível'
  
  return date.toLocaleDateString('pt-BR', { day: 'numeric', month: 'short' })
}

const hasBestDeal = computed(() => {
  // Mostra "Best Deal" se tiver preço promocional ou se for um dos primeiros imóveis
  return props.item.promotional_price && props.item.price && props.item.promotional_price < props.item.price
})

const dailyPrice = computed(() => {
  // Usa preço promocional se disponível, senão usa o preço normal
  const price = props.item.promotional_price || props.item.price
  if (!price) return null
  // Calcula preço diário aproximado (preço mensal / 30)
  return Math.round(price / 30)
})

const amenitiesText = computed(() => {
  const parts = []
  parts.push(`${props.item.rooms} ${props.item.rooms === 1 ? 'quarto' : 'quartos'}`)
  parts.push(`${props.item.bathrooms} ${props.item.bathrooms === 1 ? 'banheiro' : 'banheiros'}`)
  
  // Verifica características do prédio (pode vir como array ou boolean)
  const buildingChars = (props.item as any).building_characteristics || []
  const apartmentAmenities = (props.item as any).apartment_amenities || []
  
  if (Array.isArray(buildingChars) && buildingChars.includes('breakfast')) {
    parts.push('Café da manhã')
  } else if (props.item.breakfast) {
    parts.push('Café da manhã')
  } else if (Array.isArray(apartmentAmenities) && apartmentAmenities.includes('linen_towels')) {
    parts.push('Roupa de cama')
  } else if (props.item.linen_towels) {
    parts.push('Roupa de cama')
  } else {
    parts.push('Limpeza diária')
  }
  
  return parts.join(' • ')
})
</script>

<template>
  <NuxtLink
    :to="`/properties/${item.id}`"
    class="block bg-white rounded-lg shadow-sm hover:shadow-lg transition-all duration-300 overflow-hidden flex-shrink-0 w-[380px]"
  >
    <!-- Image -->
    <div class="relative h-64 overflow-hidden">
      <img
        :src="item.cover_photo?.card_url || item.photos?.[0]?.card_url || '/placeholder-property.jpg'"
        class="w-full h-full object-cover"
        alt="cover"
      />
      <!-- ID Overlay -->
      <div class="absolute top-4 left-4">
        <span class="px-3 py-1 rounded-full text-xs font-semibold bg-white text-gray-900">
          ID {{ item.code || item.id }}
        </span>
      </div>
      <!-- Image Dots (indicador de múltiplas fotos) -->
      <div v-if="item.photos && item.photos.length > 1" class="absolute bottom-4 left-1/2 transform -translate-x-1/2 flex gap-1">
        <div
          v-for="(photo, index) in item.photos.slice(0, 3)"
          :key="index"
          class="w-2 h-2 rounded-full"
          :class="index === 0 ? 'bg-white' : 'bg-white bg-opacity-50'"
        ></div>
      </div>
    </div>

    <!-- Content -->
    <div class="p-5 space-y-3">
      <!-- Location -->
      <div>
        <p class="text-sm text-gray-600 mb-1">
          {{ item.address?.neighborhood || item.address?.city || 'Localização não informada' }}
        </p>
        <p class="text-base font-medium text-gray-900">
          {{ item.address?.street || item.name }}
        </p>
      </div>

      <!-- Amenities -->
      <p class="text-sm text-gray-500">
        {{ amenitiesText }}
      </p>

      <!-- Best Deal Section (sempre mostra para destacar) -->
      <div v-if="dailyPrice" class="bg-green-600 rounded-lg p-3 flex items-center justify-between">
        <div class="flex items-center gap-3">
          <div class="w-8 h-8 bg-white bg-opacity-20 rounded-full flex items-center justify-center flex-shrink-0">
            <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
          </div>
          <div>
            <p class="text-white text-sm font-semibold">Melhor Oferta</p>
            <p class="text-white text-xs opacity-90">{{ formatDate(item.available_from) }}</p>
          </div>
        </div>
        <p class="text-white font-bold text-lg whitespace-nowrap">
          {{ brl(dailyPrice) }}/dia
        </p>
      </div>

      <!-- Price and Availability -->
      <div class="flex items-center justify-between pt-2">
        <div>
          <p v-if="item.price" class="text-gray-900 font-bold text-lg">
            {{ brl(item.price) }}/mês
          </p>
          <p v-else class="text-gray-400 text-sm">Preço não informado</p>
        </div>
        <button
          class="px-4 py-2 bg-gray-100 text-gray-700 rounded-lg text-sm font-medium hover:bg-gray-200 transition-colors"
        >
          Disponível {{ formatDate(item.available_from) }}
        </button>
      </div>
    </div>
  </NuxtLink>
</template>

