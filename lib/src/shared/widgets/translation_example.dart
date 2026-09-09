import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/language_provider.dart';
import '../../core/utils/translation_service.dart';

class TranslationExample extends StatefulWidget {
  const TranslationExample({super.key});

  @override
  State<TranslationExample> createState() => _TranslationExampleState();
}

class _TranslationExampleState extends State<TranslationExample> {
  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              TranslationService.translate('settings', languageProvider.selectedLanguage),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(TranslationService.translate('select_app_language', languageProvider.selectedLanguage)),
            const SizedBox(height: 8),
            Text(TranslationService.translate('dark_mode', languageProvider.selectedLanguage)),
            const SizedBox(height: 8),
            Text(TranslationService.translate('enable_dark_theme', languageProvider.selectedLanguage)),
          ],
        ),
      ),
    );
  }
}