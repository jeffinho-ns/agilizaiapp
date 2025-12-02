// lib/screens/profile/edit_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agilizaiapp/config/api_config.dart';
import 'package:agilizaiapp/providers/user_profile_provider.dart';
import 'package:agilizaiapp/models/user_model.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:mime/mime.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:agilizaiapp/screens/splash/splash_screen.dart';
import 'package:http_parser/http_parser.dart';

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
        Uri.parse(ApiConfig.userEndpoint('me')),
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
          ? DateTime.tryParse(_dataNascimentoController.text) ??
              DateTime.now() // Usa tryParse e um fallback
          : DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale:
          const Locale('pt', 'BR'), // Define o local para português do Brasil
    );

    // Adição da verificação de nulidade:
    if (pickedDate != null) {
      // Somente formata e atribui se uma data foi selecionada
      setState(() {
        _dataNascimentoController.text = DateFormat(
          'yyyy-MM-dd',
        ).format(pickedDate);
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

  // Faz upload da foto para o Cloudinary via API e retorna a URL completa.
  Future<String?> _saveProfilePhoto() async {
    if (_imageFile == null) {
      return null;
    }

    try {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'jwt_token');

      if (token == null || token.isEmpty) {
        _showSnackBar('Erro: Token de autenticação ausente.');
        return null;
      }

      final uri = Uri.parse(
        ApiConfig.uploadImageUrl,
      );
      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';

      // Obtenha o MIME type do arquivo
      final mimeType = lookupMimeType(_imageFile!.path);
      final fileType = mimeType?.split('/');

      if (fileType == null || fileType.isEmpty || fileType[0] != 'image') {
        _showSnackBar(
            'Tipo de arquivo não suportado. Por favor, selecione uma imagem.');
        return null;
      }

      // Anexa o arquivo de imagem ao request com o MIME type correto
      request.files.add(
        await http.MultipartFile.fromPath(
          'image', // O nome do campo deve ser 'image', igual ao Next.js
          _imageFile!.path,
          contentType: MediaType(fileType[0], fileType[1]),
        ),
      );

      // Envia o request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          // Priorizar URL completa do Cloudinary se disponível
          final cloudinaryUrl = responseData['url'] as String?;
          if (cloudinaryUrl != null && cloudinaryUrl.isNotEmpty) {
            _showSnackBar('Foto de perfil enviada com sucesso!');
            print('DEBUG: URL Cloudinary recebida: $cloudinaryUrl');
            // Retorna a URL completa do Cloudinary
            return cloudinaryUrl;
          } else if (responseData['filename'] != null) {
            // Fallback para filename se URL não estiver disponível
            _showSnackBar('Foto de perfil enviada com sucesso!');
            return responseData['filename'];
          } else {
            _showSnackBar(
              'Erro no upload da foto: URL não retornada pelo servidor',
            );
            return null;
          }
        } else {
          _showSnackBar(
            'Erro no upload da foto: ${responseData['error'] ?? 'Resposta inválida'}',
          );
          return null;
        }
      } else {
        _showSnackBar('Falha no upload da foto: ${response.statusCode}');
        print('Erro no upload da foto: ${response.body}');
        return null;
      }
    } catch (e) {
      _showSnackBar('Erro de conexão ao enviar a foto: $e');
      print('Exceção no upload da foto: $e');
      return null;
    }
  }

  // NOVA FUNÇÃO: Envia os dados do perfil (com ou sem a foto)
  Future<void> _saveProfileData({String? photoFilename}) async {
    setState(() {
      _isLoading = true;
    });

    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'jwt_token');

    if (token == null || token.isEmpty) {
      _showSnackBar(
          'Erro: Token de autenticação ausente. Faça login novamente.');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await http.put(
        Uri.parse(ApiConfig.userEndpoint('me')),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'name': _fullNameController.text,
          'email': _emailController.text,
          'telefone': _phoneController.text,
          if (_passwordController.text.isNotEmpty)
            'password': _passwordController.text,
          'data_nascimento': _dataNascimentoController.text,
          'cpf': _cpfController.text,
          'sexo': _sexoController.text,
          'cep': _cepController.text,
          'endereco': _enderecoController.text,
          'numero': _numeroController.text,
          'bairro': _bairroController.text,
          'cidade': _cidadeController.text,
          'estado': _estadoController.text,
          'complemento': _complementoController.text,
          if (photoFilename != null) 'foto_perfil': photoFilename,
        }),
      );

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

  // FUNÇÃO REFEITA: Centraliza a lógica de salvamento.
  Future<void> _saveProfileChanges() async {
    setState(() {
      _isLoading = true;
    });

    String? photoFilename;
    if (_imageFile != null) {
      photoFilename = await _saveProfilePhoto();
      if (photoFilename == null) {
        // Se o upload falhar, _saveProfilePhoto já exibirá um snackbar.
        // Apenas pare o processo de salvamento.
        setState(() {
          _isLoading = false;
        });
        return;
      }
    }

    await _saveProfileData(photoFilename: photoFilename);
  }

  // Função para obter o provider de imagem de perfil
  ImageProvider _getProfileImageProvider(String fotoPerfil) {
    return NetworkImage(ApiConfig.getProfileImageUrl(fotoPerfil));
  }

  // Função para fazer logout
  Future<void> _logout() async {
    setState(() {
      _isLoading = true;
    });
    try {
      const storage = FlutterSecureStorage();
      await storage.delete(key: 'jwt_token');

      // Limpa os dados do usuário no Provider
      Provider.of<UserProfileProvider>(
        context,
        listen: false,
      ).setUser(const User(id: 0, name: '', email: ''));

      // Redireciona para a SplashScreen e remove todas as rotas anteriores
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
          'Editar Perfil', // Traduzido de 'Edit Profile'
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
                          style:
                              const TextStyle(color: Colors.red, fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchCurrentUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF26422),
                        ),
                        child: const Text(
                          'Tentar Novamente', // Traduzido
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
                              backgroundImage: _imageFile != null
                                  ? FileImage(_imageFile!)
                                      as ImageProvider<Object>
                                  : (_currentUser?.fotoPerfil != null &&
                                          _currentUser!.fotoPerfil!.isNotEmpty
                                      ? _getProfileImageProvider(
                                              _currentUser!.fotoPerfil!)
                                          as ImageProvider<Object>
                                      : const AssetImage(
                                          'assets/images/default_avatar.png',
                                        ) as ImageProvider<Object>),
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
                                  border:
                                      Border.all(color: Colors.white, width: 2),
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
                        label: 'Nome Completo', // Traduzido de 'Full Name'
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _emailController,
                        label: 'E-mail', // Traduzido de 'Email'
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _phoneController,
                        label: 'Telefone', // Traduzido de 'Phone'
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _passwordController,
                        label:
                            'Senha (deixe em branco para manter a atual)', // Traduzido de 'Password (leave blank to keep current)'
                        obscureText: true,
                      ),
                      const SizedBox(height: 20),
                      _buildDateField(
                        context: context,
                        controller: _dataNascimentoController,
                        label:
                            'Data de Nascimento (AAAA-MM-DD)', // Traduzido de 'Date of Birth (YYYY-MM-DD)'
                        onTap: () => _selectDate(context),
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _cpfController,
                        label: 'CPF',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                          controller: _sexoController,
                          label: 'Gênero'), // Traduzido de 'Gender'
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _cepController,
                        label: 'CEP',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _enderecoController,
                        label: 'Endereço', // Traduzido de 'Address'
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _numeroController,
                        label: 'Número', // Traduzido de 'Number'
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _bairroController,
                        label: 'Bairro', // Traduzido de 'Neighborhood'
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                          controller: _cidadeController,
                          label: 'Cidade'), // Traduzido de 'City'
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _estadoController,
                        label: 'Estado', // Traduzido de 'State'
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _complementoController,
                        label: 'Complemento', // Traduzido de 'Complement'
                        maxLines: 2,
                      ),
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
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text(
                                  'SALVAR ALTERAÇÕES', // Traduzido de 'SAVE CHANGES'
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
                            'SAIR', // Traduzido de 'LOGOUT'
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
