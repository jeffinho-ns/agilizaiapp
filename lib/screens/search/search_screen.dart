// lib/screens/search/search_screen.dart

import 'dart:convert';
import 'package:agilizaiapp/screens/event/event_details_screen.dart';
import 'package:http/http.dart' as http;
import 'package:agilizaiapp/models/event_model.dart';
import 'package:agilizaiapp/screens/filter/filter_screen.dart';
import 'package:agilizaiapp/widgets/search_result_tile.dart';
import 'package:flutter/material.dart';
// Importe a tela de detalhes do evento, substitua 'event_detail_screen.dart' pelo seu caminho real
import 'package:agilizaiapp/screens/event/event_details_screen.dart'; // ASSUMINDO ESTE CAMINHO

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  List<Event> _allEvents = [];
  List<Event> _filteredEvents = [];

  FilterSettings? _activeFilters;
  String _selectedCategoryChip = 'All'; // Manter em inglês para o valor interno
  final List<String> _categories = [
    'All',
    'Design',
    'Art',
    'Sports',
    'Music'
  ]; // Valores internos

  // Mapeamento para traduzir as categorias para exibição
  final Map<String, String> _translatedCategories = {
    'All': 'Todos',
    'Design': 'Design',
    'Art': 'Arte',
    'Sports': 'Esportes',
    'Music': 'Música',
    // Adicione mais categorias conforme necessário
  };

  @override
  void initState() {
    super.initState();
    _fetchEvents();
    _searchController.addListener(_runFilter);
  }

  @override
  void dispose() {
    _searchController.removeListener(_runFilter);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchEvents() async {
    try {
      final response = await http.get(
        Uri.parse('https://vamos-comemorar-api.onrender.com/api/events'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> eventData = jsonDecode(response.body);
        final List<Event> loadedEvents =
            eventData.map((json) => Event.fromJson(json)).toList();

        if (mounted) {
          setState(() {
            _allEvents = loadedEvents;
            _filteredEvents = loadedEvents;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Erro ao buscar eventos na SearchScreen: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Função para converter o 'dynamic' do preço para double de forma segura
  double _parsePrice(dynamic priceValue) {
    if (priceValue == null) return 0.0;
    if (priceValue is num) {
      return priceValue.toDouble(); // Se já for um número (int, double)
    }
    if (priceValue is String) {
      return double.tryParse(priceValue) ?? 0.0; // Se for texto
    }
    return 0.0;
  }

  void _runFilter() {
    List<Event> results = List.from(_allEvents);

    // Filtro por Texto de Busca
    if (_searchController.text.isNotEmpty) {
      results = results
          .where(
            (event) => (event.nomeDoEvento ?? '')
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()),
          )
          .toList();
    }

    // Filtro rápido por Categoria (chip na tela)
    if (_selectedCategoryChip != 'All') {
      results = results
          .where((event) => (event.categoria ?? '') == _selectedCategoryChip)
          .toList();
    }

    // Filtros avançados da FilterScreen
    if (_activeFilters != null) {
      // Categoria da FilterScreen
      if (_activeFilters!.category != 'All') {
        results = results
            .where(
                (event) => (event.categoria ?? '') == _activeFilters!.category)
            .toList();
      }

      // Preço da FilterScreen
      results = results.where((event) {
        final price = _parsePrice(event.valorDaEntrada);
        return price >= _activeFilters!.priceRange.start &&
            price <= _activeFilters!.priceRange.end;
      }).toList();

      // Filtro por Data da FilterScreen
      if (_activeFilters!.startDate != null) {
        results = results.where((event) {
          if (event.dataDoEvento == null) return false;
          try {
            final eventDate = DateTime.parse(event.dataDoEvento!);
            // Compara ignorando a hora
            final startDate = _activeFilters!.startDate!;
            final endDate = _activeFilters!.endDate!;

            final eventDateOnly = DateTime(
              eventDate.year,
              eventDate.month,
              eventDate.day,
            );
            final startDateOnly = DateTime(
              startDate.year,
              startDate.month,
              startDate.day,
            );
            final endDateOnly = DateTime(
              endDate.year,
              endDate.month,
              endDate.day,
            );

            return (eventDateOnly.isAtSameMomentAs(startDateOnly) ||
                    eventDateOnly.isAfter(startDateOnly)) &&
                (eventDateOnly.isAtSameMomentAs(endDateOnly) ||
                    eventDateOnly.isBefore(endDateOnly));
          } catch (e) {
            return false;
          }
        }).toList();
      }
    }

    if (mounted) {
      setState(() {
        _filteredEvents = results;
      });
    }
  }

  void _openFilterScreen() async {
    final newFilters = await Navigator.of(context).push<FilterSettings>(
      MaterialPageRoute(
        builder: (context) => const FilterScreen(),
        fullscreenDialog: true,
      ),
    );

    if (newFilters != null) {
      setState(() {
        _activeFilters = newFilters;
        // Ao aplicar filtros avançados, o chip "All" pode não ser o mais preciso
        // Ou você pode querer que o chip reflita a categoria do filtro avançado.
        // Se newFilters.category for 'All' e houver outros filtros,
        // _selectedCategoryChip = 'All' ainda é válido.
        // Se houver uma categoria específica no filtro, use-a.
        _selectedCategoryChip = newFilters.category;
      });
      _runFilter();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Buscar Eventos', // Traduzido de 'Search'
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText:
                          'Encontre eventos incríveis', // Traduzido de 'Find amazing events'
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: _openFilterScreen,
                  icon: const Icon(Icons.filter_list),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories
                    .map(
                      (category) => _buildChoiceChip(
                        label: _translatedCategories[
                            category]!, // Usa o valor traduzido para exibir
                        actualValue:
                            category, // Passa o valor original para seleção interna
                        selected: _selectedCategoryChip == category,
                        onSelected: (isSelected) {
                          if (isSelected) {
                            setState(() {
                              _selectedCategoryChip =
                                  category; // Atualiza com o valor original
                              _activeFilters =
                                  null; // Limpa filtros avançados ao selecionar um chip de categoria
                            });
                            _runFilter();
                          }
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredEvents.isEmpty
                      ? const Center(child: Text('Nenhum evento encontrado.'))
                      : ListView.builder(
                          padding: const EdgeInsets.only(top: 8),
                          itemCount: _filteredEvents.length,
                          itemBuilder: (context, index) {
                            final event = _filteredEvents[index];
                            return GestureDetector(
                              onTap: () => _navigateToEventDetail(
                                  event), // Torna o card clicável
                              child: SearchResultTile(event: event),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceChip({
    required String label, // Label para exibição
    required String actualValue, // Valor real da categoria
    required bool selected,
    required Function(bool) onSelected,
  }) {
    final icons = {
      'All': Icons.apps,
      'Design': Icons.design_services_outlined,
      'Art': Icons.palette_outlined,
      'Sports': Icons.sports_basketball_outlined,
      'Music': Icons.music_note_outlined,
    };
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label), // Exibe o label traduzido
        avatar: Icon(
          icons[actualValue], // Usa o valor original para o ícone
          color: selected ? Colors.white : const Color(0xFFF26422),
        ),
        selected: selected,
        onSelected: onSelected,
        backgroundColor: Colors.white,
        selectedColor: const Color(0xFFF26422),
        labelStyle: TextStyle(
          color: selected ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}
