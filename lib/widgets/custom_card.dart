import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  const CustomCard({
    super.key, 
    this.borderRadius = 16.0,
    this.backgroundColor = Colors.white70,
    this.padding = 12.0,
    required this.child,
  });

  final Widget child;
  final double borderRadius;
  final Color backgroundColor;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return Container( 
      alignment: Alignment.topCenter,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(8)), 
        color: backgroundColor
      ),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: child,
      ),
    );
  }
}