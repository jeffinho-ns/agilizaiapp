// lib/screens/home/home_screen.dart

import 'package:agilizaiapp/config/api_config.dart';
import 'package:agilizaiapp/models/event_model.dart';
import 'package:agilizaiapp/models/user_model.dart';
import 'package:agilizaiapp/screens/filter/filter_screen.dart';
import 'package:agilizaiapp/screens/search/search_screen.dart';
import 'package:agilizaiapp/widgets/event_card.dart';
import 'package:agilizaiapp/widgets/event_list_tile.dart';
import 'package:agilizaiapp/screens/event/see_all_events_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:agilizaiapp/services/http_service.dart';
import 'package:dio/dio.dart';
import 'package:agilizaiapp/widgets/app_drawer.dart';

// Importando o modelo do bar, os dados dos bares e a tela de detalhes do bar
import 'package:agilizaiapp/data/bar_data.dart';
import 'package:agilizaiapp/screens/bar/bar_details_screen.dart';

import 'package:agilizaiapp/services/event_service.dart'; // <--- NOVO: Importe o serviço de eventos
import 'package:agilizaiapp/l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  List<Event> _allEvents = [];
  List<Event> _popularEvents = [];
  List<Event> _categorizedEvents = [];

  final List<String> _categories = ['unico', 'semanal'];
  String _selectedCategory = 'semanal';

  User? _currentUser;

  late AnimationController _animationController;
  late Animation<double> _animation;
  late Animation<double> _scaleAnimation;

  static const double _drawerWidthFactor = 0.75;
  double _drawerWidth = 0.0;
  bool _isDrawerOpen = false;

  final EventService _eventService =
      EventService(); // <--- NOVO: Instância do serviço

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(_animation);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _drawerWidth = MediaQuery.of(context).size.width * _drawerWidthFactor;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleDrawer() {
    final animationStatus = _animationController.status;
    final isDrawerOpen = animationStatus == AnimationStatus.completed ||
        animationStatus == AnimationStatus.forward;
    setState(() {
      _isDrawerOpen = !isDrawerOpen;
      if (_isDrawerOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  Future<void> _loadInitialData() async {
    try {
      // Adicionado try-catch para _loadInitialData para tratamento de erro
      final results = await Future.wait([
        _fetchCurrentUser(),
        _eventService
            .fetchAllEvents() // <--- CORREÇÃO AQUI: Usando o EventService
      ]);
      if (mounted) {
        setState(() {
          _currentUser = results[0] as User?;
          // Já é List<Event> por causa do EventService.fetchAllEvents()
          _allEvents = results[1] as List<Event>;
          _popularEvents = _allEvents.take(5).toList();
          _filterEventsByCategory(_selectedCategory);
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Erro ao carregar dados iniciais na Home: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Opcional: Mostrar uma mensagem de erro na tela aqui
        });
      }
    }
  }

  Future<User?> _fetchCurrentUser() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'jwt_token');
    if (token == null || token.isEmpty) {
      return null;
    }
    try {
      final dio = HttpService().dio;
      final response = await dio.get(
        ApiConfig.userEndpoint('me'),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode == 200) {
        return User.fromJson(response.data);
      } else {
        return null;
      }
    } catch (e) {
      print(
          'Erro ao buscar usuário atual na HomeScreen: $e'); // Log para depuração
      return null;
    }
  }

  // <--- REMOVIDO: A função Future<List<Event>> _fetchEvents() não é mais necessária aqui
  // pois foi substituída pela chamada ao EventService acima.
  /*
  Future<List<Event>> _fetchEvents() async {
    // ... código antigo ...
  }
  */

  void _filterEventsByCategory(String category) {
    setState(() {
      _selectedCategory = category;
      
      // Debug: verificar tipos de eventos disponíveis
      final tiposUnicos = _allEvents.where((e) => e.tipoEvento?.toLowerCase() == 'unico').length;
      final tiposSemanais = _allEvents.where((e) => e.tipoEvento?.toLowerCase() == 'semanal').length;
      print('DEBUG: Total de eventos: ${_allEvents.length}');
      print('DEBUG: Eventos únicos: $tiposUnicos');
      print('DEBUG: Eventos semanais: $tiposSemanais');
      print('DEBUG: Categoria selecionada: $category');
      
      // Filtrar eventos pela categoria selecionada
      _categorizedEvents = _allEvents
          .where((event) {
            final tipo = event.tipoEvento?.toLowerCase().trim();
            final categoriaLower = category.toLowerCase().trim();
            final matches = tipo == categoriaLower;
            
            // Debug para eventos que não correspondem
            if (!matches && event.tipoEvento != null) {
              print('DEBUG: Evento "${event.nomeDoEvento}" tem tipo "${event.tipoEvento}" (esperado: "$category")');
            }
            
            return matches;
          })
          .toList();
      
      print('DEBUG: Eventos filtrados para "$category": ${_categorizedEvents.length}');
    });
  }

  String _getCategoryDisplayName(String category) {
    // ... (permanece o mesmo) ...
    switch (category) {
      case 'unico':
        return 'Eventos Únicos';
      case 'semanal':
        return 'Eventos Semanais';
      default:
        return category;
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... (restante do build permanece o mesmo) ...
    return Scaffold(
      backgroundColor: const Color(0xFF2B3245),
      body: Stack(
        children: [
          SizedBox(
            width: _drawerWidth,
            child: AppDrawer(onClose: _toggleDrawer),
          ),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final offsetX = _animation.value * _drawerWidth;
              final borderRadius = _animation.value * 30.0;
              return Transform.translate(
                offset: Offset(offsetX, 0),
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: _isDrawerOpen ? _toggleDrawer : null,
                    child: AbsorbPointer(
                      absorbing: _isDrawerOpen,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(borderRadius),
                        child: child,
                      ),
                    ),
                  ),
                ),
              );
            },
            child: Container(
              color: const Color(0xFF242A38),
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    backgroundColor: const Color(0xFF242A38),
                    expandedHeight: 530.0,
                    floating: false,
                    pinned: true,
                    automaticallyImplyLeading: false,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Column(
                        children: [
                          _buildHeader(),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.popularEvents,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const SeeAllEventsScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    AppLocalizations.of(context)!.viewAll,
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 280,
                            child: _isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  )
                                : _popularEvents.isEmpty
                                    ? const Center(
                                        child: Text(
                                          'Nenhum evento popular encontrado.', // Traduzido
                                          style:
                                              TextStyle(color: Colors.white70),
                                        ),
                                      )
                                    : ListView.builder(
                                        padding: const EdgeInsets.only(
                                          left: 16,
                                          right: 16,
                                        ),
                                        clipBehavior: Clip.none,
                                        scrollDirection: Axis.horizontal,
                                        itemCount: _popularEvents.length,
                                        itemBuilder: (context, index) {
                                          final event = _popularEvents[index];
                                          return EventCard(event: event);
                                        },
                                      ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      color: const Color(0xFF242A38),
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              'Conheça Nossos Bares 🍻',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              itemCount: allBars.length,
                              itemBuilder: (context, index) {
                                final bar = allBars[index];
                                return Padding(
                                  padding: const EdgeInsets.only(right: 16.0),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              BarDetailsScreen(bar: bar),
                                        ),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      width: 80,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.2),
                                            spreadRadius: 1,
                                            blurRadius: 3,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.asset(
                                          bar.logoAssetPath,
                                          fit: BoxFit.contain,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Container(
                                              color: Colors.grey[200],
                                              child: const Icon(
                                                  Icons.broken_image,
                                                  color: Colors.grey),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.only(top: 20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Escolha por Tipo de Evento ✨',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const SeeAllEventsScreen(),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        AppLocalizations.of(context)!.viewAll,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  height: 40,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _categories.length,
                                    itemBuilder: (context, index) {
                                      final category = _categories[index];
                                      final isSelected =
                                          category == _selectedCategory;
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          right: 8.0,
                                        ),
                                        child: ChoiceChip(
                                          label: Text(
                                            _getCategoryDisplayName(category),
                                          ),
                                          selected: isSelected,
                                          onSelected: (selected) {
                                            _filterEventsByCategory(category);
                                          },
                                          backgroundColor: Colors.grey[200],
                                          selectedColor: const Color(
                                            0xFFF26422,
                                          ),
                                          labelStyle: TextStyle(
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          side: BorderSide.none,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          _isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.grey,
                                  ),
                                )
                              : _categorizedEvents.isEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                      ),
                                      child: Text(
                                        'Nenhum evento na categoria "${_getCategoryDisplayName(_selectedCategory)}".',
                                        style:
                                            const TextStyle(color: Colors.grey),
                                      ),
                                    )
                                  : ListView.builder(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                      ),
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: _categorizedEvents.length,
                                      itemBuilder: (context, index) {
                                        final event = _categorizedEvents[index];
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 16.0,
                                          ),
                                          child: EventListTile(event: event),
                                        );
                                      },
                                    ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final bool hasProfileImage = _currentUser?.fotoPerfil != null &&
        _currentUser!.fotoPerfil!.isNotEmpty;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: _toggleDrawer,
                  child: CircleAvatar(
                    radius: 24,
                    backgroundImage: hasProfileImage
                        ? NetworkImage(_currentUser!.fotoPerfil!)
                        : null,
                    onBackgroundImageError: hasProfileImage
                        ? (e, s) => print('Erro ao carregar imagem: $e')
                        : null,
                    child: hasProfileImage
                        ? null
                        : const Icon(
                            Icons.person,
                            size: 28,
                            color: Colors.white,
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.hiWelcome,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    Text(
                      _currentUser?.name ?? 'Carregando...',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Localização atual',
                      style: TextStyle(color: Colors.white70),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _currentUser?.cidade != null &&
                                  _currentUser!.cidade!.isNotEmpty
                              ? '${_currentUser!.cidade}, ${_currentUser!.estado ?? ''}'
                              : 'Não definida',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    readOnly: true,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SearchScreen(),
                        ),
                      );
                    },
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.findAmazingEvents,
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.filter_list, color: Colors.white),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(12),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const FilterScreen(),
                        fullscreenDialog: true,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
