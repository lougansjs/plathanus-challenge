# Aqui temos um seed que é tipo 'dias de luta e dias de derrota' kkkkkk
# mas funciona...
require 'open-uri'
require 'net/http'
require 'stringio'
require 'tempfile'

# Criar admin padrão (senha: admin123)
Admin.find_or_create_by!(email: 'admin@plathanus.com') do |admin|
  admin.password = 'admin123'
  admin.password_confirmation = 'admin123'
end
puts "✅ Admin criado: admin@plathanus.com / admin123"

# Categorias base
%w[Apartamento Casa Studio Loft Cobertura].each do |name|
  Category.find_or_create_by!(name:)
end

puts "Seed ok: #{Category.count} categorias."

# Limpar propriedades existentes usando o repositório DDD
property_repository = ::Persistence::ActiveRecord::PropertyRepositoryImpl.new
::Persistence::Models::PropertyRecord.find_each do |record|
  property_repository.delete(record.id)
rescue StandardError => e
  puts "  ⚠️  Erro ao deletar propriedade #{record.id}: #{e.message}"
end

# Inicializar repositório e serviços DDD
property_repository = ::Persistence::ActiveRecord::PropertyRepositoryImpl.new
property_photo_service = ::Properties::Services::PropertyPhotoService

# Helper para baixar imagens
def download_image_from_url(url)
  return nil unless url.present?

  begin
    downloaded_image = URI.open(url, 'User-Agent' => 'Ruby')
    temp_file = Tempfile.new(['property_photo', '.jpg'])
    temp_file.binmode
    temp_file.write(downloaded_image.read)
    temp_file.rewind
    downloaded_image.close if downloaded_image.respond_to?(:close)
  
    uploaded_file = ActionDispatch::Http::UploadedFile.new(
      tempfile: temp_file,
      filename: File.basename(URI.parse(url).path.presence || "property_photo.jpg"),
      type: downloaded_image.content_type.presence || "image/jpeg"
    )
  
    uploaded_file
  rescue => e
    Rails.logger.warn("⚠️ Erro ao baixar imagem: #{e.message} #{url}")
    nil
  end
end

def generate_description(city, state, property_type, rooms, area)
  base_descriptions = {
    'Apartamento' => "Este encantador apartamento localizado no coração de #{city}, #{state}, representa uma oportunidade única de viver com conforto e praticidade. Com #{rooms} quarto#{rooms > 1 ? 's' : ''} espaçosos e #{area}m² de área total, o imóvel foi projetado para oferecer o máximo de funcionalidade e bem-estar aos seus moradores. A localização privilegiada garante fácil acesso aos principais pontos comerciais, restaurantes, escolas e áreas de lazer da região, tornando o dia a dia muito mais conveniente.",
    'Casa' => "Esta bela residência em #{city}, #{state}, é o lar perfeito para quem busca espaço, privacidade e qualidade de vida. Com #{rooms} quarto#{rooms > 1 ? 's' : ''} amplos e #{area}m² de área construída, a casa oferece ambientes generosos e bem distribuídos. O imóvel está situado em uma região tranquila e bem localizada, com fácil acesso às principais vias e serviços da cidade.",
    'Studio' => "Este moderno studio em #{city}, #{state}, é ideal para quem valoriza praticidade e economia sem abrir mão do conforto. Com #{area}m² bem aproveitados, o espaço foi cuidadosamente planejado para oferecer tudo que você precisa em um ambiente compacto e funcional. A localização estratégica permite acesso rápido aos principais pontos da cidade.",
    'Loft' => "Este sofisticado loft em #{city}, #{state}, combina estilo contemporâneo com funcionalidade. Com #{area}m² de área livre e #{rooms} quarto#{rooms > 1 ? 's' : ''}, o espaço oferece flexibilidade para criar ambientes personalizados. A arquitetura moderna e a localização privilegiada fazem deste imóvel uma excelente opção.",
    'Cobertura' => "Esta exclusiva cobertura em #{city}, #{state}, oferece uma experiência única de morar no alto, com vista privilegiada e muito luxo. Com #{rooms} quarto#{rooms > 1 ? 's' : ''} e #{area}m² de área total, o imóvel possui acabamentos de primeira linha e está localizado em uma das melhores regiões da cidade."
  }

  base = base_descriptions[property_type] || base_descriptions['Apartamento']

  additional = " Os ambientes foram pensados para proporcionar máximo conforto e praticidade. A sala de estar é ampla e bem iluminada, ideal para receber amigos e familiares. A cozinha é moderna e equipada, facilitando o preparo de refeições deliciosas. Os quartos são aconchegantes e oferecem privacidade, enquanto as áreas comuns foram projetadas para momentos de descontração e lazer. O imóvel conta com excelente infraestrutura, incluindo segurança 24 horas, áreas de lazer completas e fácil acesso aos principais serviços da região. A vizinhança é tranquila e bem estabelecida, com comércio próximo e transporte público acessível. Este é um imóvel que combina localização privilegiada, qualidade construtiva e design moderno, sendo uma excelente opção para quem busca qualidade de vida em #{city}."

  base + additional
end

IMAGE_URLS = [
  'https://cdn.pixabay.com/photo/2016/11/18/17/46/house-1836070_1280.jpg',
  'https://cdn.pixabay.com/photo/2017/04/10/22/28/residence-2219972_1280.jpg',
  'https://cdn.pixabay.com/photo/2016/06/24/10/47/house-1477041_1280.jpg',
  'https://cdn.pixabay.com/photo/2017/03/22/17/39/kitchen-2165756_1280.jpg',
  'https://cdn.pixabay.com/photo/2016/11/29/03/53/house-1867187_1280.jpg',
  'https://cdn.pixabay.com/photo/2014/07/10/17/18/large-home-389271_1280.jpg',
  'https://cdn.pixabay.com/photo/2017/01/07/17/48/interior-1961070_1280.jpg',
  'https://cdn.pixabay.com/photo/2016/06/24/10/47/architecture-1477041_1280.jpg',
  'https://cdn.pixabay.com/photo/2017/09/09/18/25/living-room-2732939_1280.jpg',
  'https://cdn.pixabay.com/photo/2014/08/11/21/39/wall-416060_1280.jpg',
  'https://cdn.pixabay.com/photo/2017/03/28/12/11/chairs-2181916_1280.jpg',
  'https://cdn.pixabay.com/photo/2015/10/20/18/57/furniture-998265_1280.jpg',
  'https://cdn.pixabay.com/photo/2016/11/30/08/46/living-room-1872192_1280.jpg',
  'https://cdn.pixabay.com/photo/2017/08/27/10/16/interior-2685521_1280.jpg',
  'https://cdn.pixabay.com/photo/2017/03/19/01/43/room-2155376_1280.jpg',
  'https://cdn.pixabay.com/photo/2016/11/18/17/20/living-room-1835923_1280.jpg',
  'https://cdn.pixabay.com/photo/2014/12/27/14/37/apartment-581073_1280.jpg',
  'https://cdn.pixabay.com/photo/2017/07/09/03/19/home-2486092_1280.jpg',
  'https://cdn.pixabay.com/photo/2016/12/26/17/28/spaghetti-1932466_1280.jpg'
].freeze

# Dados dos imóveis por estado
properties_data = [
  # Santa Catarina - 15 imóveis
  # Florianópolis (6)
  { city: 'Florianópolis', state: 'SC', neighborhood: 'Centro', street: 'Rua Felipe Schmidt', zipcode: '88010-001', lat: -27.5954, lng: -48.5480, category: 'Apartamento', name: 'Apartamento Moderno no Centro de Florianópolis', rooms: 2, bathrooms: 2, area: 75, parking: 1, price: 3500, furnished: true },
  { city: 'Florianópolis', state: 'SC', neighborhood: 'Jurerê Internacional', street: 'Avenida dos Búzios', zipcode: '88053-700', lat: -27.4300, lng: -48.4200, category: 'Casa', name: 'Casa de Praia em Jurerê Internacional', rooms: 4, bathrooms: 3, area: 180, parking: 2, price: 8500, furnished: true },
  { city: 'Florianópolis', state: 'SC', neighborhood: 'Lagoa da Conceição', street: 'Rua das Rendeiras', zipcode: '88062-000', lat: -27.6000, lng: -48.4500, category: 'Apartamento', name: 'Apartamento com Vista para a Lagoa', rooms: 3, bathrooms: 2, area: 95, parking: 1, price: 4200, furnished: false },
  { city: 'Florianópolis', state: 'SC', neighborhood: 'Trindade', street: 'Rua Deputado Antônio Edu Vieira', zipcode: '88040-000', lat: -27.5800, lng: -48.5200, category: 'Studio', name: 'Studio Próximo à UFSC', rooms: 1, bathrooms: 1, area: 35, parking: 0, price: 1800, furnished: true },
  { city: 'Florianópolis', state: 'SC', neighborhood: 'Ingleses', street: 'Avenida Beira Mar Norte', zipcode: '88058-700', lat: -27.4300, lng: -48.3800, category: 'Casa', name: 'Casa com Piscina nos Ingleses', rooms: 3, bathrooms: 2, area: 150, parking: 2, price: 5500, furnished: true },
  { city: 'Florianópolis', state: 'SC', neighborhood: 'Campeche Leste', street: 'Avenida Pequeno Príncipe', zipcode: '88063-000', lat: -27.685048, lng: -48.488048, category: 'Apartamento', name: 'Apartamento em Campeche', rooms: 2, bathrooms: 1, area: 65, parking: 1, price: 2800, furnished: false },
  # Joinville (5)
  { city: 'Joinville', state: 'SC', neighborhood: 'Centro', street: 'Rua do Príncipe', zipcode: '89201-000', lat: -26.3044, lng: -48.8467, category: 'Apartamento', name: 'Apartamento no Centro Histórico', rooms: 2, bathrooms: 1, area: 70, parking: 1, price: 2200, furnished: false },
  { city: 'Joinville', state: 'SC', neighborhood: 'América', street: 'Rua XV de Novembro', zipcode: '89204-200', lat: -26.3200, lng: -48.8500, category: 'Casa', name: 'Casa com Quintal em Joinville', rooms: 3, bathrooms: 2, area: 120, parking: 2, price: 3200, furnished: true },
  { city: 'Joinville', state: 'SC', neighborhood: 'Boa Vista', street: 'Rua Dona Francisca', zipcode: '89204-000', lat: -26.3100, lng: -48.8400, category: 'Apartamento', name: 'Apartamento em Boa Vista', rooms: 3, bathrooms: 2, area: 85, parking: 1, price: 2800, furnished: false },
  { city: 'Joinville', state: 'SC', neighborhood: 'Saguaçu', street: 'Avenida Santos Dumont', zipcode: '89221-000', lat: -26.2800, lng: -48.8600, category: 'Casa', name: 'Casa Moderna em Saguaçu', rooms: 4, bathrooms: 3, area: 160, parking: 2, price: 4500, furnished: true },
  { city: 'Joinville', state: 'SC', neighborhood: 'Iririu', street: 'Rua das Palmeiras', zipcode: '89227-000', lat: -26.2900, lng: -48.8700, category: 'Apartamento', name: 'Apartamento em Iririu', rooms: 2, bathrooms: 1, area: 60, parking: 1, price: 2000, furnished: false },
  # Blumenau (4)
  { city: 'Blumenau', state: 'SC', neighborhood: 'Centro', street: 'Rua XV de Novembro', zipcode: '89010-000', lat: -26.9194, lng: -49.0661, category: 'Apartamento', name: 'Apartamento no Centro de Blumenau', rooms: 2, bathrooms: 1, area: 68, parking: 1, price: 2100, furnished: false },
  { city: 'Blumenau', state: 'SC', neighborhood: 'Velha', street: 'Rua Amazonas', zipcode: '89036-000', lat: -26.9200, lng: -49.0700, category: 'Casa', name: 'Casa Típica Alemã em Blumenau', rooms: 3, bathrooms: 2, area: 110, parking: 2, price: 3000, furnished: true },
  { city: 'Blumenau', state: 'SC', neighborhood: 'Garcia', street: 'Rua São Paulo', zipcode: '89020-000', lat: -26.9100, lng: -49.0600, category: 'Apartamento', name: 'Apartamento em Garcia', rooms: 3, bathrooms: 2, area: 80, parking: 1, price: 2500, furnished: false },
  { city: 'Blumenau', state: 'SC', neighborhood: 'Fortaleza', street: 'Rua Bahia', zipcode: '89052-000', lat: -26.9300, lng: -49.0800, category: 'Casa', name: 'Casa com Vista em Blumenau', rooms: 4, bathrooms: 3, area: 140, parking: 2, price: 3800, furnished: true },

  # Paraná - 15 imóveis
  # Curitiba (6)
  { city: 'Curitiba', state: 'PR', neighborhood: 'Batel', street: 'Avenida Sete de Setembro', zipcode: '80230-000', lat: -25.4284, lng: -49.2733, category: 'Apartamento', name: 'Apartamento de Luxo no Batel', rooms: 3, bathrooms: 2, area: 120, parking: 2, price: 5500, furnished: true },
  { city: 'Curitiba', state: 'PR', neighborhood: 'Centro', street: 'Rua XV de Novembro', zipcode: '80020-310', lat: -25.4284, lng: -49.2733, category: 'Loft', name: 'Loft Moderno no Centro', rooms: 1, bathrooms: 1, area: 55, parking: 1, price: 2800, furnished: true },
  { city: 'Curitiba', state: 'PR', neighborhood: 'Água Verde', street: 'Rua João Negrão', zipcode: '80620-000', lat: -25.4400, lng: -49.2800, category: 'Apartamento', name: 'Apartamento em Água Verde', rooms: 2, bathrooms: 2, area: 75, parking: 1, price: 3200, furnished: false },
  { city: 'Curitiba', state: 'PR', neighborhood: 'Bigorrilho', street: 'Avenida República Argentina', zipcode: '80730-000', lat: -25.4500, lng: -49.2900, category: 'Cobertura', name: 'Cobertura com Vista Panorâmica', rooms: 4, bathrooms: 3, area: 200, parking: 3, price: 12000, furnished: true },
  { city: 'Curitiba', state: 'PR', neighborhood: 'Mercês', street: 'Rua Desembargador Westphalen', zipcode: '80810-000', lat: -25.4300, lng: -49.2700, category: 'Casa', name: 'Casa em Mercês', rooms: 3, bathrooms: 2, area: 130, parking: 2, price: 4500, furnished: true },
  { city: 'Curitiba', state: 'PR', neighborhood: 'Jardim das Américas', street: 'Rua Professor Pedro Viriato Parigot de Souza', zipcode: '81530-000', lat: -25.4200, lng: -49.2600, category: 'Apartamento', name: 'Apartamento em Jardim das Américas', rooms: 2, bathrooms: 1, area: 65, parking: 1, price: 2400, furnished: false },
  # Londrina (5)
  { city: 'Londrina', state: 'PR', neighborhood: 'Centro', street: 'Avenida Higienópolis', zipcode: '86020-000', lat: -23.3045, lng: -51.1696, category: 'Apartamento', name: 'Apartamento no Centro de Londrina', rooms: 2, bathrooms: 1, area: 70, parking: 1, price: 2000, furnished: false },
  { city: 'Londrina', state: 'PR', neighborhood: 'Jardim Higienópolis', street: 'Rua Sergipe', zipcode: '86020-000', lat: -23.3100, lng: -51.1700, category: 'Casa', name: 'Casa em Jardim Higienópolis', rooms: 3, bathrooms: 2, area: 115, parking: 2, price: 2800, furnished: true },
  { city: 'Londrina', state: 'PR', neighborhood: 'Aeroporto', street: 'Rua Goiás', zipcode: '86070-000', lat: -23.3200, lng: -51.1800, category: 'Apartamento', name: 'Apartamento próximo ao Aeroporto', rooms: 3, bathrooms: 2, area: 85, parking: 1, price: 2500, furnished: false },
  { city: 'Londrina', state: 'PR', neighborhood: 'Centro', street: 'Avenida Maringá', zipcode: '86010-000', lat: -23.3000, lng: -51.1600, category: 'Studio', name: 'Studio no Centro', rooms: 1, bathrooms: 1, area: 40, parking: 0, price: 1500, furnished: true },
  { city: 'Londrina', state: 'PR', neighborhood: 'Gleba Palhano', street: 'Rua Pernambuco', zipcode: '86060-000', lat: -23.3300, lng: -51.1900, category: 'Casa', name: 'Casa em Gleba Palhano', rooms: 4, bathrooms: 3, area: 150, parking: 2, price: 3500, furnished: true },
  # Maringá (4)
  { city: 'Maringá', state: 'PR', neighborhood: 'Zona 7', street: 'Avenida Brasil', zipcode: '87013-000', lat: -23.4205, lng: -51.9333, category: 'Apartamento', name: 'Apartamento em Zona 7', rooms: 2, bathrooms: 2, area: 72, parking: 1, price: 2200, furnished: false },
  { city: 'Maringá', state: 'PR', neighborhood: 'Centro', street: 'Avenida Brasil', zipcode: '87020-000', lat: -23.4250, lng: -51.9400, category: 'Casa', name: 'Casa no Centro de Maringá', rooms: 3, bathrooms: 2, area: 125, parking: 2, price: 3000, furnished: true },
  { city: 'Maringá', state: 'PR', neighborhood: 'Zona 2', street: 'Avenida Paraná', zipcode: '87020-000', lat: -23.4300, lng: -51.9500, category: 'Apartamento', name: 'Apartamento em Zona 2', rooms: 3, bathrooms: 2, area: 88, parking: 1, price: 2600, furnished: false },
  { city: 'Maringá', state: 'PR', neighborhood: 'Zona 4', street: 'Rua das Palmeiras', zipcode: '87020-000', lat: -23.4100, lng: -51.9200, category: 'Casa', name: 'Casa com Jardim em Maringá', rooms: 4, bathrooms: 3, area: 160, parking: 2, price: 4000, furnished: true },

  # São Paulo - 20 imóveis
  # São Paulo (8)
  { city: 'São Paulo', state: 'SP', neighborhood: 'Vila Madalena', street: 'Rua Harmonia', zipcode: '05435-000', lat: -23.5505, lng: -46.6333, category: 'Apartamento', name: 'Apartamento na Vila Madalena', rooms: 2, bathrooms: 1, area: 65, parking: 1, price: 4500, furnished: true },
  { city: 'São Paulo', state: 'SP', neighborhood: 'Jardins', street: 'Avenida Paulista', zipcode: '01310-100', lat: -23.5505, lng: -46.6333, category: 'Cobertura', name: 'Cobertura de Luxo nos Jardins', rooms: 4, bathrooms: 3, area: 250, parking: 3, price: 15000, furnished: true },
  { city: 'São Paulo', state: 'SP', neighborhood: 'Pinheiros', street: 'Rua dos Pinheiros', zipcode: '05422-000', lat: -23.5600, lng: -46.6900, category: 'Apartamento', name: 'Apartamento em Pinheiros', rooms: 3, bathrooms: 2, area: 95, parking: 1, price: 6000, furnished: false },
  { city: 'São Paulo', state: 'SP', neighborhood: 'Itaim Bibi', street: 'Avenida Brigadeiro Faria Lima', zipcode: '04538-132', lat: -23.5800, lng: -46.6800, category: 'Loft', name: 'Loft Moderno no Itaim', rooms: 1, bathrooms: 1, area: 50, parking: 1, price: 4200, furnished: true },
  { city: 'São Paulo', state: 'SP', neighborhood: 'Moema', street: 'Avenida Ibirapuera', zipcode: '04029-000', lat: -23.6000, lng: -46.6600, category: 'Apartamento', name: 'Apartamento em Moema', rooms: 2, bathrooms: 2, area: 80, parking: 1, price: 5000, furnished: true },
  { city: 'São Paulo', state: 'SP', neighborhood: 'Brooklin', street: 'Avenida dos Bandeirantes', zipcode: '04532-000', lat: -23.6100, lng: -46.6900, category: 'Casa', name: 'Casa no Brooklin', rooms: 3, bathrooms: 2, area: 140, parking: 2, price: 7500, furnished: true },
  { city: 'São Paulo', state: 'SP', neighborhood: 'Vila Olímpia', street: 'Rua Funchal', zipcode: '04551-060', lat: -23.5900, lng: -46.6900, category: 'Apartamento', name: 'Apartamento na Vila Olímpia', rooms: 2, bathrooms: 1, area: 70, parking: 1, price: 4800, furnished: false },
  { city: 'São Paulo', state: 'SP', neighborhood: 'Higienópolis', street: 'Rua Maranhão', zipcode: '01240-000', lat: -23.5400, lng: -46.6500, category: 'Apartamento', name: 'Apartamento em Higienópolis', rooms: 3, bathrooms: 2, area: 100, parking: 2, price: 6500, furnished: true },
  # Campinas (6)
  { city: 'Campinas', state: 'SP', neighborhood: 'Cambuí', street: 'Rua Barão de Jaguara', zipcode: '13015-000', lat: -22.9068, lng: -47.0636, category: 'Apartamento', name: 'Apartamento no Cambuí', rooms: 2, bathrooms: 1, area: 68, parking: 1, price: 2800, furnished: false },
  { city: 'Campinas', state: 'SP', neighborhood: 'Centro', street: 'Avenida Francisco Glicério', zipcode: '13010-000', lat: -22.9050, lng: -47.0600, category: 'Casa', name: 'Casa no Centro de Campinas', rooms: 3, bathrooms: 2, area: 120, parking: 2, price: 3500, furnished: true },
  { city: 'Campinas', state: 'SP', neighborhood: 'Barão Geraldo', street: 'Rua da Reitoria', zipcode: '13083-970', lat: -22.8200, lng: -47.0700, category: 'Apartamento', name: 'Apartamento em Barão Geraldo', rooms: 2, bathrooms: 2, area: 75, parking: 1, price: 3000, furnished: false },
  { city: 'Campinas', state: 'SP', neighborhood: 'Taquaral', street: 'Avenida Nossa Senhora de Fátima', zipcode: '13087-000', lat: -22.8800, lng: -47.0500, category: 'Casa', name: 'Casa no Taquaral', rooms: 4, bathrooms: 3, area: 170, parking: 2, price: 5000, furnished: true },
  { city: 'Campinas', state: 'SP', neighborhood: 'Nova Campinas', street: 'Rua Doutor Quirino', zipcode: '13092-000', lat: -22.9000, lng: -47.0800, category: 'Apartamento', name: 'Apartamento em Nova Campinas', rooms: 3, bathrooms: 2, area: 90, parking: 1, price: 3200, furnished: false },
  { city: 'Campinas', state: 'SP', neighborhood: 'Sousas', street: 'Rua das Flores', zipcode: '13100-000', lat: -22.8500, lng: -47.0400, category: 'Casa', name: 'Casa em Sousas', rooms: 3, bathrooms: 2, area: 135, parking: 2, price: 3800, furnished: true },
  # Santos (6)
  { city: 'Santos', state: 'SP', neighborhood: 'Gonzaga', street: 'Avenida Ana Costa', zipcode: '11060-000', lat: -23.9608, lng: -46.3331, category: 'Apartamento', name: 'Apartamento em Gonzaga', rooms: 2, bathrooms: 1, area: 60, parking: 1, price: 2500, furnished: false },
  { city: 'Santos', state: 'SP', neighborhood: 'Boqueirão', street: 'Avenida da Praia', zipcode: '11045-000', lat: -23.9700, lng: -46.3400, category: 'Apartamento', name: 'Apartamento com Vista para o Mar', rooms: 3, bathrooms: 2, area: 85, parking: 1, price: 4200, furnished: true },
  { city: 'Santos', state: 'SP', neighborhood: 'Embaré', street: 'Avenida Bartolomeu de Gusmão', zipcode: '11040-000', lat: -23.9500, lng: -46.3200, category: 'Casa', name: 'Casa em Embaré', rooms: 3, bathrooms: 2, area: 110, parking: 2, price: 3200, furnished: true },
  { city: 'Santos', state: 'SP', neighborhood: 'Ponta da Praia', street: 'Avenida Almirante Saldanha da Gama', zipcode: '11030-000', lat: -23.9800, lng: -46.3500, category: 'Apartamento', name: 'Apartamento na Ponta da Praia', rooms: 2, bathrooms: 1, area: 65, parking: 1, price: 2800, furnished: false },
  { city: 'Santos', state: 'SP', neighborhood: 'José Menino', street: 'Avenida Presidente Wilson', zipcode: '11065-000', lat: -23.9400, lng: -46.3100, category: 'Casa', name: 'Casa em José Menino', rooms: 4, bathrooms: 3, area: 150, parking: 2, price: 4500, furnished: true },
  { city: 'Santos', state: 'SP', neighborhood: 'Aparecida', street: 'Rua do Comércio', zipcode: '11035-000', lat: -23.9650, lng: -46.3350, category: 'Studio', name: 'Studio em Aparecida', rooms: 1, bathrooms: 1, area: 38, parking: 0, price: 1800, furnished: true }
]

# Amenities e características possíveis
APARTMENT_AMENITIES = [ 'wifi', 'smart_tv', 'air_conditioning', 'oven', 'microwave', 'stove', 'linen_towels', 'kitchen', 'balcony', 'washer_dryer' ].freeze
BUILDING_CHARACTERISTICS = [ 'parking', 'pets_allowed', 'gym', 'gated_building', 'breakfast', 'sauna', 'elevator', 'doorman', 'coworking', 'pool' ].freeze

puts "\nIniciando criação de #{properties_data.length} imóveis..."

properties_data.each_with_index do |data, index|
  category = Category.find_by(name: data[:category])
  next unless category

  # Preparar preço promocional (30% têm)
  promotional_price = rand < 0.3 ? (data[:price] * 0.9).round(2) : nil

  # Preparar fotos primeiro
  num_photos = rand(3..5)
  photos = []
  num_photos.times do |i|
    image_url = IMAGE_URLS.sample
    temp_file = download_image_from_url(image_url)
    if temp_file
      photos << temp_file
      sleep(0.2) # Pequeno delay para não sobrecarregar
    end
  end

  # Validar fotos
  begin
    property_photo_service.validate_for_create(photos)
  rescue ArgumentError => e
    puts "  ⚠️  Erro de validação de fotos: #{e.message}"
    photos.each(&:close) if photos.any?
    next
  end

  # Criar entidade de domínio
  property = ::Properties::Entities::Property.new(
    name: data[:name],
    status: 'available',
    category_id: category.id,
    rooms: data[:rooms],
    bathrooms: data[:bathrooms],
    area: data[:area],
    parking_slots: data[:parking],
    furnished: data[:furnished],
    contract_type: 'rent',
    price: data[:price],
    promotional_price: promotional_price,
    available_from: Date.today + rand(0..60).days,
    description: generate_description(data[:city], data[:state], data[:category], data[:rooms], data[:area]),
    apartment_amenities: APARTMENT_AMENITIES.sample(rand(4..8)),
    building_characteristics: BUILDING_CHARACTERISTICS.sample(rand(3..6)),
    rooms_list: data[:rooms] > 1 ? [
      { name: 'Quarto Master', type: 'bedroom', description: 'Quarto principal com armário embutido' },
      { name: 'Quarto 2', type: 'bedroom', description: 'Segundo quarto espaçoso' }
    ].first(data[:rooms] - 1) : []
  )

  # Criar endereço
  property.address = ::Properties::Entities::Address.new(
    street: "#{data[:street]}, #{rand(100..9999)}",
    neighborhood: data[:neighborhood],
    city: data[:city],
    state: data[:state],
    country: 'Brasil',
    zipcode: data[:zipcode],
    latitude: data[:lat] + (rand(-0.01..0.01)),
    longitude: data[:lng] + (rand(-0.01..0.01))
  )

  # Salvar usando o repositório DDD
  begin
    saved_property = property_repository.create(property, photos: photos)
    puts "✓ Imóvel #{index + 1}/#{properties_data.length} criado: #{saved_property.name}"
  rescue StandardError => e
    puts "  ⚠️  Erro ao criar imóvel: #{e.message}"
    # Limpar arquivos temporários em caso de erro
    photos.each do |photo|
      if photo.respond_to?(:tempfile) && photo.tempfile
        photo.tempfile.close rescue nil
      elsif photo.respond_to?(:close)
        photo.close rescue nil
      end
    end
  end
end

property_count = ::Persistence::Models::PropertyRecord.count
sc_count = ::Persistence::Models::PropertyRecord.joins(:address).where(addresses: { state: 'SC' }).count
pr_count = ::Persistence::Models::PropertyRecord.joins(:address).where(addresses: { state: 'PR' }).count
sp_count = ::Persistence::Models::PropertyRecord.joins(:address).where(addresses: { state: 'SP' }).count

puts "\n✅ Seed concluído! #{property_count} imóveis criados."
puts "   - Santa Catarina: #{sc_count} imóveis"
puts "   - Paraná: #{pr_count} imóveis"
puts "   - São Paulo: #{sp_count} imóveis"
