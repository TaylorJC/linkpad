import 'dart:convert';
import 'package:fleather/fleather.dart' hide kToolbarHeight;
import 'package:flutter/material.dart';
import 'package:linkpad/data/data_controller.dart';
import 'package:linkpad/data/data_model.dart';
import 'package:linkpad/data/datetime_parse.dart';
import 'package:linkpad/widgets/rotating_icon_button.dart';

class DocumentAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DocumentAppBar({
    super.key,
    required this.titleController,
    required this.focusNode,
    required this.editorController,
    required this.document,
  });

  final TextEditingController titleController;
  final FocusNode focusNode;
  final FleatherController editorController;
  final Document document;

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  Future<bool> _saveDocument(BuildContext context) async {
    final dataController = DataProvider.require(context);

    if (titleController.text.trim().isEmpty && editorController.plainTextEditingValue.text.trim().isEmpty) {
      return false; // Do not save if both title and content are empty
    }

    if (dataController.items.any((item) => item.title == titleController.text.trim() && item.id != document.id)) {
      // If a document with the same title already exists, show an error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('A document with this title already exists.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return false; // Do not save if title already exists
    }

    if (document.title != titleController.text) {
      await dataController.removeItem(document);
      document.title = titleController.text.trim();
    }

    document.lastModified = dateTimeNowToInt();
    await dataController.updateItem(document);

    dataController.saveDocumentToFile(
      document,
      jsonEncode(editorController.document.toJson()),
    );

    return true; // Document saved successfully
  }

  @override
  Widget build(BuildContext context) {
    final DataController dataController = DataProvider.require(context);
    final colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: colorScheme.onPrimary, size: 32,),
        onPressed: () async {
          if ((titleController.text.trim().isEmpty) && editorController.plainTextEditingValue.text.trim().length <= 1) {
            await dataController.removeItem(document);
            Navigator.of(context).pop();
            return;
          } else if (titleController.text.isEmpty) {
            titleController.text = editorController.plainTextEditingValue.text.isNotEmpty
                ? editorController.plainTextEditingValue.text.substring(0, editorController.plainTextEditingValue.text.length > 20 ? 20 : editorController.plainTextEditingValue.text.length)
                : 'Untitled';
          }

          await _saveDocument(context).whenComplete(() {
            Navigator.of(context).pop();
          });
        },
      ),
      actions: [
        // IconButton(
        //   icon: Icon(Icons.undo, color: colorScheme.onPrimary, size: 32,),
        //   onPressed: editorController.canUndo ? () {
        //     editorController.undo();
        //   } : null,
        // ),
        // IconButton(
        //   icon: Icon(Icons.redo, color: colorScheme.onPrimary, size: 32,),
        //   onPressed: editorController.canRedo ? () {
        //     editorController.redo();
        //   } : null,
        // ),
        // RotatingIconButton(
        //   icon: Icons.format_bold,
        //   onPressed: () {
        //     editorController.formatSelection(ParchmentAttribute.bold);
        //   },
        // ),
        // RotatingIconButton(
        //   icon: Icons.format_italic,
        //   onPressed: () {
        //     editorController.formatSelection(ParchmentAttribute.italic);
        //   },
        // ),
        // PopupMenuButton(
        //   icon: Icon(Icons.menu_outlined, color: colorScheme.onPrimary),
        //   itemBuilder: (context) {
        //   return [
        //     PopupMenuItem(
        //       value: ParchmentAttribute.bold,
        //       child: Text('Bold'),
        //     ),
        //     PopupMenuItem(
        //       value: ParchmentAttribute.italic,
        //       child: Text('Italic'),
        //     ),
        //     PopupMenuItem(
        //       value: ParchmentAttribute.underline,
        //       child: Text('Underline'),
        //     ),
        //     PopupMenuItem(
        //       value: ParchmentAttribute.strikethrough,
        //       child: Text('Strikethrough'),
        //     ),
            
        //   ];
        // }, onSelected: (value) {
        //   editorController.formatSelection(value);
        // }),
        // RotatingIconButton(
        //   icon: Icons.format_align_center,
        //   onPressed: () {
        //     editorController.formatSelection(ParchmentAttribute.center);
        //   },
        // ),
        RotatingIconButton(
          icon: Icons.save,
          onPressed: () async {
            var saved = await _saveDocument(context);

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
        RotatingIconButton(
          icon: Icons.link,
          onPressed: () {
            _saveDocument(context);

            Scaffold.of(context).openEndDrawer();
          },
        )
      ],
      backgroundColor: colorScheme.primary,
    );
  }
}
