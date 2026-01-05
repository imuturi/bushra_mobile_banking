import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../providers/local_provider.dart';

class LanguageDropdown extends StatefulWidget {
  const LanguageDropdown({super.key});
  @override
  State<LanguageDropdown> createState() => _LanguageDropdownState();
}

class _LanguageDropdownState extends State<LanguageDropdown> {
  String? _selectedLanguage;

  final List<Map<String, String>> languages = [
    {"name": "English", "flag": "assets/icons/gb.svg", "code": "en"},
    {"name": "العربية", "flag": "assets/icons/sa.svg", "code": "ar"},
    {"name": "Somali", "flag": "assets/icons/so.svg", "code": "so"},
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentLanguage();
  }

  void _loadCurrentLanguage() {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final currentLocale = localeProvider.locale.languageCode;

    final language = languages.firstWhere(
          (lang) => lang["code"] == currentLocale,
      orElse: () => languages.first,
    );

    _selectedLanguage = language["name"];
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedLanguage,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
          focusColor: Colors.white,
          items: languages.map((lang) {
            return DropdownMenuItem<String>(
              value: lang["name"],
              child: Row(
                children: [
                  SvgPicture.asset(
                    lang["flag"]!,
                    width: 15,
                    height: 10,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    lang["name"]!,
                    style: const TextStyle(
                        fontSize: 10,
                        color: Colors.black,
                        fontWeight: FontWeight.w600
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (String? newValue) async {
            if (newValue != null) {
              setState(() {
                _selectedLanguage = newValue;
              });

              final selectedLang = languages.firstWhere(
                    (lang) => lang["name"] == newValue,
                orElse: () => languages.first,
              );

              final localeCode = selectedLang["code"] ?? 'en';
              await localeProvider.setLocale(Locale(localeCode));
            }
          },
        ),
      ),
    );
  }
}