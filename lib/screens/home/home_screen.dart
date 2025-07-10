import 'dart:convert';

import 'package:agilizaiapp/models/event_model.dart';

import 'package:agilizaiapp/models/user_model.dart';

// Imports das novas telas

import 'package:agilizaiapp/screens/filter/filter_screen.dart';

import 'package:agilizaiapp/screens/search/search_screen.dart';

import 'package:agilizaiapp/widgets/event_card.dart';

import 'package:agilizaiapp/widgets/event_list_tile.dart';

import 'package:agilizaiapp/screens/event/see_all_events_screen.dart';

import 'package:flutter/material.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:http/http.dart' as http;

import 'package:agilizaiapp/widgets/app_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;

  List<Event> _popularEvents = [];

  User? _currentUser;

  final List<String> _categories = ['Design', 'Art', 'Sports', 'Music', 'Food'];

  String _selectedCategory = 'Design';

  late AnimationController _animationController;

  late Animation<double> _animation;

  late Animation<double> _scaleAnimation;

  static const double _drawerWidthFactor = 0.75;

  double _drawerWidth = 0.0;

  bool _isDrawerOpen = false;

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

    final isDrawerOpen =
        animationStatus == AnimationStatus.completed ||
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
    final results = await Future.wait([_fetchCurrentUser(), _fetchEvents()]);

    if (mounted) {
      setState(() {
        _currentUser = results[0] as User?;

        _popularEvents = results[1] as List<Event>;

        _isLoading = false;
      });
    }
  }

  Future<User?> _fetchCurrentUser() async {
    const storage = FlutterSecureStorage();

    final token = await storage.read(key: 'jwt_token');

    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      final response = await http
          .get(
            Uri.parse('https://vamos-comemorar-api.onrender.com/api/users/me'),

            headers: {
              'Content-Type': 'application/json',

              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<List<Event>> _fetchEvents() async {
    try {
      final response = await http
          .get(
            Uri.parse('https://vamos-comemorar-api.onrender.com/api/events/'),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> eventData = jsonDecode(response.body);

        return eventData.map((json) => Event.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
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
                                const Text(
                                  'Popular Events 🔥',

                                  style: TextStyle(
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

                                  child: const Text(
                                    'VIEW ALL',

                                    style: TextStyle(color: Colors.white70),
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
                                      'Nenhum evento popular encontrado.',

                                      style: TextStyle(color: Colors.white70),
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
                                      'Choose By Category ✨',

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

                                      child: const Text('VIEW ALL'),
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
                                          label: Text(category),

                                          selected: isSelected,

                                          onSelected: (selected) {
                                            setState(() {
                                              _selectedCategory = category;
                                            });
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

                          ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),

                            shrinkWrap: true,

                            physics: const NeverScrollableScrollPhysics(),

                            itemCount: _popularEvents.length,

                            itemBuilder: (context, index) {
                              final event = _popularEvents[index];

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),

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

  // --- WIDGET DO HEADER (COM AS ALTERAÇÕES) ---

  Widget _buildHeader() {
    final bool hasProfileImage =
        _currentUser?.fotoPerfil != null &&
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
                    const Text(
                      'Hi Welcome 👋',

                      style: TextStyle(color: Colors.white70),
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
                      'Current location',

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
                  // --- ALTERAÇÃO 1: NAVEGAÇÃO AO TOCAR NO CAMPO DE BUSCA ---
                  child: TextField(
                    readOnly: true, // Impede que o teclado abra

                    onTap: () {
                      // Navega para a tela de busca

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SearchScreen(),
                        ),
                      );
                    },

                    decoration: InputDecoration(
                      hintText: 'Find amazing events',

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

                // --- ALTERAÇÃO 2: NAVEGAÇÃO AO TOCAR NO BOTÃO DE FILTRO ---
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
                    // Navega para a tela de filtro

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const FilterScreen(),

                        fullscreenDialog: true, // Abre a tela como um modal
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
