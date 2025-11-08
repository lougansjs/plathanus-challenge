export function toMessage(e: any, fallback = 'Algo deu ruim! Revise a sua requisição.') {
  return (
    e?.response?.data?.details?.join?.(', ') ||
    e?.response?.data?.error ||
    e?.message ||
    fallback
  )
}