import 'package:flutter/material.dart';
import 'package:agilizaiapp/models/event_model.dart';
import 'package:agilizaiapp/services/event_service.dart';
import 'package:agilizaiapp/screens/event_participation/event_participation_form_screen.dart';

class EventSearchScreen extends StatefulWidget {
  const EventSearchScreen({super.key});

  @override
  State<EventSearchScreen> createState() => _EventSearchScreenState();
}

class _EventSearchScreenState extends State<EventSearchScreen> {
  final EventService _eventService = EventService();
  List<Event> _allEvents = [];
  List<Event> _filteredEvents = [];
  bool _isLoading = true;
  String _errorMessage = '';
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Todos';

  @override
  void initState() {
    super.initState();
    _fetchAllEvents();
  }

  Future<void> _fetchAllEvents() async {
    setState(() => _isLoading = true);
    try {
      final events = await _eventService.fetchAllEvents();
      setState(() {
        _allEvents = events;
        _filteredEvents = events;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar eventos: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _filterEvents(String query) {
    setState(() {
      _filteredEvents = _allEvents.where((event) {
        final eventName = event.nomeDoEvento?.toLowerCase() ?? '';
        final eventLocation = event.localDoEvento?.toLowerCase() ?? '';
        final eventCasa = event.casaDoEvento?.toLowerCase() ?? '';
        final searchLower = query.toLowerCase();

        bool matchesSearch = eventName.contains(searchLower) ||
            eventLocation.contains(searchLower) ||
            eventCasa.contains(searchLower);

        // Aplicar filtro adicional se selecionado
        if (_selectedFilter != 'Todos') {
          matchesSearch = matchesSearch && event.tipoEvento == _selectedFilter;
        }

        return matchesSearch;
      }).toList();
    });
  }

  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      _filterEvents(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Participar de Evento'),
        backgroundColor: const Color(0xFFF26422),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchAllEvents,
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de busca
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar Evento',
                hintText: 'Nome, local ou estabelecimento',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterEvents('');
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: _filterEvents,
            ),
          ),

          // Filtros
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip('Todos'),
                _buildFilterChip('unico'),
                _buildFilterChip('semanal'),
              ],
            ),
          ),

          // Resultados
          Expanded(
            child: _buildResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filter) {
    final isSelected = _selectedFilter == filter;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(filter == 'unico'
            ? 'Evento Único'
            : filter == 'semanal'
                ? 'Evento Semanal'
                : filter),
        selected: isSelected,
        onSelected: (_) => _applyFilter(filter),
        selectedColor: const Color(0xFFF26422),
        checkmarkColor: Colors.white,
        backgroundColor: Colors.grey[200],
      ),
    );
  }

  Widget _buildResults() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Carregando eventos...'),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchAllEvents,
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    if (_filteredEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Nenhum evento encontrado',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchController.text.isEmpty
                  ? 'Não há eventos disponíveis no momento.'
                  : 'Tente ajustar sua busca ou filtros.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchAllEvents,
      child: ListView.builder(
        itemCount: _filteredEvents.length,
        itemBuilder: (context, index) {
          final event = _filteredEvents[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 2,
            child: ListTile(
              leading: CircleAvatar(
                radius: 25,
                backgroundColor: const Color(0xFFF26422),
                backgroundImage: event.imagemDoEventoUrl != null
                    ? NetworkImage(event.imagemDoEventoUrl!)
                    : null,
                child: event.imagemDoEventoUrl == null
                    ? const Icon(Icons.event, color: Colors.white)
                    : null,
              ),
              title: Text(
                event.nomeDoEvento ?? 'Evento Sem Nome',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.casaDoEvento ?? '',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '${event.localDoEvento ?? ''}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  Text(
                    '${event.dataDoEvento ?? ''} às ${event.horaDoEvento}',
                    style: const TextStyle(
                      color: Color(0xFFF26422),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFFF26422),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => EventParticipationFormScreen(event: event),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
