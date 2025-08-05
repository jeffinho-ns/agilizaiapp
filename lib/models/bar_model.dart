// lib/models/bar_model.dart

import 'package:agilizaiapp/models/amenity_model.dart'; // <--- Importe a classe Amenity
import 'package:agilizaiapp/models/place_model.dart'; // <--- Importe o modelo Place
import 'package:flutter/material.dart'; // Para IconData se Amenity for definido aqui

class Bar {
  final int id;
  final String name;
  final String slug;
  final String description; // Este será o 'about'
  final String logoAssetPath; // Corresponde a 'logo' no DB
  final String coverImagePath; // <--- NOVO: Caminho da imagem de capa
  final String street;
  final int number;
  final String?
      address; // <--- NOVO: Endereço formatado (pode ser "street, number")
  final double rating; // <--- NOVO: Avaliação
  final int reviewsCount; // <--- NOVO: Contagem de avaliações
  final List<String> ambianceImagePaths; // <--- NOVO: Imagens de ambiente
  final List<String> foodImagePaths; // <--- NOVO: Imagens de comida
  final List<String> drinksImagePaths; // <--- NOVO: Imagens de bebidas
  final String? mapImageUrl; // <--- NOVO: URL da imagem do mapa
  final List<Amenity> amenities; // <--- NOVO: Lista de amenidades
  final double? latitude; // <--- NOVO: Latitude para mapas
  final double? longitude; // <--- NOVO: Longitude para mapas

  const Bar({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.logoAssetPath,
    required this.coverImagePath, // Adicionado ao construtor
    required this.street,
    required this.number,
    this.address, // Opcional no construtor
    required this.rating, // Adicionado
    required this.reviewsCount, // Adicionado
    required this.ambianceImagePaths, // Adicionado
    required this.foodImagePaths, // Adicionado
    required this.drinksImagePaths, // Adicionado
    this.mapImageUrl, // Opcional
    required this.amenities, // Adicionado
    this.latitude, // Opcional
    this.longitude, // Opcional
  });

  // Endereço completo formatado
  String get fullAddress => '$street, $number';

  // Coordenadas para o mapa
  bool get hasCoordinates => latitude != null && longitude != null;

  // Gerar URL do mapa estático com coordenadas reais
  String get staticMapUrl {
    if (hasCoordinates) {
      return 'https://maps.googleapis.com/maps/api/staticmap?'
          'center=$latitude,$longitude'
          '&zoom=15'
          '&size=600x300'
          '&markers=color:red%7C$latitude,$longitude'
          '&key=AIzaSyCYujVw1ifZiGAYCrp30RD4yiB5DFcrj4k';
    }
    return mapImageUrl ?? 'https://via.placeholder.com/600x300?text=Mapa';
  }

  // Factory para criar Bar a partir de Place (da API)
  factory Bar.fromPlace(Place place) {
    return Bar(
      id: place.id,
      name: place.name,
      slug: place.slug,
      description: place.description ?? '',
      logoAssetPath: place.logo ?? 'assets/images/default-logo.png',
      coverImagePath: place.photos.isNotEmpty
          ? place.photos.first.url
          : 'assets/images/default-cover.jpg',
      street: place.street,
      number: place.number,
      address: place.fullAddress,
      rating: 4.5, // Valor padrão
      reviewsCount: 0, // Valor padrão
      ambianceImagePaths: place.photos
          .where((p) => p.type == 'ambiance')
          .map((p) => p.url)
          .toList(),
      foodImagePaths: place.photos
          .where((p) => p.type == 'food')
          .map((p) => p.url)
          .toList(),
      drinksImagePaths: place.photos
          .where((p) => p.type == 'drinks')
          .map((p) => p.url)
          .toList(),
      mapImageUrl: place.hasCoordinates
          ? 'https://maps.googleapis.com/maps/api/staticmap?center=${place.latitude},${place.longitude}&zoom=15&size=600x300&markers=color:red%7C${place.latitude},${place.longitude}&key=AIzaSyCYujVw1ifZiGAYCrp30RD4yiB5DFcrj4k'
          : null,
      amenities: place.commodities
          .map((c) => Amenity(
                icon: _getIconForCommodity(c.name),
                label: c.name,
              ))
          .toList(),
      latitude: place.latitude,
      longitude: place.longitude,
    );
  }

  // Método auxiliar para converter commodities em ícones
  static IconData _getIconForCommodity(String commodityName) {
    switch (commodityName.toLowerCase()) {
      case 'pet friendly':
        return Icons.pets;
      case 'área aberta':
        return Icons.outdoor_grill;
      case 'acessível':
        return Icons.accessible;
      case 'estacionamento':
        return Icons.local_parking;
      case '+18':
        return Icons.person;
      case 'mesas':
        return Icons.table_restaurant;
      case 'wifi':
        return Icons.wifi;
      case 'música ao vivo':
        return Icons.music_note;
      case 'fumódromo':
        return Icons.smoking_rooms;
      default:
        return Icons.star;
    }
  }
}
