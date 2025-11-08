<!-- app/pages/index.vue -->
<script setup lang="ts">
import { onMounted, ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { usePropertiesStore } from '../stores/properties'
// @ts-ignore - Vue component
import HomePropertyCard from '../components/properties/HomePropertyCard.vue'

const router = useRouter()
const store = usePropertiesStore()
const searchQuery = ref('')
const selectedCity = ref<string | null>(null)

// Cidades disponíveis
const cities = [
  'São Paulo',
  'Rio de Janeiro',
  'Florianópolis',
  'Curitiba',
  'Campinas',
  'Santos'
]

// Pega os 3 imóveis mais recentes
const recentProperties = computed(() => {
  return store.list.slice(0, 3)
})

onMounted(() => {
  store.fetchIndex({ order: 'recent', page: 1, per_page: 3 })
})

function handleSearch() {
  if (searchQuery.value.trim()) {
    router.push({
      path: '/imoveis',
      query: { search: searchQuery.value }
    })
  } else {
    router.push('/imoveis')
  }
}

function selectCity(city: string | null) {
  selectedCity.value = city
  if (city) {
    router.push({
      path: '/imoveis',
      query: { city }
    })
  } else {
    router.push('/imoveis')
  }
}
</script>

<template>
  <div class="min-h-screen bg-white">
    <!-- Hero Section -->
    <section class="bg-white py-12">
      <div class="max-w-7xl mx-auto px-4">
        <!-- Search Bar -->
        <div class="max-w-2xl mx-auto mb-12">
          <div class="flex gap-2 bg-white rounded-lg shadow-md border border-gray-200 p-2">
            <input
              v-model="searchQuery"
              @keyup.enter="handleSearch"
              type="text"
              placeholder="Escolha uma cidade"
              class="flex-1 px-4 py-3 border-none outline-none text-gray-700"
            />
            <button
              @click="handleSearch"
              class="bg-gray-100 text-gray-600 px-4 py-3 rounded-lg hover:bg-gray-200 flex items-center"
            >
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
              </svg>
            </button>
          </div>
        </div>

        <!-- Title Section -->
        <div class="text-center mb-8">
          <h1 class="text-4xl md:text-5xl font-bold text-gray-900 mb-3">
            Procurando um apartamento mobiliado?
          </h1>
          <p class="text-lg text-gray-600">
            Explore nossos apartamentos nos melhores destinos
          </p>
        </div>

        <!-- City Filters -->
        <div class="flex justify-center gap-3 mb-12 flex-wrap">
          <button
            v-for="city in cities"
            :key="city"
            @click="selectCity(city)"
            class="px-6 py-2 rounded-full text-sm font-medium transition-colors"
            :class="selectedCity === city 
              ? 'bg-gray-900 text-white' 
              : 'bg-gray-100 text-gray-700 hover:bg-gray-200'"
          >
            {{ city }}
          </button>
        </div>
      </div>
    </section>

    <!-- Properties Carousel Section -->
    <section v-if="!store.loading && recentProperties.length > 0" class="py-12 bg-white">
      <div class="max-w-7xl mx-auto px-4">
        <!-- Carousel Container -->
        <div class="relative">
          <div class="overflow-x-auto scrollbar-hide pb-4 -mx-4 px-4">
            <div class="flex gap-6" style="scroll-snap-type: x mandatory;">
              <div
                v-for="property in recentProperties"
                :key="property.id"
                style="scroll-snap-align: start;"
              >
                <HomePropertyCard :item="property" />
              </div>
            </div>
          </div>
        </div>

        <!-- View More Button -->
        <div class="text-center">
          <NuxtLink
            to="/imoveis"
            class="inline-block bg-gray-900 text-white px-8 py-3 rounded-lg hover:bg-gray-800 font-semibold transition-colors"
          >
            Ver mais imóveis
          </NuxtLink>
        </div>
      </div>
    </section>

    <!-- Loading State -->
    <section v-if="store.loading" class="py-20 bg-gray-50">
      <div class="max-w-7xl mx-auto px-4">
        <div class="flex gap-6 justify-center">
          <div v-for="i in 3" :key="i" class="bg-white rounded-lg shadow-sm w-[380px] h-96 animate-pulse">
            <div class="h-64 bg-gray-200"></div>
            <div class="p-5 space-y-3">
              <div class="h-4 bg-gray-200 rounded w-3/4"></div>
              <div class="h-4 bg-gray-200 rounded w-1/2"></div>
              <div class="h-12 bg-gray-200 rounded"></div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Empty State -->
    <section v-if="!store.loading && store.list.length === 0" class="py-20 bg-gray-50">
      <div class="max-w-2xl mx-auto px-4 text-center">
        <div class="w-24 h-24 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-6">
          <svg class="w-12 h-12 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />
          </svg>
        </div>
        <h3 class="text-2xl font-bold text-gray-900 mb-2">Nenhum imóvel cadastrado ainda</h3>
        <p class="text-gray-600 mb-6">Acesse a área administrativa para começar a adicionar imóveis</p>
        <NuxtLink
          to="/admin"
          class="inline-block bg-green-600 text-white px-6 py-3 rounded-lg hover:bg-green-700 font-semibold"
        >
          Ir para Admin
        </NuxtLink>
      </div>
    </section>
  </div>
</template>

<style scoped>
.scrollbar-hide {
  -ms-overflow-style: none;
  scrollbar-width: none;
}

.scrollbar-hide::-webkit-scrollbar {
  display: none;
}
</style>
