import 'package:flutter/material.dart';

import '../data/data_controller.dart';

class ColorPicker extends StatefulWidget {
  const ColorPicker({super.key});


  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  final List<Color> colorChoices = List.from(
    {
      Colors.orange,
      const Color.fromARGB(255, 255, 85, 85),
      Colors.purple,
      const Color.fromARGB(255,189,147,249),
      Colors.indigo,
      Colors.blueAccent,
      Colors.teal,
      Colors.cyan,
      const Color.fromARGB(255, 80, 250, 123),  
    }
  );

  @override
  Widget build(BuildContext context) {
    final dataController = DataProvider.require(context);
    final width = MediaQuery.sizeOf(context).width;
    final iconWidth = width < 400 ? 60.0 : 80.0;

    return Builder(
      builder: (context) {
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List<Widget>.generate(colorChoices.length, (index) {
            return AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeIn,
              child: MaterialButton(
                onPressed: () {
                  dataController.updateThemeColor(colorChoices[index]);
                },
                elevation: 4,
                hoverElevation: 10,
                hoverColor: colorChoices[index].withAlpha(10),
                color: colorChoices[index],
                minWidth: iconWidth,
                height: 50,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                child: dataController.themeColor == colorChoices[index] ? Icon(Icons.check) : null,
              ),
            );
          }),
        );
      }
    );
  }
}