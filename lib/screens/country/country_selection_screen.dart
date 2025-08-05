import 'package:flutter/material.dart';
import 'package:agilizaiapp/screens/auth/signin_screen.dart';
import 'package:agilizaiapp/providers/language_provider.dart';
import 'package:provider/provider.dart';
import 'package:agilizaiapp/l10n/app_localizations.dart';

// 1. Nosso modelo de dados simples para cada idioma
class Language {
  final String code;
  final String name;
  final String nativeName;
  final String flagEmoji;

  Language({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flagEmoji,
  });
}

// 2. A tela em si
class CountrySelectionScreen extends StatefulWidget {
  const CountrySelectionScreen({super.key});

  @override
  State<CountrySelectionScreen> createState() => _CountrySelectionScreenState();
}

class _CountrySelectionScreenState extends State<CountrySelectionScreen> {
  // 3. Nossa lista de idiomas disponíveis
  final List<Language> _languages = [
    Language(
      code: 'pt',
      name: 'Português Brasileiro',
      nativeName: 'Português Brasileiro',
      flagEmoji: '🇧🇷',
    ),
    Language(
      code: 'en',
      name: 'English US',
      nativeName: 'English US',
      flagEmoji: '🇺🇸',
    ),
    Language(
      code: 'es',
      name: 'Español',
      nativeName: 'Español',
      flagEmoji: '🇪🇸',
    ),
    Language(
      code: 'de',
      name: 'Deutsch',
      nativeName: 'Deutsch',
      flagEmoji: '🇩🇪',
    ),
  ];

  // 4. Variável para guardar o idioma que o usuário selecionou
  Language? _selectedLanguage;

  @override
  void initState() {
    super.initState();
    // Pré-seleciona o primeiro idioma da lista (Português Brasileiro)
    _selectedLanguage = _languages[0];
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
        title: Text(AppLocalizations.of(context)!.countrySelectionTitle),
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
                hintText: AppLocalizations.of(context)!
                    .findCountryHint, // O texto dentro do campo
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

          // 6. A lista de idiomas
          Expanded(
            child: ListView.builder(
              itemCount: _languages.length,
              itemBuilder: (context, index) {
                final language = _languages[index];
                return RadioListTile<Language>(
                  title: Text('${language.flagEmoji}  ${language.nativeName}'),
                  value: language,
                  groupValue: _selectedLanguage,
                  onChanged: (Language? value) {
                    setState(() {
                      _selectedLanguage = value;
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
                onPressed: () async {
                  if (_selectedLanguage != null) {
                    // Salva o idioma selecionado
                    final languageProvider =
                        Provider.of<LanguageProvider>(context, listen: false);
                    await languageProvider.setLanguage(_selectedLanguage!.code);

                    // Navega para a tela de login
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SignInScreen()),
                    );
                  }
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
                child: Text(
                  AppLocalizations.of(context)!.saveButton,
                  style: const TextStyle(
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
