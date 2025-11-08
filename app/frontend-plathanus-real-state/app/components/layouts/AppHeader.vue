<!-- app/components/layouts/AppHeader.vue -->
<script setup lang="ts">
import { computed } from 'vue'
import { useRoute } from 'vue-router'

const route = useRoute()

const isActive = (path: string) => {
  if (path === '/') {
    return route.path === '/'
  }
  return route.path.startsWith(path)
}

// Props para customizar o header
interface Props {
  variant?: 'default' | 'admin'
}

const props = withDefaults(defineProps<Props>(), {
  variant: 'default'
})

const headerClasses = computed(() => {
  return props.variant === 'admin' 
    ? 'border-b bg-white' 
    : 'border-b'
})
</script>

<template>
  <header :class="headerClasses">
    <nav class="max-w-7xl mx-auto px-4 py-4 flex items-center justify-between">
      <NuxtLink to="/" class="flex items-center gap-2">
        <img src="/icon.svg" alt="Plathannus Imóveis" class="w-8 h-8" />
        <span class="text-green-600 font-semibold text-lg">Plathannus Imóveis</span>
      </NuxtLink>
      <div class="flex items-center gap-6">
        <NuxtLink
          to="/"
          :class="[
            'transition-colors',
            isActive('/') && route.path !== '/imoveis' && route.path !== '/admin' 
              ? 'text-green-600 font-medium' 
              : 'text-gray-600 hover:text-gray-900'
          ]"
        >
          Início
        </NuxtLink>
        <NuxtLink
          to="/imoveis"
          :class="[
            'transition-colors',
            isActive('/imoveis') 
              ? 'text-green-600 font-medium' 
              : 'text-gray-600 hover:text-gray-900'
          ]"
        >
          Imóveis
        </NuxtLink>
        <NuxtLink
          to="/admin"
          :class="[
            'transition-colors',
            isActive('/admin') 
              ? 'text-green-600 font-medium' 
              : 'text-gray-600 hover:text-gray-900'
          ]"
        >
          Admin
        </NuxtLink>
      </div>
    </nav>
  </header>
</template>

