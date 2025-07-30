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
        'assets/images/seujustino_cover.jpg', // <--- Exemplo de imagem de capa
    street: 'Rua Harmonia',
    number: 70,
    address:
        'Rua Harmonia, 70 - Vila Madalena, São Paulo', // Exemplo de endereço formatado
    rating: 4.5,
    reviewsCount: 1200,
    ambianceImagePaths: [
      'assets/images/seujustino_amb_1.jpg',
      'assets/images/seujustino_amb_2.jpg',
    ],
    foodImagePaths: [
      'assets/images/seujustino_food_1.jpg',
      'assets/images/seujustino_food_2.jpg',
    ],
    drinksImagePaths: [
      'assets/images/seujustino_drink_1.jpg',
      'assets/images/seujustino_drink_2.jpg',
    ],
    mapImageUrl:
        'https://maps.googleapis.com/maps/api/staticmap?center=-23.567086,-46.687522&zoom=15&size=600x300&markers=color:red%7C-23.567086,-46.687522&key=YOUR_Maps_API_KEY', // Substitua pela sua chave
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
    coverImagePath: 'assets/images/ohfregues_cover.jpg',
    street: 'Rua das Flores',
    number: 123,
    address: 'Rua das Flores, 123 - Centro, São Paulo',
    rating: 4.2,
    reviewsCount: 850,
    ambianceImagePaths: [
      'assets/images/ohfregues_amb_1.jpg',
      'assets/images/ohfregues_amb_2.jpg',
    ],
    foodImagePaths: [
      'assets/images/ohfregues_food_1.jpg',
      'assets/images/ohfregues_food_2.jpg',
    ],
    drinksImagePaths: [
      'assets/images/ohfregues_drink_1.jpg',
      'assets/images/ohfregues_drink_2.jpg',
    ],
    mapImageUrl:
        'https://maps.googleapis.com/maps/api/staticmap?center=-23.567086,-46.687522&zoom=15&size=600x300&markers=color:red%7C-23.567086,-46.687522&key=YOUR_Maps_API_KEY',
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
    coverImagePath: 'assets/images/highline_cover.jpg',
    street: 'Avenida Paulista',
    number: 900,
    address: 'Avenida Paulista, 900 - Bela Vista, São Paulo',
    rating: 4.8,
    reviewsCount: 2100,
    ambianceImagePaths: [
      'assets/images/highline_amb_1.jpg',
      'assets/images/highline_amb_2.jpg',
    ],
    foodImagePaths: [
      'assets/images/highline_food_1.jpg',
      'assets/images/highline_food_2.jpg',
    ],
    drinksImagePaths: [
      'assets/images/highline_drink_1.jpg',
      'assets/images/highline_drink_2.jpg',
    ],
    mapImageUrl:
        'https://maps.googleapis.com/maps/api/staticmap?center=-23.567086,-46.687522&zoom=15&size=600x300&markers=color:red%7C-23.567086,-46.687522&key=YOUR_Maps_API_KEY',
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
    coverImagePath: 'assets/images/pracinha_cover.jpg',
    street: 'Rua Harmonia',
    number: 144,
    address: 'Rua Harmonia, 144 - Vila Madalena, São Paulo',
    rating: 4.6,
    reviewsCount: 1500,
    ambianceImagePaths: [
      'assets/images/pracinha_amb_1.jpg',
      'assets/images/pracinha_amb_2.jpg',
    ],
    foodImagePaths: [
      'assets/images/pracinha_food_1.jpg',
      'assets/images/pracinha_food_2.jpg',
    ],
    drinksImagePaths: [
      'assets/images/pracinha_drink_1.jpg',
      'assets/images/pracinha_drink_2.jpg',
    ],
    mapImageUrl:
        'https://maps.googleapis.com/maps/api/staticmap?center=-23.567086,-46.687522&zoom=15&size=600x300&markers=color:red%7C-23.567086,-46.687522&key=YOUR_Maps_API_KEY',
    amenities: [
      Amenity(icon: Icons.ac_unit, label: 'Ar Condicionado'),
      Amenity(icon: Icons.wifi, label: 'Wi-Fi'),
      Amenity(icon: Icons.elevator, label: 'Elevador'),
      Amenity(icon: Icons.nightlife, label: 'Vista Panorâmica'),
    ],
  ),
];
