import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:agilizaiapp/models/bar_model.dart';
import 'package:agilizaiapp/services/birthday_reservation_service.dart';

// Modelos para os novos campos
class DecorationOption {
  final String name;
  final double price;
  final String image;
  final String description;

  DecorationOption({
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

  BeverageOption({
    required this.name,
    required this.price,
    required this.category,
    required this.description,
  });
}

class FoodOption {
  final String name;
  final double price;
  final String category;
  final String description;

  FoodOption({
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

  GiftOption({
    required this.name,
    required this.price,
    required this.category,
    required this.image,
  });
}

// ✨ CORREÇÃO: Certifique-se de que estas importações NÃO estejam ativas se você não usa o mapa diretamente nesta tela
// O erro anterior era devido a 'Maps_flutter' no lugar de 'Maps_flutter'
// Para esta tela, como ela não usa o mapa diretamente, é melhor deixá-las COMENTADAS
// ou REMOVIDAS para evitar erros e manter o código limpo.
// import 'package:Maps_flutter/Maps_flutter.dart';
// import 'package:geocoding/geocoding.dart';

class BirthdayReservationScreen extends StatefulWidget {
  final Bar? selectedBar;
  const BirthdayReservationScreen({super.key, this.selectedBar});

  @override
  State<BirthdayReservationScreen> createState() =>
      _BirthdayReservationScreenState();
}

class _BirthdayReservationScreenState extends State<BirthdayReservationScreen> {
  final _aniversarianteNomeController = TextEditingController();
  final _documentoController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _emailController = TextEditingController();
  final _painelTemaController = TextEditingController();
  final _painelFraseController = TextEditingController();

  final DraggableScrollableController _draggableSheetController =
      DraggableScrollableController();

  final BirthdayReservationService _birthdayService =
      BirthdayReservationService();

  int _quantidadeConvidados = 1;
  String? _selectedBar;
  DateTime? _selectedBirthdayDate;

  // Decoração
  DecorationOption? _selectedDecoration;
  String? _selectedPainelOption; // 'estoque' ou 'personalizado'
  String? _selectedPainelImage;

  // Bebidas e comidas
  Map<String, int> _selectedBeverages = {};
  Map<String, int> _selectedFoods = {};

  // Presentes
  List<GiftOption> _selectedGifts = [];

  // Lista de bares
  final List<String> _bars = [
    'Justino',
    'Pracinha',
    'Oh Fregês',
    'Higline',
    'Reserva Rooftop'
  ];

  // Opções de decoração com preços
  final List<DecorationOption> _decorationOptions = [
    DecorationOption(
      name: 'Opção 1',
      price: 150.0,
      image: 'assets/images/kit-1.jpg',
      description: 'Painel e um balão simples',
    ),
    DecorationOption(
      name: 'Opção 2',
      price: 180.0,
      image: 'assets/images/kit-2.jpg',
      description: 'Painel um balão e duas bandejas',
    ),
    DecorationOption(
      name: 'Opção 3',
      price: 220.0,
      image: 'assets/images/kit-3.jpg',
      description: 'Painel três bandejas e arco de balões',
    ),
    DecorationOption(
      name: 'Opção 4',
      price: 550.0,
      image: 'assets/images/kit-4.jpg',
      description: 'Painel três bandejas, arco de balões e bolo',
    ),
    DecorationOption(
      name: 'Opção 5',
      price: 650.0,
      image: 'assets/images/kit-5.jpg',
      description: 'Painel três bandejas, arco de balões + Combo Gin142',
    ),
    DecorationOption(
      name: 'Opção 6',
      price: 800.0,
      image: 'assets/images/kit-6.jpg',
      description: 'Painel três bandejas, arco de balões, bolo + Combo Gin142',
    ),
  ];

  // Opções de bebidas
  final List<BeverageOption> _beverageOptions = [
    // Cervejas
    BeverageOption(
        name: 'Balde Budweiser (5 und)',
        price: 45.0,
        category: 'Cervejas',
        description: '5 cervejas Budweiser'),
    BeverageOption(
        name: 'Balde Corona (5 und)',
        price: 50.0,
        category: 'Cervejas',
        description: '5 cervejas Corona'),
    BeverageOption(
        name: 'Balde Heineken (5 und)',
        price: 55.0,
        category: 'Cervejas',
        description: '5 cervejas Heineken'),
    BeverageOption(
        name: 'Balde Stella Artois (5 und)',
        price: 60.0,
        category: 'Cervejas',
        description: '5 cervejas Stella'),

    // Drinks
    BeverageOption(
        name: 'Caipirinha',
        price: 18.0,
        category: 'Drinks',
        description: 'Caipirinha tradicional'),
    BeverageOption(
        name: 'Mojito',
        price: 22.0,
        category: 'Drinks',
        description: 'Mojito com hortelã'),
    BeverageOption(
        name: 'Margarita',
        price: 25.0,
        category: 'Drinks',
        description: 'Margarita clássica'),
    BeverageOption(
        name: 'Negroni',
        price: 28.0,
        category: 'Drinks',
        description: 'Negroni italiano'),
    BeverageOption(
        name: 'Gin Tônica',
        price: 20.0,
        category: 'Drinks',
        description: 'Gin com tônica'),
    BeverageOption(
        name: 'Whisky Cola',
        price: 18.0,
        category: 'Drinks',
        description: 'Whisky com Coca-Cola'),

    // Outros
    BeverageOption(
        name: 'Água (500ml)',
        price: 5.0,
        category: 'Outros',
        description: 'Água mineral'),
    BeverageOption(
        name: 'Refrigerante (350ml)',
        price: 8.0,
        category: 'Outros',
        description: 'Coca-Cola, Sprite, Fanta'),
    BeverageOption(
        name: 'Suco Natural',
        price: 12.0,
        category: 'Outros',
        description: 'Suco de laranja ou limão'),
    BeverageOption(
        name: 'Combo Gin 142 (5 Red Bull)',
        price: 120.0,
        category: 'Outros',
        description: 'Gin 142 com 5 Red Bull'),
    BeverageOption(
        name: 'Garrafa Licor Rufus Caramel',
        price: 85.0,
        category: 'Outros',
        description: 'Licor Rufus Caramel 750ml'),
  ];

  // Opções de comida
  final List<FoodOption> _foodOptions = [
    // Porções
    FoodOption(
        name: 'Batata Frita',
        price: 25.0,
        category: 'Porções',
        description: 'Batata frita crocante'),
    FoodOption(
        name: 'Batata Rústica',
        price: 28.0,
        category: 'Porções',
        description: 'Batata rústica temperada'),
    FoodOption(
        name: 'Onion Rings',
        price: 22.0,
        category: 'Porções',
        description: 'Anéis de cebola empanados'),
    FoodOption(
        name: 'Nuggets de Frango',
        price: 30.0,
        category: 'Porções',
        description: 'Nuggets de frango (10 und)'),
    FoodOption(
        name: 'Camarão Empanado',
        price: 45.0,
        category: 'Porções',
        description: 'Camarão empanado (8 und)'),
    FoodOption(
        name: 'Coxinha de Frango',
        price: 8.0,
        category: 'Porções',
        description: 'Coxinha de frango (1 und)'),
    FoodOption(
        name: 'Pastel de Queijo',
        price: 6.0,
        category: 'Porções',
        description: 'Pastel de queijo (1 und)'),
    FoodOption(
        name: 'Esfiha de Carne',
        price: 7.0,
        category: 'Porções',
        description: 'Esfiha de carne (1 und)'),

    // Sanduíches
    FoodOption(
        name: 'X-Burger',
        price: 35.0,
        category: 'Sanduíches',
        description: 'Hambúrguer com queijo e salada'),
    FoodOption(
        name: 'X-Bacon',
        price: 40.0,
        category: 'Sanduíches',
        description: 'Hambúrguer com bacon e queijo'),
    FoodOption(
        name: 'X-Tudo',
        price: 45.0,
        category: 'Sanduíches',
        description: 'Hambúrguer completo'),
    FoodOption(
        name: 'Sanduíche Natural',
        price: 20.0,
        category: 'Sanduíches',
        description: 'Sanduíche natural de frango'),
  ];

  // Opções de presentes
  final List<GiftOption> _giftOptions = [
    // Produtos do bar
    GiftOption(
        name: 'Kit Whisky',
        price: 150.0,
        category: 'Bebidas',
        image: 'assets/images/prod-1.png'),
    GiftOption(
        name: 'Kit Whisky',
        price: 150.0,
        category: 'Bebidas',
        image: 'assets/images/prod-2.png'),
    GiftOption(
        name: 'Kit Gin',
        price: 120.0,
        category: 'Bebidas',
        image: 'assets/images/prod-3.png'),
    GiftOption(
        name: 'Kit Vodka',
        price: 80.0,
        category: 'Bebidas',
        image: 'assets/images/prod-4.png'),
    GiftOption(
        name: 'Kit Cervejas Especiais',
        price: 60.0,
        category: 'Bebidas',
        image: 'assets/images/prod-5.png'),

    // Produtos promocionais
    GiftOption(
        name: 'Caneca Personalizada',
        price: 25.0,
        category: 'Promocional',
        image: 'assets/images/prod-6.png'),
    GiftOption(
        name: 'Camiseta do Bar',
        price: 35.0,
        category: 'Promocional',
        image: 'assets/images/prod-7.png'),
    GiftOption(
        name: 'Porta Retrato',
        price: 20.0,
        category: 'Promocional',
        image: 'assets/images/prod-8.png'),
    GiftOption(
        name: 'Garrafa Térmica',
        price: 45.0,
        category: 'Promocional',
        image: 'assets/images/prod-9.png'),
    GiftOption(
        name: 'Kit Copos',
        price: 30.0,
        category: 'Promocional',
        image: 'assets/images/prod-10.png'),
    GiftOption(
        name: 'Boné do Bar',
        price: 25.0,
        category: 'Promocional',
        image: 'assets/images/prod-11.png'),

    // Produtos do cardápio
    GiftOption(
        name: 'Vale Comida (R\$ 50)',
        price: 50.0,
        category: 'Vale',
        image: 'assets/images/prod-12.png'),
    GiftOption(
        name: 'Vale Bebida (R\$ 30)',
        price: 30.0,
        category: 'Vale',
        image: 'assets/images/prod-13.png'),
    GiftOption(
        name: 'Vale Combo (R\$ 80)',
        price: 80.0,
        category: 'Vale',
        image: 'assets/images/prod-14.png'),
  ];

  // Opções de Painel do Estoque (com imagens mockadas)
  final List<String> _painelEstoqueImages = [
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

  // Lista de posições e tamanhos para os confetes para o efeito de paralaxe
  final List<Map<String, double>> _confetti = List.generate(
    20, // Número de confetes
    (index) => {
      'left': Random().nextDouble() * 400,
      'top': Random().nextDouble() * 1000,
      'size': Random().nextDouble() * (25 - 10) + 10,
      'rotation': Random().nextDouble() * 360,
      'colorR': Random().nextDouble() * 255,
      'colorG': Random().nextDouble() * 255,
      'colorB': Random().nextDouble() * 255,
    },
  );

  @override
  void initState() {
    super.initState();
    _draggableSheetController.addListener(() {
      setState(() {});
    });
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
      lastDate:
          DateTime.now().add(const Duration(days: 365 * 2)), // Próximos 2 anos
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
    // Validação já foi feita no botão, aqui apenas mostra o resumo

    // Calcular valor total
    double totalValue = 0.0;
    if (_selectedDecoration != null) {
      totalValue += _selectedDecoration!.price;
    }

    // Adicionar valor das bebidas
    for (var entry in _selectedBeverages.entries) {
      final beverage = _beverageOptions.firstWhere((b) => b.name == entry.key);
      totalValue += beverage.price * entry.value;
    }

    // Adicionar valor das comidas
    for (var entry in _selectedFoods.entries) {
      final food = _foodOptions.firstWhere((f) => f.name == entry.key);
      totalValue += food.price * entry.value;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                    Text('Imagem: ${_selectedPainelImage!.split('/').last}',
                        style: const TextStyle(color: Colors.white70)),
                ] else if (_selectedPainelOption == 'personalizado') ...[
                  const Text('Painel Personalizado: Sim',
                      style: TextStyle(color: Colors.white70)),
                  Text('Tema: ${_painelTemaController.text}',
                      style: const TextStyle(color: Colors.white70)),
                  Text('Frase: ${_painelFraseController.text}',
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
                const Text('🎁 PRESENTES ESCOLHIDOS',
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
                    children: [
                      const Text(
                        '💰 VALOR TOTAL PARA A COMANDA',
                        style: TextStyle(
                          color: Color(0xFFF26422),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'R\$ ${totalValue.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Color(0xFFF26422),
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '💡 Lembre-se: Decoração, bebidas e comidas são opcionais e seus valores serão adicionados à sua comanda no bar.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
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
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar',
                  style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();

                // Mostrar loading
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                );

                try {
                  // Preparar dados das bebidas
                  List<Map<String, dynamic>> bebidasDetalhes = [];
                  for (var entry in _selectedBeverages.entries) {
                    final beverage =
                        _beverageOptions.firstWhere((b) => b.name == entry.key);
                    bebidasDetalhes.add({
                      'nome': beverage.name,
                      'preco': beverage.price,
                      'categoria': beverage.category,
                      'descricao': beverage.description,
                      'quantidade': entry.value,
                    });
                  }

                  // Preparar dados das comidas
                  List<Map<String, dynamic>> comidasDetalhes = [];
                  for (var entry in _selectedFoods.entries) {
                    final food =
                        _foodOptions.firstWhere((f) => f.name == entry.key);
                    comidasDetalhes.add({
                      'nome': food.name,
                      'preco': food.price,
                      'categoria': food.category,
                      'descricao': food.description,
                      'quantidade': entry.value,
                    });
                  }

                  // Preparar dados dos presentes
                  List<Map<String, dynamic>> presentesDetalhes = _selectedGifts
                      .map((gift) => {
                            'nome': gift.name,
                            'preco': gift.price,
                            'categoria': gift.category,
                            'imagem': gift.image,
                          })
                      .toList();

                  // Calcular valor total
                  double totalValue = 0.0;
                  if (_selectedDecoration != null) {
                    totalValue += _selectedDecoration!.price;
                  }
                  for (var entry in _selectedBeverages.entries) {
                    final beverage =
                        _beverageOptions.firstWhere((b) => b.name == entry.key);
                    totalValue += beverage.price * entry.value;
                  }
                  for (var entry in _selectedFoods.entries) {
                    final food =
                        _foodOptions.firstWhere((f) => f.name == entry.key);
                    totalValue += food.price * entry.value;
                  }

                  // Enviar dados para o banco
                  final result =
                      await _birthdayService.createBirthdayReservation(
                    aniversarianteNome: _aniversarianteNomeController.text,
                    documento: _documentoController.text,
                    whatsapp: _whatsappController.text,
                    email: _emailController.text,
                    dataAniversario: _selectedBirthdayDate!,
                    barSelecionado: _selectedBar!,
                    quantidadeConvidados: _quantidadeConvidados,

                    // Dados de decoração
                    decoOpcao: _selectedDecoration?.name,
                    decoPreco: _selectedDecoration?.price,
                    decoDescricao: _selectedDecoration?.description,

                    // Dados do painel
                    painelTipo: _selectedPainelOption,
                    painelImagem: _selectedPainelImage,
                    painelTema: _painelTemaController.text.isNotEmpty
                        ? _painelTemaController.text
                        : null,
                    painelFrase: _painelFraseController.text.isNotEmpty
                        ? _painelFraseController.text
                        : null,

                    // Dados de bebidas
                    bebidasSelecionadas: _selectedBeverages.isNotEmpty
                        ? _selectedBeverages
                        : null,
                    bebidasDetalhes:
                        bebidasDetalhes.isNotEmpty ? bebidasDetalhes : null,

                    // Dados de comidas
                    comidasSelecionadas:
                        _selectedFoods.isNotEmpty ? _selectedFoods : null,
                    comidasDetalhes:
                        comidasDetalhes.isNotEmpty ? comidasDetalhes : null,

                    // Dados de presentes
                    presentesSelecionados:
                        presentesDetalhes.isNotEmpty ? presentesDetalhes : null,

                    // Valor total
                    valorTotal: totalValue,
                  );

                  // Fechar loading
                  if (mounted) {
                    Navigator.pop(context);
                  }

                  // Mostrar sucesso
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Reserva de aniversário criada com sucesso! ID: ${result['id']}'),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 5),
                      ),
                    );
                  }

                  // Navegar para a tela de detalhes da reserva se disponível
                  if (mounted && result['id'] != null) {
                    Navigator.of(context).pushReplacementNamed(
                      '/reservation-details',
                      arguments: {'reservationId': result['id']},
                    );
                  }
                } catch (e) {
                  // Fechar loading
                  if (mounted) {
                    Navigator.pop(context);
                  }

                  // Mostrar erro
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
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
    const bottomBarHeight = 90.0;
    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight =
        AppBar().preferredSize.height; // Altura padrão da AppBar
    final statusBarHeight =
        MediaQuery.of(context).padding.top; // Altura da status bar
    final totalOffsetFromTop = appBarHeight + statusBarHeight;

    final headerHeight = screenHeight * 0.4; // Ajuste conforme necessário

    final double initialSheetSize =
        (screenHeight - totalOffsetFromTop - headerHeight + 40) / screenHeight;

    return Scaffold(
      backgroundColor: const Color(0xFF242A38),
      body: Stack(
        children: [
          Positioned(
            top: _draggableSheetController.isAttached
                ? -_draggableSheetController.pixels * 0.5
                : 0,
            left: 0,
            right: 0,
            height: headerHeight +
                (_draggableSheetController.isAttached
                    ? _draggableSheetController.pixels
                    : 0),
            child: OverflowBox(
              maxHeight: double.infinity,
              alignment: Alignment.topCenter,
              child: Image.asset(
                'assets/images/niver.jpeg',
                fit: BoxFit.cover,
                width: MediaQuery.of(context).size.width,
                height: headerHeight * 1.5,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[800],
                    child: const Center(
                      child: Text(
                        'Falha ao carregar banner',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          ..._confetti.map((confetti) {
            return Positioned(
              left: confetti['left'],
              top: confetti['top']! -
                  (_draggableSheetController.isAttached
                      ? _draggableSheetController.pixels * 0.7
                      : 0),
              child: Transform.rotate(
                angle: confetti['rotation']! * (pi / 180),
                child: Container(
                  width: confetti['size'],
                  height: confetti['size'],
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(
                      confetti['colorR']!.toInt(),
                      confetti['colorG']!.toInt(),
                      confetti['colorB']!.toInt(),
                      1,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }).toList(),
          Padding(
            padding: const EdgeInsets.only(bottom: bottomBarHeight),
            child: DraggableScrollableSheet(
              initialChildSize: initialSheetSize,
              minChildSize: initialSheetSize,
              maxChildSize: 0.95,
              controller: _draggableSheetController,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF2B3245),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(24.0),
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.grey[700],
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      Text(
                        'Bem-vindo(a) ao seu espaço para a festa perfeita!',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                      ),
                      const SizedBox(height: 20),
                      _buildDarkTextField(
                        controller: _aniversarianteNomeController,
                        labelText: 'Nome do(a) Aniversariante*',
                        icon: Icons.cake,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira o nome do(a) aniversariante.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildDarkTextField(
                        controller: _documentoController,
                        labelText: 'Documento RG/CPF*',
                        icon: Icons.badge,
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira o documento.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildDarkTextField(
                        controller: _whatsappController,
                        labelText: 'WhatsApp*',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira o WhatsApp.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildDarkTextField(
                        controller: _emailController,
                        labelText: 'E-mail*',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira o e-mail.';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                            return 'Por favor, insira um e-mail válido.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildDarkDateField(
                        context: context,
                        controller: TextEditingController(
                          text: _selectedBirthdayDate == null
                              ? ''
                              : DateFormat('dd/MM/yyyy')
                                  .format(_selectedBirthdayDate!),
                        ),
                        labelText: 'Data do Aniversário*',
                        onTap: () => _selectBirthdayDate(context),
                        validator: (value) {
                          if (_selectedBirthdayDate == null) {
                            return 'Por favor, selecione a data do aniversário.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Qual bar vai comemorar seu aniversário?*',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _selectedBar,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          filled: true,
                          fillColor: const Color(0xFF333A4D),
                          labelStyle: const TextStyle(color: Colors.white70),
                        ),
                        dropdownColor: const Color(0xFF2B3245),
                        style: const TextStyle(color: Colors.white),
                        iconEnabledColor: Colors.white,
                        hint: const Text('Selecione um bar*',
                            style: TextStyle(color: Colors.white70)),
                        items: _bars.map((bar) {
                          return DropdownMenuItem(
                            value: bar,
                            child: Text(
                              bar,
                              style: const TextStyle(color: Colors.white70),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedBar = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, selecione um bar.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      Text(
                        'Quantidade de convidados*',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<int>(
                        value: _quantidadeConvidados,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          filled: true,
                          fillColor: const Color(0xFF333A4D),
                          labelStyle: const TextStyle(color: Colors.white70),
                        ),
                        dropdownColor: const Color(0xFF2B3245),
                        style: const TextStyle(color: Colors.white),
                        iconEnabledColor: Colors.white,
                        items: List.generate(50, (index) => index + 1).map((e) {
                          return DropdownMenuItem(
                            value: e,
                            child: Text(
                              '$e Convidados',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _quantidadeConvidados = value;
                            });
                          }
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Por favor, selecione a quantidade de convidados.';
                          }
                          return null;
                        },
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
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF26422).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: const Color(0xFFF26422).withOpacity(0.3)),
                        ),
                        child: const Text(
                          '💡 A decoração é um aluguel, não pode levar os painéis e bandejas para casa apenas os brindes que estiverem. O valor de cada opção está em cada card e será adicionado à sua comanda.',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
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
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF26422).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: const Color(0xFFF26422).withOpacity(0.3)),
                        ),
                        child: const Text(
                          '💡 Tanto o painel que temos no estoque quanto os personalizados não tem valor adicional pois já está incluso o valor na decoração.',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
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
                          height: 150,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _painelEstoqueImages.length,
                            itemBuilder: (context, index) {
                              final imageUrl = _painelEstoqueImages[index];
                              final isSelected =
                                  _selectedPainelImage == imageUrl;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedPainelImage = imageUrl;
                                  });
                                },
                                child: Container(
                                  width: 150,
                                  margin: const EdgeInsets.only(right: 15),
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
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.asset(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error,
                                              stackTrace) =>
                                          const Center(
                                              child: Icon(Icons.broken_image,
                                                  color: Colors.white70)),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                      if (_selectedPainelOption == 'personalizado') ...[
                        const SizedBox(height: 20),
                        if (!_isPersonalizedPanelAllowed())
                          const Padding(
                            padding: EdgeInsets.only(bottom: 15.0),
                            child: Text(
                              'Atenção: Painel personalizado só pode ser solicitado com no mínimo 5 dias de antecedência da data do aniversário.',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        _buildDarkTextField(
                          controller: _painelTemaController,
                          labelText: 'Tema do Painel Personalizado',
                          icon: Icons.palette,
                          validator: (value) {
                            // Só validar se painel personalizado foi selecionado
                            if (_selectedPainelOption == 'personalizado') {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, insira o tema do painel.';
                              }
                              if (!_isPersonalizedPanelAllowed()) {
                                return 'Data do aniversário muito próxima para painel personalizado.';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),
                        _buildDarkTextField(
                          controller: _painelFraseController,
                          labelText: 'Frase para o Painel Personalizado',
                          icon: Icons.text_fields,
                          maxLines: 3,
                          validator: (value) {
                            // Só validar se painel personalizado foi selecionado
                            if (_selectedPainelOption == 'personalizado' &&
                                (value == null || value.isEmpty)) {
                              return 'Por favor, insira uma frase para o painel.';
                            }
                            return null;
                          },
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
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF26422).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: const Color(0xFFF26422).withOpacity(0.3)),
                        ),
                        child: const Text(
                          '💡 Cada bebida que for adicionada será acrescentada o valor na comanda de quem está criando essa lista.',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
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
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF26422).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: const Color(0xFFF26422).withOpacity(0.3)),
                        ),
                        child: const Text(
                          '💡 Lembre que cada porção será acrescentada na comanda.',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
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
                        'Brindes Especiais 🎁',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF26422).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: const Color(0xFFF26422).withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '💡 Regras dos Brindes:',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '• 10 convidados ou mais: VIP',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12),
                            ),
                            const Text(
                              '• Acima de 20 pessoas: 2 VIPs + Drink da casa',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12),
                            ),
                            const Text(
                              '• Acima de 30 pessoas: 2 VIPs + garrafa de Rufus Caramel',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
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
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF26422).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: const Color(0xFFF26422).withOpacity(0.3)),
                        ),
                        child: const Text(
                          '💡 Escolha até 20 itens que você gostaria de receber como presente dos seus convidados.',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
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
                            // Validar apenas os campos obrigatórios
                            bool isValid = true;
                            String errorMessage = '';

                            // Verificar campos obrigatórios
                            if (_aniversarianteNomeController.text.isEmpty) {
                              errorMessage =
                                  'Nome do aniversariante é obrigatório';
                              isValid = false;
                            } else if (_documentoController.text.isEmpty) {
                              errorMessage = 'Documento é obrigatório';
                              isValid = false;
                            } else if (_whatsappController.text.isEmpty) {
                              errorMessage = 'WhatsApp é obrigatório';
                              isValid = false;
                            } else if (_emailController.text.isEmpty) {
                              errorMessage = 'E-mail é obrigatório';
                              isValid = false;
                            } else if (_selectedBirthdayDate == null) {
                              errorMessage =
                                  'Data do aniversário é obrigatória';
                              isValid = false;
                            } else if (_selectedBar == null ||
                                _selectedBar!.isEmpty) {
                              errorMessage = 'Seleção do bar é obrigatória';
                              isValid = false;
                            } else if (_quantidadeConvidados <= 0) {
                              errorMessage =
                                  'Quantidade de convidados é obrigatória';
                              isValid = false;
                            }

                            // Validar e-mail se foi preenchido
                            if (_emailController.text.isNotEmpty) {
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(_emailController.text)) {
                                errorMessage = 'E-mail inválido';
                                isValid = false;
                              }
                            }

                            // Validar painel personalizado se foi selecionado
                            if (_selectedPainelOption == 'personalizado') {
                              if (_painelTemaController.text.isEmpty) {
                                errorMessage =
                                    'Tema do painel personalizado é obrigatório';
                                isValid = false;
                              } else if (_painelFraseController.text.isEmpty) {
                                errorMessage =
                                    'Frase do painel personalizado é obrigatória';
                                isValid = false;
                              } else if (!_isPersonalizedPanelAllowed()) {
                                errorMessage =
                                    'Data do aniversário muito próxima para painel personalizado';
                                isValid = false;
                              }
                            }

                            if (isValid) {
                              _showConfirmationSummary();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(errorMessage),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
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
                );
              },
            ),
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
    required BuildContext context,
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
    double totalValue = 0.0;

    // Adicionar valor da decoração
    if (_selectedDecoration != null) {
      totalValue += _selectedDecoration!.price;
    }

    // Adicionar valor das bebidas
    for (var entry in _selectedBeverages.entries) {
      final beverage = _beverageOptions.firstWhere((b) => b.name == entry.key);
      totalValue += beverage.price * entry.value;
    }

    // Adicionar valor das comidas
    for (var entry in _selectedFoods.entries) {
      final food = _foodOptions.firstWhere((f) => f.name == entry.key);
      totalValue += food.price * entry.value;
    }

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
            'R\$ ${totalValue.toStringAsFixed(2)}',
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
