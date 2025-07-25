import 'package:flex_seed_scheme/flex_seed_scheme.dart';
import 'package:flutter/material.dart';

class ToggleIconButton extends StatelessWidget {
  const ToggleIconButton({
    super.key,
    required this.onPressed,
    required this.selected,
    required this.icon,
    this.rotate = true,
    this.selectedIcon,
    this.seedColor
  });

  final Function? onPressed;
  final bool selected;
  final IconData icon;
  final bool rotate;
  final IconData? selectedIcon;
  final Color? seedColor;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final iconWidth = width < 450 ? 30.0 : 80.0;
    final colorScheme = seedColor != null ? SeedColorScheme.fromSeeds(
      brightness: Brightness.light, 
      tones: FlexTones.vivid(Brightness.light), 
      primary: seedColor!,
      primaryKey: seedColor!,
    ) : Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(right: 4.0, left: 4),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 100),
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: iconWidth),
          child: IconButton(
            onPressed: onPressed != null ? () => onPressed!() : null, 
            icon: AnimatedRotation(
              turns: selected && rotate ? 1 : 0,
              duration: Duration(milliseconds: 300),
              child: Icon(
                selected ? selectedIcon != null ? selectedIcon! : icon : icon,
              ),
            ), 
            style: IconButton.styleFrom(
              backgroundColor: selected ? colorScheme.primary : colorScheme.secondaryContainer,
              foregroundColor: selected ? colorScheme.onPrimary : colorScheme.onSecondaryContainer,
              disabledBackgroundColor: Colors.transparent,
              disabledForegroundColor: colorScheme.onPrimary,
            ),
          ),
        ),
      ),
    );
  }
}