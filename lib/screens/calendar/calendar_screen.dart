import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:agilizaiapp/models/event_model.dart';
import 'package:agilizaiapp/widgets/event_preview_sheet.dart';
import 'package:agilizaiapp/widgets/event_timeline_tile.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  bool _isLoading = true;
  bool _isCalendarOpen = false;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  Map<DateTime, List<Event>> _events = {};

  @override
  void initState() {
    super.initState();
    _fetchAndGroupEvents();
  }

  Future<void> _fetchAndGroupEvents() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('https://vamos-comemorar-api.onrender.com/api/events'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> eventData = jsonDecode(response.body);
        final Map<DateTime, List<Event>> groupedEvents = {};

        for (var eventJson in eventData) {
          final Event event = Event.fromJson(eventJson);

          if (event.dataDoEvento != null && event.dataDoEvento!.isNotEmpty) {
            try {
              final eventDate = DateTime.parse(event.dataDoEvento!);
              final dateOnly = DateTime.utc(
                eventDate.year,
                eventDate.month,
                eventDate.day,
              );

              if (groupedEvents[dateOnly] == null) {
                groupedEvents[dateOnly] = [];
              }
              groupedEvents[dateOnly]!.add(event);
            } catch (e) {
              print(
                "Formato de data inválido para o evento '${event.nomeDoEvento}': ${event.dataDoEvento}",
              );
            }
          }
        }

        if (mounted) {
          setState(() {
            _events = groupedEvents;
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Falha ao carregar eventos da API');
      }
    } catch (e) {
      print("Erro ao buscar e agrupar eventos: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<Event> _getEventsForDay(DateTime day) {
    DateTime dateOnly = DateTime.utc(day.year, day.month, day.day);
    return _events[dateOnly] ?? [];
  }

  void _showEventPreview(BuildContext context, Event event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (_, controller) {
            // Assumindo que EventPreviewSheet aceita 'event' e 'scrollController'
            // Se não aceitar 'scrollController', você pode removê-lo.
            return EventPreviewSheet(
              event: event,
              scrollController: controller,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventDays = _events.keys.toList()..sort();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: GestureDetector(
          onTap: () {
            setState(() {
              _isCalendarOpen = !_isCalendarOpen;
            });
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Calendário', // Traduzido
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                _isCalendarOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                color: Colors.black,
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isCalendarOpen) _buildCalendarView(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFF26422)),
                  )
                : _events.isEmpty
                    ? const Center(
                        child: Text(
                          "Nenhum evento agendado.",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 10),
                        itemCount: _isCalendarOpen ? 1 : eventDays.length,
                        itemBuilder: (context, index) {
                          final DateTime date =
                              _isCalendarOpen ? _selectedDay : eventDays[index];
                          final List<Event> eventsForDay =
                              _getEventsForDay(date);

                          if (eventsForDay.isEmpty && _isCalendarOpen) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32.0),
                                child: Text(
                                  "Nenhum evento para esta data.",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            );
                          }

                          if (eventsForDay.isEmpty)
                            return const SizedBox.shrink();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDateHeader(date),
                              ...eventsForDay.map((event) {
                                return GestureDetector(
                                  onTap: () =>
                                      _showEventPreview(context, event),
                                  child: EventTimelineTile(event: event),
                                );
                              }).toList(),
                            ],
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarView() {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 10.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Text('Todos os Eventos'), // Traduzido
                      Icon(Icons.arrow_drop_down)
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    /* Navegar para a FilterScreen */
                  },
                  icon: const Icon(Icons.filter_list),
                  label: const Text('Filtrar'), // Traduzido
                  style: TextButton.styleFrom(foregroundColor: Colors.black),
                ),
              ],
            ),
          ),
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: CalendarFormat.month,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: _getEventsForDay,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            headerStyle: const HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: Color(0xFFF26422),
                shape: BoxShape.circle,
              ),
              markerDecoration: const BoxDecoration(
                color: Color(0xFFF26422),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildDateHeader(DateTime date) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
              ],
            ),
            child: Column(
              children: [
                Text(
                  // Garante que o mês seja em português
                  DateFormat.MMM('pt_BR').format(date).toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFFF26422),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  DateFormat.d().format(date),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            // Garante que o dia da semana e o mês sejam em português
            DateFormat('EEEE, d MMMM, y', 'pt_BR').format(date).toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
