import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:agilizaiapp/models/place_model.dart';
import 'package:agilizaiapp/services/place_service.dart';

class SelectLocationScreen extends StatefulWidget {
  const SelectLocationScreen({super.key});

  @override
  State<SelectLocationScreen> createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  GoogleMapController? mapController;
  LatLng _center = const LatLng(-23.55052, -46.633309); // São Paulo
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  late Future<List<Place>> _placesFuture;
  final PlaceService _placeService = PlaceService();
  Position? _currentPosition;
  Place? _selectedPlace;

  @override
  void initState() {
    super.initState();
    _placesFuture = _placeService.fetchAllPlaces();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Verificar permissões
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      // Obter localização atual
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _center = LatLng(position.latitude, position.longitude);
      });

      // Mover câmera para localização atual
      if (mapController != null) {
        mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(_center, 15.0),
        );
      }

      // Adicionar marcador da localização atual
      _addCurrentLocationMarker();
    } catch (e) {
      print('Erro ao obter localização: $e');
    }
  }

  void _addCurrentLocationMarker() {
    if (_currentPosition != null) {
      setState(() {
        _markers.add(
          Marker(
            markerId: const MarkerId('current_location'),
            position:
                LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            infoWindow: const InfoWindow(
              title: 'Sua Localização',
              snippet: 'Você está aqui',
            ),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          ),
        );
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _loadPlaces();
  }

  Future<void> _loadPlaces() async {
    try {
      final places = await _placesFuture;
      setState(() {
        for (Place place in places) {
          if (place.hasCoordinates) {
            _markers.add(
              Marker(
                markerId: MarkerId('place_${place.id}'),
                position: LatLng(place.latitude!, place.longitude!),
                infoWindow: InfoWindow(
                  title: place.name,
                  snippet: place.fullAddress,
                  onTap: () => _showPlaceDetails(place),
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed),
              ),
            );
          }
        }
      });
    } catch (e) {
      print('Erro ao carregar lugares: $e');
    }
  }

  void _showPlaceDetails(Place place) {
    setState(() {
      _selectedPlace = place;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPlaceDetailsSheet(place),
    );
  }

  Widget _buildPlaceDetailsSheet(Place place) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nome e endereço
                  Text(
                    place.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          place.fullAddress,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Descrição
                  if (place.description != null) ...[
                    const Text(
                      'Sobre',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      place.description!,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Botões de ação
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _openDirections(place),
                          icon: const Icon(Icons.directions),
                          label: const Text('Traçar Rota'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF26422),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (place.email != null)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _callPlace(place),
                            icon: const Icon(Icons.phone),
                            label: const Text('Ligar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Distância e tempo estimado
                  if (_currentPosition != null && place.hasCoordinates) ...[
                    _buildDistanceInfo(place),
                    const SizedBox(height: 20),
                  ],

                  // Amenidades
                  if (place.commodities.isNotEmpty) ...[
                    const Text(
                      'Serviços Disponíveis',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: place.commodities.map((commodity) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Color(int.parse(
                                '0xFF${commodity.color.replaceAll('#', '')}')),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            commodity.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistanceInfo(Place place) {
    if (_currentPosition == null || !place.hasCoordinates) {
      return const SizedBox.shrink();
    }

    double distance = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      place.latitude!,
      place.longitude!,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Distância: ${(distance / 1000).toStringAsFixed(1)} km',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Tempo estimado: ${(distance / 1000 * 3).round()} min',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openDirections(Place place) async {
    if (!place.hasCoordinates) return;

    final url =
        'https://www.google.com/maps/dir/?api=1&destination=${place.latitude},${place.longitude}';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o mapa')),
      );
    }
  }

  Future<void> _callPlace(Place place) async {
    if (place.email == null) return;

    final url = 'tel:${place.email}';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível fazer a ligação')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 12.0,
            ),
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 10.0,
              ),
              child: Column(
                children: [
                  // Barra de pesquisa
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Buscar bares próximos...',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.my_location,
                            color: Color(0xFFF26422),
                          ),
                          onPressed: _getCurrentLocation,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Lista de bares
                  Expanded(
                    child: FutureBuilder<List<Place>>(
                      future: _placesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Erro ao carregar bares: ${snapshot.error}',
                              style: const TextStyle(color: Colors.red),
                            ),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(
                            child: Text(
                              'Nenhum bar encontrado',
                              style: TextStyle(color: Colors.grey),
                            ),
                          );
                        }

                        final places = snapshot.data!;
                        return Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Bares Disponíveis',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: places.length,
                                  itemBuilder: (context, index) {
                                    final place = places[index];
                                    return _buildPlaceCard(place);
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceCard(Place place) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFF26422),
          child: Text(
            place.name[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          place.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(place.fullAddress),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _showPlaceDetails(place),
      ),
    );
  }
}
