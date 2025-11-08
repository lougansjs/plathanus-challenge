<!-- app/components/properties/PropertyGallery.vue -->
<script setup lang="ts">
import type { PhotoUrls } from '../../../types/property'

// @ts-ignore - defineProps and defineEmits are auto-imported by Nuxt
const props = defineProps<{ photos: PhotoUrls[] }>()
const emit = defineEmits<{
  'photo-click': [index: number]
}>()

function handlePhotoClick(index: number) {
  emit('photo-click', index)
}
</script>

<template>
  <div class="grid grid-cols-2 sm:grid-cols-3 gap-4">
    <img
      v-for="(ph, i) in photos"
      :key="i"
      :src="ph.thumb_url"
      @click="handlePhotoClick(i)"
      class="w-full h-36 object-cover rounded-lg cursor-pointer hover:opacity-80 transition-opacity"
      alt="photo"
    />
  </div>
</template>
