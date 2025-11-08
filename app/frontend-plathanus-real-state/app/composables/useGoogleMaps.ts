/**
 * Composable para carregar Google Maps API uma única vez
 * Evita múltiplos carregamentos e erros de duplicação
 */
export const useGoogleMaps = () => {
  const config = useRuntimeConfig()
  const apiKey = config.public.googleMapsApiKey || ''
  
  let loadingPromise: Promise<any> | null = null
  let googleMaps: any = null

  const loadGoogleMaps = async (): Promise<any> => {
    // Se já está carregado, retorna
    if (googleMaps) {
      return googleMaps
    }

    // Se já está carregando, aguarda
    if (loadingPromise) {
      return loadingPromise
    }

    if (!apiKey) {
      throw new Error('Google Maps API key não configurada')
    }

    // Inicia o carregamento
    loadingPromise = new Promise((resolve, reject) => {
      // Verifica se já está carregado no window
      if (typeof window !== 'undefined' && (window as any).google?.maps) {
        googleMaps = (window as any).google.maps
        resolve(googleMaps)
        return
      }

      // Verifica se o script já existe
      const existingScript = document.querySelector(
        `script[src*="maps.googleapis.com/maps/api/js"]`
      )

      if (existingScript) {
        // Script já existe, aguarda carregar
        const checkInterval = setInterval(() => {
          if ((window as any).google?.maps) {
            clearInterval(checkInterval)
            googleMaps = (window as any).google.maps
            resolve(googleMaps)
          }
        }, 100)

        // Timeout de 10 segundos
        setTimeout(() => {
          clearInterval(checkInterval)
          reject(new Error('Timeout ao aguardar Google Maps carregar'))
        }, 10000)
        return
      }

      // Cria novo script
      const script = document.createElement('script')
      script.src = `https://maps.googleapis.com/maps/api/js?key=${apiKey}&libraries=places&loading=async`
      script.async = true
      script.defer = true

      const timeout = setTimeout(() => {
        reject(new Error('Timeout ao carregar Google Maps API'))
      }, 15000)

      script.onload = () => {
        clearTimeout(timeout)
        // Aguarda um pouco para garantir que está totalmente carregado
        const waitForGoogleMaps = () => {
          if ((window as any).google?.maps?.Map) {
            googleMaps = (window as any).google.maps
            resolve(googleMaps)
          } else {
            setTimeout(waitForGoogleMaps, 50)
          }
        }
        waitForGoogleMaps()
      }

      script.onerror = () => {
        clearTimeout(timeout)
        reject(new Error('Erro ao carregar Google Maps API'))
      }

      document.head.appendChild(script)
    })

    return loadingPromise
  }

  return {
    loadGoogleMaps,
    apiKey
  }
}

