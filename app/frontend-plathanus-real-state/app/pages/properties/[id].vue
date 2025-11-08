<!-- app/pages/properties/[id].vue -->
<script setup lang="ts">
import { onMounted, computed, ref, onUnmounted } from 'vue'
import { useRoute } from 'vue-router'
import { usePropertiesStore } from '../../stores/properties'
import { useMoney } from '../../composables/useMoney'
// @ts-ignore - Vue component
import PropertyGallery from '../../components/properties/PropertyGallery.vue'
// @ts-ignore - Vue component
import PropertyMap from '../../components/properties/PropertyMap.vue'
import type { Property } from '../../../types/property'
import { ChevronLeft, ChevronRight, X } from 'lucide-vue-next'
// Ícones Lucide
import { 
  Wifi, 
  Microwave, 
  ChefHat, 
  Tv, 
  BedDouble, 
  Snowflake, 
  UtensilsCrossed, 
  Home, 
  Shirt, 
  Flame,
  Waves,
  Car,
  Building2,
  Dog,
  DoorOpen,
  User,
  Dumbbell,
  Coffee,
  Sparkles,
  Briefcase,
  Calendar,
  Bed,
  Bath,
  Square,
  ParkingCircle
} from 'lucide-vue-next'

const route = useRoute()
const store = usePropertiesStore()
const { brl } = useMoney()
const showGallery = ref(false)
const selectedPhotoIndex = ref<number | null>(null)

// Converte arrays de amenities/features para booleanos e garante tipos numéricos
function convertArraysToBooleans(data: any): Property {
  if (!data) return data
  
  const apartmentAmenities = data.apartment_amenities || []
  const buildingCharacteristics = data.building_characteristics || []

  return {
    ...data,
    // Converte preços para números se vierem como strings
    price: data.price != null ? (typeof data.price === 'string' ? parseFloat(data.price) : Number(data.price)) : null,
    promotional_price: data.promotional_price != null ? (typeof data.promotional_price === 'string' ? parseFloat(data.promotional_price) : Number(data.promotional_price)) : null,
    // Converte amenities para booleanos
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
  } as Property
}

const property = computed(() => {
  const current = store.current
  return current ? convertArraysToBooleans(current) : null
})

// Breadcrumbs
const breadcrumbs = computed(() => {
  if (!property.value?.address) return []
  const parts = []
  if (property.value.address.city) parts.push(property.value.address.city)
  if (property.value.address.neighborhood) parts.push(property.value.address.neighborhood)
  if (property.value.address.street) parts.push(property.value.address.street)
  return parts
})

// Lista de comodidades do apartamento
const apartmentAmenities = computed(() => {
  if (!property.value) return []
  const amenities: Array<{ label: string; icon: any }> = []
  
  if (property.value.wifi) amenities.push({ label: 'Wi-Fi', icon: Wifi })
  if (property.value.microwave && property.value.oven) amenities.push({ label: 'Micro-ondas e Forno', icon: Microwave })
  else if (property.value.microwave) amenities.push({ label: 'Micro-ondas', icon: Microwave })
  else if (property.value.oven) amenities.push({ label: 'Forno', icon: ChefHat })
  if (property.value.smart_tv) amenities.push({ label: 'Smart TV', icon: Tv })
  if (property.value.linen_towels) amenities.push({ label: 'Roupa de Cama e Toalhas', icon: BedDouble })
  if (property.value.air_conditioning) amenities.push({ label: 'Ar Condicionado', icon: Snowflake })
  if (property.value.kitchen) amenities.push({ label: 'Equipado para Cozinhar', icon: UtensilsCrossed })
  if (property.value.balcony) amenities.push({ label: 'Varanda', icon: Home })
  if (property.value.washer_dryer) amenities.push({ label: 'Lavadora e Secadora', icon: Shirt })
  if (property.value.stove) amenities.push({ label: 'Fogão', icon: Flame })
  
  return amenities
})

// Lista de características do prédio
const buildingFeatures = computed(() => {
  if (!property.value) return []
  const features: Array<{ label: string; icon: any }> = []
  
  if (property.value.pool) features.push({ label: 'Piscina', icon: Waves })
  if (property.value.parking) features.push({ label: 'Estacionamento', icon: Car })
  if (property.value.elevator) features.push({ label: 'Elevador', icon: Building2 })
  if (property.value.pets_allowed) features.push({ label: 'Aceita Pets', icon: Dog })
  if (property.value.gated_building) features.push({ label: 'Prédio Fechado', icon: DoorOpen })
  if (property.value.doorman) features.push({ label: 'Portaria 24h', icon: User })
  if (property.value.gym) features.push({ label: 'Academia', icon: Dumbbell })
  if (property.value.breakfast) features.push({ label: 'Café da Manhã', icon: Coffee })
  if (property.value.sauna) features.push({ label: 'Sauna', icon: Sparkles })
  if (property.value.coworking) features.push({ label: 'Coworking', icon: Briefcase })
  
  return features
})

// Formata data de disponibilidade
const formattedAvailableDate = computed(() => {
  if (!property.value?.available_from) return null
  const date = new Date(property.value.available_from)
  const months = ['jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez']
  const day = date.getDate()
  const month = months[date.getMonth()]
  const year = date.getFullYear()
  return `${day} ${month} ${year}`
})

// Scroll to location section
function scrollToLocation() {
  if (typeof window !== 'undefined') {
    const element = document.getElementById('location-section')
    element?.scrollIntoView({ behavior: 'smooth' })
  }
}

// URL do WhatsApp com mensagem pré-definida
const whatsappUrl = computed(() => {
  const phone = '5547997795600'
  const message = 'Eae Lougans, bora marcar uma conversa técnica?'
  return `https://wa.me/${phone}?text=${encodeURIComponent(message)}`
})

// Funções do carrossel
function openCarousel(index: number) {
  selectedPhotoIndex.value = index
}

function closeCarousel() {
  selectedPhotoIndex.value = null
}

function nextPhoto() {
  if (selectedPhotoIndex.value === null || !property.value?.photos) return
  selectedPhotoIndex.value = (selectedPhotoIndex.value + 1) % property.value.photos.length
}

function prevPhoto() {
  if (selectedPhotoIndex.value === null || !property.value?.photos) return
  selectedPhotoIndex.value = selectedPhotoIndex.value === 0 
    ? property.value.photos.length - 1 
    : selectedPhotoIndex.value - 1
}

// Navegação por teclado
function handleKeydown(e: KeyboardEvent) {
  if (selectedPhotoIndex.value === null) return
  
  if (e.key === 'Escape') {
    closeCarousel()
  } else if (e.key === 'ArrowLeft') {
    prevPhoto()
  } else if (e.key === 'ArrowRight') {
    nextPhoto()
  }
}

onMounted(() => {
  store.fetchShow(route.params.id as string)
  window.addEventListener('keydown', handleKeydown)
})

onUnmounted(() => {
  window.removeEventListener('keydown', handleKeydown)
})
</script>

<template>
  <div v-if="!property" class="min-h-screen bg-gray-50">
    <div class="max-w-7xl mx-auto p-6">
      <div class="h-96 bg-gray-200 animate-pulse rounded-xl"></div>
    </div>
  </div>

  <div v-else class="min-h-screen bg-gray-50">
    <!-- Breadcrumbs -->
    <div v-if="breadcrumbs.length > 0" class="bg-white border-b">
      <div class="max-w-7xl mx-auto px-4 py-3">
        <nav class="text-sm text-gray-600">
          <span v-for="(crumb, index) in breadcrumbs" :key="index">
            <span v-if="index > 0"> > </span>
            <span>{{ crumb }}</span>
          </span>
        </nav>
      </div>
    </div>

    <!-- Hero Section -->
    <div class="relative w-full h-[600px]">
      <img
        :src="property.cover_photo?.cover_url || property.photos?.[0]?.cover_url || ''"
        class="w-full h-full object-cover"
        alt="Property cover"
      />

      <!-- Overlay -->
      <div class="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-black/80 via-black/60 to-transparent p-8">
        <div class="max-w-7xl mx-auto">
          <div class="text-white">
            <div v-if="property.code" class="text-sm font-medium mb-1">{{ property.code }}</div>
            <div v-if="property.address?.neighborhood" class="text-sm opacity-90 mb-1">
              {{ property.category?.name || 'Apartment' }} - {{ property.address.neighborhood }}
            </div>
            <h1 class="text-2xl md:text-3xl font-bold mb-4">{{ property.name }}</h1>

            <!-- Property Details -->
            <div class="flex flex-wrap gap-4 mb-4 text-sm">
              <span class="flex items-center gap-1">
                <Bed class="w-5 h-5" />
                {{ property.rooms }} Quarto{{ property.rooms !== 1 ? 's' : '' }}
              </span>
              <span class="flex items-center gap-1">
                <Bath class="w-5 h-5" />
                {{ property.bathrooms }} Banheiro{{ property.bathrooms !== 1 ? 's' : '' }}
              </span>
              <span class="flex items-center gap-1">
                <Square class="w-5 h-5" />
                {{ property.area }} m²
              </span>
              <span v-if="property.parking_slots" class="flex items-center gap-1">
                <ParkingCircle class="w-5 h-5" />
                {{ property.parking_slots }} Vaga{{ property.parking_slots !== 1 ? 's' : '' }}
              </span>
            </div>

            <!-- Action Buttons -->
            <div class="flex gap-3">
              <button
                @click="showGallery = true"
                class="px-4 py-2 bg-white/20 backdrop-blur-sm text-white rounded-lg hover:bg-white/30 transition-colors text-sm font-medium"
              >
                Galeria
              </button>
              <button
                @click="scrollToLocation"
                class="px-4 py-2 bg-white/20 backdrop-blur-sm text-white rounded-lg hover:bg-white/30 transition-colors text-sm font-medium"
              >
                Ver no mapa
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Main Content -->
    <div class="max-w-7xl mx-auto px-4 py-8">
      <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <!-- Left Column - Main Content -->
        <div class="lg:col-span-2 space-y-8">
          <!-- Description -->
          <section>
            <h2 class="text-2xl font-bold text-gray-900 mb-4">Descrição</h2>
            <p v-if="property.description" class="text-gray-700 leading-relaxed mb-4 whitespace-pre-line">
              {{ property.description }}
            </p>
            <p v-else class="text-gray-500 italic">Nenhuma descrição disponível.</p>
          </section>

          <!-- Room Arrangement -->
          <section v-if="property.rooms_list && property.rooms_list.length > 0">
            <h2 class="text-2xl font-bold text-gray-900 mb-4">Disposição dos Cômodos</h2>
            <ul class="space-y-2">
              <li v-for="(room, index) in property.rooms_list" :key="index" class="text-gray-700">
                <span v-if="room.description">{{ room.description }}</span>
                <span v-else>{{ room.name }}</span>
                <span v-if="room.type" class="text-gray-500 ml-2">({{ room.type }})</span>
              </li>
            </ul>
          </section>

          <!-- Comodidades do Apartamento -->
          <section v-if="apartmentAmenities.length > 0">
            <h2 class="text-2xl font-bold text-gray-900 mb-4">Comodidades do Apartamento</h2>
            <div class="grid grid-cols-2 gap-4">
              <div
                v-for="(amenity, index) in apartmentAmenities"
                :key="index"
                class="flex items-center gap-3 p-3 bg-gray-50 rounded-lg"
              >
                <component :is="amenity.icon" class="w-6 h-6 text-gray-700" />
                <span class="text-gray-700">{{ amenity.label }}</span>
              </div>
            </div>
          </section>

          <!-- Características do Prédio -->
          <section v-if="buildingFeatures.length > 0">
            <h2 class="text-2xl font-bold text-gray-900 mb-4">Características do Prédio</h2>
            <div class="grid grid-cols-2 gap-4">
              <div
                v-for="(feature, index) in buildingFeatures"
                :key="index"
                class="flex items-center gap-3 p-3 bg-gray-50 rounded-lg"
              >
                <component :is="feature.icon" class="w-6 h-6 text-gray-700" />
                <span class="text-gray-700">{{ feature.label }}</span>
              </div>
            </div>
          </section>

          <!-- Localização -->
          <section id="location-section" v-if="property.address">
            <h2 class="text-2xl font-bold text-gray-900 mb-4">Localização</h2>
            <p class="text-gray-700 mb-4">{{ property.address.street }}</p>
            <PropertyMap :address="property.address" />
          </section>
        </div>

        <!-- Right Column - Sidebar -->
        <div class="lg:col-span-1">
          <div class="sticky top-8 bg-white rounded-lg shadow-lg p-6 space-y-6">
            <!-- Preço -->
            <div>
              <div class="text-3xl font-bold text-gray-900 mb-2">
                <span v-if="property.price">{{ brl(property.price) }}/mês</span>
                <span v-else class="text-gray-400">Preço não disponível</span>
              </div>
              <div v-if="formattedAvailableDate" class="text-gray-600">
                Disponível a partir de {{ formattedAvailableDate }}
              </div>
            </div>

            <!-- Melhor Oferta -->
            <div v-if="property.promotional_price" class="bg-green-50 border border-green-200 rounded-lg p-4">
              <div class="flex items-center gap-2 mb-2">
                <div class="w-3 h-3 bg-green-500 rounded-full"></div>
                <span class="font-semibold text-green-800">Melhor Oferta</span>
              </div>
              <div class="text-sm text-gray-600 mb-1">Período disponível</div>
              <div class="text-lg font-semibold text-gray-900 line-through mb-1">
                {{ brl(property.promotional_price) }}
              </div>
              <div class="text-xl font-bold text-green-600">
                {{ brl(property.price || 0) }}
              </div>
            </div>

            <!-- Botões de Ação -->
            <div class="space-y-3">
              <button class="w-full bg-gray-900 text-white py-3 rounded-lg font-medium hover:bg-gray-800 transition-colors">
                Escolher datas
              </button>
              
              <div class="text-center text-gray-500 text-sm">OU</div>
              
              <a
                :href="whatsappUrl"
                target="_blank"
                rel="noopener noreferrer"
                class="w-full bg-gray-100 text-gray-900 py-3 rounded-lg font-medium hover:bg-gray-200 transition-colors flex items-center justify-center gap-2"
              >
                <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413Z"/>
                </svg>
                WhatsApp
              </a>
              
              <a href="#" class="block text-center text-gray-600 hover:text-gray-900 text-sm">
                ou Entre em contato
              </a>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Gallery Modal -->
    <div
      v-if="showGallery"
      @click.self="showGallery = false"
      class="fixed inset-0 bg-black/80 z-50 flex items-center justify-center p-4"
    >
      <div class="bg-white rounded-lg max-w-4xl w-full max-h-[90vh] overflow-y-auto p-6">
        <div class="flex justify-between items-center mb-4">
          <h2 class="text-2xl font-bold">Galeria</h2>
          <button
            @click="showGallery = false"
            class="text-gray-500 hover:text-gray-700 text-2xl"
          >
            ×
          </button>
        </div>
        <PropertyGallery 
          :photos="property.photos" 
          @photo-click="openCarousel"
        />
      </div>
    </div>

    <!-- Carrossel de Imagens Grande -->
    <div
      v-if="selectedPhotoIndex !== null && property?.photos"
      class="fixed inset-0 bg-black/95 z-[60] flex items-center justify-center"
      @click.self="closeCarousel"
    >
      <!-- Botão Fechar -->
      <button
        @click="closeCarousel"
        class="absolute top-4 right-4 text-white hover:text-gray-300 z-10 p-2"
        aria-label="Fechar"
      >
        <X :size="32" />
      </button>

      <!-- Botão Anterior -->
      <button
        v-if="property.photos.length > 1"
        @click.stop="prevPhoto"
        class="absolute left-4 text-white hover:text-gray-300 z-10 p-2 bg-black/50 rounded-full hover:bg-black/70 transition-colors"
        aria-label="Foto anterior"
      >
        <ChevronLeft :size="32" />
      </button>

      <!-- Imagem Grande -->
      <div class="max-w-7xl w-full h-full flex items-center justify-center p-4">
        <img
          v-if="selectedPhotoIndex !== null"
          :src="property.photos[selectedPhotoIndex]?.original_url || property.photos[selectedPhotoIndex]?.thumb_url"
          :alt="`Foto ${selectedPhotoIndex + 1} de ${property.photos.length}`"
          class="max-w-full max-h-full object-contain rounded-lg"
        />
      </div>

      <!-- Botão Próximo -->
      <button
        v-if="property.photos.length > 1"
        @click.stop="nextPhoto"
        class="absolute right-4 text-white hover:text-gray-300 z-10 p-2 bg-black/50 rounded-full hover:bg-black/70 transition-colors"
        aria-label="Próxima foto"
      >
        <ChevronRight :size="32" />
      </button>

      <!-- Indicador de posição -->
      <div
        v-if="property.photos.length > 1 && selectedPhotoIndex !== null"
        class="absolute bottom-4 left-1/2 transform -translate-x-1/2 text-white bg-black/50 px-4 py-2 rounded-full text-sm"
      >
        {{ selectedPhotoIndex + 1 }} / {{ property.photos.length }}
      </div>
    </div>
  </div>
</template>
