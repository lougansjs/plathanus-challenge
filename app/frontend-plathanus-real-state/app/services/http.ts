import { useNuxtApp } from 'nuxt/app'
import type { AxiosInstance } from 'axios'

export const useHttp = (): AxiosInstance => {
  const nuxtApp = useNuxtApp()
  const api = nuxtApp.$api as AxiosInstance | undefined
  
  if (!api) {
    throw new Error('API instance not available. Make sure the api plugin is loaded.')
  }
  
  return api
}