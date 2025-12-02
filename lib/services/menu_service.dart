// lib/services/menu_service.dart

import 'package:agilizaiapp/config/api_config.dart';
import 'package:dio/dio.dart';
import 'package:agilizaiapp/models/menu_models.dart';

class MenuService {
  final String _baseUrl = ApiConfig.cardapioEndpoint;
  final Dio _dio = Dio();

  // Cache para melhorar performance
  final Map<int, Map<String, List<MenuItemFromAPI>>> _menuCache = {};
  final Map<int, List<MenuCategoryFromAPI>> _categoriesCache = {};
  final Map<int, List<MenuItemFromAPI>> _itemsCache = {};
  List<BarFromAPI>? _barsCache;

  // Cache para detectar se API suporta filtros
  bool? _apiSupportsFilters;
  DateTime? _lastFilterTest;

  // Limpar cache na inicialização para garantir IDs corretos
  MenuService() {
    clearAllCache();
  }

  // Buscar todos os bares
  Future<List<BarFromAPI>> fetchBars() async {
    try {
      // Verificar cache primeiro
      if (_barsCache != null) {
        print('DEBUG: Usando bares do cache');
        return _barsCache!;
      }

      final response = await _dio.get('$_baseUrl/bars');

      if (response.statusCode == 200) {
        final List<dynamic> barsData = response.data;
        final bars = barsData.map((json) => BarFromAPI.fromJson(json)).toList();

        // Salvar no cache
        _barsCache = bars;

        print('DEBUG: ${bars.length} bares carregados da API');
        return bars;
      } else {
        throw Exception(
            'Falha ao carregar bares: Status ${response.statusCode}');
      }
    } on DioException catch (e) {
      print(
          'DioError ao buscar bares: ${e.response?.statusCode} - ${e.response?.data}');
      String errorMessage = 'Falha ao carregar bares.';
      if (e.response != null &&
          e.response!.data is Map &&
          e.response!.data.containsKey('error')) {
        errorMessage = e.response!.data['error'];
      }
      throw Exception(errorMessage);
    } catch (e) {
      print('Erro inesperado ao buscar bares: $e');
      throw Exception('Erro desconhecido ao carregar bares');
    }
  }

  // Detectar se a API suporta filtros por barId
  Future<bool> _detectApiFilterSupport() async {
    // Testar apenas uma vez por sessão (cache por 5 minutos)
    if (_apiSupportsFilters != null &&
        _lastFilterTest != null &&
        DateTime.now().difference(_lastFilterTest!).inMinutes < 5) {
      return _apiSupportsFilters!;
    }

    try {
      print('DEBUG: Testando suporte a filtros da API...');

      // Testar com barId=1 (que sempre existe)
      final response = await _dio.get('$_baseUrl/categories', queryParameters: {
        'barId': 1,
      });

      if (response.statusCode == 200) {
        final filteredData = response.data as List;
        final allDataResponse = await _dio.get('$_baseUrl/categories');
        final allData = allDataResponse.data as List;

        // Se os dados filtrados são diferentes dos dados completos, a API suporta filtros
        final supportsFilters = filteredData.length != allData.length;

        _apiSupportsFilters = supportsFilters;
        _lastFilterTest = DateTime.now();

        print('DEBUG: API suporta filtros: $supportsFilters');
        print(
            'DEBUG: Dados filtrados: ${filteredData.length}, Dados completos: ${allData.length}');

        return supportsFilters;
      }
    } catch (e) {
      print('DEBUG: Erro ao testar filtros da API: $e');
    }

    // Em caso de erro, assumir que não suporta filtros
    _apiSupportsFilters = false;
    _lastFilterTest = DateTime.now();
    return false;
  }

  // Buscar categorias de um bar específico
  Future<List<MenuCategoryFromAPI>> fetchCategoriesByBar(int barId) async {
    try {
      // Verificar cache primeiro
      if (_categoriesCache.containsKey(barId)) {
        print('DEBUG: Usando categorias do cache para barId $barId');
        return _categoriesCache[barId]!;
      }

      // Detectar se a API suporta filtros
      final supportsFilters = await _detectApiFilterSupport();

      Response response;
      List<dynamic> categoriesData;

      if (supportsFilters) {
        // API suporta filtros - usar parâmetro barId
        print('DEBUG: API suporta filtros, usando barId=$barId');
        response = await _dio.get('$_baseUrl/categories', queryParameters: {
          'barId': barId,
        });
        categoriesData = response.data;
      } else {
        // API não suporta filtros - buscar tudo e filtrar localmente
        print('DEBUG: API não suporta filtros, filtrando localmente');
        response = await _dio.get('$_baseUrl/categories');
        final allCategoriesData = response.data as List;

        // Filtrar categorias por barId localmente
        categoriesData = allCategoriesData
            .where((category) => category['barId'] == barId)
            .toList();
      }

      if (response.statusCode == 200) {
        print(
            'DEBUG: Categorias carregadas para barId $barId: ${categoriesData.length}');

        if (categoriesData.isNotEmpty) {
          print('DEBUG: Primeira categoria: ${categoriesData.first}');
        }

        final categories = categoriesData
            .map((json) => MenuCategoryFromAPI.fromJson(json))
            .toList();

        // Salvar no cache
        _categoriesCache[barId] = categories;

        return categories;
      } else {
        throw Exception(
            'Falha ao carregar categorias: Status ${response.statusCode}');
      }
    } on DioException catch (e) {
      print(
          'DioError ao buscar categorias: ${e.response?.statusCode} - ${e.response?.data}');
      String errorMessage = 'Falha ao carregar categorias.';
      if (e.response != null &&
          e.response!.data is Map &&
          e.response!.data.containsKey('error')) {
        errorMessage = e.response!.data['error'];
      }
      throw Exception(errorMessage);
    } catch (e) {
      print('Erro inesperado ao buscar categorias: $e');
      throw Exception('Erro desconhecido ao carregar categorias');
    }
  }

  // Buscar itens de um bar específico
  Future<List<MenuItemFromAPI>> fetchItemsByBar(int barId) async {
    try {
      // Verificar cache primeiro
      if (_itemsCache.containsKey(barId)) {
        print('DEBUG: Usando itens do cache para barId $barId');
        return _itemsCache[barId]!;
      }

      // Detectar se a API suporta filtros
      final supportsFilters = await _detectApiFilterSupport();

      Response response;
      List<dynamic> itemsData;

      if (supportsFilters) {
        // API suporta filtros - usar parâmetro barId
        print('DEBUG: API suporta filtros, usando barId=$barId');
        response = await _dio.get('$_baseUrl/items', queryParameters: {
          'barId': barId,
        });
        itemsData = response.data;
      } else {
        // API não suporta filtros - buscar tudo e filtrar localmente
        print('DEBUG: API não suporta filtros, filtrando localmente');
        response = await _dio.get('$_baseUrl/items');
        final allItemsData = response.data as List;

        // Filtrar itens por barId localmente
        itemsData =
            allItemsData.where((item) => item['barId'] == barId).toList();
      }

      if (response.statusCode == 200) {
        print('DEBUG: Itens carregados para barId $barId: ${itemsData.length}');

        if (itemsData.isNotEmpty) {
          print('DEBUG: Primeiro item: ${itemsData.first}');
        }

        final items =
            itemsData.map((json) => MenuItemFromAPI.fromJson(json)).toList();

        // Salvar no cache
        _itemsCache[barId] = items;

        return items;
      } else {
        throw Exception(
            'Falha ao carregar itens: Status ${response.statusCode}');
      }
    } on DioException catch (e) {
      print(
          'DioError ao buscar itens: ${e.response?.statusCode} - ${e.response?.data}');
      String errorMessage = 'Falha ao carregar itens.';
      if (e.response != null &&
          e.response!.data is Map &&
          e.response!.data.containsKey('error')) {
        errorMessage = e.response!.data['error'];
      }
      throw Exception(errorMessage);
    } catch (e) {
      print('Erro inesperado ao buscar itens: $e');
      throw Exception('Erro desconhecido ao carregar itens');
    }
  }

  // Buscar cardápio completo de um bar (categorias + itens agrupados)
  Future<Map<String, List<MenuItemFromAPI>>> fetchMenuByBar(int barId) async {
    try {
      // Verificar cache primeiro
      if (_menuCache.containsKey(barId)) {
        print('DEBUG: Usando cardápio completo do cache para barId $barId');
        return _menuCache[barId]!;
      }

      // Carregar categorias e itens em paralelo para melhor performance
      final futures = await Future.wait([
        fetchCategoriesByBar(barId),
        fetchItemsByBar(barId),
      ]);

      final List<MenuCategoryFromAPI> categories =
          futures[0] as List<MenuCategoryFromAPI>;
      final List<MenuItemFromAPI> items = futures[1] as List<MenuItemFromAPI>;

      print(
          'DEBUG: Processando cardápio - Categorias: ${categories.length}, Itens: ${items.length}');

      // Ordenar categorias por ordem
      categories.sort((a, b) => a.order.compareTo(b.order));

      // Agrupar itens por categoria e subcategoria (igual ao Next.js)
      final Map<String, List<MenuItemFromAPI>> groupedMenu = {};

      for (final MenuCategoryFromAPI category in categories) {
        final List<MenuItemFromAPI> categoryItems = items
            .where((MenuItemFromAPI item) => item.categoryId == category.id)
            .toList();

        // Ordenar itens por ordem
        categoryItems.sort((a, b) => a.order.compareTo(b.order));

        if (categoryItems.isNotEmpty) {
          // Agrupar por subcategoria dentro da categoria
          final Map<String, List<MenuItemFromAPI>> subcategoryGroups = {};

          for (final MenuItemFromAPI item in categoryItems) {
            final subcategoryName = item.subCategoryName?.isNotEmpty == true
                ? item.subCategoryName!
                : 'Geral';

            if (!subcategoryGroups.containsKey(subcategoryName)) {
              subcategoryGroups[subcategoryName] = [];
            }
            subcategoryGroups[subcategoryName]!.add(item);
          }

          // Adicionar ao menu agrupado com chave "Categoria - Subcategoria"
          for (final entry in subcategoryGroups.entries) {
            final key = '${category.name} - ${entry.key}';
            groupedMenu[key] = entry.value;
          }
        }
      }

      print('DEBUG: Cardápio agrupado com ${groupedMenu.length} grupos');

      // Salvar no cache
      _menuCache[barId] = groupedMenu;

      return groupedMenu;
    } catch (e) {
      print('Erro ao buscar cardápio completo: $e');
      rethrow;
    }
  }

  // Função auxiliar para construir URL de imagem válida
  String getValidImageUrl(String? imageUrl) {
    return ApiConfig.getMenuImageUrl(imageUrl);
  }

  // Limpar cache específico de um bar
  void clearCacheForBar(int barId) {
    _menuCache.remove(barId);
    _categoriesCache.remove(barId);
    _itemsCache.remove(barId);
    print('DEBUG: Cache limpo para barId $barId');
  }

  // Limpar todo o cache
  void clearAllCache() {
    _menuCache.clear();
    _categoriesCache.clear();
    _itemsCache.clear();
    _barsCache = null;
    print('DEBUG: Todo o cache foi limpo');
  }

  // Forçar atualização do cardápio de um bar específico
  Future<Map<String, List<MenuItemFromAPI>>> refreshMenuForBar(
      int barId) async {
    clearCacheForBar(barId);
    return await fetchMenuByBar(barId);
  }
}
