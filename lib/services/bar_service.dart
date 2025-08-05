// lib/services/bar_service.dart

import 'dart:math';
import 'package:agilizaiapp/models/bar_model.dart';
import 'package:agilizaiapp/services/place_service.dart';

class BarService {
  final PlaceService _placeService = PlaceService();

  // Buscar todos os bares da API
  Future<List<Bar>> fetchAllBars() async {
    try {
      print('Iniciando busca de bares...');
      final places = await _placeService.fetchAllPlaces();
      print('Places encontrados: ${places.length}');
      final bars = places.map((place) => Bar.fromPlace(place)).toList();
      print('Bares convertidos: ${bars.length}');
      return bars;
    } catch (e) {
      print('Erro ao buscar bares: $e');
      // Retornar lista vazia em caso de erro para não quebrar a UI
      return [];
    }
  }

  // Buscar um bar específico por ID
  Future<Bar> fetchBarById(int barId) async {
    try {
      final place = await _placeService.fetchPlaceById(barId);
      return Bar.fromPlace(place);
    } catch (e) {
      print('Erro ao buscar bar: $e');
      throw Exception('Falha ao carregar bar: $e');
    }
  }

  // Buscar bares por slug
  Future<Bar?> fetchBarBySlug(String slug) async {
    try {
      final bars = await fetchAllBars();
      return bars.firstWhere((bar) => bar.slug == slug);
    } catch (e) {
      print('Erro ao buscar bar por slug: $e');
      return null;
    }
  }

  // Buscar bares próximos (dentro de uma distância)
  Future<List<Bar>> fetchNearbyBars(
      double latitude, double longitude, double radiusKm) async {
    try {
      final bars = await fetchAllBars();
      final nearbyBars = <Bar>[];

      for (final bar in bars) {
        if (bar.hasCoordinates) {
          final distance = _calculateDistance(
            latitude,
            longitude,
            bar.latitude!,
            bar.longitude!,
          );
          if (distance <= radiusKm) {
            nearbyBars.add(bar);
          }
        }
      }

      // Ordenar por distância
      nearbyBars.sort((a, b) {
        final distanceA = _calculateDistance(
          latitude,
          longitude,
          a.latitude!,
          a.longitude!,
        );
        final distanceB = _calculateDistance(
          latitude,
          longitude,
          b.latitude!,
          b.longitude!,
        );
        return distanceA.compareTo(distanceB);
      });

      return nearbyBars;
    } catch (e) {
      print('Erro ao buscar bares próximos: $e');
      throw Exception('Falha ao carregar bares próximos: $e');
    }
  }

  // Calcular distância entre dois pontos (fórmula de Haversine)
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Raio da Terra em km

    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        sin(_degreesToRadians(lat1)) *
            sin(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final double c = 2 * asin(sqrt(a));

    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }
}
