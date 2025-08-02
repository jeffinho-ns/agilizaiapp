import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:agilizaiapp/screens/interests/select_interest_screen.dart';
import 'package:agilizaiapp/services/auth_service.dart';
import 'package:agilizaiapp/services/phone_service.dart';
import 'package:agilizaiapp/screens/main_screen.dart';

class VerificationScreen extends StatefulWidget {
  final String telefone;
  final Map<String, String> userData;

  const VerificationScreen({
    super.key,
    required this.telefone,
    required this.userData,
  });

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  Timer? _timer;
  int _start = 53; // Tempo inicial do contador
  bool _isVerifying = false;
  final AuthService _authService = AuthService();
  final PhoneService _phoneService = PhoneService();

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

  Future<void> _verifyCode(String code) async {
    setState(() => _isVerifying = true);

    try {
      final isValid = await _phoneService.verifyCode(widget.telefone, code);

      if (isValid) {
        // Código válido, fazer o cadastro do usuário
        await _authService.signUp(
          widget.userData['name']!,
          widget.userData['email']!,
          widget.userData['cpf']!,
          widget.userData['password']!,
          widget.userData['telefone']!,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Cadastro realizado com sucesso!"),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => MainScreen()),
            (route) => false,
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Código inválido. Tente novamente."),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    }
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
              'Verificação',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Texto com partes em cores diferentes usando RichText
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(fontSize: 16, color: Colors.grey),
                children: <TextSpan>[
                  const TextSpan(
                      text: "Enviamos o código de verificação para "),
                  TextSpan(
                    text: _phoneService.formatPhone(widget.telefone),
                    style: const TextStyle(
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
              onCompleted: (pin) async {
                await _verifyCode(pin);
              },
            ),
            const SizedBox(height: 40),

            // Botão Continue
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isVerifying
                    ? null
                    : () {
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
                child: _isVerifying
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'CONTINUAR',
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
                  const TextSpan(text: "Reenviar código em "),
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
