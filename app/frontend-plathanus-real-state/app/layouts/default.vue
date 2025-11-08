<!-- app/layouts/default.vue -->
<template>
  <div class="min-h-screen bg-white">
    <AppHeader variant="default" />
    <main><slot /></main>
    <footer class="border-t mt-16 py-8">
      <div class="max-w-7xl mx-auto px-4 text-center text-gray-500 text-sm">
        © 2025 Plathannus Imóveis. Todos os direitos reservados.
      </div>
    </footer>
  </div>
</template>
