# Sistema de Upload FTP para Fotos de Perfil

## Visão Geral

Este documento descreve a implementação do sistema de upload de fotos de perfil para o FTP no projeto Agilizaiapp Flutter, seguindo o mesmo padrão usado no projeto Next.js para imagens do cardápio.

## Arquitetura

### Backend (Nova Rota)
- **Rota**: `/api/images/upload-profile-photo`
- **Método**: POST
- **Arquivo**: `vamos-comemorar-api/routes/images.js`
- **Funcionalidade**: Upload de foto de perfil para o servidor FTP

### Frontend (Flutter)
- **Arquivo**: `lib/screens/profile/edit_profile_screen.dart`
- **Funcionalidade**: Interface para seleção e upload de foto de perfil

## Como Funciona

### 1. Seleção de Imagem
- O usuário toca na foto de perfil na tela de edição
- É aberta a galeria para seleção de imagem
- A imagem selecionada é armazenada temporariamente em `_imageFile`

### 2. Upload para FTP
- Quando o usuário salva o perfil, se uma nova imagem foi selecionada:
  1. A imagem é enviada para `/api/images/upload-profile-photo`
  2. O servidor faz upload para o FTP em `https://grupoideiaum.com.br/cardapio-agilizaiapp/`
  3. O nome do arquivo é retornado (ex: `profile_ABC123.jpg`)

### 3. Atualização do Perfil
- O nome do arquivo retornado é enviado para `/api/users/me` como campo `foto_perfil`
- O backend salva apenas o nome do arquivo no banco de dados

### 4. Exibição da Imagem
- O modelo `User` constrói automaticamente a URL completa:
  - Se `foto_perfil` for uma URL completa → usa diretamente
  - Se `foto_perfil` for apenas o nome do arquivo → constrói: `https://grupoideiaum.com.br/cardapio-agilizaiapp/{nome_arquivo}`

## Configuração FTP

```javascript
// config/environment.js
ftp: {
  host: '195.35.41.247',
  user: 'u621081794',
  password: 'Jeffl1ma!@',
  secure: false,
  port: 21,
  remoteDirectory: '/public_html/cardapio-agilizaiapp/',
  baseUrl: 'https://grupoideiaum.com.br/cardapio-agilizaiapp/'
}
```

## Vantagens da Implementação

1. **Separação de Responsabilidades**: Upload FTP separado da atualização de perfil
2. **Compatibilidade**: Não afeta outros projetos que usam a rota original
3. **Padrão Consistente**: Mesmo sistema usado para imagens do cardápio
4. **URLs Persistentes**: Imagens ficam acessíveis via HTTPS
5. **Fallback Inteligente**: Suporta tanto URLs completas quanto nomes de arquivo

## Estrutura de Arquivos

```
agilizaiapp/
├── lib/
│   ├── screens/profile/
│   │   └── edit_profile_screen.dart    # Interface de upload
│   ├── models/
│   │   └── user_model.dart             # Modelo com lógica de URL
│   └── providers/
│       └── user_profile_provider.dart  # Gerenciamento de estado
```

## Fluxo de Dados

```
Usuário seleciona imagem
         ↓
Flutter envia para /api/images/upload-profile-photo
         ↓
Backend faz upload para FTP
         ↓
Retorna nome do arquivo
         ↓
Flutter envia nome do arquivo para /api/users/me
         ↓
Backend salva no banco
         ↓
Modelo User constrói URL completa
         ↓
Interface exibe imagem do FTP
```

## Tratamento de Erros

- **Upload FTP falha**: Usuário recebe mensagem de erro e pode tentar novamente
- **Atualização de perfil falha**: Foto não é salva no banco, mas usuário é notificado
- **Imagem não carrega**: Fallback para imagem padrão com log de erro

## Testes

Para testar o sistema:

1. Acesse a tela de edição de perfil
2. Toque na foto de perfil
3. Selecione uma nova imagem
4. Salve o perfil
5. Verifique se a imagem aparece corretamente
6. Confirme no servidor FTP se o arquivo foi enviado

## Manutenção

- **Logs**: Todas as operações são logadas no backend
- **Monitoramento**: Verificar logs do servidor para problemas de upload
- **Backup**: Imagens ficam no servidor FTP, não apenas localmente
- **Limpeza**: Considerar implementar limpeza automática de arquivos antigos
