import 'package:flutter/material.dart';

class BasicProgressDialog extends StatefulWidget {
  final String message;
  const BasicProgressDialog({super.key, required this.message});

  @override
  _BasicProgressDialogState createState() => _BasicProgressDialogState();
}

class _BasicProgressDialogState extends State<BasicProgressDialog>{

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      content: Row(
        children: [
          const CircularProgressIndicator(
            color: Colors.red,
          ),
          Container(
              margin: const EdgeInsets.only(left: 7),
              child: Text(widget.message
              )
          ),
        ],),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}