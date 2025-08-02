#!/bin/bash

echo "🤖 Configurando renovação automática do Agilizaiapp..."

# Criar diretório para logs
mkdir -p ~/agilizaiapp_logs

# Criar script de renovação automática
cat > ~/renovar_agilizaiapp_auto.sh << 'EOF'
#!/bin/bash

# Log da renovação
LOG_FILE="$HOME/agilizaiapp_logs/renovacao_$(date +%Y%m%d_%H%M%S).log"

echo "$(date): Iniciando renovação automática do Agilizaiapp" >> "$LOG_FILE"

# Navegar para o projeto
cd /Users/preto/Documents/GitHub/agilizaiapp

# Verificar se o iPhone está conectado
if xcrun devicectl list devices | grep -q "iPhone"; then
    echo "$(date): iPhone detectado, fazendo build..." >> "$LOG_FILE"
    
    # Build rápido
    flutter build ios --release --no-codesign >> "$LOG_FILE" 2>&1
    
    if [ $? -eq 0 ]; then
        echo "$(date): Build concluído com sucesso!" >> "$LOG_FILE"
        echo "✅ Renovação automática concluída! Abra o Xcode e pressione Cmd+R"
    else
        echo "$(date): Erro no build" >> "$LOG_FILE"
        echo "❌ Erro na renovação automática. Verifique os logs: $LOG_FILE"
    fi
else
    echo "$(date): iPhone não detectado" >> "$LOG_FILE"
    echo "📱 Conecte o iPhone e execute novamente"
fi
EOF

# Tornar executável
chmod +x ~/renovar_agilizaiapp_auto.sh

echo "✅ Script de renovação automática criado!"
echo ""
echo "📅 Para configurar renovação automática a cada 6 dias:"
echo "1. Abra o terminal"
echo "2. Execute: crontab -e"
echo "3. Adicione esta linha:"
echo "   0 9 */6 * * ~/renovar_agilizaiapp_auto.sh"
echo ""
echo "📝 Isso fará a renovação automática às 9h da manhã a cada 6 dias"
echo ""
echo "📊 Logs serão salvos em: ~/agilizaiapp_logs/"
echo ""
echo "🔄 Para renovação manual, execute:"
echo "   ~/renovar_agilizaiapp_auto.sh" 