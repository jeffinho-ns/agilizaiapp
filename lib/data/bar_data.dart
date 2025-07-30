// lib/data/bar_data.dart

import 'package:agilizaiapp/models/bar_model.dart'; // Importe o modelo Bar
import 'package:agilizaiapp/models/amenity_model.dart'; // <--- Importe Amenity
import 'package:flutter/material.dart'; // Para IconData

// A lista completa de bares
const List<Bar> allBars = [
  Bar(
    id: 1, // ID do bar
    name: 'Seu Justino',
    slug: 'seujustino',
    description:
        'Onde cada detalhe é pensado para proporcionar uma experiência inesquecível.', // Este é o 'about'
    logoAssetPath:
        'assets/images/logo-justino.png', // Verifique o caminho real do seu asset
    coverImagePath:
        'assets/images/capa-justino.png', // <--- Exemplo de imagem de capa
    street: 'Rua Harmonia',
    number: 70,
    address:
        'Rua Harmonia, 70 - Vila Madalena, São Paulo', // Exemplo de endereço formatado
    rating: 4.5,
    reviewsCount: 1200,
    ambianceImagePaths: [
      'assets/images/ambiente-justino-1.jpeg',
      'assets/images/ambiente-justino-2.jpeg',
      'assets/images/ambiente-justino-3.jpeg',
      'assets/images/ambiente-justino-4.jpeg',
    ],
    foodImagePaths: [
      'assets/images/gastronomia-justino-1.jpeg',
      'assets/images/gastronomia-justino-2.jpeg',
      'assets/images/gastronomia-justino-3.jpeg',
      'assets/images/gastronomia-justino-4.jpeg',
    ],
    drinksImagePaths: [
      'assets/images/bebida-justino-1.jpeg',
      'assets/images/bebida-justino-2.jpeg',
      'assets/images/bebida-justino-3.jpeg',
      'assets/images/bebida-justino-4.jpeg',
    ],
    mapImageUrl:
        'https://maps.googleapis.com/maps/api/staticmap?center=-23.567086,-46.687522&zoom=15&size=600x300&markers=color:red%7C-23.567086,-46.687522&key=AIzaSyCYujVw1ifZiGAYCrp30RD4yiB5DFcrj4k', // Substitua pela sua chave
    amenities: [
      Amenity(icon: Icons.wifi, label: 'Wi-Fi'),
      Amenity(icon: Icons.accessible, label: 'Acessível'),
      Amenity(icon: Icons.local_parking, label: 'Estacionamento'),
      Amenity(icon: Icons.smoking_rooms, label: 'Fumódromo'),
      Amenity(icon: Icons.music_note, label: 'Música ao vivo'),
    ],
  ),
  Bar(
    id: 4,
    name: 'Oh Fregues',
    slug: 'ohfregues',
    description: 'Um lugar incrível para curtir com os amigos.',
    logoAssetPath: 'assets/images/logo-fregues.png',
    coverImagePath: 'assets/images/capa-ohfregues.jpg',
    street: 'Rua das Flores',
    number: 123,
    address: 'Rua das Flores, 123 - Centro, São Paulo',
    rating: 4.2,
    reviewsCount: 850,
    ambianceImagePaths: [
      'assets/images/ambiente-ohfregues-1.jpg',
      'assets/images/ambiente-ohfregues-2.jpg',
      'assets/images/ambiente-ohfregues-3.jpg',
      'assets/images/ambiente-ohfregues-4.jpg',
    ],
    foodImagePaths: [
      'assets/images/gastronomia-ohfregues-1.jpg',
      'assets/images/gastronomia-ohfregues-2.jpg',
      'assets/images/gastronomia-ohfregues-3.jpg',
      'assets/images/gastronomia-ohfregues-4.jpg',
    ],
    drinksImagePaths: [
      'assets/images/bebidas-ohfregues-1.jpg',
      'assets/images/bebidas-ohfregues-2.jpg',
      'assets/images/bebidas-ohfregues-3.jpg',
      'assets/images/bebidas-ohfregues-4.jpg',
    ],
    mapImageUrl:
        'https://maps.googleapis.com/maps/api/staticmap?center=-23.567086,-46.687522&zoom=15&size=600x300&markers=color:red%7C-23.567086,-46.687522&key=AIzaSyCYujVw1ifZiGAYCrp30RD4yiB5DFcrj4k',
    amenities: [
      Amenity(icon: Icons.music_note, label: 'Samba ao vivo'),
      Amenity(icon: Icons.restaurant, label: 'Feijoada'),
      Amenity(icon: Icons.outdoor_grill, label: 'Área externa'),
    ],
  ),
  Bar(
    id: 7,
    name: 'HighLine',
    slug: 'highline',
    description: 'Vista panorâmica e drinks exclusivos.',
    logoAssetPath: 'assets/images/logo-highline.png',
    coverImagePath: 'assets/images/capa-highline.jpeg',
    street: 'Avenida Paulista',
    number: 900,
    address: 'Avenida Paulista, 900 - Bela Vista, São Paulo',
    rating: 4.8,
    reviewsCount: 2100,
    ambianceImagePaths: [
      'assets/images/ambiente-highline-1.jpeg',
      'assets/images/ambiente-highline-2.jpeg',
      'assets/images/ambiente-highline-3.jpeg',
      'assets/images/ambiente-highline-4.jpeg',
    ],
    foodImagePaths: [
      'assets/images/gastronomia-highline-1.jpeg',
      'assets/images/gastronomia-highline-2.jpeg',
      'assets/images/gastronomia-highline-3.jpeg',
      'assets/images/gastronomia-highline-4.jpeg',
    ],
    drinksImagePaths: [
      'assets/images/bebida-highline-1.jpeg',
      'assets/images/bebida-highline-2.jpeg',
      'assets/images/bebida-highline-3.jpeg',
      'assets/images/bebida-highline-4.jpeg',
    ],
    mapImageUrl:
        'https://maps.googleapis.com/maps/api/staticmap?center=-23.567086,-46.687522&zoom=15&size=600x300&markers=color:red%7C-23.567086,-46.687522&key=AIzaSyCYujVw1ifZiGAYCrp30RD4yiB5DFcrj4k',
    amenities: [
      Amenity(icon: Icons.pets, label: 'Pet Friendly'),
      Amenity(icon: Icons.local_bar, label: 'Cervejas Artesanais'),
    ],
  ),
  Bar(
    id: 8,
    name: 'Pracinha do Seu Justino',
    slug: 'pracinha',
    description: 'O melhor do samba e gastronomia em um só lugar.',
    logoAssetPath: 'assets/images/logo-pracinha.png',
    coverImagePath: 'assets/images/capa-pracinha.jpg',
    street: 'Rua Harmonia',
    number: 144,
    address: 'Rua Harmonia, 144 - Vila Madalena, São Paulo',
    rating: 4.6,
    reviewsCount: 1500,
    ambianceImagePaths: [
      'assets/images/ambiente-pracinha-1.jpg',
      'assets/images/ambiente-pracinha-2.jpg',
      'assets/images/ambiente-pracinha-3.jpg',
      'assets/images/ambiente-pracinha-4.jpg',
    ],
    foodImagePaths: [
      'assets/images/gastronomia-pracinha-1.jpg',
      'assets/images/gastronomia-pracinha-2.jpg',
      'assets/images/gastronomia-pracinha-3.jpg',
      'assets/images/gastronomia-pracinha-4.jpg',
    ],
    drinksImagePaths: [
      'assets/images/bebida-pracinha-1.jpg',
      'assets/images/bebida-pracinha-2.jpg',
      'assets/images/bebida-pracinha-3.jpg',
      'assets/images/bebida-pracinha-4.jpg',
    ],
    mapImageUrl:
        'https://maps.googleapis.com/maps/api/staticmap?center=-23.567086,-46.687522&zoom=15&size=600x300&markers=color:red%7C-23.567086,-46.687522&key=AIzaSyCYujVw1ifZiGAYCrp30RD4yiB5DFcrj4k',
    amenities: [
      Amenity(icon: Icons.ac_unit, label: 'Ar Condicionado'),
      Amenity(icon: Icons.wifi, label: 'Wi-Fi'),
      Amenity(icon: Icons.elevator, label: 'Elevador'),
      Amenity(icon: Icons.nightlife, label: 'Vista Panorâmica'),
    ],
  ),
];
