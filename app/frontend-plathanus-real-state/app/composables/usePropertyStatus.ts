// app/composables/usePropertyStatus.ts
export function usePropertyStatus() {
  const statusLabels: Record<string, string> = {
    available: 'Disponível',
    unavailable: 'Indisponível',
    rented: 'Alugado',
    maintenance: 'Manutenção',
    archived: 'Arquivado'
  }

  const statusColors: Record<string, { bg: string; text: string }> = {
    available: { bg: 'bg-green-500', text: 'text-white' },
    unavailable: { bg: 'bg-gray-500', text: 'text-white' },
    rented: { bg: 'bg-blue-500', text: 'text-white' },
    maintenance: { bg: 'bg-yellow-500', text: 'text-white' },
    archived: { bg: 'bg-gray-400', text: 'text-white' }
  }

  const contractTypeLabels: Record<string, string> = {
    rent: 'Aluguel',
    sale: 'Venda',
    seasonal: 'Temporada'
  }

  function getStatusLabel(status: string): string {
    return statusLabels[status] || status
  }

  function getStatusColor(status: string): { bg: string; text: string } {
    return statusColors[status] || { bg: 'bg-gray-500', text: 'text-white' }
  }

  function getContractTypeLabel(contractType: string): string {
    return contractTypeLabels[contractType] || contractType
  }

  return {
    statusLabels,
    statusColors,
    contractTypeLabels,
    getStatusLabel,
    getStatusColor,
    getContractTypeLabel
  }
}

