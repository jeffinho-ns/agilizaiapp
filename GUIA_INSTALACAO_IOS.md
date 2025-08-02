# 🍎 Guia de Instalação iOS - Agilizaiapp

## 📋 Pré-requisitos

1. **Mac com Xcode instalado** (versão 15.0 ou superior)
2. **iPhone com iOS 16.6 ou superior**
3. **Cabo USB** (para primeira instalação)
4. **Apple ID** configurado no Xcode

## 🔧 Configurações do Xcode

### 1. Abrir o Projeto
```bash
# No terminal, navegue até a pasta do projeto
cd /Users/preto/Documents/GitHub/agilizaiapp

# Execute o script de build
./build_ios.sh
```

### 2. Configurar o Xcode
1. Abra o **Xcode**
2. Abra o projeto: `ios/Runner.xcworkspace`
3. Selecione o projeto **Runner** no navegador
4. Vá para a aba **Signing & Capabilities**

### 3. Configurações de Assinatura
- **Team**: Selecione sua Apple ID (jeffinho_ns@hotmail.com)
- **Bundle Identifier**: `com.agilizaiapp.mobile`
- **Signing**: Automatic
- **Provisioning Profile**: Deixe vazio (será gerado automaticamente)

## 📱 Instalação no iPhone

### 1. Conectar o iPhone
1. Conecte seu iPhone ao Mac via cabo USB
2. No iPhone, confie no computador se solicitado
3. No Xcode, selecione seu dispositivo na lista de destinos

### 2. Configurar o iPhone para Desenvolvimento
1. No iPhone, vá em **Configurações > Geral > Gerenciamento de Dispositivo**
2. Toque em sua Apple ID
3. Toque em **Confiar** para permitir apps de desenvolvedor

### 3. Instalar o App
1. No Xcode, pressione **Cmd + R** ou clique em **Product > Run**
2. Aguarde o build e instalação
3. O app será instalado no seu iPhone

## ⚙️ Configurações Importantes

### Bundle ID Atualizado
- **Antigo**: `com.example.agilizaiapp`
- **Novo**: `com.agilizaiapp.mobile`

### Permissões Configuradas
- ✅ Localização
- ✅ Câmera
- ✅ Galeria
- ✅ Face ID
- ✅ Background modes

## 🔄 Renovação Após 7 Dias

### Opção 1: Via Xcode (Recomendado)
1. Conecte o iPhone ao Mac
2. Abra o projeto no Xcode
3. Pressione **Cmd + R** para reinstalar
4. O app será renovado por mais 7 dias

### Opção 2: Via Script
```bash
# Execute o script novamente
./build_ios.sh
# Siga os passos de instalação
```

## 🚨 Solução de Problemas

### Erro: "Untrusted Developer"
1. Vá em **Configurações > Geral > Gerenciamento de Dispositivo**
2. Toque em sua Apple ID
3. Toque em **Confiar**

### Erro: "Code Signing"
1. No Xcode, vá em **Preferences > Accounts**
2. Adicione sua Apple ID se não estiver
3. Clique em **Download Manual Profiles**

### App não abre
1. Delete o app do iPhone
2. Reinstale via Xcode
3. Verifique se o iPhone está em modo desenvolvedor

## 📞 Suporte

Se encontrar problemas:
1. Verifique se o Xcode está atualizado
2. Confirme que sua Apple ID está ativa
3. Tente reinstalar o app
4. Verifique as configurações de segurança do iPhone

## ✅ Checklist Final

- [ ] Xcode configurado com Apple ID
- [ ] iPhone conectado e confiado
- [ ] Bundle ID atualizado
- [ ] App instalado com sucesso
- [ ] App abre sem erros
- [ ] Funcionalidades testadas

---

**🎉 Parabéns! Seu app está configurado para rodar por 7 dias sem precisar estar conectado ao cabo!** 