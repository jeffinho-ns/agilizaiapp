// lib/screens/bar/bar_menu_screen.dart

import 'package:flutter/material.dart';
import 'package:agilizaiapp/models/menu_models.dart';
import 'package:agilizaiapp/services/menu_service.dart';

// Constantes dos selos (igual ao Next.js)
const Map<String, Map<String, String>> FOOD_SEALS = {
  'especial-do-dia': {'name': 'Especial do Dia', 'color': '#FF6B35'},
  'vegetariano': {'name': 'Vegetariano', 'color': '#4CAF50'},
  'saudavel-leve': {'name': 'Saudável/Leve', 'color': '#8BC34A'},
  'prato-da-casa': {'name': 'Prato da Casa', 'color': '#FF9800'},
  'artesanal': {'name': 'Artesanal', 'color': '#795548'},
};

const Map<String, Map<String, String>> DRINK_SEALS = {
  'assinatura-bartender': {
    'name': 'Assinatura do Bartender',
    'color': '#9C27B0'
  },
  'edicao-limitada': {'name': 'Edição Limitada', 'color': '#E91E63'},
  'processo-artesanal': {'name': 'Processo Artesanal', 'color': '#673AB7'},
  'sem-alcool': {'name': 'Sem Álcool', 'color': '#00BCD4'},
  'refrescante': {'name': 'Refrescante', 'color': '#00E5FF'},
  'citrico': {'name': 'Cítrico', 'color': '#FFEB3B'},
  'doce': {'name': 'Doce', 'color': '#FFC107'},
};

// --- WIDGET DA TELA ---

class BarMenuScreen extends StatefulWidget {
  final int barId; // Alterado para int barId
  final Color appBarColor;

  const BarMenuScreen({
    super.key,
    required this.barId, // Agora espera barId
    this.appBarColor = Colors.deepPurple,
  });

  @override
  State<BarMenuScreen> createState() => _BarMenuScreenState();
}

class _BarMenuScreenState extends State<BarMenuScreen> {
  List<MenuCategory> _currentMenu = [];
  String _barName = 'Cardápio';
  bool _isLoading = true;
  String? _error;
  final MenuService _menuService = MenuService();
  final ScrollController _scrollController = ScrollController();

  // Controle do menu pegajoso
  String _selectedCategory = '';
  String _selectedSubcategory = '';
  final Map<String, GlobalKey> _categoryKeys = {};
  final Map<String, GlobalKey> _subcategoryKeys = {};

  @override
  void initState() {
    super.initState();
    _loadMenu();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // Listener de scroll para detectar categoria ativa
  void _onScroll() {
    if (!_scrollController.hasClients || _currentMenu.isEmpty) return;

    final screenHeight = MediaQuery.of(context).size.height;
    final menuHeight = 90.0; // Altura do menu pegajoso
    final threshold = screenHeight * 0.2; // 20% da tela para detecção

    String? newSelectedCategory;
    String? newSelectedSubcategory;

    // Detectar categoria ativa baseada na posição do scroll
    for (final category in _currentMenu) {
      final key = _categoryKeys[category.name];
      if (key?.currentContext != null) {
        final RenderBox? renderBox =
            key!.currentContext!.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          final position = renderBox.localToGlobal(Offset.zero);
          final categoryTop = position.dy - menuHeight;
          final categoryBottom = categoryTop + renderBox.size.height;

          // Se a categoria está visível na tela
          if (categoryTop <= threshold && categoryBottom >= threshold) {
            newSelectedCategory = category.name;

            // Detectar subcategoria ativa dentro da categoria
            for (final subcategory in category.subcategories) {
              final subKey = _subcategoryKeys['${category.name}-$subcategory'];
              if (subKey?.currentContext != null) {
                final RenderBox? subRenderBox =
                    subKey!.currentContext!.findRenderObject() as RenderBox?;
                if (subRenderBox != null) {
                  final subPosition = subRenderBox.localToGlobal(Offset.zero);
                  final subcategoryTop = subPosition.dy - menuHeight;
                  final subcategoryBottom =
                      subcategoryTop + subRenderBox.size.height;

                  // Se a subcategoria está visível na tela
                  if (subcategoryTop <= threshold &&
                      subcategoryBottom >= threshold) {
                    newSelectedSubcategory = subcategory;
                    break;
                  }
                }
              }
            }
            break;
          }
        }
      }
    }

    // Atualizar estado apenas se houver mudanças
    if (newSelectedCategory != null &&
        (newSelectedCategory != _selectedCategory ||
            newSelectedSubcategory != _selectedSubcategory)) {
      setState(() {
        _selectedCategory = newSelectedCategory!;
        _selectedSubcategory = newSelectedSubcategory ?? '';
      });
    }
  }

  Future<void> _loadMenu() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print(
          'DEBUG: Iniciando carregamento do cardápio para barId ${widget.barId}');

      // Carregar cardápio com timeout para evitar travamentos
      final menuData = await _menuService
          .fetchMenuByBar(widget.barId)
          .timeout(const Duration(seconds: 30));

      // Buscar informações do bar apenas se necessário
      List<BarFromAPI> bars = [];
      try {
        bars =
            await _menuService.fetchBars().timeout(const Duration(seconds: 10));
      } catch (e) {
        print('DEBUG: Erro ao buscar bares, continuando sem nome do bar: $e');
      }

      // Processar dados de forma otimizada
      await _processMenuData(menuData, bars);

      print(
          'DEBUG: Cardápio carregado com sucesso - ${menuData.length} grupos');
    } catch (e) {
      print('DEBUG: Erro ao carregar cardápio: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _barName = 'Erro ao carregar cardápio';
      });
    }
  }

  // Processar dados do menu de forma otimizada
  Future<void> _processMenuData(
    Map<String, List<MenuItemFromAPI>> menuData,
    List<BarFromAPI> bars,
  ) async {
    print('DEBUG: Processando dados do menu - ${menuData.length} grupos');

    // Converter dados da API para o formato da UI (agrupado por categoria e subcategoria)
    final List<MenuCategory> categories = [];
    final Map<String, Map<String, List<MenuItem>>> categoryGroups = {};

    // Processar itens de forma mais eficiente
    for (final entry in menuData.entries) {
      final key = entry.key; // Formato: "Categoria - Subcategoria"
      final items = entry.value;

      // Extrair nome da categoria e subcategoria
      final parts = key.split(' - ');
      final categoryName = parts[0];
      final subcategoryName = parts.length > 1 ? parts[1] : 'Geral';

      if (!categoryGroups.containsKey(categoryName)) {
        categoryGroups[categoryName] = {};
      }
      if (!categoryGroups[categoryName]!.containsKey(subcategoryName)) {
        categoryGroups[categoryName]![subcategoryName] = [];
      }

      // Converter itens de forma otimizada
      for (final item in items) {
        final menuItem = MenuItem.fromAPI(
            item, _menuService.getValidImageUrl(item.imageUrl));
        categoryGroups[categoryName]![subcategoryName]!.add(menuItem);
      }
    }

    // Converter para lista de categorias com subcategorias
    for (final entry in categoryGroups.entries) {
      final categoryName = entry.key;
      final subcategories = entry.value;

      // Criar chaves para ancoragem
      _categoryKeys[categoryName] = GlobalKey();

      // Converter subcategorias para lista de itens
      final List<MenuItem> allItems = [];
      for (final subcategoryEntry in subcategories.entries) {
        final subcategoryName = subcategoryEntry.key;
        final items = subcategoryEntry.value;

        _subcategoryKeys['$categoryName-$subcategoryName'] = GlobalKey();
        allItems.addAll(items);
      }

      categories.add(MenuCategory(
        name: categoryName,
        items: allItems,
        subcategories: subcategories.keys.toList(),
      ));
    }

    // Inicializar seleção
    if (categories.isNotEmpty) {
      _selectedCategory = categories.first.name;
      if (categories.first.subcategories.isNotEmpty) {
        _selectedSubcategory = categories.first.subcategories.first;
      }
    }

    // Encontrar o nome do bar
    if (bars.isNotEmpty) {
      try {
        final bar = bars.firstWhere(
          (bar) => bar.id == widget.barId,
          orElse: () => bars.first,
        );
        _barName = bar.name;
      } catch (e) {
        print('DEBUG: Erro ao encontrar nome do bar: $e');
        _barName = 'Cardápio';
      }
    } else {
      _barName = 'Cardápio';
    }

    print('DEBUG: Menu processado - ${categories.length} categorias');

    if (mounted) {
      setState(() {
        _currentMenu = categories;
        _isLoading = false;
        _error = null;

        // Selecionar primeira categoria se disponível
        if (categories.isNotEmpty) {
          _selectedCategory = categories.first.name;
          if (categories.first.subcategories.isNotEmpty) {
            _selectedSubcategory = categories.first.subcategories.first;
          }
        }
      });
    }
  }

  // Widget para exibir selos
  Widget _buildSeals(List<String> seals, {bool isCompact = false}) {
    if (seals.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: isCompact ? 3 : 6,
      runSpacing: isCompact ? 2 : 4,
      children: seals.map((seal) {
        try {
          // Verificar se é um selo de comida ou bebida
          final sealInfo = FOOD_SEALS[seal] ?? DRINK_SEALS[seal];
          if (sealInfo == null) return const SizedBox.shrink();

          final colorString = sealInfo['color'] ?? '#000000';
          final color = Color(int.parse(colorString.replaceAll('#', '0xFF')));

          return Container(
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 4 : 8,
              vertical: isCompact ? 2 : 4,
            ),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(isCompact ? 8 : 12),
            ),
            child: Text(
              sealInfo['name'] ?? seal,
              style: TextStyle(
                color: Colors.white,
                fontSize: isCompact ? 8 : 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        } catch (e) {
          print('Erro ao processar selo $seal: $e');
          return const SizedBox.shrink();
        }
      }).toList(),
    );
  }

  // Widget para o menu mobile (igual ao Next.js)
  Widget _buildMobileMenu() {
    return Column(
      children: [
        // Menu pegajoso de categorias e subcategorias
        _buildStickyMenu(),
        // Conteúdo com scroll
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _currentMenu.map((category) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título da categoria
                    Container(
                      key: _categoryKeys[category.name],
                      padding: const EdgeInsets.only(top: 32.0, bottom: 16.0),
                      child: Text(
                        category.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    // Subcategorias
                    if (category.subcategories.isNotEmpty) ...[
                      for (final subcategory in category.subcategories) ...[
                        Container(
                          key:
                              _subcategoryKeys['${category.name}-$subcategory'],
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            subcategory,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        // Grid de itens da subcategoria (2 colunas)
                        _buildItemsGrid(category.items.where((item) {
                          // Filtrar itens da subcategoria específica
                          // Por enquanto, mostrar todos os itens da categoria
                          return true;
                        }).toList()),
                        const SizedBox(height: 24),
                      ],
                    ] else ...[
                      // Grid de itens da categoria (2 colunas)
                      _buildItemsGrid(category.items),
                    ],
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  // Widget para o menu pegajoso
  Widget _buildStickyMenu() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Menu de categorias
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _currentMenu.length,
              itemBuilder: (context, index) {
                final category = _currentMenu[index];
                final isSelected = _selectedCategory == category.name;

                return GestureDetector(
                  onTap: () => _scrollToCategory(category.name),
                  child: Container(
                    alignment: Alignment.center,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? widget.appBarColor : Colors.grey[200],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      category.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Menu de subcategorias (se houver)
          if (_selectedCategory.isNotEmpty) ...[
            Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _currentMenu
                    .firstWhere((cat) => cat.name == _selectedCategory,
                        orElse: () => MenuCategory(name: '', items: []))
                    .subcategories
                    .length,
                itemBuilder: (context, index) {
                  final subcategory = _currentMenu
                      .firstWhere((cat) => cat.name == _selectedCategory,
                          orElse: () => MenuCategory(name: '', items: []))
                      .subcategories[index];
                  final isSelected = _selectedSubcategory == subcategory;

                  return GestureDetector(
                    onTap: () =>
                        _scrollToSubcategory(_selectedCategory, subcategory),
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue[600] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        subcategory,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.white : Colors.black54,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Widget para o grid de itens
  Widget _buildItemsGrid(List<MenuItem> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7, // Ajustado para evitar overflow
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildMenuItemCard(item);
      },
    );
  }

  // Métodos para scroll para categorias e subcategorias
  void _scrollToCategory(String categoryName) {
    final key = _categoryKeys[categoryName];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      setState(() {
        _selectedCategory = categoryName;
        _selectedSubcategory = '';
      });
    }
  }

  void _scrollToSubcategory(String categoryName, String subcategoryName) {
    final key = _subcategoryKeys['$categoryName-$subcategoryName'];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      setState(() {
        _selectedCategory = categoryName;
        _selectedSubcategory = subcategoryName;
      });
    }
  }

  // Widget para o card do item (igual ao Next.js mobile)
  Widget _buildMenuItemCard(MenuItem item) {
    return GestureDetector(
      onTap: () => _showItemDetails(item),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem do item
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Stack(
                  children: [
                    Image.network(
                      item.imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.broken_image,
                            color: Colors.grey[600],
                            size: 40,
                          ),
                        );
                      },
                    ),
                    // Badge de preço
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          'R\$ ${item.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Conteúdo do card
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Nome do item
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    // Descrição
                    Text(
                      item.description,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Selos (com tamanho reduzido)
                    Expanded(
                      child: _buildSeals(item.seals, isCompact: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Mostrar detalhes do item (modal completo)
  void _showItemDetails(MenuItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildItemDetailModal(item),
    );
  }

  // Modal de detalhes do item (igual ao Next.js)
  Widget _buildItemDetailModal(MenuItem item) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle do modal
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Conteúdo do modal
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagem do item
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      item.imageUrl,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 200,
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.broken_image,
                            color: Colors.grey[600],
                            size: 50,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Nome e preço
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Text(
                        'R\$ ${item.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: widget.appBarColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Descrição
                  Text(
                    item.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Selos
                  if (item.seals.isNotEmpty) ...[
                    const Text(
                      'Características:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSeals(item.seals),
                    const SizedBox(height: 20),
                  ],
                  // Toppings (adicionais)
                  if (item.toppings.isNotEmpty) ...[
                    const Text(
                      'Adicionais:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...item.toppings.map((topping) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                topping.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                ),
                              ),
                              Text(
                                '+R\$ ${topping.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _barName,
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: widget.appBarColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Carregando cardápio...',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Erro ao carregar cardápio',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadMenu,
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                )
              : _currentMenu.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.restaurant_menu,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Cardápio não disponível',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Este estabelecimento ainda não possui itens cadastrados no cardápio.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[500],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _loadMenu,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Tentar novamente'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: widget.appBarColor,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _buildMobileMenu(),
    );
  }
}
