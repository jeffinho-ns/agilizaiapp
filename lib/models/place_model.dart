// lib/models/place_model.dart

class Place {
  final int id;
  final String slug;
  final String name;
  final String? email;
  final String? description;
  final String? logo;
  final String street;
  final int number;
  final double? latitude;
  final double? longitude;
  final String status;
  final int visible;
  final List<Commodity> commodities;
  final List<Photo> photos;

  Place({
    required this.id,
    required this.slug,
    required this.name,
    this.email,
    this.description,
    this.logo,
    required this.street,
    required this.number,
    this.latitude,
    this.longitude,
    required this.status,
    required this.visible,
    required this.commodities,
    required this.photos,
  });

  // Endereço completo formatado
  String get fullAddress => '$street, $number';

  // Coordenadas para o mapa
  bool get hasCoordinates => latitude != null && longitude != null;

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'],
      slug: json['slug'],
      name: json['name'],
      email: json['email'],
      description: json['description'],
      logo: json['logo'],
      street: json['street'],
      number: json['number'],
      latitude: json['latitude'] != null
          ? double.parse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.parse(json['longitude'].toString())
          : null,
      status: json['status'] ?? 'active',
      visible: json['visible'] ?? 1,
      commodities: json['commodities'] != null
          ? (json['commodities'] as List)
              .map((c) => Commodity.fromJson(c))
              .toList()
          : [],
      photos: json['photos'] != null
          ? (json['photos'] as List).map((p) => Photo.fromJson(p)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slug': slug,
      'name': name,
      'email': email,
      'description': description,
      'logo': logo,
      'street': street,
      'number': number,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'visible': visible,
      'commodities': commodities.map((c) => c.toJson()).toList(),
      'photos': photos.map((p) => p.toJson()).toList(),
    };
  }
}

class Commodity {
  final int? id;
  final int placeId;
  final String icon;
  final String color;
  final String name;
  final String description;

  Commodity({
    this.id,
    required this.placeId,
    required this.icon,
    required this.color,
    required this.name,
    required this.description,
  });

  factory Commodity.fromJson(Map<String, dynamic> json) {
    return Commodity(
      id: json['id'],
      placeId: json['place_id'],
      icon: json['icon'],
      color: json['color'],
      name: json['name'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'place_id': placeId,
      'icon': icon,
      'color': color,
      'name': name,
      'description': description,
    };
  }
}

class Photo {
  final int? id;
  final int placeId;
  final String photo;
  final String type;
  final String url;

  Photo({
    this.id,
    required this.placeId,
    required this.photo,
    required this.type,
    required this.url,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'],
      placeId: json['place_id'],
      photo: json['photo'],
      type: json['type'],
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'place_id': placeId,
      'photo': photo,
      'type': type,
      'url': url,
    };
  }
}
