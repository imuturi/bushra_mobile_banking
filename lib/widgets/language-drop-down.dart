import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LanguageDropdown extends StatefulWidget {
  const LanguageDropdown({super.key});
  @override
  State<LanguageDropdown> createState() => _LanguageDropdownState();
}

class _LanguageDropdownState extends State<LanguageDropdown> {
  String selectedLanguage = "English"; // Default language

  final List<Map<String, String>> languages = [
    {"name": "English", "flag": "assets/icons/gb.svg"},
    {"name": "العربية", "flag": "assets/icons/sa.svg"},
    {"name": "Somali", "flag": "assets/icons/so.svg"},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white, // White background
        borderRadius: BorderRadius.circular(8), // Rounded corners
        border: Border.all(color: Colors.grey.shade300), // Light border
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedLanguage,
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
                    style: const TextStyle(fontSize: 10, color: Colors.black, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                selectedLanguage = newValue;
              });
            }
          },
        ),
      ),
    );
  }
}
