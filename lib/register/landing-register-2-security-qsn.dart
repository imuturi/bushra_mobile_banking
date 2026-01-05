import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../utils/providers/provider-registration.dart';
import '../widgets/progress-dialog.dart';
import 'landing-register-3-pin-create.dart';

class RegisterSecurityQuestions extends StatefulWidget {
  const RegisterSecurityQuestions({super.key});

  @override
  State<RegisterSecurityQuestions> createState() => _RegisterSecurityQuestionsState();
}

class _RegisterSecurityQuestionsState extends State<RegisterSecurityQuestions> {
  bool isLoading = false;
  String? _question1;
  String? _question2;
  String? _question3;

  final TextEditingController _answer1Controller = TextEditingController();
  final TextEditingController _answer2Controller = TextEditingController();
  final TextEditingController _answer3Controller = TextEditingController();

  final List<String> _set = [
    'Whats your pet name',
    'Whats your favourite car',
    'Whats the name of your best friend'
  ];

  void showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 10),
        backgroundColor: color,
        action: SnackBarAction(
          label: "DISMISS",
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void showCrossingBallsProgressDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CrossingBallsProgressDialog(message: message),
    );
  }

  void showAlertDialogSecurityQuestion(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.asset('assets/images/icons/success-check.png', width: 70),
              const SizedBox(height: 16),
               Text(
                AppLocalizations.of(context)!.securityQuestionSetSuccessfully,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
               Text(
                AppLocalizations.of(context)!.youHaveSuccessfullySetYourSecurityQuestionsPleasePressContinueButtonToProceed,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 8,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade900,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterPinInputScreen1(),
                    ),
                  );
                },
                child: const Text(
                  'CONTINUE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final registrationData = Provider.of<RegistrationData>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title:  Text(
          AppLocalizations.of(context)!.setSecurityQuestion,
          style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text(
                      AppLocalizations.of(context)!.pleaseProvideTheFollowingSecurityQuestionsToFinaliseActivation,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                     Text(
                        AppLocalizations.of(context)!.setAndAnswerTheFollowingQuestions,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                    ),
                    const SizedBox(height: 15),
                     Text(
                       AppLocalizations.of(context)!.q1WhatsYourPetName,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                    ),
                    const SizedBox(height: 8),
                    InputDecorator(
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _question1,
                          hint: Text(AppLocalizations.of(context)!.selectAQuestionHere,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              color: Colors.grey.shade800,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              _question1 = newValue!;
                            });
                          },
                          dropdownColor: Colors.white,
                          items: _set
                              .where((value) => value != _question2 && value != _question3)
                              .map((value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: TextStyle(fontSize: 12),),
                          )).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _answer1Controller,
                      decoration:   InputDecoration(
                        hintText: AppLocalizations.of(context)!.giveYourAnswerHere,
                        border: OutlineInputBorder(),
                      ),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: Colors.grey.shade800,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 10),
                     Text(
                      AppLocalizations.of(context)!.q2WhatsYourFavouriteCar,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                    ),
                    const SizedBox(height: 8),
                    InputDecorator(
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _question2,
                          hint: Text(AppLocalizations.of(context)!.selectAQuestionHere,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              color: Colors.grey.shade800,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              _question2 = newValue!;
                            });
                          },
                          dropdownColor: Colors.white,
                          items: _set
                              .where((value) => value != _question1 && value != _question3)
                              .map((value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: TextStyle(fontSize: 12),),
                          ))
                              .toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _answer2Controller,
                      decoration:   InputDecoration(
                        hintText: AppLocalizations.of(context)!.giveYourAnswerHere,
                        border: OutlineInputBorder(),
                      ),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: Colors.grey.shade800,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 10),
                     Text(
                      AppLocalizations.of(context)!.q3WhatsTheNameOfYourBestFriend,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                    ),
                    const SizedBox(height: 8),
                    InputDecorator(
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          hint: Text(AppLocalizations.of(context)!.selectAQuestionHere,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              color: Colors.grey.shade800,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          value: _question3,
                          onChanged: (String? newValue) {
                            setState(() {
                              _question3 = newValue!;
                            });
                          },
                          dropdownColor: Colors.white,
                          items: _set
                              .where((value) => value != _question1 && value != _question2)
                              .map((value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: TextStyle(fontSize: 12),),
                          ))
                              .toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _answer3Controller,
                      decoration:   InputDecoration(
                        // hintText: 'Give your answer here',
                        hintText: AppLocalizations.of(context)!.giveYourAnswerHere,
                        border: OutlineInputBorder(),
                      ),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: Colors.grey.shade800,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    isLoading = true;
                  });

                  if (_question1 == null || _question2 == null || _question3 == null) {
                    showSnackBar(context, 'Please select all questions', Colors.red);
                    setState(() => isLoading = false);
                    return;
                  }
                  if (_answer1Controller.text.isEmpty ||
                      _answer2Controller.text.isEmpty ||
                      _answer3Controller.text.isEmpty) {
                    showSnackBar(context, 'Please provide answers to all questions', Colors.red);
                    setState(() => isLoading = false);
                    return;
                  }
                  if (_question1 == _question2 ||
                      _question1 == _question3 ||
                      _question2 == _question3) {
                    showSnackBar(context, 'Please select different questions', Colors.red);
                    setState(() => isLoading = false);
                    return;
                  }

                  showCrossingBallsProgressDialog(context, 'We are verifying your answer \n Please Wait...');
                  registrationData.updateScreen2Data(
                    question1: _question1 ?? '',
                    answer1: _answer1Controller.text.trim(),
                    question2: _question2 ?? '',
                    answer2: _answer2Controller.text.trim(),
                    question3: _question3 ?? '',
                    answer3: _answer3Controller.text.trim(),
                  );

                  Future.delayed(const Duration(seconds: 1), () {
                    setState(() => isLoading = false);
                    Navigator.pop(context);
                    showAlertDialogSecurityQuestion(context);
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade900,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'CONTINUE',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
