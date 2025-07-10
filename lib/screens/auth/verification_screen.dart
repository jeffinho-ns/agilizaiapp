import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart'; // Importa o pacote do Pinput
import 'package:agilizaiapp/screens/interests/select_interest_screen.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  Timer? _timer;
  int _start = 53; // Tempo inicial do contador

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  // É importante cancelar o timer quando a tela for destruída para não usar memória à toa
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) {
      if (_start == 0) {
        setState(() {
          timer.cancel();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Estilo padrão para os campos do Pinput
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Verification',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Texto com partes em cores diferentes usando RichText
            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                style: TextStyle(fontSize: 16, color: Colors.grey),
                children: <TextSpan>[
                  TextSpan(text: "We've send you the verification code on "),
                  TextSpan(
                    text: '+1 6358 9248 5789',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Widget do Pinput
            Pinput(
              length: 4,
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: defaultPinTheme.copyWith(
                decoration: defaultPinTheme.decoration!.copyWith(
                  border: Border.all(color: const Color(0xFFF26422)),
                ),
              ),
              onCompleted: (pin) {
                print("Completed: " + pin); // Ação quando o código é preenchido
              },
            ),
            const SizedBox(height: 40),

            // Botão Continue
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Usamos pushReplacement para que o usuário não volte para a tela de verificação
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const SelectInterestScreen(),
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
                  'CONTINUE',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Texto de reenviar código com o contador
            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                children: <TextSpan>[
                  const TextSpan(text: "Re-send code in "),
                  TextSpan(
                    text:
                        '0:${_start.toString().padLeft(2, '0')}', // Formata o número para ter sempre 2 dígitos
                    style: const TextStyle(
                      color: Color(0xFFF26422),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // O teclado numérico customizado será adicionado depois
          ],
        ),
      ),
    );
  }
}
