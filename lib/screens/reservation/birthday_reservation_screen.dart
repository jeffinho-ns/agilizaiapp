import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math'; // Para gerar posições aleatórias para os confetes

// Placeholder para o modelo de evento e bar, se precisar de dados deles para a reserva
import 'package:agilizaiapp/models/bar_model.dart'; // Se for associar a um bar específico

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
  final _painelTemaController = TextEditingController();
  final _painelFraseController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Chave para o formulário

  final DraggableScrollableController _draggableSheetController =
      DraggableScrollableController();

  int _quantidadeConvidados = 1;
  List<TextEditingController> _nomeConvidadosControllers = [];

  String? _selectedDecoracaoType; // Tipo de decoração selecionado
  String? _selectedPainelOption; // 'estoque' ou 'personalizado'
  String?
      _selectedPainelImage; // URL/path da imagem do painel de estoque selecionado

  DateTime? _selectedBirthdayDate; // Data do aniversário

  // Quantidades de bebidas
  int _budweiserBuckets = 0;
  int _coronaBuckets = 0;
  int _heinekenBuckets = 0;
  int _gin142Combos = 0;
  int _rufusLiqueurBottles = 0;

  // Opções de Decoração (com imagens mockadas)
  final List<Map<String, String>> _decoracaoOptions = [
    {
      'type': 'Painel e um balão simples',
      'image': 'assets/images/kit-1.jpg', // ✨ Imagem local
    },
    {
      'type': 'Painel um balão e duas bandejas',
      'image': 'assets/images/kit-2.jpg', // ✨ Imagem local
    },
    {
      'type': 'Painel três bandejas e arco de balões',
      'image': 'assets/images/kit-3.jpg', // ✨ Imagem local
    },
    {
      'type': 'Painel três bandejas, arco de balões e bolo',
      'image': 'assets/images/kit-4.jpg', // ✨ Imagem local
    },
    {
      'type': 'Painel três bandejas, arco de balões + Combo Gin142',
      'image': 'assets/images/kit-5.jpg', // ✨ Imagem local
    },
    {
      'type': 'Painel três bandejas, arco de balões, bolo + Combo Gin142',
      'image': 'assets/images/kit-6.jpg', // ✨ Imagem local
    },
  ];

  // Opções de Painel do Estoque (com imagens mockadas)
  final List<String> _painelEstoqueImages = [
    'assets/images/painel-estoque-1.jpg',
    'assets/images/painel-estoque-2.jpg',
    'assets/images/painel-estoque-3.jpg',
    'assets/images/painel-estoque-4.jpg',
    'assets/images/painel-estoque-5.jpg',
    'assets/images/painel-estoque-6.jpg',
    'assets/images/painel-estoque-7.jpg',
    'assets/images/painel-estoque-8.jpg',
    'assets/images/painel-estoque-9.jpg',
    'assets/images/painel-estoque-10.jpg',
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
    _updateConvidadoControllers();
    _draggableSheetController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _aniversarianteNomeController.dispose();
    _painelTemaController.dispose();
    _painelFraseController.dispose();
    for (var controller in _nomeConvidadosControllers) {
      controller.dispose();
    }
    _draggableSheetController.dispose();
    super.dispose();
  }

  void _updateConvidadoControllers() {
    if (_nomeConvidadosControllers.length > _quantidadeConvidados) {
      for (int i = _quantidadeConvidados;
          i < _nomeConvidadosControllers.length;
          i++) {
        _nomeConvidadosControllers[i].dispose();
      }
      _nomeConvidadosControllers = _nomeConvidadosControllers.sublist(
        0,
        _quantidadeConvidados,
      );
    } else if (_nomeConvidadosControllers.length < _quantidadeConvidados) {
      for (int i = _nomeConvidadosControllers.length;
          i < _quantidadeConvidados;
          i++) {
        _nomeConvidadosControllers.add(TextEditingController());
      }
    }
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
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Por favor, preencha todos os campos obrigatórios e corrija os erros de validação.')),
      );
      return;
    }

    final List<String> convidadosNomes = _nomeConvidadosControllers
        .map((controller) => controller.text)
        .where((name) => name.isNotEmpty)
        .toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2B3245),
          title: const Text('Confirmar Reserva de Aniversário',
              style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Aniversariante: ${_aniversarianteNomeController.text}',
                    style: const TextStyle(color: Colors.white70)),
                Text(
                    'Data: ${_selectedBirthdayDate != null ? DateFormat('dd/MM/yyyy').format(_selectedBirthdayDate!) : 'Não selecionada'}',
                    style: const TextStyle(color: Colors.white70)),
                Text('Convidados: $_quantidadeConvidados pessoas',
                    style: const TextStyle(color: Colors.white70)),
                if (convidadosNomes.isNotEmpty)
                  Text('Nomes: ${convidadosNomes.join(', ')}',
                      style: const TextStyle(color: Colors.white70)),
                Text('Decoração: ${_selectedDecoracaoType ?? 'Nenhuma'}',
                    style: const TextStyle(color: Colors.white70)),
                if (_selectedPainelOption == 'estoque' &&
                    _selectedPainelImage != null)
                  Text(
                      'Painel de Estoque: ${_selectedPainelImage!.split('/').last.split('?').first}',
                      style: const TextStyle(color: Colors.white70)),
                if (_selectedPainelOption == 'personalizado') ...[
                  const Text('Painel Personalizado: Sim',
                      style: TextStyle(color: Colors.white70)),
                  Text('Tema: ${_painelTemaController.text}',
                      style: const TextStyle(color: Colors.white70)),
                  Text('Frase: ${_painelFraseController.text}',
                      style: const TextStyle(color: Colors.white70)),
                ],
                const Divider(color: Colors.white30),
                const Text('Bebidas:', style: TextStyle(color: Colors.white)),
                if (_budweiserBuckets > 0)
                  Text('Balde Budweiser: $_budweiserBuckets',
                      style: const TextStyle(color: Colors.white70)),
                if (_coronaBuckets > 0)
                  Text('Balde Corona: $_coronaBuckets',
                      style: const TextStyle(color: Colors.white70)),
                if (_heinekenBuckets > 0)
                  Text('Balde Heineken: $_heinekenBuckets',
                      style: const TextStyle(color: Colors.white70)),
                if (_gin142Combos > 0)
                  Text('Combo Gin 142: $_gin142Combos',
                      style: const TextStyle(color: Colors.white70)),
                if (_rufusLiqueurBottles > 0)
                  Text('Garrafa Licor Rufus: $_rufusLiqueurBottles',
                      style: const TextStyle(color: Colors.white70)),
                if (_budweiserBuckets == 0 &&
                    _coronaBuckets == 0 &&
                    _heinekenBuckets == 0 &&
                    _gin142Combos == 0 &&
                    _rufusLiqueurBottles == 0)
                  const Text('Nenhuma bebida selecionada.',
                      style: TextStyle(color: Colors.white70)),
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
              onPressed: () {
                // TODO: Lógica para enviar a reserva para a API
                // Por enquanto, apenas fecha o diálogo
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'Reserva de aniversário confirmada (apenas simulação)!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF26422), // Botão laranja
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
                        labelText: 'Nome do(a) Aniversariante',
                        icon: Icons.cake,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira o nome do(a) aniversariante.';
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
                        labelText: 'Data do Aniversário',
                        onTap: () => _selectBirthdayDate(context),
                        validator: (value) {
                          if (_selectedBirthdayDate == null) {
                            return 'Por favor, selecione a data do aniversário.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      Text(
                        'Quantas pessoas você vai levar?',
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
                              _updateConvidadoControllers();
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      ...List.generate(_quantidadeConvidados, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 15.0),
                          child: _buildDarkTextField(
                            controller: _nomeConvidadosControllers[index],
                            labelText: 'Nome do Convidado ${index + 1}',
                            icon: Icons.person,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, insira o nome do convidado ${index + 1}.';
                              }
                              return null;
                            },
                          ),
                        );
                      }),
                      const SizedBox(height: 30),
                      Text(
                        'Escolha sua Decoração ✨ (Selecione apenas uma)',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
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
                        itemCount: _decoracaoOptions.length,
                        itemBuilder: (context, index) {
                          final option = _decoracaoOptions[index];
                          final isSelected =
                              _selectedDecoracaoType == option['type'];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedDecoracaoType = option['type'];
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
                                        // ✨ USANDO Image.asset para imagens locais
                                        option['image']!,
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
                                    child: Text(
                                      option['type']!,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: isSelected
                                            ? const Color(0xFFF26422)
                                            : Colors.white,
                                      ),
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
                            itemCount:
                                10, // Assumindo que você tem painel-1.jpg até painel-10.jpg
                            itemBuilder: (context, index) {
                              final imageName = 'painel-${index + 1}.jpg';
                              final imageUrl = 'assets/images/$imageName';
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
                                      // ✨ USANDO Image.asset para imagens locais
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
                            if (_selectedPainelOption == 'personalizado' &&
                                (value == null || value.isEmpty)) {
                              return 'Por favor, insira o tema do painel.';
                            }
                            if (_selectedPainelOption == 'personalizado' &&
                                !_isPersonalizedPanelAllowed()) {
                              return 'Data do aniversário muito próxima para painel personalizado.';
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
                        'Quer acrescentar bebidas à sua reserva? 🥂',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                      ),
                      const SizedBox(height: 15),
                      _buildDarkBeverageQuantitySelector(
                        label: 'Balde de Cerveja Budweiser (5 und)',
                        value: _budweiserBuckets,
                        onChanged: (value) =>
                            setState(() => _budweiserBuckets = value),
                      ),
                      _buildDarkBeverageQuantitySelector(
                        label: 'Balde de Cerveja Corona (5 und)',
                        value: _coronaBuckets,
                        onChanged: (value) =>
                            setState(() => _coronaBuckets = value),
                      ),
                      _buildDarkBeverageQuantitySelector(
                        label: 'Balde de Cerveja Heineken (5 und)',
                        value: _heinekenBuckets,
                        onChanged: (value) =>
                            setState(() => _heinekenBuckets = value),
                      ),
                      _buildDarkBeverageQuantitySelector(
                        label: 'Combo Gin 142 (5 Red Bull)',
                        value: _gin142Combos,
                        onChanged: (value) =>
                            setState(() => _gin142Combos = value),
                      ),
                      _buildDarkBeverageQuantitySelector(
                        label: 'Garrafa de Licor Rufus Caramel',
                        value: _rufusLiqueurBottles,
                        onChanged: (value) =>
                            setState(() => _rufusLiqueurBottles = value),
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // ✨ CORREÇÃO: Adicione uma verificação de nulidade antes de usar '!'
                            if (_formKey.currentState != null &&
                                _formKey.currentState!.validate()) {
                              _showConfirmationSummary();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Por favor, preencha todos os campos obrigatórios e corrija os erros.')),
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

  Widget _buildDarkBeverageQuantitySelector({
    required String label,
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF333A4D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
              child: Text(label, style: const TextStyle(color: Colors.white))),
          IconButton(
            icon:
                const Icon(Icons.remove_circle_outline, color: Colors.white70),
            onPressed: value > 0 ? () => onChanged(value - 1) : null,
          ),
          Text('$value', style: const TextStyle(color: Colors.white)),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.white70),
            onPressed: () => onChanged(value + 1),
          ),
        ],
      ),
    );
  }
}
