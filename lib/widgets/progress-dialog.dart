import 'package:flutter/material.dart';

//TODO -------------------------------------------------------------------------
//TODO -------------------------------------------------------------------------
//TODO - PROGRESS DIALOG -------------------------------------------------------
//TODO -------------------------------------------------------------------------
//TODO -------------------------------------------------------------------------
class CrossingBallsProgressDialog extends StatefulWidget {
  final String message;
  const CrossingBallsProgressDialog({super.key, required this.message});

  @override
  _CrossingBallsProgressDialogState createState() => _CrossingBallsProgressDialogState();
}

class _CrossingBallsProgressDialogState extends State<CrossingBallsProgressDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: -20, end: 20).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 40,
              width: 100,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Transform.translate(
                        offset: Offset(_animation.value, 0),
                        child: CircleAvatar(radius: 10, backgroundColor: Colors.red.shade900),
                      ),
                      Transform.translate(
                        offset: Offset(-_animation.value, 0),
                        child: CircleAvatar(radius: 10, backgroundColor: Colors.indigo.shade900),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}