// lib/screens/guests/guest_list_management_screen.dart

import 'package:flutter/material.dart';
import 'package:agilizaiapp/models/event_model.dart';
import 'package:agilizaiapp/models/guest_model.dart';
import 'package:agilizaiapp/models/user_model.dart';
import 'package:agilizaiapp/services/guest_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class GuestListManagementScreen extends StatefulWidget {
  final Event event;

  const GuestListManagementScreen({super.key, required this.event});

  @override
  State<GuestListManagementScreen> createState() =>
      _GuestListManagementScreenState();
}

class _GuestListManagementScreenState extends State<GuestListManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GuestService _guestService = GuestService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  List<Guest> _guests = [];
  List<GuestCount> _guestCounts = [];
  bool _isLoadingGuests = true;
  bool _isLoadingCounts = true;
  String _guestSearchQuery = '';
  final TextEditingController _addGuestNameController = TextEditingController();
  final TextEditingController _addGuestDocumentController =
      TextEditingController();
  String _selectedGuestListType = 'Geral';

  final TextEditingController _newListNameController = TextEditingController();
  final TextEditingController _newListCreatorDocumentController =
      TextEditingController();
  String _selectedNewGuestListType = 'Convidado';

  User? _currentUser;
  bool _isLoadingCurrentUser = true;

  final List<String> _listTypes = ['Geral', 'VIP', 'Camarote', 'Cortesia'];

  final List<String> _newListTypes = ['VIP', 'Pista', 'Camarote', 'Convidado'];

  // Nova estrutura para armazenar as contagens agrupadas
  Map<String, Map<String, int>> _groupedGuestCounts = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchGuestsAndCounts();
    _loadCurrentUserFromToken();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _addGuestNameController.dispose();
    _addGuestDocumentController.dispose();
    _newListNameController.dispose();
    _newListCreatorDocumentController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUserFromToken() async {
    setState(() {
      _isLoadingCurrentUser = true;
    });
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null || token.isEmpty) {
        print('DEBUG: Token JWT não encontrado.');
        _currentUser = null;
        return;
      }

      final response = await http.get(
        Uri.parse('https://vamos-comemorar-api.onrender.com/api/users/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        _currentUser = User.fromJson(userData);
        print(
            'DEBUG: Usuário logado carregado com sucesso: ${_currentUser?.name}');
      } else {
        print(
            'DEBUG: Falha ao carregar usuário: ${response.statusCode} - ${response.body}');
        _currentUser = null;
      }
    } catch (e) {
      print('Erro ao carregar usuário logado do token/API: $e');
      _currentUser = null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Erro ao carregar dados do usuário: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoadingCurrentUser = false;
      });
    }
  }

  Future<void> _fetchGuestsAndCounts() async {
    await Future.wait([
      _fetchGuests(),
      _fetchGuestCounts(),
    ]);
    // Após buscar os convidados, agrupe-os
    _groupGuestsByListAndCreator(); // Chama a nova função de agrupamento
  }

  Future<void> _fetchGuests() async {
    setState(() {
      _isLoadingGuests = true;
    });
    try {
      final fetchedGuests =
          await _guestService.fetchGuestsByEvent(widget.event.id);
      setState(() {
        _guests = fetchedGuests;
        _isLoadingGuests = false;
      });
    } catch (e) {
      print('Erro ao buscar convidados: $e');
      setState(() {
        _isLoadingGuests = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar convidados: ${e.toString()}')),
      );
    }
  }

  Future<void> _fetchGuestCounts() async {
    setState(() {
      _isLoadingCounts = true;
    });
    try {
      final fetchedCounts =
          await _guestService.fetchGuestCounts(widget.event.id);
      setState(() {
        _guestCounts = fetchedCounts;
        _isLoadingCounts = false;
      });
    } catch (e) {
      print('Erro ao buscar contagens: $e');
      setState(() {
        _isLoadingCounts = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar contagens: ${e.toString()}')),
      );
    }
  }

  // **NOVA FUNÇÃO:** Agrupa convidados por tipo de lista e nome do criador
  void _groupGuestsByListAndCreator() {
    _groupedGuestCounts = {}; // Limpa o mapa antes de preencher

    for (var guest in _guests) {
      final listType = guest.lista;
      final creatorName = guest.creatorName ??
          'Desconhecido'; // Usa 'Desconhecido' se não houver criador

      _groupedGuestCounts.putIfAbsent(listType, () => {});
      _groupedGuestCounts[listType]!
          .update(creatorName, (value) => value + 1, ifAbsent: () => 1);
    }
    // Opcional: ordenar os tipos de lista e criadores para exibição consistente
    _groupedGuestCounts = Map.fromEntries(
      _groupedGuestCounts.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key)),
    );
    _groupedGuestCounts.forEach((listType, creators) {
      _groupedGuestCounts[listType] = Map.fromEntries(
        creators.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
      );
    });
  }

  Future<void> _addGuestManually() async {
    if (_addGuestNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, insira o nome do convidado.')),
      );
      return;
    }
    try {
      await _guestService.addGuests(
        widget.event.id,
        [_addGuestNameController.text.trim()],
        lista: _selectedGuestListType,
        documento: _addGuestDocumentController.text.trim().isEmpty
            ? null
            : _addGuestDocumentController.text.trim(),
      );
      _addGuestNameController.clear();
      _addGuestDocumentController.clear();
      _selectedGuestListType = 'Geral';
      Navigator.of(context).pop();
      _fetchGuestsAndCounts(); // Isso vai chamar _groupGuestsByListAndCreator novamente
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Convidado adicionado com sucesso!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Falha ao adicionar convidado: ${e.toString()}')),
      );
    }
  }

  Future<void> _createNewGuestList() async {
    if (_newListNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, insira o nome da nova lista.')),
      );
      return;
    }
    if (_currentUser == null || _currentUser!.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Não foi possível obter os dados do criador da lista. Tente novamente.')),
      );
      return;
    }

    try {
      await _guestService.createNewGuestList(
        eventId: widget.event.id,
        listName: _newListNameController.text.trim(),
        creatorId: _currentUser!.id.toString(),
        listType: _selectedNewGuestListType,
        creatorDocument: _newListCreatorDocumentController.text.trim().isEmpty
            ? null
            : _newListCreatorDocumentController.text.trim(),
      );

      _newListNameController.clear();
      _newListCreatorDocumentController.clear();
      _selectedNewGuestListType = 'Convidado';
      Navigator.of(context).pop();
      _fetchGuestsAndCounts(); // Isso vai chamar _groupGuestsByListAndCreator novamente
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nova lista criada com sucesso!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao criar nova lista: ${e.toString()}')),
      );
    }
  }

  Future<void> _exportGuestsToCsv() async {
    try {
      final csvContent = await _guestService.exportGuestsCsv(widget.event.id);
      print('CSV Conteúdo:\n$csvContent');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CSV de convidados gerado com sucesso!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao exportar CSV: ${e.toString()}')),
      );
    }
  }

  void _showAddGuestOptionsDialog() {
    bool createNewList = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSB) {
            return AlertDialog(
              title: const Text('Opções de Adição'),
              content: _isLoadingCurrentUser
                  ? const SizedBox(
                      height: 150,
                      child: Center(child: CircularProgressIndicator()))
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RadioListTile<bool>(
                          title:
                              const Text('Criar Nova Lista para este evento'),
                          value: true,
                          groupValue: createNewList,
                          onChanged: (value) {
                            setStateSB(() {
                              createNewList = value!;
                            });
                          },
                        ),
                        RadioListTile<bool>(
                          title: const Text(
                              'Adicionar Convidado à lista existente'),
                          value: false,
                          groupValue: createNewList,
                          onChanged: (value) {
                            setStateSB(() {
                              createNewList = value!;
                            });
                          },
                        ),
                        const Divider(),
                        if (createNewList) ...[
                          const SizedBox(height: 10),
                          TextField(
                            controller: _newListNameController,
                            decoration: const InputDecoration(
                                labelText: 'Nome da Nova Lista'),
                          ),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Criador da Lista:'),
                            subtitle: Text(
                                _currentUser?.name ?? 'Não disponível',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ),
                          TextField(
                            controller: _newListCreatorDocumentController,
                            decoration: const InputDecoration(
                                labelText: 'Documento do Criador (Opcional)'),
                          ),
                          DropdownButtonFormField<String>(
                            value: _selectedNewGuestListType,
                            decoration: const InputDecoration(
                                labelText: 'Tipo da Nova Lista'),
                            items: _newListTypes
                                .map((type) => DropdownMenuItem(
                                    value: type, child: Text(type)))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setStateSB(() {
                                  _selectedNewGuestListType = value;
                                });
                              }
                            },
                          ),
                        ] else ...[
                          const SizedBox(height: 10),
                          TextField(
                            controller: _addGuestNameController,
                            decoration: const InputDecoration(
                                labelText: 'Nome do Convidado'),
                          ),
                          TextField(
                            controller: _addGuestDocumentController,
                            decoration: const InputDecoration(
                                labelText: 'Documento (Opcional)'),
                          ),
                          DropdownButtonFormField<String>(
                            value: _selectedGuestListType,
                            decoration: const InputDecoration(
                                labelText: 'Tipo de Lista'),
                            items: _listTypes
                                .map((type) => DropdownMenuItem(
                                    value: type, child: Text(type)))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setStateSB(() {
                                  _selectedGuestListType = value;
                                });
                              }
                            },
                          ),
                        ],
                      ],
                    ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _addGuestNameController.clear();
                    _addGuestDocumentController.clear();
                    _newListNameController.clear();
                    _newListCreatorDocumentController.clear();
                    _selectedNewGuestListType = 'Convidado';
                    _selectedGuestListType = 'Geral';
                  },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_isLoadingCurrentUser) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Aguarde enquanto os dados do usuário são carregados.')),
                      );
                      return;
                    }
                    if (createNewList) {
                      _createNewGuestList();
                    } else {
                      _addGuestManually();
                    }
                  },
                  child: Text(
                      createNewList ? 'Criar Lista' : 'Adicionar Convidado'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditGuestDialog(Guest guest) {
    _addGuestNameController.text = guest.nome;
    _addGuestDocumentController.text = guest.documento ?? '';
    _selectedGuestListType = guest.lista;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSB) {
            return AlertDialog(
              title: const Text('Editar Convidado'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _addGuestNameController,
                    decoration:
                        const InputDecoration(labelText: 'Nome do Convidado'),
                  ),
                  TextField(
                    controller: _addGuestDocumentController,
                    decoration: const InputDecoration(
                        labelText: 'Documento (Opcional)'),
                  ),
                  DropdownButtonFormField<String>(
                    value: _selectedGuestListType,
                    decoration:
                        const InputDecoration(labelText: 'Tipo de Lista'),
                    items: _listTypes
                        .map((type) =>
                            DropdownMenuItem(value: type, child: Text(type)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setStateSB(() {
                          _selectedGuestListType = value;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _addGuestNameController.clear();
                    _addGuestDocumentController.clear();
                  },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await _guestService.updateGuest(
                        guest.id,
                        nome: _addGuestNameController.text.trim(),
                        documento:
                            _addGuestDocumentController.text.trim().isEmpty
                                ? null
                                : _addGuestDocumentController.text.trim(),
                        lista: _selectedGuestListType,
                      );
                      _addGuestNameController.clear();
                      _addGuestDocumentController.clear();
                      _fetchGuestsAndCounts();
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Convidado atualizado com sucesso!')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Falha ao atualizar convidado: ${e.toString()}')),
                      );
                    }
                  },
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteGuest(int guestId) async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover Convidado'),
        content: const Text('Tem certeza que deseja remover este convidado?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Não')),
          ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Sim')),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _guestService.deleteGuest(guestId);
        _fetchGuestsAndCounts();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Convidado removido com sucesso!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Falha ao remover convidado: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gerenciar Convidados: ${widget.event.nomeDoEvento ?? ''}'),
        backgroundColor: const Color(0xFF242A38),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Dashboard', icon: Icon(Icons.dashboard)),
            Tab(text: 'Convidados', icon: Icon(Icons.people)),
            Tab(text: 'Reservas', icon: Icon(Icons.table_bar)),
          ],
          labelColor: const Color(0xFFF26422),
          unselectedLabelColor: Colors.white70,
          indicatorColor: const Color(0xFFF26422),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDashboardTab(),
          _buildGuestsListTab(),
          _buildReservationsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddGuestOptionsDialog,
        backgroundColor: const Color(0xFFF26422),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildDashboardTab() {
    int totalGuests = _guests.length;
    return _isLoadingCounts || _isLoadingGuests
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total de Convidados:',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('$totalGuests',
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFF26422))),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Contagem por Tipo de Lista e Criador:',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                _groupedGuestCounts.isEmpty
                    ? const Text('Nenhuma lista ou convidado disponível.')
                    : Expanded(
                        // Adicione Expanded para que a lista ocupe o espaço restante
                        child: ListView(
                          children: _groupedGuestCounts.entries.map((entry) {
                            final listType = entry.key;
                            final creators = entry.value;
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              child: ExpansionTile(
                                title: Text(
                                  'Tipo: $listType (Total: ${creators.values.fold(0, (sum, count) => sum + count)})',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                children: creators.entries.map((creatorEntry) {
                                  final creatorName = creatorEntry.key;
                                  final count = creatorEntry.value;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 4.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('  - Criador: $creatorName'),
                                        Text('$count Convidados'),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: _exportGuestsToCsv,
                    icon: const Icon(Icons.download),
                    label: const Text('Exportar CSV'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          );
  }

  Widget _buildGuestsListTab() {
    final filteredGuests = _guests.where((guest) {
      if (_guestSearchQuery.isEmpty) return true;
      return guest.nome.toLowerCase().contains(_guestSearchQuery.toLowerCase());
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Buscar Convidado por Nome',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _guestSearchQuery = value;
              });
            },
            onSubmitted: (value) {},
          ),
        ),
        _isLoadingGuests
            ? const Expanded(child: Center(child: CircularProgressIndicator()))
            : filteredGuests.isEmpty
                ? const Expanded(
                    child: Center(child: Text('Nenhum convidado encontrado.')))
                : Expanded(
                    child: ListView.builder(
                      itemCount: filteredGuests.length,
                      itemBuilder: (context, index) {
                        final guest = filteredGuests[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          child: ListTile(
                            title: Text(guest.nome),
                            subtitle: Text(
                                'Lista: ${guest.lista} - Doc: ${guest.documento ?? 'N/A'} - Criador: ${guest.creatorName ?? 'Desconhecido'}'), // Adicionado o criador aqui também
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  onPressed: () => _showEditGuestDialog(guest),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () => _deleteGuest(guest.id),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
      ],
    );
  }

  Widget _buildReservationsTab() {
    return const Center(
      child: Text('Funcionalidade de Reservas a ser implementada aqui.'),
    );
  }
}
