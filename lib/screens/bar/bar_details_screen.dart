// lib/screens/bar/bar_details_screen.dart

import 'package:agilizaiapp/screens/event/event_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:agilizaiapp/models/bar_model.dart';
import 'package:agilizaiapp/models/event_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:agilizaiapp/widgets/search_result_tile.dart';
import 'package:agilizaiapp/screens/bar/bar_menu_screen.dart';

// Pacote para remover acentos
import 'package:diacritic/diacritic.dart';

// Enum para gerenciar as abas
enum BarDetailTab { about, events, reviews, menu }

class BarDetailsScreen extends StatefulWidget {
  final Bar bar;

  const BarDetailsScreen({super.key, required this.bar});

  @override
  State<BarDetailsScreen> createState() => _BarDetailsScreenState();
}

class _BarDetailsScreenState extends State<BarDetailsScreen> {
  BarDetailTab _selectedTab = BarDetailTab.about;
  List<Event> _barEvents = [];
  bool _isLoadingEvents = false;
  String? _eventsErrorMessage;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _fetchEventsForBar() async {
    if (_isLoadingEvents) return;
    setState(() {
      _isLoadingEvents = true;
      _eventsErrorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse(
            'https://vamos-comemorar-api.onrender.com/api/events?casaDoEvento=${Uri.encodeComponent(widget.bar.name)}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> eventData = jsonDecode(response.body);
        final List<Event> loadedEvents =
            eventData.map((json) => Event.fromJson(json)).toList();

        if (mounted) {
          setState(() {
            _barEvents = loadedEvents;
            _isLoadingEvents = false;
          });
        }
      } else {
        throw Exception(
            'Falha ao carregar eventos: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _eventsErrorMessage = 'Erro ao carregar eventos. Tente novamente.';
          _isLoadingEvents = false;
        });
      }
    }
  }

  void _navigateToEventDetail(Event event) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EventDetailsPage(event: event),
      ),
    );
  }

  void _navigateToBarMenu() {
    Color menuAppBarColor;

    // Padronização completa para a lógica: minúsculas, sem espaços e sem acentos.
    final standardizedBarName =
        removeDiacritics(widget.bar.name.toLowerCase()).replaceAll(' ', '');

    switch (standardizedBarName) {
      case 'pracinha':
        menuAppBarColor = const Color(0xFF2DA28E);
        break;
      case 'seujustino':
        menuAppBarColor = const Color(0xFF095D4E);
        break;
      case 'highline':
        menuAppBarColor = const Color(0xFF292929);
        break;
      case 'ohfregues':
        menuAppBarColor = const Color(0xFFC5831A);
        break;
      default:
        menuAppBarColor = Colors.deepPurple;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BarMenuScreen(
          barName: widget.bar.name,
          appBarColor: menuAppBarColor,
        ),
      ),
    );
  }

  Widget _buildContentBasedOnTab() {
    switch (_selectedTab) {
      case BarDetailTab.about:
        return Text(
          widget.bar.about,
          style: const TextStyle(fontSize: 16, height: 1.5),
        );
      case BarDetailTab.events:
        if (_isLoadingEvents) {
          return const Center(child: CircularProgressIndicator());
        } else if (_eventsErrorMessage != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _eventsErrorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
          );
        } else if (_barEvents.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Nenhum evento encontrado para esta casa.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          );
        } else {
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _barEvents.length,
            itemBuilder: (context, index) {
              final event = _barEvents[index];
              return GestureDetector(
                onTap: () => _navigateToEventDetail(event),
                child: SearchResultTile(event: event),
              );
            },
          );
        }
      case BarDetailTab.reviews:
        return const Center(
            child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Avaliações em breve!',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ));
      case BarDetailTab.menu:
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Clique em "Cardápio" para ver os itens!',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
        );
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.asset(
                widget.bar.coverImagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite_border, color: Colors.white),
                onPressed: () {
                  // Lógica de favoritar
                },
              ),
            ],
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.bar.name,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${widget.bar.rating.toStringAsFixed(1)} (${widget.bar.reviewsCount} Avaliações)',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            widget.bar.logoAssetPath,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildTabsSection(),
                    const SizedBox(height: 24),
                    _buildContentBasedOnTab(),
                    const SizedBox(height: 24),
                    if (_selectedTab == BarDetailTab.about) ...[
                      _buildSectionTitle('Ambientes'),
                      _buildHorizontalImageList(widget.bar.ambianceImagePaths),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Gastronomia'),
                      _buildHorizontalImageList(widget.bar.foodImagePaths),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Drinks'),
                      _buildHorizontalImageList(widget.bar.drinksImagePaths),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Localização'),
                      const SizedBox(height: 8),
                      Text(
                        widget.bar.address,
                        style:
                            const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          widget.bar.mapImageUrl,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              width: double.infinity,
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Facilidades'),
                      const SizedBox(height: 16),
                      _buildAmenitiesGrid(widget.bar.amenities),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Horários'),
                      _buildScheduleRow('Hoje', '14:00 - 04:00'),
                      _buildScheduleRow('Amanhã', '14:00 - 04:00'),
                      const SizedBox(height: 24),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('Reservar no ${widget.bar.name}')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF26422),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Reservar',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildTabsSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildTabItem('Sobre', _selectedTab == BarDetailTab.about, () {
          setState(() {
            _selectedTab = BarDetailTab.about;
          });
        }),
        _buildTabItem('Eventos', _selectedTab == BarDetailTab.events, () {
          setState(() {
            _selectedTab = BarDetailTab.events;
            _fetchEventsForBar();
          });
        }),
        _buildTabItem('Avaliações', _selectedTab == BarDetailTab.reviews, () {
          setState(() {
            _selectedTab = BarDetailTab.reviews;
          });
        }),
        _buildTabItem('Cardápio', false, () {
          _navigateToBarMenu();
        }),
      ],
    );
  }

  Widget _buildTabItem(String title, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.black : Colors.grey,
            ),
          ),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 8),
              height: 3,
              width: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF26422),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHorizontalImageList(List<String> imagePaths) {
    if (imagePaths.isEmpty) {
      return const Text('Nenhuma imagem disponível nesta categoria.');
    }
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imagePaths.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                imagePaths[index],
                width: 150,
                height: 150,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 150,
                    height: 150,
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAmenitiesGrid(List<Amenity> amenities) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.0,
      ),
      itemCount: amenities.length,
      itemBuilder: (context, index) {
        final amenity = amenities[index];
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(amenity.icon, size: 24, color: Colors.black54),
            ),
            const SizedBox(height: 4),
            Text(
              amenity.label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        );
      },
    );
  }

  Widget _buildScheduleRow(String day, String hours) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(day, style: const TextStyle(fontSize: 16)),
          Text(
            hours,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
