import 'package:flutter/material.dart';
import 'package:agilizaiapp/screens/auth/signin_screen.dart';

// 1. Nosso modelo de dados simples para cada país
class Country {
  final String name;
  final String flagEmoji;

  Country({required this.name, required this.flagEmoji});
}

// 2. A tela em si
class CountrySelectionScreen extends StatefulWidget {
  const CountrySelectionScreen({super.key});

  @override
  State<CountrySelectionScreen> createState() => _CountrySelectionScreenState();
}

class _CountrySelectionScreenState extends State<CountrySelectionScreen> {
  // 3. Nossa lista de países de exemplo
  final List<Country> _countries = [
    Country(name: 'Bangladesh', flagEmoji: '🇧🇩'),
    Country(name: 'Australia', flagEmoji: '🇦🇺'),
    Country(name: 'Pakistan', flagEmoji: '🇵🇰'),
    Country(name: 'England', flagEmoji: '🏴󠁧󠁢󠁥󠁮󠁧󠁿'),
    Country(name: 'United Arab Emirates', flagEmoji: '🇦🇪'),
    Country(name: 'Germany', flagEmoji: '🇩🇪'),
    Country(name: 'United States America', flagEmoji: '🇺🇸'),
    Country(name: 'Netherlands', flagEmoji: '🇳🇱'),
    Country(name: 'Brazil', flagEmoji: '🇧🇷'),
  ];

  // 4. Variável para guardar o país que o usuário selecionou
  Country? _selectedCountry;

  @override
  void initState() {
    super.initState();
    // Pré-seleciona o primeiro país da lista, como no design
    _selectedCountry = _countries[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Seta de "voltar"
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // TODO: Adicionar lógica se necessário, por exemplo, Navigator.pop(context);
          },
        ),
        title: const Text('Country Selection'),
        centerTitle: true,
        // Ícone de "mais opções"
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // 5. Barra de busca
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Find Country', // O texto dentro do campo
                prefixIcon: const Icon(Icons.search), // Ícone de lupa
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none, // Sem borda visível
                ),
                filled: true, // Necessário para a cor de fundo funcionar
                fillColor: Colors.grey[200], // Cor de fundo cinza claro
              ),
            ),
          ),

          // 6. A lista de países
          Expanded(
            child: ListView.builder(
              itemCount: _countries.length,
              itemBuilder: (context, index) {
                final country = _countries[index];
                return RadioListTile<Country>(
                  title: Text('${country.flagEmoji}  ${country.name}'),
                  value: country,
                  groupValue: _selectedCountry,
                  onChanged: (Country? value) {
                    setState(() {
                      _selectedCountry = value;
                    });
                  },
                  activeColor: const Color(
                    0xFFF26422,
                  ), // Cor do item selecionado
                  controlAffinity: ListTileControlAffinity
                      .trailing, // Coloca o botão de rádio no final
                );
              },
            ),
          ),

          // 7. Botão de Salvar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity, // Ocupa toda a largura
              child: ElevatedButton(
                onPressed: () {
                  // Usamos Navigator.push para que o usuário possa voltar
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SignInScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(
                    0xFF242A38,
                  ), // Cor de fundo do botão
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'SAVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
