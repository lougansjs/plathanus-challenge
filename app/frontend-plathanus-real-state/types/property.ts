// types/property.ts
import type { Category } from './category'

export interface PhotoUrls {
  thumb_url: string
  card_url: string
  cover_url: string
  original_url: string
  signed_id?: string // ID para deletar foto no backend
}

export interface Address {
  street?: string
  neighborhood?: string
  city?: string
  state?: string
  country?: string
  zipcode?: string
  latitude?: number
  longitude?: number
}

export interface Property {
  id: number
  name: string
  code?: string
  status: 'available' | 'unavailable' | 'rented' | 'maintenance' | 'archived'
  rooms: number
  bathrooms: number
  area: number
  parking_slots?: number | null
  furnished: boolean
  contract_type: 'rent' //| 'sale' | 'seasonal'
  // Comodidades do apartamento/casa
  wifi: boolean
  smart_tv: boolean
  air_conditioning: boolean
  oven: boolean
  microwave: boolean
  stove: boolean
  linen_towels: boolean
  pool: boolean
  kitchen: boolean
  balcony: boolean
  washer_dryer: boolean
  // Características do prédio
  parking: boolean
  pets_allowed: boolean
  gym: boolean
  gated_building: boolean
  breakfast: boolean
  sauna: boolean
  elevator: boolean
  doorman: boolean
  coworking: boolean
  description?: string | null
  price?: number | null
  promotional_price?: number | null
  available_from?: string | null
  category: Category | null
  address: Address | null
  photos: PhotoUrls[]
  cover_photo: PhotoUrls | null
  rooms_list?: Array<{ name: string; type: string; description: string }>
  created_at: string
}
