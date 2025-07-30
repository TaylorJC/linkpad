import 'package:fleather/fleather.dart' hide kToolbarHeight;
import 'package:flutter/material.dart';
import 'package:linkpad/data/data_controller.dart';
import 'package:linkpad/data/data_model.dart';
import 'package:linkpad/widgets/rotating_icon_button.dart';

class DocumentAppBar extends StatelessWidget implements PreferredSizeWidget {
  DocumentAppBar({
    super.key,
    required this.titleController,
    required this.focusNode,
    required this.editorController,
    required this.document,
    required this.dataController,
  });

  final TextEditingController titleController;
  final FocusNode focusNode;
  final FleatherController editorController;
  final Document document;
  final DataController dataController;
  // late Timer autosaveTimer;

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final DataController dataController = DataProvider.require(context);
    final colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: colorScheme.onPrimary, size: 32,),
        onPressed: () async {
          var didSave = await document.saveDocument(titleController, editorController, dataController);

          if (!didSave) {
            dataController.removeItem(document);
          }

          Navigator.of(context).pop();
        },
      ),
      actions: [
        RotatingIconButton(
          icon: Icons.undo,
          direction: TurnDirection.counterClockwise,
          onPressed: () {
            editorController.undo();
          },
        ),
        RotatingIconButton(
          icon: Icons.redo,
          onPressed: () {
            editorController.redo();
          },
        ),
        RotatingIconButton(
          icon: Icons.save,
          onPressed: () async {
            var saved = await document.saveDocument(titleController, editorController, dataController);

            if (saved) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: colorScheme.primary,
                  content: Text(
                    '"${document.title}" saved',
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontSize: TextTheme.of(context).titleMedium?.fontSize,
                    ),
                  ),
                  duration: Duration(seconds: 1),
                ),
              );
            }
          },
        ),
        MenuBar(
          style: MenuStyle(
            backgroundColor: WidgetStatePropertyAll(colorScheme.primary),
            elevation: WidgetStatePropertyAll(0),
            padding: WidgetStatePropertyAll(EdgeInsets.zero),
            shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(50)))
          ),
          children: [
            SubmenuButton(
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(colorScheme.primary),
                foregroundColor: WidgetStatePropertyAll(colorScheme.onPrimary),
                padding: WidgetStatePropertyAll(EdgeInsets.zero),
                elevation: WidgetStatePropertyAll(0),
                shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(50)))
              ),
              menuChildren: [
              MenuItemButton(
                child: Text('Export as Plaintext'),
                onPressed: () async {
                  final savePath = await dataController.export(document, ExportType.plainText);

                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    backgroundColor: colorScheme.primary,
                    content: Text(
                      'Saved to "$savePath"',
                      style: TextStyle(
                        color: colorScheme.onPrimary
                      ),
                    ),
                  ));
                },
              ),
              MenuItemButton(
                child: Text('Export as JSON'),
                onPressed: () async {
                  final savePath = await dataController.export(document, ExportType.json);

                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    backgroundColor: colorScheme.primary,
                    content: Text(
                      'Saved to "$savePath"',
                      style: TextStyle(
                        color: colorScheme.onPrimary
                      ),
                    ),
                  ));
                },
              ),
              // MenuItemButton(
              //   child: Text('Export as MarkDown'),
              //   onPressed: () {
              //     dataController.export(document, ExportType.markDown);
              //   },
              // ),
            ], child: Icon(Icons.more_vert,
              color: colorScheme.onPrimary,
            )
            ),
            ],
        ),
        SizedBox(width: 20,),
        RotatingIconButton(
          icon: Icons.link,
          onPressed: () async {
            await document.saveDocument(titleController, editorController, dataController);

            Scaffold.of(context).openEndDrawer();
          },
        )
      ],
      backgroundColor: colorScheme.primary,
    );
  }
}
