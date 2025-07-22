// lib/screens/filter/filter_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Importa o pacote de formatação de data

// --- CLASSE DE FILTROS APRIMORADA ---
// Agora retorna datas concretas para facilitar a busca
class FilterSettings {
  final String category;
  final RangeValues priceRange;
  final DateTime? startDate; // Data de início do filtro
  final DateTime? endDate; // Data de fim do filtro

  FilterSettings({
    required this.category,
    required this.priceRange,
    this.startDate,
    this.endDate,
  });
}

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  // Variáveis de estado
  String _selectedCategory = 'Sports'; // Manter em inglês para lógica interna
  String _selectedTime = 'Tomorrow'; // Manter em inglês para lógica interna
  RangeValues _currentRangeValues = const RangeValues(20, 120);
  DateTime? _selectedDate; // Guarda a data escolhida no calendário

  final List<String> _categories = [
    'Design',
    'Art',
    'Sports',
    'Music'
  ]; // Valores internos
  final List<String> _timeOptions = [
    'Today',
    'Tomorrow',
    'This week'
  ]; // Valores internos

  // Mapeamento para traduzir as categorias para exibição
  final Map<String, String> _translatedCategories = {
    'Design': 'Design',
    'Art': 'Arte',
    'Sports': 'Esportes',
    'Music': 'Música',
  };

  // Mapeamento para traduzir as opções de tempo para exibição
  final Map<String, String> _translatedTimeOptions = {
    'Today': 'Hoje',
    'Tomorrow': 'Amanhã',
    'This week': 'Esta semana',
  };

  // --- LÓGICA DO CALENDÁRIO ---
  Future<void> _openDatePicker() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale:
          const Locale('pt', 'BR'), // Define o local para português do Brasil
      builder: (context, child) {
        // Personaliza a aparência do DatePicker para combinar com o app
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFF26422), // Cor principal
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFF26422),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _selectedTime = ''; // Limpa a seleção de "Hoje", "Amanhã", etc.
      });
    }
  }

  void _resetFilters() {
    setState(() {
      _selectedCategory = 'Sports'; // Volta para o padrão
      _selectedTime = 'Tomorrow'; // Volta para o padrão
      _currentRangeValues = const RangeValues(20, 120); // Volta para o padrão
      _selectedDate = null; // Reseta a data do calendário
    });
  }

  void _applyFilters() {
    DateTime? startDate;
    DateTime? endDate;
    final now = DateTime.now();

    // Converte a seleção de tempo em um intervalo de datas
    if (_selectedDate != null) {
      startDate = _selectedDate;
      // Para o endDate, queremos o final do dia selecionado
      endDate = DateTime(_selectedDate!.year, _selectedDate!.month,
          _selectedDate!.day, 23, 59, 59);
    } else {
      switch (_selectedTime) {
        case 'Today':
          startDate = DateTime(now.year, now.month, now.day);
          endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
          break;
        case 'Tomorrow':
          final tomorrow = now.add(const Duration(days: 1));
          startDate = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
          endDate = DateTime(
            tomorrow.year,
            tomorrow.month,
            tomorrow.day,
            23,
            59,
            59,
          );
          break;
        case 'This week':
          startDate = DateTime(now.year, now.month, now.day);
          // Calcula o fim da semana (domingo, se a semana começar no domingo, ou sábado se começar na segunda)
          // Ajuste conforme a definição de "esta semana" no seu contexto
          endDate = now.add(Duration(
              days: DateTime.daysPerWeek -
                  now.weekday)); // Considerando que a semana termina no dia 7 (domingo)
          endDate = DateTime(endDate.year, endDate.month, endDate.day, 23, 59,
              59); // Garante que é o final do dia
          break;
      }
    }

    final settings = FilterSettings(
      category: _selectedCategory,
      priceRange: _currentRangeValues,
      startDate: startDate,
      endDate: endDate,
    );
    Navigator.of(context).pop(settings);
  }

  @override
  Widget build(BuildContext context) {
    // Formata o texto da data para exibição
    final String calendarButtonText = _selectedDate == null
        ? 'Escolher do calendário' // Traduzido
        : DateFormat('d MMMM, y', 'pt_BR')
            .format(_selectedDate!); // Formato em português

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Filtro', // Traduzido de 'Filter'
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Categoria de Chips
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
                        selected: _selectedCategory == category,
                        onSelected: (isSelected) {
                          if (isSelected) {
                            setState(() {
                              _selectedCategory =
                                  category; // Atualiza com o valor original
                            });
                          }
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Hora e Data', // Traduzido de 'Time and Date'
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Chips de tempo
            Row(
              children: _timeOptions
                  .map(
                    (time) => _buildTimeChip(
                      label: _translatedTimeOptions[
                          time]!, // Usa o valor traduzido para exibir
                      actualValue:
                          time, // Passa o valor original para seleção interna
                      selected: _selectedTime == time,
                      onSelected: (_) {
                        setState(() {
                          _selectedTime = time; // Atualiza com o valor original
                          _selectedDate = null; // Limpa a seleção do calendário
                        });
                      },
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            // Botão do Calendário
            _buildPickerRow(
              icon: Icons.calendar_today_outlined,
              text: calendarButtonText, // Texto dinâmico e traduzido
              onTap: _openDatePicker, // Chama a função do calendário
            ),
            const SizedBox(height: 24),

            const Text(
              'Localização', // Traduzido de 'Location'
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildPickerRow(
              icon: Icons.location_on_outlined,
              text:
                  'Mirpur 10, Dhaka, Bangladesh', // Manter se for um placeholder fixo
              onTap: () {
                print('Abrir seletor de localização clicado');
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Selecionar faixa de preço', // Traduzido de 'Select price range'
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'R\$${_currentRangeValues.start.round()}-R\$${_currentRangeValues.end.round()}', // Traduzido para R$
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF26422),
                  ),
                ),
              ],
            ),
            RangeSlider(
              values: _currentRangeValues,
              min: 0,
              max: 200,
              activeColor: const Color(0xFFF26422),
              inactiveColor: Colors.orange.shade100,
              onChanged: (RangeValues values) {
                setState(() {
                  _currentRangeValues = values;
                });
              },
            ),
            const Spacer(),

            // Botões de Ação
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _resetFilters,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text('REDEFINIR',
                        style: TextStyle(fontSize: 16)), // Traduzido de 'RESET'
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E273A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text('APLICAR',
                        style: TextStyle(fontSize: 16)), // Traduzido de 'APPLY'
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- MÉTODOS AUXILIARES PARA CONSTRUIR A UI ---

  Widget _buildChoiceChip({
    required String label, // Label para exibição
    required String actualValue, // Valor real da categoria
    required bool selected,
    required Function(bool) onSelected,
  }) {
    final icons = {
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: selected ? Colors.transparent : Colors.grey[300]!,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }

  Widget _buildTimeChip({
    required String label, // Label para exibição
    required String actualValue, // Valor real da opção de tempo
    required bool selected,
    required Function(bool) onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label), // Exibe o label traduzido
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
