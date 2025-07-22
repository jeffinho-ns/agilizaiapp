// lib/screens/bar/bar_details_screen.dart

import 'package:agilizaiapp/screens/event/event_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:agilizaiapp/models/bar_model.dart';
import 'package:agilizaiapp/models/event_model.dart'; // Importe o modelo de Evento
import 'package:http/http.dart' as http; // Para fazer requisições HTTP
import 'dart:convert'; // Para jsonDecode
import 'package:agilizaiapp/widgets/search_result_tile.dart'; // Reutilizando o widget de card de evento
import 'package:agilizaiapp/screens/event/event_details_screen.dart'; // Para navegar para detalhes do evento

// Enum para gerenciar as abas
enum BarDetailTab { about, events, reviews }

class BarDetailsScreen extends StatefulWidget {
  final Bar bar;

  const BarDetailsScreen({super.key, required this.bar});

  @override
  State<BarDetailsScreen> createState() => _BarDetailsScreenState();
}

class _BarDetailsScreenState extends State<BarDetailsScreen> {
  BarDetailTab _selectedTab =
      BarDetailTab.about; // Estado para a aba selecionada
  List<Event> _barEvents = [];
  bool _isLoadingEvents = false;
  String? _eventsErrorMessage;

  @override
  void initState() {
    super.initState();
    // Você pode decidir se quer carregar eventos imediatamente
    // ou apenas quando a aba de eventos for clicada pela primeira vez.
    // Se desejar carregar imediatamente, chame _fetchEventsForBar() aqui.
  }

  // Função para buscar eventos da API baseados no nome da casa
  Future<void> _fetchEventsForBar() async {
    if (_isLoadingEvents) return; // Evita múltiplas chamadas
    setState(() {
      _isLoadingEvents = true;
      _eventsErrorMessage = null;
    });

    try {
      // ✨ MUDANÇA CRUCIAL AQUI: Adiciona o parâmetro de consulta 'casaDoEvento'
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
      print("Erro ao buscar eventos para ${widget.bar.name}: $e");
      if (mounted) {
        setState(() {
          _eventsErrorMessage = 'Erro ao carregar eventos. Tente novamente.';
          _isLoadingEvents = false;
        });
      }
    }
  }

  // Função para navegar para a tela de detalhes do evento
  void _navigateToEventDetail(Event event) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EventDetailsPage(event: event),
      ),
    );
  }

  // --- ONDE ESTARÁ O CONTEÚDO DINÂMICO ---
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
                'Nenhum evento encontrado para esta casa.', // Traduzido
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          );
        } else {
          return ListView.builder(
            shrinkWrap:
                true, // Importante para ListView dentro de Column/SliverList
            physics:
                const NeverScrollableScrollPhysics(), // Desabilita scroll do ListView
            itemCount: _barEvents.length,
            itemBuilder: (context, index) {
              final event = _barEvents[index];
              return GestureDetector(
                onTap: () => _navigateToEventDetail(event),
                child: SearchResultTile(event: event), // Reutilizando o tile
              );
            },
          );
        }
      case BarDetailTab.reviews:
        return const Center(
            child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Avaliações em breve!', // Traduzido
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ));
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
            expandedHeight: 250.0, // Altura da imagem de cabeçalho
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.asset(
                widget.bar
                    .coverImagePath, // Usando a nova propriedade coverImagePath para a capa
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
            // Botões de voltar e favoritar na AppBar
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite_border, color: Colors.white),
                onPressed: () {
                  // TODO: Adicionar lógica de favoritar
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
                    // Cabeçalho do Bar (Nome, Logo, Avaliação)
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
                                    '${widget.bar.rating.toStringAsFixed(1)} (${widget.bar.reviewsCount} Avaliações)', // Traduzido
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
                        // Logo do Bar
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

                    // Tabs (Sobre, Eventos, Avaliações)
                    _buildTabsSection(),
                    const SizedBox(height: 24),

                    // Conteúdo dinâmico baseado na aba selecionada
                    _buildContentBasedOnTab(),
                    const SizedBox(height: 24),

                    // As seções abaixo só devem aparecer se a aba "Sobre" estiver selecionada
                    if (_selectedTab == BarDetailTab.about) ...[
                      // Seção "Ambientes"
                      _buildSectionTitle('Ambientes'), // Traduzido
                      _buildHorizontalImageList(widget.bar.ambianceImagePaths),
                      const SizedBox(height: 24),

                      // Seção "Gastronomia"
                      _buildSectionTitle('Gastronomia'), // Traduzido
                      _buildHorizontalImageList(widget.bar.foodImagePaths),
                      const SizedBox(height: 24),

                      // Seção "Drinks"
                      _buildSectionTitle('Drinks'), // Traduzido
                      _buildHorizontalImageList(widget.bar.drinksImagePaths),
                      const SizedBox(height: 24),

                      // Seção de Localização (Mapa)
                      _buildSectionTitle('Localização'), // Traduzido
                      const SizedBox(height: 8),
                      Text(
                        widget.bar.address,
                        style:
                            const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        // Usar Image.network para o mapa da internet
                        child: Image.network(
                          widget.bar.mapImageUrl, // Agora é um URL online
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

                      // Seção de Facilidades
                      _buildSectionTitle('Facilidades'), // Traduzido
                      const SizedBox(height: 16),
                      _buildAmenitiesGrid(widget.bar.amenities),
                      const SizedBox(height: 24),

                      // Horários (Exemplo - você pode tornar dinâmico com o modelo Bar)
                      _buildSectionTitle('Horários'), // Traduzido
                      _buildScheduleRow('Hoje', '14:00 - 04:00'), // Traduzido
                      _buildScheduleRow('Amanhã', '14:00 - 04:00'), // Traduzido
                      // ... adicione mais horários dinamicamente se precisar
                      const SizedBox(height: 24),
                    ],

                    // Botão de Reservar (similar ao da imagem)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Lógica para reservar
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Reservar no ${widget.bar.name}')), // Traduzido
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
                          'Reservar', // Traduzido
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

  // Restante dos widgets auxiliares (_buildSectionTitle, _buildTabsSection, etc.)
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
          });
          _fetchEventsForBar(); // Busca eventos quando a aba "Eventos" é clicada
        }),
        _buildTabItem('Avaliações', _selectedTab == BarDetailTab.reviews, () {
          setState(() {
            _selectedTab = BarDetailTab.reviews;
          });
        }),
      ],
    );
  }

  // Ajustado para receber um onTap
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
      return const Text(
          'Nenhuma imagem disponível nesta categoria.'); // Traduzido
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
