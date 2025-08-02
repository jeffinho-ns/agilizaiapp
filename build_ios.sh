#!/bin/bash

echo "🚀 Configurando build do Agilizaiapp para iOS (7 dias de execução)"

# Limpar builds anteriores
echo "🧹 Limpando builds anteriores..."
flutter clean
cd ios
rm -rf build
rm -rf Pods
rm -rf Podfile.lock
cd ..

# Instalar dependências
echo "📦 Instalando dependências..."
flutter pub get
cd ios
pod install
cd ..

# Build para iOS
echo "🔨 Fazendo build para iOS..."
flutter build ios --release --no-codesign

echo "✅ Build concluído!"
echo ""
echo "📱 Para instalar no seu iPhone:"
echo "1. Abra o Xcode"
echo "2. Abra o projeto: ios/Runner.xcworkspace"
echo "3. Conecte seu iPhone via cabo USB"
echo "4. Selecione seu dispositivo no Xcode"
echo "5. Clique em 'Product' > 'Run' (ou Cmd+R)"
echo ""
echo "🔧 Configurações importantes:"
echo "- Bundle ID: com.agilizaiapp.mobile"
echo "- Team: 9HHX57B4G5"
echo "- Signing: Automatic"
echo ""
echo "⚠️  IMPORTANTE:"
echo "- O app será válido por 7 dias"
echo "- Você precisa estar logado com sua Apple ID no Xcode"
echo "- Seu iPhone precisa estar em modo desenvolvedor"
echo ""
echo "🔄 Para renovar após 7 dias, execute este script novamente" 