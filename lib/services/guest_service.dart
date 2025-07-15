// lib/services/guest_service.dart

import 'dart:convert';
import 'package:agilizaiapp/models/guest_model.dart';
import 'package:agilizaiapp/models/event_model.dart'; // Para Event
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class GuestService {
  final String _baseUrl =
      'https://vamos-comemorar-api.onrender.com/api/convidados'; // Seu endpoint de convidados
  final String _eventApiUrl =
      'https://vamos-comemorar-api.onrender.com/api/events'; // Seu endpoint de eventos
  // **NOVO ENDPOINT:** Para gerenciar as listas de convidados, se houver um endpoint específico para isso
  final String _guestListApiUrl =
      'https://vamos-comemorar-api.onrender.com/api/guestlists'; // Exemplo: Adicione um novo endpoint para listas de convidados
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Helper para obter o token JWT
  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) {
      throw Exception('Token JWT não encontrado. Usuário não autenticado.');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Obter eventos criados pelo usuário logado (Promotor)
  // NOTA: Sua API de eventos não tem um filtro por promotor.
  // Você precisará adicionar um endpoint no backend (ex: /api/events/meus-eventos)
  // ou filtrar no frontend se a rota /api/events/ retornar todos os eventos
  // e o Event model tiver um 'promotorId' ou 'userId' associado.
  // Por enquanto, vamos buscar todos e você pode filtrar por userId no Flutter,
  // ou adaptar seu backend.
  Future<List<Event>> fetchPromoterEvents(int currentUserId) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse(
                _eventApiUrl), // Ou _eventApiUrl/meus-eventos se criar o endpoint
            headers: headers,
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> eventData = jsonDecode(response.body);
        // Se sua API não filtra por promotor, filtre aqui no Flutter:
        // return eventData.map((json) => Event.fromJson(json)).where((event) => event.promoterId == currentUserId).toList();
        return eventData.map((json) => Event.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Não autorizado. Token inválido ou expirado.');
      } else {
        throw Exception('Falha ao carregar eventos: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao buscar eventos do promotor: $e');
      rethrow;
    }
  }

  // **MÉTODO MODIFICADO:** Adicionar convidados com 'lista' e 'documento'
  Future<void> addGuests(
    int eventId,
    List<String> nomes, {
    String? lista, // Agora aceita o nome da lista
    String? documento, // Agora aceita o documento do convidado
  }) async {
    try {
      final headers = await _getHeaders();
      final List<Map<String, dynamic>> guestsData = nomes
          .map((name) => {
                'nome': name,
                'lista': lista ??
                    'Geral', // Usa o parâmetro 'lista' ou 'Geral' como padrão
                'documento': documento,
              })
          .toList();

      final response = await http
          .post(
            Uri.parse(_baseUrl),
            headers: headers,
            body: jsonEncode({
              'eventId': eventId,
              'convidados': guestsData, // Envia uma lista de objetos convidado
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 201) {
        final errorBody = jsonDecode(response.body);
        throw Exception(
            'Falha ao adicionar convidados: ${errorBody['message'] ?? response.statusCode}');
      }
    } catch (e) {
      print('Erro ao adicionar convidados: $e');
      rethrow;
    }
  }

  // **NOVO MÉTODO:** Criar uma nova lista de convidados
  // Este método requer que seu backend tenha um endpoint como POST /api/guestlists
  // que receba: eventId, nomeDaLista, idDoCriador, tipoDaLista, documentoDoCriador
  Future<void> createNewGuestList({
    required int eventId,
    required String listName,
    required String creatorId, // ID do usuário criador da lista
    required String listType, // VIP, Pista, Camarote, Convidado
    String? creatorDocument, // Documento do criador da lista
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .post(
            Uri.parse(
                _guestListApiUrl), // Use o novo endpoint de listas de convidados
            headers: headers,
            body: jsonEncode({
              'eventId': eventId,
              'nomeDaLista': listName,
              'idDoCriador': creatorId,
              'tipoDaLista': listType,
              'documentoDoCriador': creatorDocument,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 201) {
        // 201 Created é o código para sucesso na criação
        final errorBody = jsonDecode(response.body);
        throw Exception(
            'Falha ao criar nova lista: ${errorBody['message'] ?? response.statusCode}');
      }
    } catch (e) {
      print('Erro ao criar nova lista de convidados: $e');
      rethrow;
    }
  }

  // Listar convidados por evento (GET /convidados/:event_id)
  Future<List<Guest>> fetchGuestsByEvent(int eventId) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse('$_baseUrl/$eventId'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> guestData = jsonDecode(response.body);
        return guestData.map((json) => Guest.fromJson(json)).toList();
      } else {
        throw Exception('Falha ao carregar convidados: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao buscar convidados do evento $eventId: $e');
      rethrow;
    }
  }

  // Buscar convidados com filtro por nome (GET /convidados/search/:event_id?nome=)
  Future<List<Guest>> searchGuests(int eventId, String query) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse('$_baseUrl/search/$eventId?nome=$query'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> guestData = jsonDecode(response.body);
        return guestData.map((json) => Guest.fromJson(json)).toList();
      } else {
        throw Exception('Falha ao buscar convidados: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao buscar convidados por nome no evento $eventId: $e');
      rethrow;
    }
  }

  // Contagem por lista (GET /convidados/contagem/:event_id)
  Future<List<GuestCount>> fetchGuestCounts(int eventId) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse('$_baseUrl/contagem/$eventId'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> countData = jsonDecode(response.body);
        return countData.map((json) => GuestCount.fromJson(json)).toList();
      } else {
        throw Exception('Falha ao carregar contagens: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao buscar contagens de convidados do evento $eventId: $e');
      rethrow;
    }
  }

  // Deletar convidado (DELETE /convidados/:id)
  Future<void> deleteGuest(int guestId) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .delete(
            Uri.parse('$_baseUrl/$guestId'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        final errorBody = jsonDecode(response.body);
        throw Exception(
            'Falha ao deletar convidado: ${errorBody['message'] ?? response.statusCode}');
      }
    } catch (e) {
      print('Erro ao deletar convidado $guestId: $e');
      rethrow;
    }
  }

  // Atualizar convidado (PUT /convidados/:id)
  Future<void> updateGuest(int guestId,
      {String? nome, String? documento, String? lista}) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .put(
            Uri.parse('$_baseUrl/$guestId'),
            headers: headers,
            body: jsonEncode({
              'nome': nome,
              'documento': documento,
              'lista': lista,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        final errorBody = jsonDecode(response.body);
        throw Exception(
            'Falha ao atualizar convidado: ${errorBody['message'] ?? response.statusCode}');
      }
    } catch (e) {
      print('Erro ao atualizar convidado $guestId: $e');
      rethrow;
    }
  }

  // Importar CSV (POST /convidados/importar/:event_id)
  // Esta função é mais complexa, pois envolve FilePicker e MultipartRequest.
  // Você precisará do pacote `file_picker` para selecionar o arquivo.
  /*
  Future<void> importGuestsCsv(int eventId, File csvFile) async {
    try {
      final headers = await _getHeaders();
      final request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/importar/$eventId'));
      request.headers.addAll(headers); // Adicione headers como Authorization
      request.files.add(await http.MultipartFile.fromPath('arquivo', csvFile.path));

      final response = await request.send().timeout(const Duration(seconds: 30));
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode != 200) {
        final errorBody = jsonDecode(responseBody);
        throw Exception('Falha ao importar CSV: ${errorBody['message'] ?? response.statusCode}');
      }
      print('CSV importado com sucesso!');
    } catch (e) {
      print('Erro ao importar CSV: $e');
      rethrow;
    }
  }
  */

  // Exportar CSV (GET /convidados/exportar/:event_id)
  // Esta função retornará os dados CSV como uma string ou bytes para download.
  Future<String> exportGuestsCsv(int eventId) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse('$_baseUrl/exportar/$eventId'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return response.body; // Retorna o conteúdo CSV como string
      } else if (response.statusCode == 404) {
        throw Exception(
            'Nenhum convidado encontrado para esse evento para exportar.');
      } else {
        throw Exception('Falha ao exportar CSV: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao exportar CSV: $e');
      rethrow;
    }
  }
}
