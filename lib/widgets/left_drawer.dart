import 'dart:io';

import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'drawer_title.dart';
import 'sidedrawer_card.dart';
import 'toggle_icon_button.dart';
import '../data/data_controller.dart';
import 'color_picker.dart';

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

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
              // topLeft: Radius.circular(16),
              // bottomLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
        ),
        SingleChildScrollView(
          child: Column(
            spacing: 8,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // DrawerTitle(
              //   title: 'Settings',
              //   menuButtonSide: DrawerTitleButtonSide.right,
              // ),
              Padding(
                padding: EdgeInsets.only(left: 16.0, right: 16, top: MediaQuery.viewInsetsOf(context).top + 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 8,
                  children: [
                    SidedrawerCard(
                      title: 'Save Directory:',
                      child: StatefulBuilder(
                        builder: (context, setState) {
                          return ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxHeight: 200,
                              maxWidth: 300,
                            ),
                            child: TextField(
                              controller: TextEditingController(text: dataController.saveDirectory.path),
                              readOnly: true,
                              decoration: InputDecoration(
                                suffixIcon: Icon(Icons.folder_open, color: colorScheme.onSecondaryContainer),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onTap: () async {
                                var docDir = await getApplicationDocumentsDirectory();
                            
                                var newDir = await FilesystemPicker.open(
                                  context: context,
                                  rootDirectory: docDir,
                                  directory: dataController.saveDirectory,
                                  title: 'Select Save Directory',
                                  fsType: FilesystemType.folder,
                                  pickText: 'Select',
                                  contextActions: [
                                    FilesystemPickerContextAction(
                                      text: 'Create New Folder',
                                      icon: Icon(Icons.create_new_folder),
                                      action: (context, directory) async {
                                        var newFolder = await showDialog<String>(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Text('New Folder Name'),
                                              content: TextField(
                                                autofocus: true,
                                                decoration: InputDecoration(hintText: 'Enter folder name'),
                                                onSubmitted: Navigator.of(context).pop,
                                              ),
                                            );
                                          },
                                        );
                            
                                        if (newFolder != null && newFolder.isNotEmpty) {
                                          var newDirectory = Directory('${directory.path}/$newFolder');
                                          await newDirectory.create();
                                          return true;
                                        }
                            
                                        return false;
                                      },
                                    ),
                                  ],
                                  theme: FilesystemPickerTheme(
                                    backgroundColor: colorScheme.surfaceContainer,
                                    topBar: FilesystemPickerTopBarThemeData(
                                      backgroundColor: colorScheme.primaryContainer,
                                    ),
                                    pickerAction: FilesystemPickerActionThemeData(
                                      location: FilesystemPickerActionLocation.floatingCenter,
                                      backgroundColor: colorScheme.primaryContainer,
                                      textStyle: TextStyle(color: colorScheme.onPrimaryContainer),
                                    )
                                  )
                                );
                            
                                if (newDir != null) {
                                  dataController.updateSaveDirectory(newDir);
                                }
                              },
                            ),
                          );
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
