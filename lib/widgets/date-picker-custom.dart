import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomDatePickerWidget extends StatelessWidget {
  final BuildContext context;
  final String hint;
  final TextEditingController controller;

  const CustomDatePickerWidget({super.key,
    required this.context,
    required this.hint,
    required this.controller,
  });

  Widget _buildTextInputFieldGrayDateTime() {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          TextField(
            controller: controller,
            readOnly: true,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              hintText: hint,
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: const Icon(Icons.calendar_today),
            ),
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                locale: const Locale('en', 'GB'),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
                builder: (context, child) {
                  return Theme(
                    data: ThemeData.light().copyWith(
                      colorScheme: ColorScheme.light(
                        primary: Colors.red.shade900,
                        onPrimary: Colors.white,
                        surface: Colors.white,
                        onSurface: Colors.black,
                      ),
                      dialogBackgroundColor: Colors.white,
                    ),
                    child: child!,
                  );
                },
              );

              if (pickedDate != null) {
                controller.text = dateFormat.format(pickedDate);
              }
            },
          ),
          Positioned(
            left: 10,
            right: 10,
            bottom: 0,
            child: Container(
              height: 1,
              color: Colors.grey.shade900,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildTextInputFieldGrayDateTime();
  }
}
