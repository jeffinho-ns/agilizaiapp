import 'dart:math';
import 'package:agilizaiapp/config/api_config.dart';
import 'package:dio/dio.dart';

class PhoneService {
  final String _baseUrl = ApiConfig.apiBaseUrl;
  final Dio _dio = Dio();

  /// Gera um código de verificação de 4 dígitos
  String _generateVerificationCode() {
    Random random = Random();
    return (1000 + random.nextInt(9000)).toString();
  }

  /// Envia código de verificação via telefone
  Future<bool> sendVerificationCode(String telefone) async {
    try {
      final verificationCode = _generateVerificationCode();

      // Remove caracteres especiais do telefone (apenas números)
      final cleanTelefone = telefone.replaceAll(RegExp(r'[^\d]'), '');

      // TEMPORÁRIO: Simular envio (remover quando backend estiver pronto)
      print('🔔 CÓDIGO SIMULADO: $verificationCode para $cleanTelefone');
      print(
          '📱 Mensagem: Seu código de verificação do Agilizaiapp é: $verificationCode');

      // Salva o código temporariamente para verificação
      await _saveVerificationCode(cleanTelefone, verificationCode);

      // Simular delay de envio
      await Future.delayed(const Duration(seconds: 2));

      return true;

      // DESCOMENTAR QUANDO BACKEND ESTIVER PRONTO:
      /*
      final response = await _dio.post(
        '$_baseUrl/api/phone/send-code',
        data: {
          'telefone': cleanTelefone,
          'code': verificationCode,
          'message':
              'Seu código de verificação do Agilizaiapp é: $verificationCode'
        },
      );

      if (response.statusCode == 200) {
        // Salva o código temporariamente para verificação
        await _saveVerificationCode(cleanTelefone, verificationCode);
        return true;
      } else {
        throw Exception('Falha ao enviar código via WhatsApp');
      }
      */
    } on DioException catch (e) {
      print('Erro ao enviar código WhatsApp: ${e.response?.data}');
      throw Exception(
          e.response?.data['error'] ?? 'Erro ao enviar código via WhatsApp');
    }
  }

  /// Verifica se o código enviado está correto
  Future<bool> verifyCode(String telefone, String code) async {
    try {
      print('🔍 Verificando código: $code para telefone: $telefone');

      // MOCKADO: Aceita qualquer código de 4 dígitos para facilitar testes
      if (code.length == 4 && RegExp(r'^\d{4}$').hasMatch(code)) {
        print('✅ Código válido (mockado): $code');
        return true;
      }

      print('❌ Código inválido: $code');
      return false;

      // CÓDIGO ORIGINAL (descomentar quando tiver serviço de WhatsApp):
      /*
      final cleanTelefone = telefone.replaceAll(RegExp(r'[^\d]'), '');
      final savedCode = await _getVerificationCode(cleanTelefone);

      if (savedCode == code) {
        // Remove o código após verificação bem-sucedida
        await _removeVerificationCode(cleanTelefone);
        return true;
      }
      return false;
      */
    } catch (e) {
      print('❌ Erro ao verificar código: $e');
      return false;
    }
  }

  /// Salva o código de verificação temporariamente
  Future<void> _saveVerificationCode(String telefone, String code) async {
    // Aqui você pode usar SharedPreferences ou outro método de armazenamento
    // Por simplicidade, vou usar um Map em memória (não recomendado para produção)
    // Em produção, use SharedPreferences ou um banco local
    _verificationCodes[telefone] = code;
  }

  /// Recupera o código de verificação salvo
  Future<String?> _getVerificationCode(String telefone) async {
    return _verificationCodes[telefone];
  }

  /// Remove o código de verificação após uso
  Future<void> _removeVerificationCode(String telefone) async {
    _verificationCodes.remove(telefone);
  }

  // Map temporário para armazenar códigos (em produção, use SharedPreferences)
  static final Map<String, String> _verificationCodes = {};

  /// Formata o número de telefone para exibição
  String formatPhone(String telefone) {
    final clean = telefone.replaceAll(RegExp(r'[^\d]'), '');
    if (clean.length == 11) {
      return '(${clean.substring(0, 2)}) ${clean.substring(2, 7)}-${clean.substring(7)}';
    } else if (clean.length == 13) {
      return '+${clean.substring(0, 2)} (${clean.substring(2, 4)}) ${clean.substring(4, 9)}-${clean.substring(9)}';
    }
    return telefone;
  }

  /// Valida se o número de telefone é válido
  bool isValidPhone(String telefone) {
    final clean = telefone.replaceAll(RegExp(r'[^\d]'), '');
    return clean.length >= 10 && clean.length <= 13;
  }
}
