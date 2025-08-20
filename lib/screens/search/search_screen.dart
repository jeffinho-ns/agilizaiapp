// lib/screens/search/search_screen.dart

import 'package:agilizaiapp/screens/event/event_details_screen.dart';
// AINDA USADO PARA _fetchEvents mas vamos remover
import 'package:agilizaiapp/models/event_model.dart';
import 'package:agilizaiapp/screens/filter/filter_screen.dart';
import 'package:agilizaiapp/widgets/search_result_tile.dart';
import 'package:flutter/material.dart';
import 'package:agilizaiapp/services/event_service.dart'; // <--- NOVO: Importe o serviço de eventos

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
  };

  final EventService _eventService =
      EventService(); // <--- NOVO: Instância do serviço

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
    setState(() {
      _isLoading = true;
    });
    try {
      final List<Event> loadedEvents =
          await _eventService.fetchAllEvents(); // <--- CORREÇÃO AQUI
      if (mounted) {
        setState(() {
          _allEvents = loadedEvents;
          _filteredEvents = loadedEvents;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Erro ao buscar eventos na SearchScreen: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Opcional: mostrar erro na UI
        });
      }
    }
  }

  // ... (Resto do código permanece o mesmo) ...

  double _parsePrice(dynamic priceValue) {
    if (priceValue == null) return 0.0;
    if (priceValue is num) {
      return priceValue.toDouble();
    }
    if (priceValue is String) {
      return double.tryParse(priceValue) ?? 0.0;
    }
    return 0.0;
  }

  void _runFilter() {
    List<Event> results = List.from(_allEvents);

    if (_searchController.text.isNotEmpty) {
      results = results
          .where(
            (event) => (event.nomeDoEvento ?? '')
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()),
          )
          .toList();
    }

    if (_selectedCategoryChip != 'All') {
      results = results
          .where((event) => (event.categoria ?? '') == _selectedCategoryChip)
          .toList();
    }

    if (_activeFilters != null) {
      if (_activeFilters!.category != 'All') {
        results = results
            .where(
                (event) => (event.categoria ?? '') == _activeFilters!.category)
            .toList();
      }

      results = results.where((event) {
        final price = _parsePrice(event.valorDaEntrada);
        return price >= _activeFilters!.priceRange.start &&
            price <= _activeFilters!.priceRange.end;
      }).toList();

      if (_activeFilters!.startDate != null) {
        results = results.where((event) {
          if (event.dataDoEvento == null) return false;
          try {
            final eventDate = DateTime.parse(event.dataDoEvento!);
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
              23,
              59,
              59,
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
        _selectedCategoryChip = newFilters.category;
      });
      _runFilter();
    }
  }

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
          'Buscar Eventos',
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
                      hintText: 'Encontre eventos incríveis',
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
                        label: _translatedCategories[category]!,
                        actualValue: category,
                        selected: _selectedCategoryChip == category,
                        onSelected: (isSelected) {
                          if (isSelected) {
                            setState(() {
                              _selectedCategoryChip = category;
                              _activeFilters = null;
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
                              onTap: () => _navigateToEventDetail(event),
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
    required String label,
    required String actualValue,
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
        label: Text(label),
        avatar: Icon(
          icons[actualValue],
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

  Widget _buildTimeChip({
    required String label,
    required String actualValue,
    required bool selected,
    required Function(bool) onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: onSelected,
        backgroundColor: Colors.grey[200],
        selectedColor: const Color(0xFFF26422),
        labelStyle: TextStyle(
          color: selected ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide.none,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }

  Widget _buildPickerRow({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
