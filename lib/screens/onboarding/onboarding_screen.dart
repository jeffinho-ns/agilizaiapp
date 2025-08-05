import 'package:flutter/material.dart';
import 'package:agilizaiapp/screens/country/country_selection_screen.dart';
import 'package:agilizaiapp/l10n/app_localizations.dart';

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

  // --- Dados de Onboarding com Traduções ---
  List<Map<String, String>> _getOnboardingData(BuildContext context) {
    return [
      {
        "image": "assets/images/onboarding-1.png",
        "title": AppLocalizations.of(context)!.onboardingExploreTitle,
        "subtitle": AppLocalizations.of(context)!.onboardingExploreSubtitle,
      },
      {
        "image": "assets/images/onboarding-2.png",
        "title": AppLocalizations.of(context)!.onboardingCreateFindTitle,
        "subtitle": AppLocalizations.of(context)!.onboardingCreateFindSubtitle,
      },
      {
        "image": "assets/images/onboarding-3.png",
        "title": AppLocalizations.of(context)!.onboardingWatchFreeTitle,
        "subtitle": AppLocalizations.of(context)!.onboardingWatchFreeSubtitle,
      },
    ];
  }

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
                itemCount: _getOnboardingData(context).length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  // Certifique-se de que os assets de imagem existem neste caminho
                  return Image.asset(
                      _getOnboardingData(context)[index]['image']!);
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
                    _getOnboardingData(context)[_currentPage]['title']!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _getOnboardingData(context)[_currentPage]['subtitle']!,
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
                        child: Text(
                          AppLocalizations.of(context)!.onboardingSkip,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),

                      Row(
                        children: List.generate(
                          _getOnboardingData(context).length,
                          (index) => buildDot(index),
                        ),
                      ),

                      // Botão PRÓXIMO / COMEÇAR
                      TextButton(
                        onPressed: () {
                          // Se não for a última página, avança
                          if (_currentPage <
                              _getOnboardingData(context).length - 1) {
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
                          _currentPage == _getOnboardingData(context).length - 1
                              ? AppLocalizations.of(context)!
                                  .onboardingGetStarted
                              : AppLocalizations.of(context)!.onboardingNext,
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
