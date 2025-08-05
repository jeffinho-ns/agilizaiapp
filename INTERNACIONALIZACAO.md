# Sistema de Internacionalização - Agilizai App

## Visão Geral

O Agilizai App agora suporta **4 idiomas** com traduções automáticas:

- 🇧🇷 **Português Brasileiro** (padrão/nativo)
- 🇺🇸 **English US** 
- 🇪🇸 **Español**
- 🇩🇪 **Deutsch**

## Como Funciona

### 1. Seleção de Idioma
- O usuário escolhe o idioma na tela `CountrySelectionScreen` (renomeada para seleção de idioma)
- A escolha é salva automaticamente no `SharedPreferences`
- O idioma persiste entre sessões do app

### 2. Traduções Automáticas
- Todas as strings do app estão traduzidas nos arquivos `.arb`
- O sistema usa o Flutter's `gen-l10n` para gerar automaticamente as classes de tradução
- As traduções são aplicadas automaticamente em todo o app

## Estrutura de Arquivos

```
lib/l10n/
├── app_pt.arb          # Português Brasileiro (padrão)
├── app_en.arb          # Inglês US
├── app_es.arb          # Espanhol
├── app_de.arb          # Alemão
├── app_localizations.dart      # Classe principal
├── app_localizations_pt.dart   # Implementação PT
├── app_localizations_en.dart   # Implementação EN
├── app_localizations_es.dart   # Implementação ES
└── app_localizations_de.dart   # Implementação DE
```

## Como Usar as Traduções

### 1. Importar a Biblioteca
```dart
import 'package:agilizaiapp/l10n/app_localizations.dart';
```

### 2. Usar em Widgets
```dart
// Texto simples
Text(AppLocalizations.of(context)!.hiWelcome)

// Texto com parâmetros
Text(AppLocalizations.of(context)!.noEventsInCategory("Festa"))

// Botões
ElevatedButton(
  child: Text(AppLocalizations.of(context)!.saveButton),
  onPressed: () {},
)
```

### 3. Exemplo Completo
```dart
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.countrySelectionTitle),
      ),
      body: Column(
        children: [
          Text(AppLocalizations.of(context)!.hiWelcome),
          Text(AppLocalizations.of(context)!.loading),
          ElevatedButton(
            child: Text(AppLocalizations.of(context)!.saveButton),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
```

## Adicionando Novas Traduções

### 1. Adicionar a Chave em Todos os Arquivos .arb

**app_pt.arb:**
```json
{
  "novaChave": "Texto em Português"
}
```

**app_en.arb:**
```json
{
  "novaChave": "Text in English"
}
```

**app_es.arb:**
```json
{
  "novaChave": "Texto en Español"
}
```

**app_de.arb:**
```json
{
  "novaChave": "Text auf Deutsch"
}
```

### 2. Regenerar as Classes
```bash
flutter gen-l10n
```

### 3. Usar no Código
```dart
Text(AppLocalizations.of(context)!.novaChave)
```

## Traduções com Parâmetros

### 1. Definir no .arb
```json
{
  "welcomeMessage": "Olá, {userName}!",
  "@welcomeMessage": {
    "placeholders": {
      "userName": {
        "type": "String"
      }
    }
  }
}
```

### 2. Usar no Código
```dart
Text(AppLocalizations.of(context)!.welcomeMessage("João"))
```

## Provider de Idioma

O `LanguageProvider` gerencia o idioma selecionado:

```dart
// Obter o provider
final languageProvider = Provider.of<LanguageProvider>(context, listen: false);

// Mudar idioma
await languageProvider.setLanguage('en');

// Obter idioma atual
Locale currentLocale = languageProvider.currentLocale;
```

## Idiomas Disponíveis

```dart
LanguageProvider.availableLanguages = [
  {
    'code': 'pt',
    'name': 'Português Brasileiro',
    'nativeName': 'Português Brasileiro',
    'flag': '🇧🇷'
  },
  {
    'code': 'en',
    'name': 'English US',
    'nativeName': 'English US',
    'flag': '🇺🇸'
  },
  {
    'code': 'es',
    'name': 'Español',
    'nativeName': 'Español',
    'flag': '🇪🇸'
  },
  {
    'code': 'de',
    'name': 'Deutsch',
    'nativeName': 'Deutsch',
    'flag': '🇩🇪'
  }
];
```

## Configuração no main.dart

O app está configurado para usar automaticamente o idioma selecionado:

```dart
Consumer<LanguageProvider>(
  builder: (context, languageProvider, child) {
    return MaterialApp(
      locale: languageProvider.currentLocale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // ...
    );
  },
)
```

## Comandos Úteis

```bash
# Gerar classes de tradução
flutter gen-l10n

# Analisar o projeto
flutter analyze

# Executar o app
flutter run
```

## Notas Importantes

1. **Português Brasileiro é o idioma padrão** - sempre será usado se nenhum idioma for selecionado
2. **As traduções são automáticas** - não precisa de API externa
3. **O idioma persiste** - a escolha do usuário é salva automaticamente
4. **Sempre use AppLocalizations.of(context)!** - para acessar as traduções
5. **Regenere as classes** - sempre que adicionar novas traduções

## Exemplo de Implementação Completa

Veja como a tela de onboarding foi atualizada para usar traduções:

```dart
// Antes (hardcoded)
Text("Explore Eventos Próximos e Futuros")

// Depois (traduzível)
Text(AppLocalizations.of(context)!.onboardingExploreTitle)
```

Isso garante que o texto será exibido no idioma correto automaticamente! 