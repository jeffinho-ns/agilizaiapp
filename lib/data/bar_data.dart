// lib/data/bar_data.dart

import 'package:flutter/material.dart';
import 'package:agilizaiapp/models/bar_model.dart';

final List<Bar> allBars = [
  Bar(
    id: 'ohfregues',
    name: 'Oh Freguês',
    logoAssetPath: 'assets/images/logo-fregues.png',
    coverImagePath:
        'assets/images/capa-ohfregues.jpg', // NOVO: Caminho para a capa
    rating: 4.9,
    reviewsCount: 2700, // 2.7K
    about:
        'O Oh Freguês oferece uma experiência única de entretenimento noturno. Localizado em um complexo de 5 mil metros quadrados, é o ponto de encontro perfeito para Happy Hour, aniversário ou evento corporativo. Além da balada, possui diversos hostels espalhados pelo mundo para você e seus amigos. Tudo isso com muito som ao vivo, DJ, drinks tropicais e uma ótima gastronomia.\n\nSão quatro ambientes: calçada, onde passa a galera no happy hour, um deck de 400 metros de piso térreo, que conta com uma decoração moderna, um lounge que também tem um palco para shows acústicos e um mezanino com vista panorâmica para agitar as tardes. Além da balada, para completar a noite, temos um bar que esquenta. Um projeto realizado pelo Grupo Ideia, que administra as baladas do Largo da Batata, Pinheiros e Vila Mariana, que caminha do seu Justino e High Line Bar.',
    address: 'Largo da Matriz de Nossa Senhora do Ó, 145',
    mapImageUrl:
        'https://maps.googleapis.com/maps/api/staticmap?center=-23.55052,-46.633309&zoom=14&size=400x200&markers=color:red%7Clabel:O%7C-23.55052,-46.633309&key=YOUR_Maps_API_KEY', // <<< IMAGEM DE MAPA DA INTERNET (Substitua YOUR_Maps_API_KEY pela sua chave)
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
    amenities: [
      Amenity(icon: Icons.wifi, label: 'Wi-Fi'),
      Amenity(icon: Icons.accessible, label: 'Acessível'),
      Amenity(icon: Icons.local_parking, label: 'Estacionamento'),
      Amenity(icon: Icons.smoking_rooms, label: 'Fumódromo'),
      Amenity(icon: Icons.music_note, label: 'Música ao vivo'),
    ],
  ),
  Bar(
    id: 'justino',
    name: 'Seu Justino',
    logoAssetPath: 'assets/images/logo-justino.png',
    coverImagePath:
        'assets/images/capa-justino.png', // NOVO: Caminho para a capa
    rating: 4.5,
    reviewsCount: 5000,
    about:
        'Um dos bares mais tradicionais da Vila Madalena, conhecido pelo seu samba e feijoada. Ambiente descontraído e cheio de energia.',
    address: 'Rua Harmonia, 117 - Vila Madalena',
    mapImageUrl:
        'https://maps.googleapis.com/maps/api/staticmap?center=-23.555813,-46.685324&zoom=14&size=400x200&markers=color:blue%7Clabel:J%7C-23.555813,-46.685324&key=YOUR_Maps_API_KEY', // <<< IMAGEM DE MAPA DA INTERNET
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
    ],
    drinksImagePaths: [
      'assets/images/bebida-justino-1.jpeg',
      'assets/images/bebida-justino-2.jpeg',
      'assets/images/bebida-justino-3.jpeg',
      'assets/images/bebida-justino-4.jpeg',
    ],
    amenities: [
      Amenity(icon: Icons.music_note, label: 'Samba ao vivo'),
      Amenity(icon: Icons.restaurant, label: 'Feijoada'),
      Amenity(icon: Icons.outdoor_grill, label: 'Área externa'),
    ],
  ),
  Bar(
    id: 'pracinha',
    name: 'Pracinha',
    logoAssetPath: 'assets/images/logo-pracinha.png',
    coverImagePath:
        'assets/images/capa-pracinha.jpg', // NOVO: Caminho para a capa
    rating: 4.2,
    reviewsCount: 1200,
    about:
        'Um bar com conceito de praça, perfeito para encontros casuais, com petiscos deliciosos e chopp gelado.',
    address: 'Rua Aspicuelta, 123 - Vila Madalena',
    mapImageUrl:
        'https://maps.googleapis.com/maps/api/staticmap?center=-23.554033,-46.687481&zoom=14&size=400x200&markers=color:green%7Clabel:P%7C-23.554033,-46.687481&key=YOUR_Maps_API_KEY', // <<< IMAGEM DE MAPA DA INTERNET
    ambianceImagePaths: [
      'assets/images/ambiente-pracinha-1.jpeg',
      'assets/images/ambiente-pracinha-2.jpeg',
      'assets/images/ambiente-pracinha-3.jpeg',
      'assets/images/ambiente-pracinha-4.jpeg',
    ],
    foodImagePaths: [
      'assets/images/gastronomia-pracinha-1.jpeg',
      'assets/images/gastronomia-pracinha-2.jpeg',
      'assets/images/gastronomia-pracinha-3.jpeg',
      'assets/images/gastronomia-pracinha-4.jpeg',
    ],
    drinksImagePaths: [
      'assets/images/bebida-pracinha-1.jpeg',
      'assets/images/bebida-pracinha-2.jpeg',
      'assets/images/bebida-pracinha-3.jpeg',
      'assets/images/bebida-pracinha-4.jpeg',
    ],
    amenities: [
      Amenity(icon: Icons.pets, label: 'Pet Friendly'),
      Amenity(icon: Icons.local_bar, label: 'Cervejas Artesanais'),
    ],
  ),
  Bar(
    id: 'highline',
    name: 'High Line',
    logoAssetPath: 'assets/images/logo-highline.png',
    coverImagePath:
        'assets/images/capa-highline.jpeg', // NOVO: Caminho para a capa
    rating: 4.7,
    reviewsCount: 3500,
    about:
        'Um rooftop bar sofisticado com vista panorâmica da cidade, ideal para coquetéis e boa música.',
    address: 'Rua Girassol, 153 - Vila Madalena',
    mapImageUrl:
        'https://maps.googleapis.com/maps/api/staticmap?center=-23.550119,-46.687595&zoom=14&size=400x200&markers=color:purple%7Clabel:H%7C-23.550119,-46.687595&key=YOUR_Maps_API_KEY', // <<< IMAGEM DE MAPA DA INTERNET
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
    amenities: [
      Amenity(icon: Icons.ac_unit, label: 'Ar Condicionado'),
      Amenity(icon: Icons.wifi, label: 'Wi-Fi'),
      Amenity(icon: Icons.elevator, label: 'Elevador'),
      Amenity(icon: Icons.nightlife, label: 'Vista Panorâmica'),
    ],
  ),
];
