// Configurações centralizadas da API
// Este arquivo centraliza todas as URLs da API para facilitar manutenção

class ApiConfig {
  // URL base da API em produção
  static const String baseUrl = 'https://vamos-comemorar-api.onrender.com';
  
  // URL base da API para desenvolvimento local (opcional)
  static const String localBaseUrl = 'http://localhost:3001';
  
  // Determina qual URL usar baseado no ambiente
  // Por padrão, usa produção. Para desenvolvimento local, altere para localBaseUrl
  static String get apiBaseUrl => baseUrl;
  
  // Endpoints da API
  static String get apiUrl => '$apiBaseUrl/api';
  
  // Endpoints específicos
  static String get usersEndpoint => '$apiUrl/users';
  static String get placesEndpoint => '$apiUrl/places';
  static String get eventsEndpoint => '$apiUrl/events';
  static String get reservasEndpoint => '$apiUrl/reservas';
  static String get birthdayReservationsEndpoint => '$apiUrl/birthday-reservations';
  static String get cardapioEndpoint => '$apiUrl/cardapio';
  static String get phoneEndpoint => '$apiUrl/phone';
  static String get imagesEndpoint => '$apiUrl/images';
  static String get convidadosEndpoint => '$apiUrl/convidados';
  
  // Métodos auxiliares para construir URLs completas
  static String userEndpoint(String path) => '$usersEndpoint/$path';
  static String placeEndpoint(String path) => '$placesEndpoint/$path';
  static String eventEndpoint(String path) => '$eventsEndpoint/$path';
  static String reservaEndpoint(String path) => '$reservasEndpoint/$path';
  static String birthdayReservationEndpoint(String path) => '$birthdayReservationsEndpoint/$path';
  
  // URL para upload de imagens de perfil
  static String get uploadProfilePhotoUrl => '$imagesEndpoint/upload-profile-photo';
  
  // URL para upload de imagens genérico
  static String get uploadImageUrl => '$imagesEndpoint/upload';
  
  // URL para construir imagem de perfil completa
  // NOTA: O backend agora retorna URLs completas do Cloudinary
  // Este método mantém compatibilidade com URLs legadas do FTP
  static String getProfileImageUrl(String? filename) {
    if (filename == null || filename.isEmpty) {
      return 'https://via.placeholder.com/300x200?text=Sem+Imagem';
    }
    
    // Se já é uma URL completa (Cloudinary, FTP ou outro serviço), retorna como está
    if (filename.startsWith('http://') || filename.startsWith('https://')) {
      return filename;
    }
    
    // Se for apenas o nome do arquivo (legado), retorna placeholder
    // O backend deve sempre retornar URLs completas do Cloudinary
    return 'https://via.placeholder.com/300x200?text=Imagem+Nao+Encontrada';
  }
  
  // URL para construir imagem de cardápio completa
  // NOTA: O backend agora retorna URLs completas do Cloudinary
  // Este método mantém compatibilidade com URLs legadas do FTP
  static String getMenuImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return 'https://via.placeholder.com/300x200?text=Sem+Imagem';
    }
    
    // Se já é uma URL completa (Cloudinary, FTP ou outro serviço), retorna como está
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }
    
    // Se for apenas o nome do arquivo (legado), retorna placeholder
    // O backend deve sempre retornar URLs completas do Cloudinary
    return 'https://via.placeholder.com/300x200?text=Imagem+Nao+Encontrada';
  }
}



