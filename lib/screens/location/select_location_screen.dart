import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Corrigido o pacote

class SelectLocationScreen extends StatefulWidget {
  const SelectLocationScreen({super.key});

  @override
  State<SelectLocationScreen> createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  GoogleMapController? mapController;
  LatLng _center = const LatLng(-23.55052, -46.633309);
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _addInitialMarkers();
  }

  void _addInitialMarkers() {
    setState(() {
      _markers.add(
        Marker(
          markerId: const MarkerId('event1'),
          position: const LatLng(-23.561352, -46.656041),
          infoWindow: const InfoWindow(
              title: 'Show no Parque', snippet: 'Um evento incrível!'),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      );
      _markers.add(
        Marker(
          markerId: const MarkerId('event2'),
          position: const LatLng(-23.543594, -46.666114),
          infoWindow: const InfoWindow(
              title: 'Festival de Música', snippet: 'No centro da cidade.'),
        ),
      );
    });
  }

  Future<void> _addRoute() async {
    final List<LatLng> routeCoordinates = [
      const LatLng(-23.561352, -46.656041),
      const LatLng(-23.543594, -46.666114),
    ];

    setState(() {
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('test_route'),
          points: routeCoordinates,
          color: Colors.blue,
          width: 5,
        ),
      );
    });
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
                          Icons.location_on_outlined,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Search new address...',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.my_location,
                            color: Color(0xFFF26422),
                          ),
                          onPressed: () {
                            // TODO: Lógica para mover a câmera para a localização atual do usuário
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Column(
                      children: [
                        _buildLocationRow(
                          Icons.storefront,
                          "Hary's Street Market",
                        ),
                        const Divider(),
                        _buildLocationRow(Icons.local_cafe, "Park Stone Cafe"),
                        TextButton(
                          onPressed: _addRoute,
                          child: const Text('Desenhar Rota Exemplo'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Lógica para adicionar a localização e ir para a Home do App
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF242A38),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'ADD',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFF26422)),
          const SizedBox(width: 16),
          Text(text),
        ],
      ),
    );
  }
}
