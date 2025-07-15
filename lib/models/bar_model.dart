// lib/models/bar_model.dart

import 'package:flutter/material.dart'; // Para IconData

class Bar {
  final String id; // Um identificador único, ex: 'ohfregues', 'justino'
  final String name;
  final String logoAssetPath; // Caminho para o logo do bar (asset local)
  final String
      coverImagePath; // NOVO: Caminho para a imagem de capa do bar (asset local)
  final double rating;
  final int reviewsCount; // Contagem de reviews (ex: 2.7K)
  final String about; // Texto "Sobre" o bar
  final String address; // Endereço completo
  final String mapImageUrl; // Agora será um URL online para o mapa
  final List<String>
      ambianceImagePaths; // Lista de caminhos para imagens do ambiente
  final List<String>
      foodImagePaths; // Lista de caminhos para imagens de gastronomia
  final List<String>
      drinksImagePaths; // Lista de caminhos para imagens de drinks
  final List<Amenity> amenities; // Lista de facilidades/comodidades

  Bar({
    required this.id,
    required this.name,
    required this.logoAssetPath,
    required this.coverImagePath, // NOVO: Campo no construtor
    required this.rating,
    required this.reviewsCount,
    required this.about,
    required this.address,
    required this.mapImageUrl,
    required this.ambianceImagePaths,
    required this.foodImagePaths,
    required this.drinksImagePaths,
    required this.amenities,
  });
}

// Modelo para as facilidades (ícone + descrição)
class Amenity {
  final IconData icon;
  final String label;

  Amenity({required this.icon, required this.label});
}
