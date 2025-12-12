import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../widgets/date-picker-custom.dart';
import 'open-account-2-terms.dart';

class OpenAccountScreen1 extends StatefulWidget {
  const OpenAccountScreen1({super.key});
  @override
  State<OpenAccountScreen1> createState() => _OpenAccountScreen1State();
}

class _OpenAccountScreen1State extends State<OpenAccountScreen1> {
  bool? value = false;
  FocusNode focusNode = FocusNode();

  TextEditingController idController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  String phoneNumber = '';

  @override
  void dispose() {
    idController.dispose();
    phoneController.dispose();
    dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Open Account",
          style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
          child: Column(
            children: [
              Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Please provide the following details.',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 25),

                        Text('ID Number / Passport Number', style: TextStyle(color: Colors.grey.shade700, fontSize: 12,)),
                        const SizedBox(height: 6),
                        _buildTextInputFieldRed("Eg. P12345678", idController, TextInputType.text),
                        const SizedBox(height: 20),

                        Text('Phone Number', style: TextStyle(color: Colors.grey.shade700, fontSize: 12,)),
                        const SizedBox(height: 6),
                        _buildTextInputFieldPhoneNumber('Eg 615566243', phoneController),
                        const SizedBox(height: 20),

                        Text('Date of Birth', style: TextStyle(color: Colors.grey.shade700, fontSize: 12,)),
                        const SizedBox(height: 6),
                        CustomDatePickerWidget(
                          context: context,
                          hint: 'Eg dd/MM/yyyy',
                          controller: dobController,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: <Widget>[
                        const SizedBox(width: 10),
                        Checkbox(
                          tristate: true,
                          value: value,
                          onChanged: (bool? newValue) {
                            setState(() {
                              value = newValue;
                            });
                          },
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'I agree to the terms & conditions: ',
                          style: TextStyle(fontSize: 12.0),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Action to continue
                          String accountType = 'BUSINESS_ACCOUNT';
                          String passportNumber = idController.text;
                          String phoneNumber = phoneController.text;
                          String dateOfBirth = dobController.text;
                          //TODO
                          Navigator.push(context, MaterialPageRoute(builder: (context) => OpenAccountTerms(
                            accountType: accountType,
                            passportNumber: passportNumber,
                            phoneNumber: phoneNumber,
                            dateOfBirth: dateOfBirth,
                          )),);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade900,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          "CONTINUE",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
      ),
    );
  }

  Widget _buildTextInputFieldRed(String hint, TextEditingController controller, TextInputType textInputType, {int maxLines = 1}){
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.shade50, // Light red background
        borderRadius: BorderRadius.circular(8), // Rounded corners
      ),
      child: Stack(
        children: [
          TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: textInputType,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              hintText: hint,
              filled: true,
              fillColor: Colors.red.shade50,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          Positioned(
            left: 10, // Aligning with the inner curve
            right: 10, // Aligning with the inner curve
            bottom: 0,
            child: Container(
              height: 1,
              color: Colors.red.shade900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextInputFieldPhoneNumber(String hint, TextEditingController controller){
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100, // Light red background
        borderRadius: BorderRadius.circular(8), // Rounded corners
      ),
      child: Stack(
        children: [
          IntlPhoneField(
            controller: controller,
            focusNode: focusNode,
            disableLengthCheck: true,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            languageCode: "en",
            initialCountryCode: "SO",
            onChanged: (phone) {
              if (kDebugMode) {
                print(phone.completeNumber);
              }
              setState(() {
                phoneNumber = phone.completeNumber;
              });
            },
            onCountryChanged: (country) {
              if (kDebugMode) {
                print('Country changed to: ${country.name}');
              }
            },
          ),
          Positioned(
            left: 10, // Aligning with the inner curve
            right: 10, // Aligning with the inner curve
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

}