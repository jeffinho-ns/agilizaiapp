import 'package:flutter/material.dart';
import 'package:agilizaiapp/screens/country/country_selection_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _goToNextScreen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const CountrySelectionScreen()),
    );
  }

  // --- Dados de Onboarding Traduzidos ---
  final List<Map<String, String>> _onboardingData = [
    {
      "image": "assets/images/onboarding-1.png",
      "title": "Explore Eventos Próximos e Futuros",
      "subtitle":
          "No mundo da publicação e do design gráfico, Lorem Ipsum é um texto de preenchimento comumente usado.",
    },
    {
      "image":
          "assets/images/onboarding-2.png", // **Verifique se o nome do arquivo está correto**
      "title": "Crie e Encontre Eventos Facilmente em um Só Lugar",
      "subtitle":
          "Neste aplicativo você pode criar qualquer tipo de evento e participar de todos os eventos.",
    },
    {
      "image":
          "assets/images/onboarding-3.png", // **Verifique se o nome do arquivo está correto**
      "title": "Assista a Shows Gratuitos com Amigos",
      "subtitle":
          "Encontre e reserve ingressos para shows perto de você e convide seus amigos para assistirem juntos.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Image.asset('assets/images/logo.png', height: 30),
            ),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingData.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  // Certifique-se de que os assets de imagem existem neste caminho
                  return Image.asset(_onboardingData[index]['image']!);
                },
              ),
            ),

            Container(
              padding: const EdgeInsets.all(32.0),
              decoration: const BoxDecoration(
                color: Color(0xFFF28F5F),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    _onboardingData[_currentPage]['title']!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _onboardingData[_currentPage]['subtitle']!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 40),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Botão PULAR
                      TextButton(
                        onPressed:
                            _goToNextScreen, // Pula direto para a próxima tela
                        child: const Text(
                          'Pular', // Traduzido
                          style: TextStyle(color: Colors.white),
                        ),
                      ),

                      Row(
                        children: List.generate(
                          _onboardingData.length,
                          (index) => buildDot(index),
                        ),
                      ),

                      // Botão PRÓXIMO / COMEÇAR
                      TextButton(
                        onPressed: () {
                          // Se não for a última página, avança
                          if (_currentPage < _onboardingData.length - 1) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            // Se for a última página, vai para a próxima tela
                            _goToNextScreen();
                          }
                        },
                        // O texto do botão muda na última página
                        child: Text(
                          _currentPage == _onboardingData.length - 1
                              ? 'Começar' // Traduzido
                              : 'Próximo', // Traduzido
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  AnimatedContainer buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 5),
      height: 6,
      width: _currentPage == index ? 20 : 6,
      decoration: BoxDecoration(
        color: _currentPage == index ? Colors.white : Colors.white54,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
