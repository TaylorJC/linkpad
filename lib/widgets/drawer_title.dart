import 'package:flutter/material.dart';

enum DrawerTitleButtonSide {
  left,
  right,
}

class DrawerTitle extends StatelessWidget {
  const DrawerTitle({
    super.key,
    required this.title,
    required this.menuButtonSide,
  });

  final String title;
  final DrawerTitleButtonSide menuButtonSide;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // final dataController = DataProvider.require(context);

    // List<Widget> buildRow() {
    //   final titleWidget = Text(
    //     title,
    //     textAlign: TextAlign.center,
    //     style: TextStyle(
    //       color: colorScheme.onPrimary,
    //       fontSize: TextTheme.of(context).titleLarge?.fontSize,
    //       fontWeight: FontWeight.w800,
    //       letterSpacing: 2,
    //     ),
    //   );

    //   // final iconWidget = IconButton(
    //   //   onPressed: () => Navigator.of(context).pop(),
    //   //   icon: Icon(Icons.close, color: colorScheme.onPrimary, size: 32),
    //   //   padding: EdgeInsets.zero,
    //   //   alignment: Alignment.center,
    //   //   constraints: BoxConstraints(),
    //   // );

    //   if (menuButtonSide == DrawerTitleButtonSide.left) {
    //     return [
    //       // iconWidget, 
    //       titleWidget
    //     ];
    //   } else {
    //     return [
    //       titleWidget, 
    //       // iconWidget
    //     ];
    //   }
    // }

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
      ),
      child: Padding(
        padding: EdgeInsets.only(left: 16.0, top: MediaQuery.viewPaddingOf(context).top + 16, right: 16.0, bottom: 16),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colorScheme.onPrimary,
            fontSize: TextTheme.of(context).titleLarge?.fontSize,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
        // child: Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   crossAxisAlignment: CrossAxisAlignment.center,
        //   children: buildRow(),
        // ),
      ),
    );
  }
}
