<!-- app/layouts/admin.vue -->
<script setup lang="ts">
import { useAuthStore } from '../stores/auth'

const authStore = useAuthStore()

// Inicializar auth store quando layout é montado
if (process.client) {
  authStore.init()
}
</script>

<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Header só aparece se autenticado -->
    <AppHeader v-if="authStore.isAuthenticated" variant="admin" />
    <main><slot /></main>
  </div>
</template>
