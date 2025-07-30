// lib/models/bar_model.dart

import 'package:agilizaiapp/models/amenity_model.dart'; // <--- Importe a classe Amenity
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
  });

  // O BarDetailsScreen usa diretamente as propriedades do objeto Bar
  // Se você for buscar Bar de uma API, precisará de um `fromJson`
  // Assumindo que você está usando dados mockados de `bar_data.dart` por enquanto.
}
