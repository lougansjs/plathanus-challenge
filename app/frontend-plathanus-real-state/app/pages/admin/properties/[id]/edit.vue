<!-- app/pages/admin/properties/[id]/edit.vue -->
<script setup lang="ts">
// @ts-ignore - definePageMeta is auto-imported by Nuxt
definePageMeta({ layout: 'admin' })
import { onMounted, reactive } from 'vue'
import { useRoute } from 'vue-router'
import { usePropertiesStore } from '../../../../stores/properties'
// @ts-ignore - Vue component
import PropertyForm from '../../../../components/properties/PropertyForm.vue'

const route = useRoute()
const store = usePropertiesStore()
const initial = reactive<any>(null)

onMounted(async () => {
  await store.fetchShow(route.params.id as string)
  if (store.current) {
    // mapeia current -> initial (sem fotos)
    const { id, category, cover_photo, photos, ...rest } = store.current
    initial.value = { ...rest, category_id: category?.id ?? '' }
  }
})
</script>

<template>
  <div class="max-w-3xl mx-auto p-6">
    <h1 class="text-2xl font-semibold mb-4">Editar imóvel</h1>
    <PropertyForm v-if="initial" :initial="initial" mode="edit" :id="String($route.params.id)" />
    <div v-else class="h-40 bg-gray-200 animate-pulse rounded-xl"></div>
  </div>
</template>
