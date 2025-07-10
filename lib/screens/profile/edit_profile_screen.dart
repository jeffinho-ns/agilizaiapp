// lib/screens/profile/edit_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agilizaiapp/providers/user_profile_provider.dart';
import 'package:agilizaiapp/models/user_model.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:agilizaiapp/screens/splash/splash_screen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Controladores de texto para campos do User model e do formulário
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController(); // Para nova senha
  final _dataNascimentoController =
      TextEditingController(); // Ajustado para dataNascimento
  final _cpfController = TextEditingController(); // NOVO: Campo para CPF
  final _sexoController = TextEditingController(); // NOVO: Campo para Sexo
  final _cepController = TextEditingController(); // NOVO: Campo para CEP
  final _enderecoController =
      TextEditingController(); // NOVO: Campo para Endereço
  final _numeroController = TextEditingController(); // NOVO: Campo para Número
  final _bairroController = TextEditingController(); // NOVO: Campo para Bairro
  final _cidadeController = TextEditingController(); // NOVO: Campo para Cidade
  final _estadoController = TextEditingController(); // NOVO: Campo para Estado
  final _complementoController =
      TextEditingController(); // NOVO: Campo para Complemento
  // _locationController e _interestedEventsController foram removidos pois não estão no BD
  // _aboutMeController foi removido pois não está no BD

  User? _currentUser;
  bool _isLoading = true;
  String _errorMessage = '';

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _dataNascimentoController.dispose();
    _cpfController.dispose();
    _sexoController.dispose();
    _cepController.dispose();
    _enderecoController.dispose();
    _numeroController.dispose();
    _bairroController.dispose();
    _cidadeController.dispose();
    _estadoController.dispose();
    _complementoController.dispose();
    super.dispose();
  }

  // Função para buscar os dados do usuário da API
  Future<void> _fetchCurrentUser() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'jwt_token');

    if (token == null || token.isEmpty) {
      setState(() {
        _errorMessage =
            'Token de autenticação ausente. Por favor, faça login novamente.';
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('https://vamos-comemorar-api.onrender.com/api/users/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        if (mounted) {
          final Map<String, dynamic> userData = json.decode(response.body);
          setState(() {
            _currentUser = User.fromJson(userData);
            _isLoading = false;
            // Preenche os controladores com os dados do usuário
            _fullNameController.text = _currentUser!.name;
            _emailController.text = _currentUser!.email;
            _phoneController.text = _currentUser!.telefone ?? '';
            // Senha não é preenchida por segurança
            _dataNascimentoController.text =
                _currentUser!.dataNascimento ?? ''; // Usando dataNascimento
            _cpfController.text = _currentUser!.cpf ?? ''; // Preenchendo CPF
            _sexoController.text = _currentUser!.sexo ?? ''; // Preenchendo Sexo
            _cepController.text = _currentUser!.cep ?? ''; // Preenchendo CEP
            _enderecoController.text =
                _currentUser!.endereco ?? ''; // Preenchendo Endereço
            _numeroController.text =
                _currentUser!.numero ?? ''; // Preenchendo Número
            _bairroController.text =
                _currentUser!.bairro ?? ''; // Preenchendo Bairro
            _cidadeController.text =
                _currentUser!.cidade ?? ''; // Preenchendo Cidade
            _estadoController.text =
                _currentUser!.estado ?? ''; // Preenchendo Estado
            _complementoController.text =
                _currentUser!.complemento ?? ''; // Preenchendo Complemento
          });
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        setState(() {
          _errorMessage =
              'Sessão expirada ou inválida. Por favor, faça login novamente.';
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Falha ao carregar perfil: ${response.statusCode}.';
          _isLoading = false;
        });
        print(
          'Erro API ao carregar perfil para edição: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage =
            'Erro de conexão: Não foi possível conectar ao servidor. ($e)';
        _isLoading = false;
      });
      print('Exceção ao carregar perfil para edição: $e');
    }
  }

  // Função para selecionar data
  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _dataNascimentoController.text.isNotEmpty
          ? DateTime.parse(_dataNascimentoController.text)
          : DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _dataNascimentoController.text = DateFormat(
          'yyyy-MM-dd',
        ).format(pickedDate); // Usando dataNascimento
      });
    }
  }

  // Função para selecionar imagem da galeria
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // Função para enviar as atualizações para a API (incluindo foto)
  Future<void> _saveProfileChanges() async {
    setState(() {
      _isLoading = true;
    });

    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'jwt_token');

    if (token == null || token.isEmpty) {
      _showSnackBar(
        'Erro: Token de autenticação ausente. Faça login novamente.',
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final uri = Uri.parse(
      'https://vamos-comemorar-api.onrender.com/api/users/me',
    );
    final request = http.MultipartRequest(
      'PUT',
      uri,
    ); // Usando PUT para atualização
    request.headers['Authorization'] = 'Bearer $token';

    // Adiciona os campos de texto que correspondem ao BD
    request.fields['name'] = _fullNameController.text;
    request.fields['email'] = _emailController.text;
    request.fields['telefone'] = _phoneController.text;
    if (_passwordController.text.isNotEmpty) {
      request.fields['password'] =
          _passwordController.text; // Envia senha se não estiver vazia
    }
    request.fields['data_nascimento'] =
        _dataNascimentoController.text; // Nome do campo da API/BD
    request.fields['cpf'] = _cpfController.text;
    request.fields['sexo'] = _sexoController.text;
    request.fields['cep'] = _cepController.text;
    request.fields['endereco'] = _enderecoController.text;
    request.fields['numero'] = _numeroController.text;
    request.fields['bairro'] = _bairroController.text;
    request.fields['cidade'] = _cidadeController.text;
    request.fields['estado'] = _estadoController.text;
    request.fields['complemento'] = _complementoController.text;
    // Campos como 'role' e 'provider' geralmente não são editáveis pelo usuário comum.
    // Se fossem, seriam adicionados aqui também.

    // Adiciona a foto de perfil se uma nova foi selecionada
    if (_imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'foto_perfil', // Este nome deve corresponder ao 'upload.single('foto_perfil')' na sua API
          _imageFile!.path,
          filename: _imageFile!.path.split('/').last,
        ),
      );
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        _showSnackBar('Perfil atualizado com sucesso!');
        // Atualiza o estado do Provider após o sucesso na API
        Provider.of<UserProfileProvider>(
          context,
          listen: false,
        ).fetchUserProfile();
        Navigator.of(context).pop(true); // Volta e indica sucesso
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        _showSnackBar(
          'Sessão expirada ou não autorizada. Faça login novamente.',
        );
      } else {
        _showSnackBar('Falha ao atualizar perfil: ${response.statusCode}.');
        print(
          'Erro API ao salvar perfil: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      _showSnackBar('Erro de conexão ao salvar: $e');
      print('Exceção ao salvar perfil: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Função para fazer logout
  Future<void> _logout() async {
    setState(() {
      _isLoading = true;
    });
    try {
      const storage = FlutterSecureStorage();
      await storage.delete(key: 'jwt_token');

      Provider.of<UserProfileProvider>(
        context,
        listen: false,
      ).setUser(User(id: 0, name: '', email: ''));

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const SplashScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      _showSnackBar('Erro ao fazer logout: $e');
      print('Erro ao fazer logout: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchCurrentUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF26422),
                    ),
                    child: const Text(
                      'Tentar Novamente',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Foto de Perfil com função de alteração
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          // CORREÇÃO AQUI: Usa _currentUser!.fotoPerfil! diretamente,
                          // pois o User model já constrói a URL completa ou a mantém
                          backgroundImage: _imageFile != null
                              ? FileImage(_imageFile!) as ImageProvider<Object>?
                              : (_currentUser?.fotoPerfil != null &&
                                        _currentUser!.fotoPerfil!.isNotEmpty
                                    ? NetworkImage(
                                        _currentUser!.fotoPerfil!,
                                      ) // <<-- AGORA APENAS USA O VALOR
                                    : null),
                          child:
                              (_imageFile == null &&
                                  (_currentUser?.fotoPerfil == null ||
                                      _currentUser!.fotoPerfil!.isEmpty))
                              ? const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.grey,
                                )
                              : null,
                          onBackgroundImageError: (exception, stackTrace) {
                            print(
                              'Erro ao carregar imagem de perfil para edição: $exception',
                            );
                          },
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF26422),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Campos de Edição - Agora refletindo o DB
                  _buildTextField(
                    controller: _fullNameController,
                    label: 'Full Name',
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _phoneController,
                    label: 'Phone',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _passwordController,
                    label: 'Password (deixe em branco para manter a atual)',
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  _buildDateField(
                    context: context,
                    controller:
                        _dataNascimentoController, // Usando dataNascimento
                    label: 'Date of Birth (YYYY-MM-DD)',
                    onTap: () => _selectDate(context),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _cpfController,
                    label: 'CPF',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(controller: _sexoController, label: 'Gender'),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _cepController,
                    label: 'CEP',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _enderecoController,
                    label: 'Address',
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _numeroController,
                    label: 'Number',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _bairroController,
                    label: 'Neighborhood',
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(controller: _cidadeController, label: 'City'),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _estadoController,
                    label: 'State',
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _complementoController,
                    label: 'Complement',
                    maxLines: 2,
                  ),
                  // Campos 'About Me' e 'Interested Events' foram removidos
                  const SizedBox(height: 40),

                  // Botão Salvar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveProfileChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C2C2C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'SAVE CHANGES',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Botão de Sair (Logout)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'SAIR',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Widget auxiliar para campos de texto
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    bool readOnly = false,
    VoidCallback? onTap,
    int? maxLines = 1,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      maxLines: maxLines,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[100],
        suffixIcon: icon != null ? Icon(icon, color: Colors.grey[600]) : null,
      ),
    );
  }

  // Widget auxiliar para campo de data
  Widget _buildDateField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required VoidCallback onTap,
  }) {
    return TextField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[100],
        suffixIcon: const Icon(
          Icons.calendar_today_outlined,
          color: Colors.grey,
        ),
      ),
    );
  }
}
