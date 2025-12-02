#!/bin/bash

# Script para corrigir problemas de build no iOS
# Uso: ./scripts/fix-ios-build.sh

set -e

echo "🔧 Corrigindo problemas de build iOS..."

# Configurar encoding
export LANG=en_US.UTF-8

# Limpar Flutter
echo "📦 Limpando Flutter..."
cd "$(dirname "$0")/.."
flutter clean

# Limpar iOS
echo "📦 Limpando iOS..."
cd ios
rm -rf Pods Podfile.lock .symlinks build DerivedData

# Limpar cache do CocoaPods
echo "📦 Limpando cache do CocoaPods..."
pod cache clean --all || true

# Reinstalar pods
echo "📦 Reinstalando pods..."
pod install --repo-update

# Voltar para raiz
cd ..

# Obter dependências Flutter
echo "📦 Obtendo dependências Flutter..."
flutter pub get

echo "✅ Correção concluída!"
echo ""
echo "📝 Próximos passos:"
echo "1. Abra o Xcode"
echo "2. Product → Clean Build Folder (Shift + Cmd + K)"
echo "3. Product → Build (Cmd + B)"
echo "4. Product → Run (Cmd + R)"


