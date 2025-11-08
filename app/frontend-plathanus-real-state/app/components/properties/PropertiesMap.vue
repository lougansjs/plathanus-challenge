<!-- app/components/properties/PropertiesMap.vue -->
<template>
  <div class="w-full h-full relative">
    <div 
      ref="mapContainer" 
      class="w-full h-full rounded-lg overflow-hidden shadow-lg border border-gray-200"
    >
    </div>
    <div v-if="loading && !mapLoaded" class="absolute inset-0 flex items-center justify-center bg-white bg-opacity-90 z-10 rounded-lg">
      <div class="text-center">
        <div class="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-green-600 mb-2"></div>
        <p class="text-gray-500 text-sm">Carregando mapa...</p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
/// <reference types="../../../types/google-maps" />
import { ref, onMounted, onUnmounted, computed, watch } from 'vue'
import { useRuntimeConfig } from 'nuxt/app'
import type { Property } from '../../../types/property'

const props = defineProps<{
  properties: Property[]
  selectedCity?: string | null
}>()

const mapContainer = ref<HTMLDivElement | null>(null)
const map = ref<any>(null)
const markers = ref<any[]>([])
const infoWindows = ref<any[]>([])
const loading = ref(true)
const mapLoaded = ref(false)

// Coordenadas das cidades principais (para zoom automático)
const cityCoordinates: Record<string, { lat: number; lng: number }> = {
  'Florianópolis': { lat: -27.5954, lng: -48.5480 },
  'Joinville': { lat: -26.3044, lng: -48.8467 },
  'Blumenau': { lat: -26.9194, lng: -49.0661 },
  'Curitiba': { lat: -25.4284, lng: -49.2733 },
  'Londrina': { lat: -23.3045, lng: -51.1696 },
  'Maringá': { lat: -23.4205, lng: -51.9333 },
  'São Paulo': { lat: -23.5505, lng: -46.6333 },
  'Campinas': { lat: -22.9068, lng: -47.0636 },
  'Santos': { lat: -23.9608, lng: -46.3331 }
}

// Converte e valida coordenadas
function parseCoordinate(value: string | number | null | undefined): number | null {
  if (value === null || value === undefined || value === '') return null
  const num = typeof value === 'string' ? parseFloat(value) : value
  if (isNaN(num) || !isFinite(num)) return null
  return num
}

// Filtra propriedades com coordenadas válidas
const propertiesWithCoordinates = computed(() => {
  return props.properties.filter(prop => {
    const lat = parseCoordinate(prop.address?.latitude)
    const lng = parseCoordinate(prop.address?.longitude)
    return lat !== null && lng !== null && 
           lat >= -90 && lat <= 90 && 
           lng >= -180 && lng <= 180
  })
})

// Cria ícone de marcador personalizado estilizado
function createCustomMarkerIcon(googleMaps: any): any {
  // Cria um SVG de marcador tipo "pin" com gradiente e sombra
  const svgMarker = `
    <svg width="40" height="50" viewBox="0 0 40 50" xmlns="http://www.w3.org/2000/svg">
      <defs>
        <linearGradient id="grad" x1="0%" y1="0%" x2="0%" y2="100%">
          <stop offset="0%" style="stop-color:#10b981;stop-opacity:1" />
          <stop offset="100%" style="stop-color:#059669;stop-opacity:1" />
        </linearGradient>
        <filter id="shadow" x="-50%" y="-50%" width="200%" height="200%">
          <feGaussianBlur in="SourceAlpha" stdDeviation="2"/>
          <feOffset dx="0" dy="2" result="offsetblur"/>
          <feComponentTransfer>
            <feFuncA type="linear" slope="0.3"/>
          </feComponentTransfer>
          <feMerge>
            <feMergeNode/>
            <feMergeNode in="SourceGraphic"/>
          </feMerge>
        </filter>
      </defs>
      <path d="M20 0 C30 0 40 8 40 18 C40 28 20 50 20 50 C20 50 0 28 0 18 C0 8 10 0 20 0 Z" 
            fill="url(#grad)" 
            stroke="#ffffff" 
            stroke-width="2"
            filter="url(#shadow)"/>
      <circle cx="20" cy="18" r="6" fill="#ffffff" opacity="0.9"/>
    </svg>
  `
  
  return {
    url: 'data:image/svg+xml;charset=UTF-8,' + encodeURIComponent(svgMarker),
    scaledSize: new googleMaps.Size(40, 50),
    anchor: new googleMaps.Point(20, 50),
    origin: new googleMaps.Point(0, 0)
  }
}

// Limpa marcadores
function clearMarkers() {
  markers.value.forEach(marker => marker.setMap(null))
  infoWindows.value.forEach(iw => iw.close())
  markers.value = []
  infoWindows.value = []
}

// Adiciona marcadores ao mapa
function addMarkers(googleMaps: any) {
  if (!map.value || !propertiesWithCoordinates.value.length) return

  clearMarkers()

  const customIcon = createCustomMarkerIcon(googleMaps)

  propertiesWithCoordinates.value.forEach(property => {
    const lat = parseCoordinate(property.address?.latitude)!
    const lng = parseCoordinate(property.address?.longitude)!

    const marker = new googleMaps.Marker({
      position: { lat, lng },
      map: map.value,
      icon: customIcon,
      title: property.name,
      optimized: false // Evita problemas de renderização
    })

    const infoWindow = new googleMaps.InfoWindow({
      content: `
        <div style="padding: 8px; min-width: 200px;">
          <h3 style="font-weight: bold; margin-bottom: 4px;">${property.name}</h3>
          <p style="color: #666; font-size: 12px; margin-bottom: 4px;">
            ${property.address?.neighborhood || property.address?.city || ''}
          </p>
          <p style="color: #10b981; font-weight: bold; margin-top: 8px;">
            ${property.price ? new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(property.price) : 'Preço não informado'}
          </p>
        </div>
      `
    })

    marker.addListener('click', () => {
      // Fecha todas as outras info windows
      infoWindows.value.forEach(iw => iw.close())
      infoWindow.open(map.value, marker)
    })

    markers.value.push(marker)
    infoWindows.value.push(infoWindow)
  })
}

// Ajusta zoom para mostrar todos os marcadores ou cidade específica
function fitBounds(googleMaps: any) {
  if (!map.value || !propertiesWithCoordinates.value.length) return

  if (props.selectedCity && cityCoordinates[props.selectedCity]) {
    // Zoom na cidade selecionada
    const cityCoords = cityCoordinates[props.selectedCity]
    map.value.setCenter(cityCoords)
    map.value.setZoom(13)
  } else {
    // Ajusta para mostrar todos os marcadores
    const bounds = new googleMaps.LatLngBounds()
    propertiesWithCoordinates.value.forEach(prop => {
      const lat = parseCoordinate(prop.address?.latitude)!
      const lng = parseCoordinate(prop.address?.longitude)!
      bounds.extend({ lat, lng })
    })
    map.value.fitBounds(bounds)
    
    // Limita zoom máximo
    googleMaps.event.addListenerOnce(map.value, 'bounds_changed', () => {
      if (map.value.getZoom() > 15) {
        map.value.setZoom(15)
      }
    })
  }
}

// Inicializa o mapa
async function initMap() {
  if (!mapContainer.value || mapLoaded.value) return

  try {
    const apiKey = useRuntimeConfig().public.googleMapsApiKey || ''
    if (!apiKey) {
      console.warn('Google Maps API key não configurada')
      loading.value = false
      return
    }

    // Verifica se o script já existe
    const existingScript = document.querySelector(
      `script[src*="maps.googleapis.com/maps/api/js"]`
    )

    // Carrega o Google Maps se necessário
    if (typeof window !== 'undefined' && !existingScript && !(window as any).google) {
      await new Promise<void>((resolve, reject) => {
        const script = document.createElement('script')
        script.src = `https://maps.googleapis.com/maps/api/js?key=${apiKey}&libraries=places`
        script.async = true
        script.defer = true
        script.onload = () => resolve()
        script.onerror = () => reject(new Error('Erro ao carregar Google Maps'))
        document.head.appendChild(script)
      })
    } else if (existingScript && !(window as any).google) {
      // Aguarda o script existente carregar
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

    // Aguarda o Google Maps estar totalmente disponível
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

    // Cria o mapa
    map.value = new googleMaps.Map(mapContainer.value, {
      center: { lat: -23.5505, lng: -46.6333 }, // Centro do Brasil
      zoom: 5,
      mapTypeControl: true,
      streetViewControl: false,
      fullscreenControl: true,
      disableDefaultUI: false,
      zoomControl: true,
      // Previne re-renderizações desnecessárias
      gestureHandling: 'cooperative'
    })

    mapLoaded.value = true
    loading.value = false

    // Aguarda um frame para garantir que o mapa está totalmente renderizado
    await new Promise(resolve => setTimeout(resolve, 100))

    // Adiciona marcadores e ajusta zoom
    addMarkers(googleMaps)
    fitBounds(googleMaps)
    
    // Atualiza o contador de propriedades
    lastPropertiesLength = propertiesWithCoordinates.value.length

  } catch (error) {
    console.error('Erro ao inicializar mapa:', error)
    loading.value = false
  }
}

// Debounce para evitar atualizações muito frequentes
let updateTimeout: NodeJS.Timeout | null = null
let lastPropertiesLength = 0

function debouncedUpdate() {
  if (updateTimeout) clearTimeout(updateTimeout)
  updateTimeout = setTimeout(() => {
    if (mapLoaded.value && (window as any).google?.maps) {
      const googleMaps = (window as any).google.maps
      // Só atualiza se realmente houver mudança no número de propriedades ou se for a primeira vez
      const currentLength = propertiesWithCoordinates.value.length
      if (currentLength !== lastPropertiesLength || lastPropertiesLength === 0) {
        addMarkers(googleMaps)
        fitBounds(googleMaps)
        lastPropertiesLength = currentLength
      }
    }
  }, 300) // Aguarda 300ms antes de atualizar
}

// Watch para atualizar marcadores quando propriedades mudarem
watch(() => props.properties, () => {
  debouncedUpdate()
}, { deep: true })

// Watch para atualizar zoom quando cidade mudar
watch(() => props.selectedCity, () => {
  if (mapLoaded.value && (window as any).google?.maps) {
    const googleMaps = (window as any).google.maps
    // Para mudança de cidade, atualiza imediatamente mas sem re-criar marcadores desnecessariamente
    if (props.selectedCity && cityCoordinates[props.selectedCity]) {
      const cityCoords = cityCoordinates[props.selectedCity]
      map.value.setCenter(cityCoords)
      map.value.setZoom(13)
    } else {
      fitBounds(googleMaps)
    }
  }
})

onMounted(() => {
  initMap()
})

onUnmounted(() => {
  if (updateTimeout) {
    clearTimeout(updateTimeout)
    updateTimeout = null
  }
  clearMarkers()
})
</script>

