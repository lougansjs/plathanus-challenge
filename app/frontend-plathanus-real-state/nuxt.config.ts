// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  ssr: false,
  srcDir: 'app',
  modules: ['@pinia/nuxt', '@nuxtjs/tailwindcss'],
  components: [
    {
      path: '~/components',
      pathPrefix: false
    }
  ],
  css: ['../assets/css/tailwind.css'],
  tailwindcss: {
    cssPath: '../assets/css/tailwind.css'
  },
  runtimeConfig: {
    public: {
      apiBase: process.env.NUXT_PUBLIC_API_BASE_URL || 'http://0.0.0.0:3001/api/v1',
      googleMapsApiKey: process.env.NUXT_PUBLIC_GOOGLE_MAPS_API_KEY || 'AIzaSyD_tQ1N8eZc68tTvZ50o63p8GODc4wRl-w'
    }
  },
  pinia: {
    storesDirs: ['./stores']
  },
  compatibilityDate: '2025-07-15',
  devtools: { enabled: true },
  devServer: {
    host: '0.0.0.0', // Permite acesso de qualquer IP
    port: 3000
  },
  vite: {
    server: {
      allowedHosts: [
        '.loca.lt',
        'localhost',
        '0.0.0.0'
      ],
      hmr: {
        clientPort: 3000
      }
    }
  },
  app: {
    head: {
      title: 'Plathannus Imóveis - Me contrata?',
      meta: [
        { name: 'description', content: 'Projeto de imóveis para desafio da Plathanus' }
      ],
      link: [
        { rel: 'icon', type: 'image/svg+xml', href: '/icon.svg' }
      ]
    }
  }
})
