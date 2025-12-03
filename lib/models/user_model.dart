// lib/models/user_model.dart

import 'package:agilizaiapp/config/api_config.dart';

// Import necessário para o `const` no construtor

class User {
  final int id;
  final String name;
  final String email;
  final String? fotoPerfil; // Agora espera a URL completa ou o nome do arquivo
  final String? telefone;
  final String? sexo;
  final String? dataNascimento;
  final String? cpf;
  final String? cep;
  final String? endereco;
  final String? numero;
  final String? bairro;
  final String? cidade;
  final String? estado;
  final String? complemento;
  final String? role;
  final String? provider;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.fotoPerfil,
    this.telefone,
    this.sexo,
    this.dataNascimento,
    this.cpf,
    this.cep,
    this.endereco,
    this.numero,
    this.bairro,
    this.cidade,
    this.estado,
    this.complemento,
    this.role,
    this.provider,
  });

  // Método para criar um User a partir de JSON da API
  factory User.fromJson(Map<String, dynamic> json) {
    // Priorizar foto_perfil_url (URL completa do Cloudinary) se disponível
    // Caso contrário, usar foto_perfil (pode ser URL completa ou nome do arquivo)
    String? rawFotoPerfil =
        json['foto_perfil_url'] as String? ?? json['foto_perfil'] as String?;
    String? finalFotoPerfilUrl;

    if (rawFotoPerfil != null && rawFotoPerfil.isNotEmpty) {
      // Verifica se a URL já é completa (Cloudinary, FTP ou outro serviço)
      if (rawFotoPerfil.startsWith('http://') ||
          rawFotoPerfil.startsWith('https://')) {
        // Se for URL do /uploads/ (legado), não usar - essas imagens não existem mais
        if (rawFotoPerfil.contains('/uploads/')) {
          print(
              '⚠️ URL de imagem legada detectada (/uploads/), ignorando: $rawFotoPerfil');
          finalFotoPerfilUrl = null; // Não usar URLs legadas que não funcionam
        } else {
          finalFotoPerfilUrl =
              rawFotoPerfil; // URL completa válida (Cloudinary)
        }
      } else {
        // Se for apenas o nome do arquivo (legado), não usar - imagens devem estar no Cloudinary
        print('⚠️ Nome de arquivo legado detectado, ignorando: $rawFotoPerfil');
        finalFotoPerfilUrl = null; // Não usar nomes de arquivo legados
      }
    }

    // Função auxiliar para converter ID de string ou int para int
    int parseId(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return User(
      id: parseId(json['id']),
      name: json['name'] as String,
      email: json['email'] as String,
      fotoPerfil: finalFotoPerfilUrl, // Usa a URL final construída/verificada
      telefone: json['telefone'] as String?,
      sexo: json['sexo'] as String?,
      dataNascimento: json['data_nascimento'] as String?,
      cpf: json['cpf'] as String?,
      cep: json['cep'] as String?,
      endereco: json['endereco'] as String?,
      numero: json['numero'] as String?,
      bairro: json['bairro'] as String?,
      cidade: json['cidade'] as String?,
      estado: json['estado'] as String?,
      complemento: json['complemento'] as String?,
      role: json['role'] as String?,
      provider: json['provider'] as String?,
    );
  }

  // Método para converter o User de volta para JSON (útil para enviar para API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      // Para toJson, geralmente enviamos apenas o nome do arquivo se a API esperar isso,
      // ou a URL completa se a API estiver configurada para aceitar URLs.
      // Vou manter a fotoPerfil como está no objeto User (que agora será uma URL completa ou null)
      'foto_perfil': fotoPerfil,
      'telefone': telefone,
      'sexo': sexo,
      'data_nascimento': dataNascimento,
      'cpf': cpf,
      'cep': cep,
      'endereco': endereco,
      'numero': numero,
      'bairro': bairro,
      'cidade': cidade,
      'estado': estado,
      'complemento': complemento,
      'role': role,
      'provider': provider,
    };
  }

  // Método para criar uma nova instância de User com dados atualizados
  User copyWith({
    String? name,
    String? email,
    String? fotoPerfil,
    String? telefone,
    String? sexo,
    String? dataNascimento,
    String? cpf,
    String? cep,
    String? endereco,
    String? numero,
    String? bairro,
    String? cidade,
    String? estado,
    String? complemento,
    String? role,
    String? provider,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      fotoPerfil: fotoPerfil ?? this.fotoPerfil,
      telefone: telefone ?? this.telefone,
      sexo: sexo ?? this.sexo,
      dataNascimento: dataNascimento ?? this.dataNascimento,
      cpf: cpf ?? this.cpf,
      cep: cep ?? this.cep,
      endereco: endereco ?? this.endereco,
      numero: numero ?? this.numero,
      bairro: bairro ?? this.bairro,
      cidade: cidade ?? this.cidade,
      estado: estado ?? this.estado,
      complemento: complemento ?? this.complemento,
      role: role ?? this.role,
      provider: provider ?? this.provider,
    );
  }
}
