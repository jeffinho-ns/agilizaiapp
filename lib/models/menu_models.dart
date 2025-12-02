// lib/models/menu_models.dart

class BarFromAPI {
  final int id;
  final String name;
  final String slug;
  final String description;
  final String logoUrl;
  final String coverImageUrl;
  final List<String>? coverImages;
  final String address;
  final double? rating;
  final int? reviewsCount;
  final List<String> amenities;
  final double? latitude;
  final double? longitude;
  final String? popupImageUrl;
  final String? facebook;
  final String? instagram;
  final String? whatsapp;

  BarFromAPI({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.logoUrl,
    required this.coverImageUrl,
    this.coverImages,
    required this.address,
    this.rating,
    this.reviewsCount,
    required this.amenities,
    this.latitude,
    this.longitude,
    this.popupImageUrl,
    this.facebook,
    this.instagram,
    this.whatsapp,
  });

  factory BarFromAPI.fromJson(Map<String, dynamic> json) {
    // Função auxiliar para converter ID de string ou int para int
    int parseId(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    // Função auxiliar para converter int nullable de string ou int para int?
    int? parseIntNullable(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }

    return BarFromAPI(
      id: parseId(json['id']),
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] ?? '',
      logoUrl: json['logoUrl'] ?? '',
      coverImageUrl: json['coverImageUrl'] ?? '',
      coverImages: json['coverImages'] != null
          ? (json['coverImages'] as List).map((e) => e.toString()).toList()
          : null,
      address: json['address'] ?? '',
      rating: json['rating'] != null
          ? double.tryParse(json['rating'].toString())
          : null,
      reviewsCount: parseIntNullable(json['reviewsCount']),
      amenities: json['amenities'] != null
          ? (json['amenities'] as List).map((e) => e.toString()).toList()
          : [],
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      popupImageUrl: json['popupImageUrl'],
      facebook: json['facebook'],
      instagram: json['instagram'],
      whatsapp: json['whatsapp'],
    );
  }
}

class MenuCategoryFromAPI {
  final int id;
  final int barId;
  final String name;
  final int order;

  MenuCategoryFromAPI({
    required this.id,
    required this.barId,
    required this.name,
    required this.order,
  });

  factory MenuCategoryFromAPI.fromJson(Map<String, dynamic> json) {
    // Função auxiliar para converter ID de string ou int para int
    int parseId(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return MenuCategoryFromAPI(
      id: parseId(json['id']),
      barId: parseId(json['barId']),
      name: json['name'] as String,
      order: parseId(json['order'] ?? 0),
    );
  }
}

class MenuItemFromAPI {
  final int id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final int categoryId;
  final int barId;
  final int order;
  final String category;
  final String? subCategoryName;
  final List<ToppingFromAPI> toppings;
  final List<String> seals;

  MenuItemFromAPI({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    required this.categoryId,
    required this.barId,
    required this.order,
    required this.category,
    this.subCategoryName,
    this.toppings = const [],
    this.seals = const [],
  });

  factory MenuItemFromAPI.fromJson(Map<String, dynamic> json) {
    // Função auxiliar para converter ID de string ou int para int
    int parseId(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return MenuItemFromAPI(
      id: parseId(json['id']),
      name: json['name'] as String,
      description: json['description'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0.0') ?? 0.0,
      imageUrl: json['imageUrl'] as String?,
      categoryId: parseId(json['categoryId']),
      barId: parseId(json['barId']),
      order: parseId(json['order'] ?? 0),
      category: json['category'] ?? '',
      subCategoryName: json['subCategoryName'],
      toppings: json['toppings'] != null
          ? (json['toppings'] as List)
              .map((topping) => ToppingFromAPI.fromJson(topping))
              .toList()
          : [],
      seals: json['seals'] != null
          ? (json['seals'] as List).map((seal) => seal.toString()).toList()
          : [],
    );
  }
}

class ToppingFromAPI {
  final int id;
  final String name;
  final double price;

  ToppingFromAPI({
    required this.id,
    required this.name,
    required this.price,
  });

  factory ToppingFromAPI.fromJson(Map<String, dynamic> json) {
    // Função auxiliar para converter ID de string ou int para int
    int parseId(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return ToppingFromAPI(
      id: parseId(json['id']),
      name: json['name'] as String,
      price: double.tryParse(json['price']?.toString() ?? '0.0') ?? 0.0,
    );
  }
}

// Modelos para compatibilidade com a UI existente
class Topping {
  final String name;
  final double price;

  Topping({required this.name, required this.price});

  factory Topping.fromAPI(ToppingFromAPI apiTopping) {
    return Topping(
      name: apiTopping.name,
      price: apiTopping.price,
    );
  }
}

class MenuItem {
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final List<Topping> toppings;
  final List<String> seals;

  MenuItem({
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.toppings = const [],
    this.seals = const [],
  });

  factory MenuItem.fromAPI(MenuItemFromAPI apiItem, String validImageUrl) {
    return MenuItem(
      name: apiItem.name,
      description: apiItem.description,
      price: apiItem.price,
      imageUrl: validImageUrl,
      toppings:
          apiItem.toppings.map((topping) => Topping.fromAPI(topping)).toList(),
      seals: apiItem.seals,
    );
  }
}

class MenuCategory {
  final String name;
  final List<MenuItem> items;
  final List<String> subcategories;

  MenuCategory({
    required this.name,
    required this.items,
    this.subcategories = const [],
  });

  factory MenuCategory.fromAPI(
    String categoryName,
    List<MenuItemFromAPI> apiItems,
    String Function(String?) getValidImageUrl,
  ) {
    return MenuCategory(
      name: categoryName,
      items: apiItems
          .map(
              (item) => MenuItem.fromAPI(item, getValidImageUrl(item.imageUrl)))
          .toList(),
    );
  }
}
