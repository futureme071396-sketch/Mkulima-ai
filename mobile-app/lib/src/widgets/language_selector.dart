// mobile-app/lib/src/widgets/language_selector.dart
import 'package:flutter/material.dart';

class Language {
  final String code;
  final String name;
  final String nativeName;
  final String flag;

  const Language({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
  });
}

class LanguageSelector extends StatefulWidget {
  final String selectedLanguage;
  final ValueChanged<String> onLanguageChanged;
  final bool compact;

  const LanguageSelector({
    Key? key,
    required this.selectedLanguage,
    required this.onLanguageChanged,
    this.compact = false,
  }) : super(key: key);

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  final List<Language> _languages = const [
    Language(
      code: 'sw',
      name: 'Swahili',
      nativeName: 'Kiswahili',
      flag: '🇹🇿',
    ),
    Language(
      code: 'en',
      name: 'English',
      nativeName: 'English',
      flag: '🇺🇸',
    ),
    Language(
      code: 'kik',
      name: 'Kikuyu',
      nativeName: 'Gikuyu',
      flag: '🇰🇪',
    ),
    Language(
      code: 'luo',
      name: 'Luo',
      nativeName: 'Dholuo',
      flag: '🇰🇪',
    ),
  ];

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _languages.length,
            itemBuilder: (context, index) {
              final language = _languages[index];
              return _buildLanguageTile(language);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageTile(Language language) {
    return ListTile(
      leading: Text(
        language.flag,
        style: const TextStyle(fontSize: 24),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(language.name),
          Text(
            language.nativeName,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
      trailing: widget.selectedLanguage == language.code
          ? const Icon(Icons.check, color: Colors.green)
          : null,
      onTap: () {
        widget.onLanguageChanged(language.code);
        Navigator.pop(context);
      },
    );
  }

  Language get _currentLanguage {
    return _languages.firstWhere(
      (lang) => lang.code == widget.selectedLanguage,
      orElse: () => _languages.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.compact) {
      return _buildCompactSelector();
    } else {
      return _buildExpandedSelector();
    }
  }

  Widget _buildCompactSelector() {
    return InkWell(
      onTap: _showLanguageDialog,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _currentLanguage.flag,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 8),
            Text(
              _currentLanguage.code.toUpperCase(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              color: Colors.grey[600],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedSelector() {
    return Card(
      child: InkWell(
        onTap: _showLanguageDialog,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.language,
                  color: Colors.blue[700],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'App Language',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_currentLanguage.name} (${_currentLanguage.nativeName})',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _currentLanguage.flag,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Language chip for quick selection
class LanguageChip extends StatelessWidget {
  final Language language;
  final bool selected;
  final VoidCallback onTap;

  const LanguageChip({
    Key? key,
    required this.language,
    required this.selected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(language.flag),
          const SizedBox(width: 6),
          Text(language.name),
        ],
      ),
      selected: selected,
      onSelected: (_) => onTap(),
      backgroundColor: Colors.grey[200],
      selectedColor: Colors.green[100],
      checkmarkColor: Colors.green,
      showCheckmark: true,
    );
  }
}

// Language toggle for settings
class LanguageToggle extends StatelessWidget {
  final String selectedLanguage;
  final ValueChanged<String> onLanguageChanged;

  const LanguageToggle({
    Key? key,
    required this.selectedLanguage,
    required this.onLanguageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languages = const [
      Language(code: 'sw', name: 'Swahili', nativeName: 'Kiswahili', flag: '🇹🇿'),
      Language(code: 'en', name: 'English', nativeName: 'English', flag: '🇺🇸'),
      Language(code: 'kik', name: 'Kikuyu', nativeName: 'Gikuyu', flag: '🇰🇪'),
      Language(code: 'luo', name: 'Luo', nativeName: 'Dholuo', flag: '🇰🇪'),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: languages.map((language) {
        return LanguageChip(
          language: language,
          selected: selectedLanguage == language.code,
          onTap: () => onLanguageChanged(language.code),
        );
      }).toList(),
    );
  }
}
