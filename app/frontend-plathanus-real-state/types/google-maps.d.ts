// types/google-maps.d.ts
declare global {
  interface Window {
    google: typeof google
  }
  
  const google: typeof google
}

declare namespace google {
  namespace maps {
    class Map {
      constructor(element: HTMLElement, options?: MapOptions)
      setCenter(latlng: LatLng | LatLngLiteral): void
      setZoom(zoom: number): void
    }

    class Marker {
      constructor(options?: MarkerOptions)
      addListener(eventName: string, handler: Function): void
      setMap(map: Map | null): void
    }

    class InfoWindow {
      constructor(options?: InfoWindowOptions)
      open(map?: Map, marker?: Marker): void
      setContent(content: string | HTMLElement): void
    }

    interface MapOptions {
      center?: LatLng | LatLngLiteral
      zoom?: number
      mapTypeControl?: boolean
      mapTypeControlOptions?: MapTypeControlOptions
      fullscreenControl?: boolean
      streetViewControl?: boolean
      zoomControl?: boolean
      styles?: MapTypeStyle[]
    }

    interface MapTypeControlOptions {
      style?: MapTypeControlStyle
      position?: ControlPosition
      mapTypeIds?: string[]
    }

    interface MarkerOptions {
      position?: LatLng | LatLngLiteral
      map?: Map
      title?: string
      icon?: string | Icon | IconSequence | Symbol
      animation?: Animation
    }

    interface InfoWindowOptions {
      content?: string | HTMLElement
      position?: LatLng | LatLngLiteral
    }

    interface LatLng {
      lat(): number
      lng(): number
    }

    interface LatLngLiteral {
      lat: number
      lng: number
    }

    interface Icon {
      url: string
      scaledSize?: Size
      anchor?: Point
    }

    interface Size {
      width: number
      height: number
    }

    interface Point {
      x: number
      y: number
    }

    interface MapTypeStyle {
      featureType?: string
      elementType?: string
      stylers?: Array<Record<string, any>>
    }

    enum MapTypeControlStyle {
      DEFAULT = 0,
      HORIZONTAL_BAR = 1,
      DROPDOWN_MENU = 2
    }

    enum ControlPosition {
      TOP_LEFT = 1,
      TOP_CENTER = 2,
      TOP_RIGHT = 3,
      LEFT_CENTER = 4,
      RIGHT_CENTER = 5,
      BOTTOM_LEFT = 6,
      BOTTOM_CENTER = 7,
      BOTTOM_RIGHT = 8,
      LEFT_TOP = 9,
      RIGHT_TOP = 10,
      LEFT_BOTTOM = 11,
      RIGHT_BOTTOM = 12
    }

    enum Animation {
      DROP = 2,
      BOUNCE = 1
    }
  }
}

export {}

