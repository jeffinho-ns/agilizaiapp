// lib/screens/bar/bar_details_screen.dart

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:agilizaiapp/models/bar_model.dart';
import 'package:agilizaiapp/models/event_model.dart'; // Importe Event para o botão de evento
import 'package:agilizaiapp/data/bar_data.dart'; // Para allBars
import 'package:agilizaiapp/screens/bar/bar_menu_screen.dart'; // Importe BarMenuScreen
import 'package:agilizaiapp/screens/event/event_details_screen.dart'; // Importe EventDetailsPage
import 'package:agilizaiapp/models/amenity_model.dart'; // <--- Importe Amenity
import 'package:agilizaiapp/screens/event/event_booked_screen.dart'; // Importe a tela de reserva confirmada
import 'package:agilizaiapp/screens/event_participation/event_participation_form_screen.dart';

class BarDetailsScreen extends StatefulWidget {
  final Bar bar;

  const BarDetailsScreen({super.key, required this.bar});

  @override
  State<BarDetailsScreen> createState() => _BarDetailsScreenState();
}

class _BarDetailsScreenState extends State<BarDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.asset(
                widget.bar.coverImagePath, // Usando coverImagePath
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image,
                        size: 80, color: Colors.grey),
                  );
                },
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite_border, color: Colors.white),
                onPressed: () {
                  // Lógica para favoritar
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          widget.bar.logoAssetPath,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.broken_image,
                                  color: Colors.grey),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.bar.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.bar.address ??
                                  '${widget.bar.street}, ${widget.bar.number}', // Usando address ou street/number
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.star_rate_rounded,
                                    color: Colors.amber, size: 20),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.bar.rating.toStringAsFixed(1)} (${widget.bar.reviewsCount} Avaliações)', // Usando rating e reviewsCount
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.bar.description, // Usando description como 'about'
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 20),

                  _buildSectionTitle('Horário de Funcionamento'),
                  _buildOpeningHours(),
                  const SizedBox(height: 20),

                  _buildSectionTitle('Cardápio'),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => BarMenuScreen(
                              barId: widget.bar.id,
                              appBarColor: Theme.of(context)
                                  .primaryColor), // <<-- CORREÇÃO AQUI! Passando barId
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Ver Cardápio Completo'),
                  ),
                  const SizedBox(height: 20),

                  _buildSectionTitle('Eventos Deste Local'),
                  // Você precisaria buscar eventos específicos deste local aqui
                  // Exemplo: FutureBuilder para buscar eventos do bar.id
                  _buildEventsForBar(),
                  const SizedBox(height: 20),

                  _buildSectionTitle('Galeria'),
                  _buildHorizontalImageList(widget.bar.ambianceImagePaths,
                      title: 'Ambiente'), // Usando ambianceImagePaths
                  const SizedBox(height: 10),
                  _buildHorizontalImageList(widget.bar.foodImagePaths,
                      title: 'Comida'), // Usando foodImagePaths
                  const SizedBox(height: 10),
                  _buildHorizontalImageList(widget.bar.drinksImagePaths,
                      title: 'Bebidas'), // Usando drinksImagePaths
                  const SizedBox(height: 20),

                  _buildSectionTitle('Localização'),
                  if (widget.bar.hasCoordinates) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        height: 200,
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: LatLng(
                                widget.bar.latitude!, widget.bar.longitude!),
                            zoom: 15.0,
                          ),
                          markers: {
                            Marker(
                              markerId: MarkerId(widget.bar.id.toString()),
                              position: LatLng(
                                  widget.bar.latitude!, widget.bar.longitude!),
                              infoWindow: InfoWindow(
                                title: widget.bar.name,
                                snippet: widget.bar.fullAddress,
                              ),
                              icon: BitmapDescriptor.defaultMarkerWithHue(
                                  BitmapDescriptor.hueRed),
                            ),
                          },
                          zoomControlsEnabled: false,
                          myLocationEnabled: false,
                          myLocationButtonEnabled: false,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _openDirections(),
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
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _callBar(),
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
                  ] else ...[
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.location_off,
                                size: 60, color: Colors.grey),
                            SizedBox(height: 8),
                            Text(
                              'Localização não disponível',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),

                  _buildSectionTitle('Comodidades'),
                  _buildAmenitiesGrid(widget.bar.amenities), // Usando amenities
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            // Lógica para reservar uma mesa
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF26422),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            textStyle:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('Reservar Mesa'),
        ),
      ),
    );
  }

  // Métodos auxiliares de build (mantidos os que você já tinha)
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildOpeningHours() {
    // Dados mockados de horário de funcionamento
    final Map<String, String> hours = {
      'Segunda a Sexta': '18:00 - 02:00',
      'Sábado': '14:00 - 04:00',
      'Domingo': '14:00 - 00:00',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: hours.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(entry.key,
                  style: const TextStyle(fontSize: 16, color: Colors.black87)),
              Text(entry.value,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHorizontalImageList(List<String> imagePaths, {String? title}) {
    if (imagePaths.isEmpty) {
      return const Text('Nenhuma imagem disponível.',
          style: TextStyle(color: Colors.grey));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
        ],
        SizedBox(
          height: 120, // Altura fixa para a lista de imagens
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: imagePaths.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    // Assumindo que são assets locais
                    imagePaths[index],
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 120,
                        height: 120,
                        color: Colors.grey[200],
                        child:
                            const Icon(Icons.broken_image, color: Colors.grey),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEventsForBar() {
    // Isto é um placeholder. Você precisaria buscar eventos filtrados por barId.
    // Exemplo usando EventService:
    // late Future<List<Event>> _eventsForBarFuture;
    // _eventsForBarFuture = EventService().fetchAllEvents(barId: widget.bar.id); // Você precisaria adicionar barId ao fetchAllEvents ou criar um novo método
    return const Text(
        'Lista de eventos para este local (funcionalidade a ser implementada com API).',
        style: TextStyle(color: Colors.grey));
  }

  // <--- CORREÇÃO AQUI: 'Amenity' deve ser importado
  Widget _buildAmenitiesGrid(List<Amenity> amenities) {
    if (amenities.isEmpty) {
      return const Text('Nenhuma comodidade disponível.',
          style: TextStyle(color: Colors.grey));
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: amenities.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // 3 colunas
        childAspectRatio: 2.5, // Largura maior que altura
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final amenity = amenities[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blueGrey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blueGrey[100]!),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(amenity.icon, size: 18, color: Colors.blueGrey[700]),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  amenity.label,
                  style: TextStyle(fontSize: 13, color: Colors.blueGrey[800]),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Método para abrir direções no Google Maps
  Future<void> _openDirections() async {
    if (!widget.bar.hasCoordinates) return;

    final url =
        'https://www.google.com/maps/dir/?api=1&destination=${widget.bar.latitude},${widget.bar.longitude}';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o mapa')),
      );
    }
  }

  // Método para ligar para o bar
  Future<void> _callBar() async {
    // Aqui você pode usar o email como telefone ou adicionar um campo telefone no modelo
    final phoneNumber = widget.bar.address ?? '11999999999'; // Placeholder
    final url = 'tel:$phoneNumber';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível fazer a ligação')),
      );
    }
  }
}
