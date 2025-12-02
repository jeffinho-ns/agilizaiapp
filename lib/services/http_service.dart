// lib/services/http_service.dart
// Serviço HTTP centralizado com configuração completa do Dio

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:agilizaiapp/config/api_config.dart';

class HttpService {
  static final HttpService _instance = HttpService._internal();
  factory HttpService() => _instance;
  HttpService._internal();

  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Dio get dio => _dio;

  void initialize() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) {
          return status != null && status < 500; // Aceita status < 500
        },
      ),
    );

    // Interceptor para adicionar token de autenticação automaticamente
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Adicionar token de autenticação se disponível
          final token = await _storage.read(key: 'jwt_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          
          // Log da requisição (apenas em debug)
          print('🌐 ${options.method} ${options.uri}');
          if (options.data != null) {
            print('📤 Request Data: ${options.data}');
          }
          
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Log da resposta (apenas em debug)
          print('✅ ${response.statusCode} ${response.requestOptions.uri}');
          return handler.next(response);
        },
        onError: (error, handler) {
          // Log do erro
          print('❌ Erro HTTP: ${error.requestOptions.method} ${error.requestOptions.uri}');
          print('   Status: ${error.response?.statusCode}');
          print('   Mensagem: ${error.response?.data ?? error.message}');
          
          // Tratamento especial para erros 401 (não autorizado)
          if (error.response?.statusCode == 401) {
            print('⚠️ Token inválido ou expirado. Limpando armazenamento...');
            _storage.deleteAll();
          }
          
          return handler.next(error);
        },
      ),
    );

  }
}

