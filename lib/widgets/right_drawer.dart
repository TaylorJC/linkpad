import 'package:flutter/material.dart';

import 'drawer_title.dart';
import 'sidedrawer_card.dart';
import 'toggle_icon_button.dart';
import '../data/data_controller.dart';
import 'color_picker.dart';

class RightDrawer extends StatelessWidget {
  const RightDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final dataController = DataProvider.require(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
        ),
        Column(
          spacing: 8,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DrawerTitle(
              title: 'Settings',
              menuButtonSide: DrawerTitleButtonSide.right,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 8,
                children: [
                  SidedrawerCard(
                    title: 'Font Size:',
                    child: Slider(
                      min: 14,
                      max: 24,
                      value: dataController.fontSize,
                      onChanged: (value) {
                        dataController.updateFontSize(value);
                      },
                    ),
                  ),
                  SidedrawerCard(
                    title: 'Theme:',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ToggleIconButton(
                          onPressed: () {
                            dataController.updateThemeMode(ThemeMode.system);
                          },
                          icon: Icons.computer_rounded,
                          selected:
                              dataController.themeMode == ThemeMode.system,
                          // rotate: false,
                        ),
                        ToggleIconButton(
                          onPressed: () {
                            dataController.updateThemeMode(ThemeMode.dark);
                          },
                          icon: Icons.dark_mode_rounded,
                          selected: dataController.themeMode == ThemeMode.dark,
                        ),
                        ToggleIconButton(
                          onPressed: () {
                            dataController.updateThemeMode(ThemeMode.light);
                          },
                          icon: Icons.light_mode_rounded,
                          selected: dataController.themeMode == ThemeMode.light,
                        ),
                      ],
                    ),
                  ),
                  SidedrawerCard(
                    title: 'Color Scheme:',
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: 200,
                        maxWidth: 300,
                      ),
                      child: SingleChildScrollView(child: ColorPicker()),
                    ),
                  ),
                  SidedrawerCard(title: 'About:', child: ConstrainedBox(constraints: const BoxConstraints(
                    maxHeight: 200,
                    maxWidth: 200,
                  ),
                  child: Text(
                    'By Jeremy Crain'
                  ),
                  )
                  )
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
