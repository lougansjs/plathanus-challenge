<!-- app/components/properties/PropertyMap.vue -->
<template>
  <div class="w-full">
    <div 
      ref="mapContainer" 
      class="w-full h-[500px] rounded-lg overflow-hidden shadow-lg border border-gray-200"
      :class="{ 'bg-gray-200 animate-pulse': loading }"
    >
      <div v-if="!hasCoordinates" class="flex items-center justify-center h-full text-gray-500">
        <p>Coordenadas não disponíveis</p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
/// <reference types="../../../types/google-maps" />
import { ref, onMounted, onUnmounted, computed } from 'vue'
import { useRuntimeConfig } from 'nuxt/app'
import type { Address } from '../../../types/property'

const props = defineProps<{
  address: Address | null
}>()

const mapContainer = ref<HTMLDivElement | null>(null)
const map = ref<any>(null)
const marker = ref<any>(null)
const loading = ref(true)
const mapLoaded = ref(false)

// Converte e valida coordenadas para números
function parseCoordinate(value: string | number | null | undefined): number | null {
  if (value === null || value === undefined || value === '') return null
  const num = typeof value === 'string' ? parseFloat(value) : value
  if (isNaN(num) || !isFinite(num)) return null
  return num
}

const hasCoordinates = computed(() => {
  const lat = parseCoordinate(props.address?.latitude)
  const lng = parseCoordinate(props.address?.longitude)
  return lat !== null && lng !== null && 
         lat >= -90 && lat <= 90 && 
         lng >= -180 && lng <= 180
})

// Coordenadas convertidas para números
const coordinates = computed(() => {
  const lat = parseCoordinate(props.address?.latitude)
  const lng = parseCoordinate(props.address?.longitude)
  return { lat, lng }
})

const formattedAddress = computed(() => {
  if (!props.address) return ''
  const parts = [
    props.address.street,
    props.address.neighborhood,
    `${props.address.city || ''}${props.address.state ? `/${props.address.state}` : ''}`,
    props.address.zipcode
  ].filter(Boolean)
  return parts.join(' • ')
})

// Cria um ícone de marcador personalizado
function createCustomMarkerIcon(googleMaps: any, color: string = '#10b981', size: number = 40): any {
  // Cria um SVG personalizado com formato de pin/marcador
  const svg = `
    <svg width="${size}" height="${size}" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
      <path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7z" fill="${color}" stroke="white" stroke-width="2"/>
      <circle cx="12" cy="9" r="3" fill="white"/>
    </svg>
  `
  
  // Converte SVG para data URL
  const svgBlob = new Blob([svg], { type: 'image/svg+xml;charset=utf-8' })
  const url = URL.createObjectURL(svgBlob)
  
  return {
    url: url,
    scaledSize: new googleMaps.Size(size, size),
    anchor: new googleMaps.Point(size / 2, size), // Ponto inferior central do marcador
    origin: new googleMaps.Point(0, 0)
  }
}

onMounted(async () => {
  if (!props.address || !mapContainer.value || !hasCoordinates.value) {
    loading.value = false
    return
  }

  // Valida e converte coordenadas
  const coords = coordinates.value
  if (coords.lat === null || coords.lng === null) {
    console.warn('Coordenadas inválidas:', props.address)
    loading.value = false
    return
  }

  // Obtém a chave da API do ambiente através do runtimeConfig do Nuxt
  const config = useRuntimeConfig()
  const apiKey = config.public.googleMapsApiKey || ''

  if (!apiKey) {
    console.warn('Google Maps API key não configurada. Configure NUXT_PUBLIC_GOOGLE_MAPS_API_KEY no .env ou nuxt.config.ts')
    loading.value = false
    return
  }

  try {
    // Verifica se o script já existe
    const existingScript = document.querySelector(
      `script[src*="maps.googleapis.com/maps/api/js"]`
    )

    // Carrega o Google Maps dinamicamente apenas se não existir
    if (typeof window !== 'undefined' && !existingScript && !(window as any).google) {
      const script = document.createElement('script')
      script.src = `https://maps.googleapis.com/maps/api/js?key=${apiKey}&libraries=places&loading=async`
      script.async = true
      script.defer = true

      await new Promise<void>((resolve, reject) => {
        // Timeout de 15 segundos
        const timeout = setTimeout(() => {
          reject(new Error('Timeout ao carregar Google Maps API'))
        }, 15000)
        
        script.onload = () => {
          clearTimeout(timeout)
          resolve()
        }
        
        script.onerror = () => {
          clearTimeout(timeout)
          reject(new Error('Erro ao carregar Google Maps API'))
        }
        
        document.head.appendChild(script)
      })
    } else if (existingScript && !(window as any).google) {
      // Script existe mas ainda não carregou, aguarda
      await new Promise<void>((resolve, reject) => {
        const timeout = setTimeout(() => {
          reject(new Error('Timeout ao aguardar Google Maps carregar'))
        }, 15000)
        
        const checkInterval = setInterval(() => {
          if ((window as any).google?.maps) {
            clearInterval(checkInterval)
            clearTimeout(timeout)
            resolve()
          }
        }, 100)
      })
    }

    // Aguarda o Google Maps estar totalmente disponível e pronto
    const waitForGoogleMaps = async (maxAttempts = 50, delay = 100): Promise<any> => {
      for (let i = 0; i < maxAttempts; i++) {
        const google = (window as any).google
        if (google?.maps?.Map) {
          return google.maps
        }
        await new Promise(resolve => setTimeout(resolve, delay))
      }
      throw new Error('Google Maps não foi carregado após múltiplas tentativas')
    }

    const googleMaps = await waitForGoogleMaps()
    
    if (!googleMaps || !googleMaps.Map) {
      throw new Error('Google Maps não foi carregado corretamente. Map constructor não está disponível.')
    }

    // Verifica se as enums necessárias estão disponíveis
    if (!googleMaps.MapTypeControlStyle || !googleMaps.ControlPosition) {
      console.warn('Google Maps enums não disponíveis, usando valores padrão')
    }

    // Garante que as coordenadas são números finitos
    const lat = Number(coords.lat)
    const lng = Number(coords.lng)
    
    if (!isFinite(lat) || !isFinite(lng)) {
      throw new Error(`Coordenadas inválidas: lat=${lat}, lng=${lng}`)
    }

    // Prepara as opções do mapTypeControl de forma segura
    const mapTypeControlOptions: any = {
      mapTypeIds: ['roadmap', 'satellite']
    }
    
    // Adiciona style e position apenas se as enums estiverem disponíveis
    if (googleMaps.MapTypeControlStyle) {
      mapTypeControlOptions.style = googleMaps.MapTypeControlStyle.HORIZONTAL_BAR
    }
    if (googleMaps.ControlPosition) {
      mapTypeControlOptions.position = googleMaps.ControlPosition.TOP_LEFT
    }

    // Cria o mapa
    map.value = new googleMaps.Map(mapContainer.value, {
      center: {
        lat: lat,
        lng: lng
      },
      zoom: 15,
      mapTypeControl: true,
      mapTypeControlOptions: mapTypeControlOptions,
      fullscreenControl: true,
      streetViewControl: true,
      zoomControl: true,
      styles: [
        {
          featureType: 'poi',
          elementType: 'labels',
          stylers: [{ visibility: 'on' }]
        }
      ]
    })

    // Cria ícone personalizado para o marcador
    const customIcon = createCustomMarkerIcon(googleMaps, '#10b981', 48) // Verde, 48px
    
    // Adiciona marcador com coordenadas validadas e ícone personalizado
    const markerOptions: any = {
      position: {
        lat: lat,
        lng: lng
      },
      map: map.value,
      title: props.address.street || 'Localização do imóvel',
      icon: customIcon,
      optimized: false // Permite melhor renderização de ícones personalizados
    }
    
    // Adiciona animation apenas se estiver disponível
    if (googleMaps.Animation) {
      markerOptions.animation = googleMaps.Animation.DROP
    }
    
    marker.value = new googleMaps.Marker(markerOptions)
    
    // Limpa o objeto URL após criar o marcador (opcional, para liberar memória)
    // URL.revokeObjectURL(customIcon.url)

    // Adiciona info window (opcional)
    const infoWindow = new googleMaps.InfoWindow({
      content: `
        <div class="p-2">
          <p class="font-semibold">${props.address.street || 'Imóvel'}</p>
          <p class="text-sm text-gray-600">${formattedAddress.value}</p>
        </div>
      `
    })

    marker.value.addListener('click', () => {
      infoWindow.open(map.value, marker.value)
    })

    mapLoaded.value = true
    loading.value = false
  } catch (error) {
    console.error('Erro ao carregar mapa:', error)
    loading.value = false
  }
})

onUnmounted(() => {
  if (marker.value) {
    marker.value.setMap(null)
  }
  map.value = null
})
</script>

