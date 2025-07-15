// lib/screens/bar/bar_details_screen.dart

import 'package:flutter/material.dart';
import 'package:agilizaiapp/models/bar_model.dart';

class BarDetailsScreen extends StatelessWidget {
  final Bar bar;

  const BarDetailsScreen({super.key, required this.bar});

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
                bar.coverImagePath, // Usando a nova propriedade coverImagePath para a capa
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
                                bar.name,
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
                                    '${bar.rating.toStringAsFixed(1)} (${bar.reviewsCount} Avaliações)',
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
                            bar.logoAssetPath,
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

                    // Tabs (Sobre, Eventos, Reviews)
                    _buildTabsSection(),
                    const SizedBox(height: 24),

                    // Seção "Sobre" (conteúdo da imagem que você enviou)
                    Text(
                      bar.about,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                    const SizedBox(height: 24),

                    // Seção "Ambientes"
                    _buildSectionTitle('Ambientes'),
                    _buildHorizontalImageList(bar.ambianceImagePaths),
                    const SizedBox(height: 24),

                    // Seção "Gastronomia"
                    _buildSectionTitle('Gastronomia'),
                    _buildHorizontalImageList(bar.foodImagePaths),
                    const SizedBox(height: 24),

                    // Seção "Drinks"
                    _buildSectionTitle('Drinks'),
                    _buildHorizontalImageList(bar.drinksImagePaths),
                    const SizedBox(height: 24),

                    // Seção de Localização (Mapa)
                    _buildSectionTitle('Localização'),
                    const SizedBox(height: 8),
                    Text(
                      bar.address,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      // Usar Image.network para o mapa da internet
                      child: Image.network(
                        bar.mapImageUrl, // Agora é um URL online
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
                    _buildSectionTitle('Facilidades'),
                    const SizedBox(height: 16),
                    _buildAmenitiesGrid(bar.amenities),
                    const SizedBox(height: 24),

                    // Horários (Exemplo - você pode tornar dinâmico com o modelo Bar)
                    _buildSectionTitle('Horários'),
                    _buildScheduleRow('Hoje', '14:00 - 04:00'),
                    _buildScheduleRow('Amanhã', '14:00 - 04:00'),
                    // ... adicione mais horários dinamicamente se precisar
                    const SizedBox(height: 24),

                    // Botão de Reservar (similar ao da imagem)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Lógica para reservar
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Reservar no ${bar.name}')),
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
        _buildTabItem('Sobre', true),
        _buildTabItem('Eventos', false),
        _buildTabItem('Avaliações', false),
      ],
    );
  }

  Widget _buildTabItem(String title, bool isSelected) {
    return Column(
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
