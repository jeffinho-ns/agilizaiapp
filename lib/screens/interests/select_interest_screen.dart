import 'package:flutter/material.dart';
import 'package:agilizaiapp/screens/location/select_location_screen.dart';

// Modelo para cada item de interesse
class Interest {
  final String name;
  final String imagePath;
  bool isSelected;

  Interest({
    required this.name,
    required this.imagePath,
    this.isSelected = false,
  });
}

class SelectInterestScreen extends StatefulWidget {
  const SelectInterestScreen({super.key});

  @override
  State<SelectInterestScreen> createState() => _SelectInterestScreenState();
}

class _SelectInterestScreenState extends State<SelectInterestScreen> {
  // Nossa lista de interesses. **ATUALIZE OS imagePath COM OS NOMES DOS SEUS ARQUIVOS!**
  final List<Interest> _interests = [
    Interest(name: 'Design', imagePath: 'assets/images/interest_design.png'),
    Interest(name: 'Music', imagePath: 'assets/images/interest_music.png'),
    Interest(name: 'Art', imagePath: 'assets/images/interest_art.png'),
    Interest(name: 'Sports', imagePath: 'assets/images/interest_sport.png'),
    Interest(name: 'Food', imagePath: 'assets/images/interest_food.png'),
    Interest(name: 'Others', imagePath: 'assets/images/interest_others.png'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // AppBar minimalista apenas com o botão de voltar
        leading: const BackButton(color: Colors.black),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Your 3 Interests',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            // A grade de interesses
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 colunas
                  crossAxisSpacing: 20, // Espaço horizontal entre os cards
                  mainAxisSpacing: 20, // Espaço vertical entre os cards
                  childAspectRatio:
                      0.85, // Proporção do card (largura / altura)
                ),
                itemCount: _interests.length,
                itemBuilder: (context, index) {
                  final interest = _interests[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        // Lógica para selecionar/desselecionar
                        interest.isSelected = !interest.isSelected;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                        // Borda muda de cor quando o item é selecionado
                        border: Border.all(
                          color: interest.isSelected
                              ? const Color(0xFFF26422)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(interest.imagePath, height: 60),
                          const SizedBox(height: 16),
                          Text(
                            interest.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Botão Next
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SelectLocationScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF242A38),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'NEXT',
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
      ),
    );
  }
}
