import 'package:flutter/material.dart';

import 'custom_card.dart';

class SidedrawerCard extends StatelessWidget {
  const SidedrawerCard({super.key,
  required this.title,
  required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CustomCard(
      backgroundColor: Colors.transparent,
      child: Column(
        spacing: 12,
        children: [
          Text(title, 
            style: TextStyle(
              color: colorScheme.onSecondaryContainer, 
              fontSize: TextTheme.of(context).titleLarge?.fontSize, 
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
          child,
        ],
      ),
    );
  }
}