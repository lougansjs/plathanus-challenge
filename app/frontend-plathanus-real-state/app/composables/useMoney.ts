// app/composables/useMoney.ts
export function useMoney() {
  const brl = (n?: number | string | null) => {
    if (n == null || n === '') return ''
    // Converte para número se for string
    const num = typeof n === 'string' ? parseFloat(n) : n
    if (isNaN(num) || !isFinite(num)) return ''
    // Formata como moeda brasileira
    return num.toLocaleString('pt-BR', { 
      style: 'currency', 
      currency: 'BRL',
      minimumFractionDigits: 2,
      maximumFractionDigits: 2
    })
  }
  return { brl }
}
