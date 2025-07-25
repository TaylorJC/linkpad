import 'package:flutter/material.dart';
import 'package:linkpad/data/data_controller.dart';
import 'package:linkpad/data/data_model.dart';

class HeroTitle extends StatelessWidget {
  HeroTitle({
    super.key,
    required this.document,
    required this.titleController,
    required this.focusNode,
  });

  final Document document;
  final TextEditingController titleController;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: TextField(
          controller: titleController,
          autofocus: true,
          maxLines: 1,
          textAlign: TextAlign.center,
          cursorColor: colorScheme.onSurface,
          textCapitalization: TextCapitalization.words,
          onSubmitted: (_) {
            focusNode.requestFocus();
          },
          decoration: InputDecoration(
            border: InputBorder.none,
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: colorScheme.onSurface)),
            hintText: 'Title',
            hintStyle: TextStyle(
              color: colorScheme.onSurface.withAlpha(150),
              fontStyle: FontStyle.italic,
              fontSize: TextTheme.of(context).titleLarge?.fontSize,
            )
          ),
          style: TextStyle(
            fontSize: TextTheme.of(context).titleLarge?.fontSize,
            color: colorScheme.onSurface,
          ),
        ),
    );
  }
}