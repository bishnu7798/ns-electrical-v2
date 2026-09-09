# Translation System Implementation Guide

This guide explains how to use the translation system implemented in the NS Electrical app.

## Overview

The translation system consists of three main components:

1. **LanguageManager** - Handles saving/loading language preferences
2. **TranslationService** - Provides translations for all supported languages
3. **SettingsScreen** - UI for selecting languages

## Supported Languages

- English (default)
- Spanish
- French
- Bengali
- Hindi

## How to Use Translations in Your Widgets

### 1. Import the Required Files

```dart
import '../../core/utils/language_manager.dart';
import '../../core/utils/translation_service.dart';
```

### 2. Load the Selected Language

In your widget's state class:

```dart
class _YourWidgetState extends State<YourWidget> {
  String _selectedLanguage = 'English';

  @override
  void initState() {
    super.initState();
    _loadLanguagePreference();
  }

  Future<void> _loadLanguagePreference() async {
    final language = await LanguageManager.getSelectedLanguage();
    setState(() {
      _selectedLanguage = language;
    });
  }
}
```

### 3. Use Translations in Your UI

```dart
Text(TranslationService.translate('settings', _selectedLanguage))
Text(TranslationService.translate('dark_mode', _selectedLanguage))
Text(TranslationService.translate('select_app_language', _selectedLanguage))
```

## Available Translation Keys

The following keys are available for translation:

- 'settings'
- 'profile'
- 'preferences'
- 'notifications'
- 'enable_or_disable_notifications'
- 'dark_mode'
- 'enable_dark_theme'
- 'language'
- 'select_app_language'
- 'theme'
- 'select_app_theme'
- 'account'
- 'change_password'
- 'update_your_password'
- 'privacy_policy'
- 'read_our_privacy_policy'
- 'terms_of_service'
- 'read_our_terms_of_service'
- 'danger_zone'
- 'delete_account'
- 'permanently_delete_your_account'
- 'logout'
- 'are_you_sure_you_want_to_logout'
- 'cancel'
- 'are_you_sure_you_want_to_delete_account'
- 'account_deleted_successfully'
- 'default'
- 'blue'
- 'green'

## Adding New Languages

To add a new language:

1. Add the language to the `languageMap` in `LanguageManager`
2. Add translations to the `_translations` map in `TranslationService`
3. Add the language option to the dropdown in `SettingsScreen`

## Adding New Translation Keys

To add new translation keys:

1. Add the key to all language dictionaries in `TranslationService`
2. Use the key in your widgets with `TranslationService.translate('your_key', _selectedLanguage)`