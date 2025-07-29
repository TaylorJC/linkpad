import 'package:flutter/material.dart';

enum TurnDirection {
  clockwise,
  counterClockwise,
}

class RotatingIconButton extends StatefulWidget {
  const RotatingIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.direction = TurnDirection.clockwise,
    this.duration = const Duration(milliseconds: 300),
    });

    final IconData icon;
    final Function onPressed;
    final TurnDirection direction;
    final Duration duration;

  @override
  State<RotatingIconButton> createState() => _RotatingIconButtonState();
}

class _RotatingIconButtonState extends State<RotatingIconButton> {

  double turns = 0.0;

  @override
  Widget build(BuildContext context) {
    return AnimatedRotation(
      turns: turns, 
      duration: widget.duration,
      child: IconButton(
        icon: Icon(widget.icon),
        onPressed: () {
          setState(() {
            if (widget.direction == TurnDirection.clockwise) {
              turns += 1;
            } else {
              turns -= 1;
            }// Increment the rotation
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