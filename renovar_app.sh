#!/bin/bash

echo "🔄 Renovando Agilizaiapp para mais 7 dias..."

# Verificar se o iPhone está conectado
if ! xcrun devicectl list devices | grep -q "iPhone"; then
    echo "❌ iPhone não detectado!"
    echo "📱 Conecte seu iPhone via cabo USB e tente novamente"
    exit 1
fi

echo "📱 iPhone detectado! Iniciando renovação..."

# Build rápido para renovação
echo "🔨 Fazendo build de renovação..."
flutter build ios --release --no-codesign

echo "✅ Build de renovação concluído!"
echo ""
echo "📱 Para instalar a renovação:"
echo "1. Abra o Xcode"
echo "2. Abra: ios/Runner.xcworkspace"
echo "3. Pressione Cmd+R para instalar"
echo ""
echo "⏰ O app será válido por mais 7 dias!"
echo ""
echo "💡 Dica: Você pode configurar este script para rodar automaticamente"
echo "   usando o crontab para renovação automática" 