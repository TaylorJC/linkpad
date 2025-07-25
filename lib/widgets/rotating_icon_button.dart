import 'package:flutter/material.dart';

class RotatingIconButton extends StatefulWidget {
  const RotatingIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    });

    final IconData icon;
    final Function onPressed;

  @override
  State<RotatingIconButton> createState() => _RotatingIconButtonState();
}

class _RotatingIconButtonState extends State<RotatingIconButton> {

  double turns = 0.0;
  final Duration duration = const Duration(milliseconds: 300);

  @override
  Widget build(BuildContext context) {
    return AnimatedRotation(
      turns: turns, 
      duration: duration,
      child: IconButton(
        icon: Icon(widget.icon),
        onPressed: () {
          setState(() {
            turns += 1.0; // Increment the rotation
          });
          widget.onPressed(); // Call the provided onPressed function
        },
        style: IconButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
  }
}