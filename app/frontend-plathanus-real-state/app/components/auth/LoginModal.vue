<!-- app/components/auth/LoginModal.vue -->
<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useAuthStore } from '../../stores/auth'

const authStore = useAuthStore()
const email = ref('')
const password = ref('')
const errorMessage = ref<string | null>(null)
const isSubmitting = ref(false)

async function handleSubmit() {
  errorMessage.value = null
  isSubmitting.value = true

  const result = await authStore.login(email.value, password.value)

  if (!result.success) {
    errorMessage.value = result.error || 'Credenciais inválidas. Tente novamente.'
  }
  // Se sucesso, o store já atualizou o token e o componente será escondido
  // pela lógica do parent que verifica isAuthenticated

  isSubmitting.value = false
}

onMounted(() => {
  // Limpar campos ao montar
  email.value = ''
  password.value = ''
  errorMessage.value = null
})
</script>

<template>
  <Teleport to="body">
    <div class="fixed inset-0 z-[100] flex items-center justify-center p-4">
      <!-- Backdrop com blur - mostra o conteúdo de fundo levemente -->
      <div class="absolute inset-0 bg-black/30 backdrop-blur-md" @click.stop></div>
    
    <!-- Modal de Login -->
    <div class="relative bg-white rounded-lg shadow-xl w-full max-w-md p-8 z-10" @click.stop>
      <div class="text-center mb-6">
        <h2 class="text-2xl font-bold text-gray-900 mb-2">Acesso Administrativo</h2>
        <p class="text-gray-600 text-sm">Digite suas credenciais para continuar</p>
      </div>

      <form @submit.prevent="handleSubmit" class="space-y-4">
        <!-- Email -->
        <div>
          <label for="email" class="block text-sm font-medium text-gray-700 mb-1">
            E-mail
          </label>
          <input
            id="email"
            v-model="email"
            type="email"
            required
            autocomplete="email"
            class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500 outline-none transition-colors"
            placeholder="admin@imoveispremium.com"
            :disabled="isSubmitting"
          />
        </div>

        <!-- Senha -->
        <div>
          <label for="password" class="block text-sm font-medium text-gray-700 mb-1">
            Senha
          </label>
          <input
            id="password"
            v-model="password"
            type="password"
            required
            autocomplete="current-password"
            class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500 outline-none transition-colors"
            placeholder="••••••••"
            :disabled="isSubmitting"
          />
        </div>

        <!-- Mensagem de Erro -->
        <div v-if="errorMessage" class="bg-red-50 border border-red-200 rounded-lg p-3">
          <p class="text-sm text-red-600">{{ errorMessage }}</p>
        </div>

        <!-- Botão Submit -->
        <button
          type="submit"
          :disabled="isSubmitting"
          class="w-full bg-green-600 text-white py-2 px-4 rounded-lg font-semibold hover:bg-green-700 transition-colors disabled:bg-gray-400 disabled:cursor-not-allowed"
        >
          <span v-if="!isSubmitting">Entrar</span>
          <span v-else class="flex items-center justify-center gap-2">
            <svg class="animate-spin h-5 w-5" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
              <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
              <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
            </svg>
            Entrando...
          </span>
        </button>
      </form>
    </div>
    </div>
  </Teleport>
</template>

