<!-- app/components/ui/Modal.vue -->
<script setup lang="ts">
// @ts-ignore - defineProps is auto-imported by Nuxt
const props = defineProps<{
  show: boolean
  title: string
  size?: 'sm' | 'md' | 'lg' | 'xl'
}>()

// @ts-ignore - defineEmits is auto-imported by Nuxt
const emit = defineEmits<{
  close: []
}>()

const sizeClasses = {
  sm: 'max-w-md',
  md: 'max-w-2xl',
  lg: 'max-w-4xl',
  xl: 'max-w-6xl'
}

function closeModal() {
  emit('close')
}

function handleOverlayClick(e: MouseEvent) {
  if (e.target === e.currentTarget) {
    closeModal()
  }
}
</script>

<template>
  <Teleport to="body">
    <Transition name="modal">
      <div
        v-if="show"
        class="fixed inset-0 z-50 overflow-y-auto"
        @click="handleOverlayClick"
      >
        <div class="flex items-center justify-center min-h-screen px-4 pt-4 pb-20 text-center sm:block sm:p-0">
          <!-- Background overlay -->
          <Transition name="modal-backdrop">
            <div
              v-if="show"
              class="fixed inset-0 bg-gray-900 bg-opacity-75 transition-opacity"
            ></div>
          </Transition>

          <!-- Modal panel -->
          <Transition name="modal-panel">
            <div
              v-if="show"
              class="inline-block align-bottom bg-white rounded-lg text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle w-full"
              :class="sizeClasses[size || 'lg']"
              @click.stop
            >
              <!-- Header -->
              <div class="flex items-center justify-between px-6 py-4 border-b">
                <h3 class="text-xl font-semibold text-gray-900">{{ title }}</h3>
                <button
                  @click="closeModal"
                  class="text-gray-400 hover:text-gray-600 transition-colors"
                >
                  <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                  </svg>
                </button>
              </div>

              <!-- Content -->
              <div class="px-6 py-4 max-h-[calc(100vh-200px)] overflow-y-auto">
                <slot />
              </div>

              <!-- Footer (optional) -->
              <div v-if="$slots.footer" class="px-6 py-4 border-t bg-gray-50">
                <slot name="footer" />
              </div>
            </div>
          </Transition>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<style scoped>
.modal-enter-active,
.modal-leave-active {
  transition: opacity 0.3s ease;
}

.modal-enter-from,
.modal-leave-to {
  opacity: 0;
}

.modal-backdrop-enter-active,
.modal-backdrop-leave-active {
  transition: opacity 0.3s ease;
}

.modal-backdrop-enter-from,
.modal-backdrop-leave-to {
  opacity: 0;
}

.modal-panel-enter-active,
.modal-panel-leave-active {
  transition: all 0.3s ease;
}

.modal-panel-enter-from,
.modal-panel-leave-to {
  opacity: 0;
  transform: scale(0.95);
}
</style>

