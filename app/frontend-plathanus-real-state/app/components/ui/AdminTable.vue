<!-- app/components/ui/AdminTable.vue -->
<script setup lang="ts">
import { useMoney } from '../../composables/useMoney'
import { usePropertyStatus } from '../../composables/usePropertyStatus'

// @ts-ignore - defineProps is auto-imported by Nuxt
defineProps<{
  items: any[]
}>()

const { brl } = useMoney()
const { getContractTypeLabel } = usePropertyStatus()
</script>

<template>
  <table class="w-full border rounded-lg overflow-hidden">
    <thead class="bg-gray-50 text-left">
      <tr>
        <th class="p-3">Imóvel</th>
        <th class="p-3">Categoria</th>
        <th class="p-3">Contrato</th>
        <th class="p-3">Preço</th>
        <th class="p-3">Ações</th>
      </tr>
    </thead>
    <tbody>
      <tr v-for="p in items" :key="p.id" class="border-t">
        <td class="p-3">{{ p.name }}</td>
        <td class="p-3">{{ p.category?.name }}</td>
        <td class="p-3">{{ getContractTypeLabel(p.contract_type) }}</td>
        <td class="p-3">{{ brl(p.price) }}</td>
        <td class="p-3 space-x-2">
          <NuxtLink :to="`/admin/properties/${p.id}/edit`" class="text-blue-600">Editar</NuxtLink>
          <slot name="actions" :item="p" />
        </td>
      </tr>
    </tbody>
  </table>
</template>
