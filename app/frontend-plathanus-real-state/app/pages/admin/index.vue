<!-- app/pages/admin/index.vue -->
<script setup lang="ts">
// @ts-ignore - definePageMeta is auto-imported by Nuxt
definePageMeta({ layout: 'admin' })
import { onMounted, ref, computed, watch } from 'vue'
import { usePropertiesStore } from '../../stores/properties'
import { useAuthStore } from '../../stores/auth'
import { useMoney } from '../../composables/useMoney'
import { usePropertyStatus } from '../../composables/usePropertyStatus'
// @ts-ignore - Vue component
import Modal from '../../components/ui/Modal.vue'
// @ts-ignore - Vue component
import PropertyForm from '../../components/properties/PropertyForm.vue'
// @ts-ignore - Vue component
import LoginModal from '../../components/auth/LoginModal.vue'

const authStore = useAuthStore()
const store = usePropertiesStore()
const { brl } = useMoney()
const { getStatusLabel, getStatusColor, getContractTypeLabel } = usePropertyStatus()
const showModal = ref(false)
const editingProperty = ref<number | null>(null)
const currentPage = ref(1)
const perPage = ref(50) // Aumentado para 50 imóveis por página na tela de admin
const checkingAuth = ref(true)

onMounted(async () => {
  // Inicializar auth store
  authStore.init()
  
  // Carregar dados sempre (para aparecer com blur quando não autenticado)
  loadPage(1)
  
  // Verificar se token é válido
  const isValid = await authStore.verifyToken()
  
  checkingAuth.value = false
})

// Watch para recarregar dados quando autenticar
watch(() => authStore.isAuthenticated, (isAuth) => {
  if (isAuth && !checkingAuth.value) {
    loadPage(1)
  }
})

function loadPage(page: number) {
  currentPage.value = page
  store.fetchIndex({ order: 'recent', page, per_page: perPage.value })
}

async function remove(id: number) {
  if (confirm('Tem certeza que deseja excluir este imóvel?')) {
    await store.destroy(id)
    loadPage(currentPage.value)
  }
}

function openCreateModal() {
  editingProperty.value = null
  showModal.value = true
}

function openEditModal(id: number) {
  editingProperty.value = id
  showModal.value = true
}

function closeModal() {
  showModal.value = false
  editingProperty.value = null
}

async function handleFormSuccess() {
  closeModal()
  loadPage(currentPage.value)
}

function goToPage(page: number) {
  if (page >= 1 && page <= totalPages.value) {
    loadPage(page)
    window.scrollTo({ top: 0, behavior: 'smooth' })
  }
}

const totalPages = computed(() => store.meta?.total_pages || 1)
const hasNextPage = computed(() => currentPage.value < totalPages.value)
const hasPrevPage = computed(() => currentPage.value > 1)

// Calcula quais números de página mostrar
const pageNumbers = computed(() => {
  const pages: number[] = []
  const total = totalPages.value
  const current = currentPage.value

  if (total <= 7) {
    // Se tem 7 ou menos páginas, mostra todas
    for (let i = 1; i <= total; i++) {
      pages.push(i)
    }
  } else {
    // Sempre mostra primeira página
    pages.push(1)

    if (current <= 4) {
      // Perto do início: 1, 2, 3, 4, 5, ..., total
      for (let i = 2; i <= 5; i++) {
        pages.push(i)
      }
      if (total > 6) pages.push(-1) // Separador
      pages.push(total)
    } else if (current >= total - 3) {
      // Perto do fim: 1, ..., total-4, total-3, total-2, total-1, total
      pages.push(-1) // Separador
      for (let i = total - 4; i <= total; i++) {
        pages.push(i)
      }
    } else {
      // No meio: 1, ..., current-1, current, current+1, ..., total
      pages.push(-1) // Separador
      for (let i = current - 1; i <= current + 1; i++) {
        pages.push(i)
      }
      pages.push(-1) // Separador
      pages.push(total)
    }
  }

  return pages
})
</script>

<template>
  <div>
    <!-- Modal de Login (mostra se não autenticado) -->
    <LoginModal v-if="!authStore.isAuthenticated && !checkingAuth" />

    <!-- Conteúdo Admin (sempre visível, mas com blur quando não autenticado) -->
    <div 
      class="max-w-7xl mx-auto px-4 py-8 transition-all duration-300"
      :class="{ 
        'pointer-events-none blur-sm opacity-50': !authStore.isAuthenticated && !checkingAuth,
        'opacity-100': authStore.isAuthenticated || checkingAuth
      }"
    >
      <div class="mb-8">
      <h1 class="text-3xl font-bold text-gray-900 mb-2">Administração de Imóveis</h1>
      <p class="text-gray-600">Gerencie todos os imóveis do sistema</p>
    </div>

    <div class="flex justify-end mb-6">
      <button
        @click="openCreateModal"
        class="flex items-center gap-2 bg-green-600 text-white px-6 py-3 rounded-lg hover:bg-green-700 font-semibold"
      >
        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
        </svg>
        Novo Imóvel
      </button>
    </div>

    <!-- Empty State -->
    <div v-if="!store.loading && store.list.length === 0" class="bg-white rounded-lg border-2 border-dashed border-gray-300 p-16 text-center">
      <div class="w-20 h-20 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-6">
        <svg class="w-10 h-10 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
        </svg>
      </div>
      <h3 class="text-xl font-semibold text-gray-900 mb-2">Nenhum imóvel cadastrado</h3>
      <p class="text-gray-600 mb-6">Comece adicionando seu primeiro imóvel</p>
      <button
        @click="openCreateModal"
        class="inline-flex items-center gap-2 bg-green-600 text-white px-6 py-3 rounded-lg hover:bg-green-700 font-semibold"
      >
        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
        </svg>
        Novo Imóvel
      </button>
    </div>

    <!-- Properties List -->
    <div v-else-if="store.loading" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <SkeletonCard v-for="i in 6" :key="i" />
    </div>

    <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <div
        v-for="p in store.list"
        :key="p.id"
        class="bg-white rounded-lg shadow-sm border hover:shadow-md transition-shadow overflow-hidden"
      >
        <div class="relative h-48">
          <img
            :src="p.cover_photo?.card_url || p.photos?.[0]?.card_url || '/placeholder-property.jpg'"
            class="w-full h-full object-cover"
            alt="cover"
          />
          <div class="absolute top-4 left-4">
            <span
              class="px-3 py-1 rounded-full text-xs font-semibold"
              :class="getStatusColor(p.status).bg + ' ' + getStatusColor(p.status).text"
            >
              {{ getStatusLabel(p.status) }}
            </span>
          </div>
        </div>
        <div class="p-4">
          <h3 class="font-semibold text-gray-900 mb-2">{{ p.name }}</h3>
          <p class="text-sm text-gray-600 mb-4">{{ p.category?.name }} • {{ getContractTypeLabel(p.contract_type) }}</p>
          <div class="flex items-center justify-between">
            <p v-if="p.price" class="text-green-600 font-bold">
              {{ brl(p.price) }}
            </p>
            <div class="flex gap-2">
              <button
                @click="openEditModal(p.id)"
                class="text-blue-600 hover:text-blue-800 text-sm font-medium"
              >
                Editar
              </button>
              <button
                @click="remove(p.id)"
                class="text-red-600 hover:text-red-800 text-sm font-medium"
              >
                Excluir
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Paginação -->
    <div v-if="store.meta && store.meta.total_pages > 1" class="mt-8 flex items-center justify-between bg-white px-4 py-3 rounded-lg border">
      <div class="flex items-center gap-2">
        <button
          @click="goToPage(currentPage - 1)"
          :disabled="!hasPrevPage"
          :class="[
            'px-4 py-2 rounded-md text-sm font-medium transition-colors',
            hasPrevPage
              ? 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              : 'bg-gray-50 text-gray-400 cursor-not-allowed'
          ]"
        >
          Anterior
        </button>
        <span class="text-sm text-gray-600">
          Página {{ currentPage }} de {{ totalPages }}
          <span class="text-gray-400">({{ store.meta.total_count }} imóveis no total)</span>
        </span>
        <button
          @click="goToPage(currentPage + 1)"
          :disabled="!hasNextPage"
          :class="[
            'px-4 py-2 rounded-md text-sm font-medium transition-colors',
            hasNextPage
              ? 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              : 'bg-gray-50 text-gray-400 cursor-not-allowed'
          ]"
        >
          Próxima
        </button>
      </div>
      <div class="flex items-center gap-1">
        <template v-for="(page, index) in pageNumbers">
          <button
            v-if="page !== -1"
            :key="`page-${page}`"
            @click="goToPage(page)"
            :class="[
              'w-10 h-10 rounded-md text-sm font-medium transition-colors',
              currentPage === page
                ? 'bg-green-600 text-white'
                : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
            ]"
          >
            {{ page }}
          </button>
          <span v-else :key="`sep-${index}`" class="px-2 text-gray-400">...</span>
        </template>
      </div>
    </div>

    <!-- Modal -->
    <Modal
      :show="showModal"
      :title="editingProperty ? 'Editar Imóvel' : 'Novo Imóvel'"
      size="xl"
      @close="closeModal"
    >
      <PropertyForm
        :mode="editingProperty ? 'edit' : 'create'"
        :id="editingProperty || undefined"
        @success="handleFormSuccess"
        @cancel="closeModal"
      />
    </Modal>
    </div>
  </div>
</template>
