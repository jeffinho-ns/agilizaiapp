import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:agilizaiapp/models/bar_model.dart';
import 'package:agilizaiapp/services/reservation_service.dart';
import 'package:agilizaiapp/models/birthday_reservation_model.dart';
import 'package:agilizaiapp/screens/location/select_location_screen.dart';

// Modelos para as opções
class DecorationOption {
  final String name;
  final double price;
  final String image;
  final String description;
  const DecorationOption({
    required this.name,
    required this.price,
    required this.image,
    required this.description,
  });
}

class BeverageOption {
  final String name;
  final double price;
  final String category;
  final String description;
  const BeverageOption({
    required this.name,
    required this.price,
    required this.category,
    required this.description,
  });
}

class GiftOption {
  final String name;
  final double price;
  final String category;
  final String image;
  const GiftOption({
    required this.name,
    required this.price,
    required this.category,
    required this.image,
  });
}

class FoodOption {
  final String name;
  final double price;
  final String category;
  final String description;
  const FoodOption({
    required this.name,
    required this.price,
    required this.category,
    required this.description,
  });
}

class BirthdayReservationScreen extends StatefulWidget {
  final Bar? selectedBar;
  const BirthdayReservationScreen({super.key, this.selectedBar});
  @override
  State<BirthdayReservationScreen> createState() =>
      _BirthdayReservationScreenState();
}

class _BirthdayReservationScreenState extends State<BirthdayReservationScreen> {
  late final ReservationService _reservationService;
  final TextEditingController _aniversarianteNomeController =
      TextEditingController();
  final TextEditingController _documentoController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _painelTemaController = TextEditingController();
  final TextEditingController _painelFraseController = TextEditingController();
  DateTime? _selectedBirthdayDate;
  String? _selectedBar;
  int _quantidadeConvidados = 1;

  // Função para mostrar popup de confirmação de aviso
  void _showWarningPopup(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2B3245),
          title: Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFF26422),
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'ENTENDI',
                style: TextStyle(
                  color: Color(0xFFF26422),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

  // Widget para construir avisos clicáveis
  Widget _buildWarningWidget(
      String displayText, String popupTitle, String popupMessage) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: GestureDetector(
        onTap: () => _showWarningPopup(popupTitle, popupMessage),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  displayText,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(
                Icons.touch_app,
                color: Colors.red,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget para construir avisos informativos clicáveis
  Widget _buildInfoWidget(
      String displayText, String popupTitle, String popupMessage) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: GestureDetector(
        onTap: () => _showWarningPopup(popupTitle, popupMessage),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF26422).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFF26422).withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: Color(0xFFF26422),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  displayText,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ),
              const Icon(
                Icons.touch_app,
                color: Color(0xFFF26422),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Decorações com os novos nomes
  List<DecorationOption> _decorationOptions = [
    DecorationOption(
        name: 'Decoração Pequena 1',
        price: 200.0,
        image: 'assets/images/kit-1.jpg',
        description: 'Decoração pequena estilo 1.'),
    DecorationOption(
        name: 'Decoração Pequena 2',
        price: 220.0,
        image: 'assets/images/kit-2.jpg',
        description: 'Decoração pequena estilo 2.'),
    DecorationOption(
        name: 'Decoração Media 3',
        price: 250.0,
        image: 'assets/images/kit-3.jpg',
        description: 'Decoração média estilo 3.'),
    DecorationOption(
        name: 'Decoração Media 4',
        price: 270.0,
        image: 'assets/images/kit-4.jpg',
        description: 'Decoração média estilo 4.'),
    DecorationOption(
        name: 'Decoração Grande 5',
        price: 300.0,
        image: 'assets/images/kit-5.jpg',
        description: 'Decoração grande estilo 5.'),
    DecorationOption(
        name: 'Decoração Grande 6',
        price: 320.0,
        image: 'assets/images/kit-6.jpg',
        description: 'Decoração grande estilo 6.'),
  ];
  DecorationOption? _selectedDecoration;
  String? _selectedPainelOption;
  String? _selectedPainelImage;

  // Painéis do estoque com os novos nomes
  List<String> _painelEstoqueImages = [
    'assets/images/painel-1.jpg',
    'assets/images/painel-2.jpg',
    'assets/images/painel-3.jpg',
    'assets/images/painel-4.jpg',
    'assets/images/painel-5.jpg',
    'assets/images/painel-6.jpg',
    'assets/images/painel-7.jpg',
    'assets/images/painel-8.jpg',
    'assets/images/painel-9.jpg',
    'assets/images/painel-10.jpg',
  ];

  // Bebidas do bar com os novos nomes
  List<BeverageOption> _beverageOptions = [
    BeverageOption(
        name: 'Item-bar-Bebida - 1',
        price: 12.0,
        category: 'Bebida',
        description: 'Bebida do bar item 1.'),
    BeverageOption(
        name: 'Item-bar-Bebida - 2',
        price: 15.0,
        category: 'Bebida',
        description: 'Bebida do bar item 2.'),
    BeverageOption(
        name: 'Item-bar-Bebida - 3',
        price: 18.0,
        category: 'Bebida',
        description: 'Bebida do bar item 3.'),
    BeverageOption(
        name: 'Item-bar-Bebida - 4',
        price: 20.0,
        category: 'Bebida',
        description: 'Bebida do bar item 4.'),
    BeverageOption(
        name: 'Item-bar-Bebida - 5',
        price: 22.0,
        category: 'Bebida',
        description: 'Bebida do bar item 5.'),
    BeverageOption(
        name: 'Item-bar-Bebida - 6',
        price: 25.0,
        category: 'Bebida',
        description: 'Bebida do bar item 6.'),
    BeverageOption(
        name: 'Item-bar-Bebida - 7',
        price: 28.0,
        category: 'Bebida',
        description: 'Bebida do bar item 7.'),
    BeverageOption(
        name: 'Item-bar-Bebida - 8',
        price: 30.0,
        category: 'Bebida',
        description: 'Bebida do bar item 8.'),
    BeverageOption(
        name: 'Item-bar-Bebida - 9',
        price: 35.0,
        category: 'Bebida',
        description: 'Bebida do bar item 9.'),
    BeverageOption(
        name: 'Item-bar-Bebida - 10',
        price: 40.0,
        category: 'Bebida',
        description: 'Bebida do bar item 10.'),
  ];
  Map<String, int> _selectedBeverages = {};
  Map<String, int> _selectedFoods = {};
  List<GiftOption> _selectedGifts = [];
  List<String> _barOptions = [
    'Seu Justino',
    'Oh Fregues',
    'HighLine',
    'Pracinha do Seu Justino'
  ];
  final ScrollController _draggableSheetController = ScrollController();

  // Comidas do bar com os novos nomes
  final List<FoodOption> _foodOptions = [
    FoodOption(
        name: 'Item-bar-Comida - 1',
        price: 25.0,
        category: 'Comida',
        description: 'Comida do bar item 1'),
    FoodOption(
        name: 'Item-bar-Comida - 2',
        price: 28.0,
        category: 'Comida',
        description: 'Comida do bar item 2'),
    FoodOption(
        name: 'Item-bar-Comida - 3',
        price: 30.0,
        category: 'Comida',
        description: 'Comida do bar item 3'),
    FoodOption(
        name: 'Item-bar-Comida - 4',
        price: 32.0,
        category: 'Comida',
        description: 'Comida do bar item 4'),
    FoodOption(
        name: 'Item-bar-Comida - 5',
        price: 35.0,
        category: 'Comida',
        description: 'Comida do bar item 5'),
    FoodOption(
        name: 'Item-bar-Comida - 6',
        price: 38.0,
        category: 'Comida',
        description: 'Comida do bar item 6'),
    FoodOption(
        name: 'Item-bar-Comida - 7',
        price: 40.0,
        category: 'Comida',
        description: 'Comida do bar item 7'),
    FoodOption(
        name: 'Item-bar-Comida - 8',
        price: 42.0,
        category: 'Comida',
        description: 'Comida do bar item 8'),
    FoodOption(
        name: 'Item-bar-Comida - 9',
        price: 45.0,
        category: 'Comida',
        description: 'Comida do bar item 9'),
    FoodOption(
        name: 'Item-bar-Comida - 10',
        price: 48.0,
        category: 'Comida',
        description: 'Comida do bar item 10'),
  ];

  // Lista de presentes com os novos nomes
  final List<GiftOption> _giftOptions = [
    GiftOption(
        name: 'Lista-Presente - 1',
        price: 50.0,
        category: 'Presente',
        image: 'assets/images/prod-1.png'),
    GiftOption(
        name: 'Lista-Presente - 2',
        price: 60.0,
        category: 'Presente',
        image: 'assets/images/prod-2.png'),
    GiftOption(
        name: 'Lista-Presente - 3',
        price: 70.0,
        category: 'Presente',
        image: 'assets/images/prod-3.png'),
    GiftOption(
        name: 'Lista-Presente - 4',
        price: 80.0,
        category: 'Presente',
        image: 'assets/images/prod-4.png'),
    GiftOption(
        name: 'Lista-Presente - 5',
        price: 90.0,
        category: 'Presente',
        image: 'assets/images/prod-5.png'),
    GiftOption(
        name: 'Lista-Presente - 6',
        price: 100.0,
        category: 'Presente',
        image: 'assets/images/prod-6.png'),
    GiftOption(
        name: 'Lista-Presente - 7',
        price: 110.0,
        category: 'Presente',
        image: 'assets/images/prod-7.png'),
    GiftOption(
        name: 'Lista-Presente - 8',
        price: 120.0,
        category: 'Presente',
        image: 'assets/images/prod-8.png'),
    GiftOption(
        name: 'Lista-Presente - 9',
        price: 130.0,
        category: 'Presente',
        image: 'assets/images/prod-9.png'),
    GiftOption(
        name: 'Lista-Presente - 10',
        price: 140.0,
        category: 'Presente',
        image: 'assets/images/prod-10.png'),
    GiftOption(
        name: 'Lista-Presente - 11',
        price: 150.0,
        category: 'Presente',
        image: 'assets/images/prod-11.png'),
    GiftOption(
        name: 'Lista-Presente - 12',
        price: 160.0,
        category: 'Presente',
        image: 'assets/images/prod-12.png'),
    GiftOption(
        name: 'Lista-Presente - 13',
        price: 170.0,
        category: 'Presente',
        image: 'assets/images/prod-13.png'),
    GiftOption(
        name: 'Lista-Presente - 14',
        price: 180.0,
        category: 'Presente',
        image: 'assets/images/prod-14.png'),
    GiftOption(
        name: 'Lista-Presente - 15',
        price: 190.0,
        category: 'Presente',
        image: 'assets/images/prod-5.png'),
    GiftOption(
        name: 'Lista-Presente - 16',
        price: 200.0,
        category: 'Presente',
        image: 'assets/images/prod-1.png'),
    GiftOption(
        name: 'Lista-Presente - 17',
        price: 210.0,
        category: 'Presente',
        image: 'assets/images/prod-2.png'),
    GiftOption(
        name: 'Lista-Presente - 18',
        price: 220.0,
        category: 'Presente',
        image: 'assets/images/prod-3.png'),
    GiftOption(
        name: 'Lista-Presente - 19',
        price: 230.0,
        category: 'Presente',
        image: 'assets/images/prod-4.png'),
    GiftOption(
        name: 'Lista-Presente - 20',
        price: 240.0,
        category: 'Presente',
        image: 'assets/images/prod-5.png'),
  ];
  @override
  void initState() {
    super.initState();
    _draggableSheetController.addListener(() {
      setState(() {});
    });
    _reservationService = ReservationService();
  }

  @override
  void dispose() {
    _aniversarianteNomeController.dispose();
    _documentoController.dispose();
    _whatsappController.dispose();
    _emailController.dispose();
    _painelTemaController.dispose();
    _painelFraseController.dispose();
    _draggableSheetController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthdayDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedBirthdayDate ?? DateTime.now().add(const Duration(days: 5)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      locale: const Locale('pt', 'BR'),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFF26422),
              onPrimary: Colors.white,
              surface: Color(0xFF242A38),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF2B3245),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedBirthdayDate) {
      setState(() {
        _selectedBirthdayDate = picked;
      });
    }
  }

  bool _isPersonalizedPanelAllowed() {
    if (_selectedPainelOption == 'personalizado' &&
        _selectedBirthdayDate != null) {
      final DateTime now = DateTime.now();
      final difference = _selectedBirthdayDate!.difference(now).inDays;
      return difference >= 5;
    }
    return true;
  }

  void _showConfirmationSummary() {
    final screenContext = context;
    showDialog(
      context: screenContext,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2B3245),
          title: const Text('Confirmar Reserva de Aniversário',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text('📋 DADOS DO ANIVERSARIANTE',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                const SizedBox(height: 8),
                Text('Nome: ${_aniversarianteNomeController.text}',
                    style: const TextStyle(color: Colors.white70)),
                Text('Documento: ${_documentoController.text}',
                    style: const TextStyle(color: Colors.white70)),
                Text('WhatsApp: ${_whatsappController.text}',
                    style: const TextStyle(color: Colors.white70)),
                Text('E-mail: ${_emailController.text}',
                    style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 12),
                const Text('🎉 DETALHES DA FESTA',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                const SizedBox(height: 8),
                Text('Bar: ${_selectedBar ?? 'Não selecionado'}',
                    style: const TextStyle(color: Colors.white70)),
                Text(
                    'Data: ${_selectedBirthdayDate != null ? DateFormat('dd/MM/yyyy').format(_selectedBirthdayDate!) : 'Não selecionada'}',
                    style: const TextStyle(color: Colors.white70)),
                Text('Convidados: $_quantidadeConvidados pessoas',
                    style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 12),
                const SizedBox(height: 12),
                const Text('🎨 DECORAÇÃO',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                const SizedBox(height: 8),
                if (_selectedDecoration != null)
                  Text(
                      '${_selectedDecoration!.name} - R\$ ${_selectedDecoration!.price.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white70))
                else
                  Text('Nenhuma decoração selecionada',
                      style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 8),
                const Text('🖼️ PAINEL',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                const SizedBox(height: 8),
                if (_selectedPainelOption == 'estoque') ...[
                  const Text('Painel de Estoque: Selecionado',
                      style: TextStyle(color: Colors.white70)),
                  if (_selectedPainelImage != null)
                    Text('Painel: $_selectedPainelImage',
                        style: const TextStyle(color: Colors.white70)),
                ] else if (_selectedPainelOption == 'personalizado') ...[
                  const Text('Painel Personalizado: Sim',
                      style: TextStyle(color: Colors.white70)),
                  Text('Tema escolhido: ${_painelTemaController.text}',
                      style: const TextStyle(color: Colors.white70)),
                  Text('Frase personalizada: ${_painelFraseController.text}',
                      style: const TextStyle(color: Colors.white70)),
                ] else ...[
                  const Text('Nenhum painel selecionado',
                      style: TextStyle(color: Colors.grey)),
                ],
                const SizedBox(height: 12),
                const Text('🥂 BEBIDAS',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                const SizedBox(height: 8),
                if (_selectedBeverages.isNotEmpty)
                  ..._selectedBeverages.entries.map((entry) {
                    final beverage =
                        _beverageOptions.firstWhere((b) => b.name == entry.key);
                    return Text(
                        '${entry.key}: ${entry.value}x - R\$ ${(beverage.price * entry.value).toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.white70));
                  })
                else
                  const Text('Nenhuma bebida selecionada',
                      style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 12),
                const Text('🍽️ COMIDAS',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                const SizedBox(height: 8),
                if (_selectedFoods.isNotEmpty)
                  ..._selectedFoods.entries.map((entry) {
                    final food =
                        _foodOptions.firstWhere((f) => f.name == entry.key);
                    return Text(
                        '${entry.key}: ${entry.value}x - R\$ ${(food.price * entry.value).toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.white70));
                  })
                else
                  const Text('Nenhuma comida selecionada',
                      style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 12),
                const Text('🎁 LISTA DE PRESENTES',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                const SizedBox(height: 8),
                if (_selectedGifts.isNotEmpty)
                  ..._selectedGifts.map((gift) => Text(
                      '${gift.name} - R\$ ${gift.price.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white70)))
                else
                  const Text('Nenhum presente selecionado',
                      style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF26422).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFF26422)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '💰 VALOR TOTAL DA RESERVA',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'R\$ ' +
                            (() {
                              double total = 0.0;
                              if (_selectedDecoration != null) {
                                total += _selectedDecoration!.price;
                              }
                              for (var entry in _selectedBeverages.entries) {
                                final beverage = _beverageOptions
                                    .firstWhere((b) => b.name == entry.key);
                                total += beverage.price * entry.value;
                              }
                              for (var entry in _selectedFoods.entries) {
                                final food = _foodOptions
                                    .firstWhere((f) => f.name == entry.key);
                                total += food.price * entry.value;
                              }
                              return total.toStringAsFixed(2);
                            })(),
                        style: const TextStyle(
                          color: Color(0xFFF26422),
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Este valor será adicionado à sua comanda no bar selecionado.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancelar',
                  style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                showDialog(
                  context: screenContext,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                );
                try {
                  // Exemplo de como obter o ID do usuário
                  final int loggedInUserId =
                      1; // Substitua com a sua lógica real

                  if (_selectedBar == null ||
                      _selectedBirthdayDate == null ||
                      _selectedDecoration == null) {
                    // Tratar caso em que dados obrigatórios estão ausentes
                    return;
                  }

                  // Mapear bebidas selecionadas para os novos campos
                  final Map<String, int> bebidasMap = {
                    'Item-bar-Bebida - 1': 0,
                    'Item-bar-Bebida - 2': 0,
                    'Item-bar-Bebida - 3': 0,
                    'Item-bar-Bebida - 4': 0,
                    'Item-bar-Bebida - 5': 0,
                    'Item-bar-Bebida - 6': 0,
                    'Item-bar-Bebida - 7': 0,
                    'Item-bar-Bebida - 8': 0,
                    'Item-bar-Bebida - 9': 0,
                    'Item-bar-Bebida - 10': 0,
                  };

                  // Mapear comidas selecionadas para os novos campos
                  final Map<String, int> comidasMap = {
                    'Item-bar-Comida - 1': 0,
                    'Item-bar-Comida - 2': 0,
                    'Item-bar-Comida - 3': 0,
                    'Item-bar-Comida - 4': 0,
                    'Item-bar-Comida - 5': 0,
                    'Item-bar-Comida - 6': 0,
                    'Item-bar-Comida - 7': 0,
                    'Item-bar-Comida - 8': 0,
                    'Item-bar-Comida - 9': 0,
                    'Item-bar-Comida - 10': 0,
                  };

                  // Preencher bebidas selecionadas
                  for (var entry in _selectedBeverages.entries) {
                    if (bebidasMap.containsKey(entry.key)) {
                      bebidasMap[entry.key] = entry.value;
                    }
                  }

                  // Preencher comidas selecionadas
                  for (var entry in _selectedFoods.entries) {
                    if (comidasMap.containsKey(entry.key)) {
                      comidasMap[entry.key] = entry.value;
                    }
                  }

                  // Lista de presentes selecionados
                  final List<String> presentesSelecionados =
                      _selectedGifts.map((gift) => gift.name).toList();

                  final reservationData = BirthdayReservationModel(
                    userId: loggedInUserId,
                    aniversarianteNome: _aniversarianteNomeController.text,
                    dataAniversario: _selectedBirthdayDate!,
                    quantidadeConvidados: _quantidadeConvidados,
                    barSelecionado: _selectedBar,
                    decoracaoTipo: _selectedDecoration?.name,
                    painelPersonalizado:
                        _selectedPainelOption == 'personalizado',
                    painelTema: _selectedPainelOption == 'personalizado'
                        ? _painelTemaController.text
                        : null,
                    painelFrase: _selectedPainelOption == 'personalizado'
                        ? _painelFraseController.text
                        : null,
                    painelEstoqueImagemUrl: _selectedPainelOption == 'estoque'
                        ? _selectedPainelImage
                        : null,
                    itemBarBebida1: bebidasMap['Item-bar-Bebida - 1'] ?? 0,
                    itemBarBebida2: bebidasMap['Item-bar-Bebida - 2'] ?? 0,
                    itemBarBebida3: bebidasMap['Item-bar-Bebida - 3'] ?? 0,
                    itemBarBebida4: bebidasMap['Item-bar-Bebida - 4'] ?? 0,
                    itemBarBebida5: bebidasMap['Item-bar-Bebida - 5'] ?? 0,
                    itemBarBebida6: bebidasMap['Item-bar-Bebida - 6'] ?? 0,
                    itemBarBebida7: bebidasMap['Item-bar-Bebida - 7'] ?? 0,
                    itemBarBebida8: bebidasMap['Item-bar-Bebida - 8'] ?? 0,
                    itemBarBebida9: bebidasMap['Item-bar-Bebida - 9'] ?? 0,
                    itemBarBebida10: bebidasMap['Item-bar-Bebida - 10'] ?? 0,
                    itemBarComida1: comidasMap['Item-bar-Comida - 1'] ?? 0,
                    itemBarComida2: comidasMap['Item-bar-Comida - 2'] ?? 0,
                    itemBarComida3: comidasMap['Item-bar-Comida - 3'] ?? 0,
                    itemBarComida4: comidasMap['Item-bar-Comida - 4'] ?? 0,
                    itemBarComida5: comidasMap['Item-bar-Comida - 5'] ?? 0,
                    itemBarComida6: comidasMap['Item-bar-Comida - 6'] ?? 0,
                    itemBarComida7: comidasMap['Item-bar-Comida - 7'] ?? 0,
                    itemBarComida8: comidasMap['Item-bar-Comida - 8'] ?? 0,
                    itemBarComida9: comidasMap['Item-bar-Comida - 9'] ?? 0,
                    itemBarComida10: comidasMap['Item-bar-Comida - 10'] ?? 0,
                    listaPresentes: presentesSelecionados,
                    documento: _documentoController.text,
                    whatsapp: _whatsappController.text,
                    email: _emailController.text,
                  );

                  final result = await _reservationService
                      .createBirthdayReservation(reservationData.toJson());

                  if (screenContext.mounted) {
                    Navigator.pop(screenContext);
                  }
                  if (screenContext.mounted) {
                    ScaffoldMessenger.of(screenContext).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Reserva de aniversário criada com sucesso! ID: ${result['id']}'),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 5),
                      ),
                    );
                  }
                  if (screenContext.mounted && result['id'] != null) {
                    Navigator.of(screenContext).pushReplacementNamed(
                      '/reservation-details',
                      arguments: {'reservationId': result['id']},
                    );
                  }
                } catch (e) {
                  if (screenContext.mounted) {
                    Navigator.pop(screenContext);
                  }
                  if (screenContext.mounted) {
                    ScaffoldMessenger.of(screenContext).showSnackBar(
                      SnackBar(
                        content: Text('Erro ao criar reserva: ${e.toString()}'),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 5),
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF26422),
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF242A38),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 180,
              child: Stack(
                children: [
                  Image.asset(
                    'assets/images/niver.jpeg',
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    width: double.infinity,
                    height: 180,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.4),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.7,
            maxChildSize: 0.98,
            builder: (context, scrollController) {
              return SingleChildScrollView(
                controller: scrollController,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDarkTextField(
                        controller: _aniversarianteNomeController,
                        labelText: 'Nome do aniversariante',
                        icon: Icons.person,
                        validator: (value) => null,
                      ),
                      const SizedBox(height: 15),
                      _buildDarkTextField(
                        controller: _documentoController,
                        labelText: 'Documento',
                        icon: Icons.badge,
                        validator: (value) => null,
                      ),
                      const SizedBox(height: 15),
                      _buildDarkTextField(
                        controller: _whatsappController,
                        labelText: 'WhatsApp',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator: (value) => null,
                      ),
                      const SizedBox(height: 15),
                      _buildDarkTextField(
                        controller: _emailController,
                        labelText: 'E-mail',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) => null,
                      ),
                      const SizedBox(height: 15),
                      _buildDarkDateField(
                        controller: TextEditingController(
                          text: _selectedBirthdayDate != null
                              ? DateFormat('dd/MM/yyyy')
                                  .format(_selectedBirthdayDate!)
                              : '',
                        ),
                        labelText: 'Data do aniversário',
                        onTap: () => _selectBirthdayDate(context),
                        validator: (value) => null,
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedBar,
                              decoration: const InputDecoration(
                                labelText: 'Bar',
                                prefixIcon:
                                    Icon(Icons.store, color: Colors.white70),
                                filled: true,
                                fillColor: Color(0xFF333A4D),
                                labelStyle: TextStyle(color: Colors.white70),
                                border: OutlineInputBorder(),
                              ),
                              dropdownColor: const Color(0xFF333A4D),
                              style: const TextStyle(color: Colors.white),
                              items: _barOptions
                                  .map((bar) => DropdownMenuItem(
                                        value: bar,
                                        child: Text(bar),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedBar = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            height: 56,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF26422),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const SelectLocationScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.location_on,
                                color: Colors.white,
                                size: 24,
                              ),
                              tooltip: 'Ver localização dos bares',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          const Text('Convidados:',
                              style: TextStyle(color: Colors.white70)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Slider(
                              value: _quantidadeConvidados.toDouble(),
                              min: 1,
                              max: 50,
                              divisions: 49,
                              label: _quantidadeConvidados.toString(),
                              onChanged: (value) {
                                setState(() {
                                  _quantidadeConvidados = value.toInt();
                                });
                              },
                            ),
                          ),
                          Text('$_quantidadeConvidados',
                              style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Text(
                        'Escolha sua Decoração ✨',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                      ),
                      const SizedBox(height: 10),
                      _buildInfoWidget(
                        '💡 A decoração é um aluguel, não pode levar os painéis e bandejas para casa apenas os brindes que estiverem. O valor de cada opção está em cada card e será adicionado à sua comanda.',
                        'Informação sobre Decoração',
                        'A decoração é um aluguel, não pode levar os painéis e bandejas para casa apenas os brindes que estiverem. O valor de cada opção está em cada card e será adicionado à sua comanda.',
                      ),
                      const SizedBox(height: 15),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: _decorationOptions.length,
                        itemBuilder: (context, index) {
                          final option = _decorationOptions[index];
                          final isSelected = _selectedDecoration == option;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedDecoration = option;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF333A4D),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFFF26422)
                                      : Colors.transparent,
                                  width: isSelected ? 3 : 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(12)),
                                      child: Image.asset(
                                        option.image,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error,
                                                stackTrace) =>
                                            const Center(
                                                child: Icon(Icons.broken_image,
                                                    color: Colors.white70)),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Text(
                                          option.name,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: isSelected
                                                ? const Color(0xFFF26422)
                                                : Colors.white,
                                          ),
                                        ),
                                        Text(
                                          'R\$ ${option.price.toStringAsFixed(2)}',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: isSelected
                                                ? const Color(0xFFF26422)
                                                : const Color(0xFFF26422),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 30),
                      Text(
                        'Seu Painel Personalizado ou do Estoque?',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                      ),
                      const SizedBox(height: 10),
                      _buildInfoWidget(
                        '💡 Tanto o painel que temos no estoque quanto os personalizados não tem valor adicional pois já está incluso o valor na decoração. Para painéis personalizados, você informa o tema e a frase que deseja.',
                        'Informação sobre Painéis',
                        'Tanto o painel que temos no estoque quanto os personalizados não tem valor adicional pois já está incluso o valor na decoração. Para painéis personalizados, você informa o tema e a frase que deseja.',
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Painel do Estoque',
                                  style: TextStyle(color: Colors.white70)),
                              value: 'estoque',
                              groupValue: _selectedPainelOption,
                              activeColor: const Color(0xFFF26422),
                              tileColor: const Color(0xFF333A4D),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              onChanged: (value) {
                                setState(() {
                                  _selectedPainelOption = value;
                                  _painelTemaController.clear();
                                  _painelFraseController.clear();
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Painel Personalizado',
                                  style: TextStyle(color: Colors.white70)),
                              value: 'personalizado',
                              groupValue: _selectedPainelOption,
                              activeColor: const Color(0xFFF26422),
                              tileColor: const Color(0xFF333A4D),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              onChanged: (value) {
                                setState(() {
                                  _selectedPainelOption = value;
                                  _selectedPainelImage = null;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (_selectedPainelOption == 'estoque') ...[
                        Text(
                          'Escolha um painel do nosso estoque:',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(color: Colors.white70),
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          height: 280,
                          child: PageView.builder(
                            controller: PageController(viewportFraction: 0.8),
                            itemCount: _painelEstoqueImages.length,
                            itemBuilder: (context, index) {
                              final painelImagePath =
                                  _painelEstoqueImages[index];
                              final painelNome = 'Estoque ${index + 1}';
                              final isSelected =
                                  _selectedPainelImage == painelImagePath;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedPainelImage = painelImagePath;
                                  });
                                },
                                child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 15,
                                        offset: const Offset(0, 8),
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    children: [
                                      // Imagem do painel (redonda)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Image.asset(
                                          painelImagePath,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Container(
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF333A4D),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Center(
                                              child: Icon(
                                                Icons.image,
                                                color: Colors.white70,
                                                size: 60,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Overlay gradiente para melhorar legibilidade do texto
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              Colors.black.withOpacity(0.7),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // Indicador de seleção
                                      if (isSelected)
                                        Positioned(
                                          top: 12,
                                          right: 12,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF26422),
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(0xFFF26422)
                                                      .withOpacity(0.5),
                                                  blurRadius: 8,
                                                  spreadRadius: 2,
                                                ),
                                              ],
                                            ),
                                            child: const Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      // Nome do painel
                                      Positioned(
                                        bottom: 20,
                                        left: 20,
                                        right: 20,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.black.withOpacity(0.8),
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            border: Border.all(
                                              color: isSelected
                                                  ? const Color(0xFFF26422)
                                                  : Colors.white
                                                      .withOpacity(0.3),
                                              width: isSelected ? 2 : 1,
                                            ),
                                          ),
                                          child: Text(
                                            painelNome,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: isSelected
                                                  ? const Color(0xFFF26422)
                                                  : Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Indicadores de página
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _painelEstoqueImages.length,
                            (index) => Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _selectedPainelImage ==
                                        _painelEstoqueImages[index]
                                    ? const Color(0xFFF26422)
                                    : Colors.white.withOpacity(0.3),
                              ),
                            ),
                          ),
                        ),
                      ],
                      if (_selectedPainelOption == 'personalizado') ...[
                        const SizedBox(height: 20),
                        if (!_isPersonalizedPanelAllowed())
                          _buildWarningWidget(
                            'Atenção: Painel personalizado só pode ser solicitado com no mínimo 5 dias de antecedência da data do aniversário.',
                            'Atenção',
                            'Painel personalizado só pode ser solicitado com no mínimo 5 dias de antecedência da data do aniversário.',
                          ),
                        _buildDarkTextField(
                          controller: _painelTemaController,
                          labelText:
                              'Qual o tema do painel? (ex: Super Heróis, Princesas, etc.)',
                          icon: Icons.palette,
                          validator: (value) => null,
                        ),
                        const SizedBox(height: 15),
                        _buildDarkTextField(
                          controller: _painelFraseController,
                          labelText:
                              'Frase que você quer no painel (ex: "Feliz Aniversário João!")',
                          icon: Icons.text_fields,
                          maxLines: 3,
                          validator: (value) => null,
                        ),
                      ],
                      const SizedBox(height: 30),
                      Text(
                        'Adicionar Bebidas 🥂',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                      ),
                      const SizedBox(height: 10),
                      _buildInfoWidget(
                        '💡 Cada bebida que for adicionada será acrescentada o valor na comanda de quem está criando essa lista.',
                        'Informação sobre Bebidas',
                        'Cada bebida que for adicionada será acrescentada o valor na comanda de quem está criando essa lista.',
                      ),
                      const SizedBox(height: 15),
                      ..._beverageOptions
                          .map((beverage) => _buildItemQuantitySelector(
                                item: beverage,
                                selectedItems: _selectedBeverages,
                                onChanged: (name, quantity) {
                                  setState(() {
                                    if (quantity > 0) {
                                      _selectedBeverages[name] = quantity;
                                    } else {
                                      _selectedBeverages.remove(name);
                                    }
                                  });
                                },
                              )),
                      const SizedBox(height: 30),
                      Text(
                        'Adicionar Porções 🍽️',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                      ),
                      const SizedBox(height: 10),
                      _buildInfoWidget(
                        '💡 Lembre que cada porção será acrescentada na comanda.',
                        'Informação sobre Porções',
                        'Lembre que cada porção será acrescentada na comanda.',
                      ),
                      const SizedBox(height: 15),
                      ..._foodOptions.map((food) => _buildItemQuantitySelector(
                            item: food,
                            selectedItems: _selectedFoods,
                            onChanged: (name, quantity) {
                              setState(() {
                                if (quantity > 0) {
                                  _selectedFoods[name] = quantity;
                                } else {
                                  _selectedFoods.remove(name);
                                }
                              });
                            },
                          )),
                      const SizedBox(height: 30),
                      Text(
                        'Lista de Presentes 🎁',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                      ),
                      const SizedBox(height: 10),
                      _buildInfoWidget(
                        '💡 Escolha até 20 itens que você gostaria de receber como presente dos seus convidados.',
                        'Informação sobre Lista de Presentes',
                        'Escolha até 20 itens que você gostaria de receber como presente dos seus convidados.',
                      ),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: _giftOptions.length,
                        itemBuilder: (context, index) {
                          final gift = _giftOptions[index];
                          final isSelected = _selectedGifts.contains(gift);
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedGifts.remove(gift);
                                } else if (_selectedGifts.length < 20) {
                                  _selectedGifts.add(gift);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Máximo de 20 presentes selecionados'),
                                    ),
                                  );
                                }
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF333A4D),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFFF26422)
                                      : Colors.transparent,
                                  width: isSelected ? 3 : 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(12)),
                                      child: Image.asset(
                                        gift.image,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error,
                                                stackTrace) =>
                                            const Center(
                                                child: Icon(Icons.broken_image,
                                                    color: Colors.white70)),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Text(
                                          gift.name,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: isSelected
                                                ? const Color(0xFFF26422)
                                                : Colors.white,
                                          ),
                                        ),
                                        Text(
                                          'R\$ ${gift.price.toStringAsFixed(2)}',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                            color: isSelected
                                                ? const Color(0xFFF26422)
                                                : const Color(0xFFF26422),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 30),
                      _buildTotalValueSection(),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            _showConfirmationSummary();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF26422),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'CONFIRMAR RESERVA',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: const Text(
                'Reserve seu Aniversário 🎉',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDarkTextField({
    required TextEditingController controller,
    required String labelText,
    IconData? icon,
    int? maxLines = 1,
    bool obscureText = false,
    TextInputType? keyboardType,
    FormFieldValidator<String>? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF26422), width: 2),
        ),
        filled: true,
        fillColor: const Color(0xFF333A4D),
        prefixIcon: icon != null ? Icon(icon, color: Colors.white70) : null,
        errorStyle: const TextStyle(color: Colors.redAccent),
      ),
      validator: validator,
    );
  }

  Widget _buildDarkDateField({
    required TextEditingController controller,
    required String labelText,
    required VoidCallback onTap,
    FormFieldValidator<String>? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF26422), width: 2),
        ),
        filled: true,
        fillColor: const Color(0xFF333A4D),
        prefixIcon:
            const Icon(Icons.calendar_today_outlined, color: Colors.white70),
        errorStyle: const TextStyle(color: Colors.redAccent),
      ),
      validator: validator,
    );
  }

  Widget _buildItemQuantitySelector({
    required dynamic item,
    required Map<String, int> selectedItems,
    required Function(String, int) onChanged,
  }) {
    final name = item.name;
    final price = item.price;
    final quantity = selectedItems[name] ?? 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF333A4D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w500),
                ),
                Text(
                  'R\$ ${price.toStringAsFixed(2)}',
                  style: const TextStyle(
                      color: const Color(0xFFF26422), fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon:
                const Icon(Icons.remove_circle_outline, color: Colors.white70),
            onPressed:
                quantity > 0 ? () => onChanged(name, quantity - 1) : null,
          ),
          Container(
            width: 30,
            alignment: Alignment.center,
            child: Text(
              '$quantity',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.white70),
            onPressed: () => onChanged(name, quantity + 1),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalValueSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF26422).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF26422)),
      ),
      child: Column(
        children: [
          const Text(
            '💰 VALOR TOTAL DA RESERVA',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'R\$ ' +
                (() {
                  double total = 0.0;
                  if (_selectedDecoration != null) {
                    total += _selectedDecoration!.price;
                  }
                  for (var entry in _selectedBeverages.entries) {
                    final beverage =
                        _beverageOptions.firstWhere((b) => b.name == entry.key);
                    total += beverage.price * entry.value;
                  }
                  for (var entry in _selectedFoods.entries) {
                    final food =
                        _foodOptions.firstWhere((f) => f.name == entry.key);
                    total += food.price * entry.value;
                  }
                  return total.toStringAsFixed(2);
                })(),
            style: const TextStyle(
              color: Color(0xFFF26422),
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Este valor será adicionado à sua comanda no bar selecionado.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
