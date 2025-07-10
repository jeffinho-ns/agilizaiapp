import 'package:flutter/material.dart';

class EmptyEventsScreen extends StatelessWidget {
  const EmptyEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Meus Eventos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Imagem no centro
              Image.asset(
                'assets/images/empty-event.png', // Caminho da sua imagem
                height: 200, // Ajuste a altura conforme necessário
                width: 200, // Ajuste a largura conforme necessário
                fit:
                    BoxFit.contain, // Garante que a imagem se ajuste sem cortar
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.image_not_supported,
                    size: 150,
                    color: Colors.grey,
                  ); // Ícone de erro se a imagem não carregar
                },
              ),
              const SizedBox(
                height: 32,
              ), // Espaço entre a imagem e o texto/botão
              const Text(
                'Nenhum evento encontrado!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Parece que você ainda não tem eventos para exibir. Que tal criar ou explorar alguns?',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40), // Espaço antes do botão
              SizedBox(
                width:
                    double.infinity, // Botão ocupa a largura total disponível
                child: ElevatedButton(
                  onPressed: () {
                    // Ação para o botão, por exemplo, navegar para uma tela de criar evento
                    print('Botão "Explorar Eventos" clicado');
                    // Navigator.of(context).push(MaterialPageRoute(builder: (_) => ExploreEventsScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFFF26422,
                    ), // Cor laranja vibrante
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'EXPLORAR EVENTOS',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
