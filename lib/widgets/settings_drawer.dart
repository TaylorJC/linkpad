import 'dart:io';

import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'sidedrawer_card.dart';
import 'toggle_icon_button.dart';
import '../data/data_controller.dart';
import 'color_picker.dart';
// import 'package:google_fonts/google_fonts.dart';

class SettingsDrawer extends StatelessWidget {
  const SettingsDrawer({super.key});

  // static const List<String> _fontOptions = [
  //   'Gowun Dodum',
  //   'Lato',
  //   'Lexend',
  //   'Red Hat Display',
  //   'Zain',
  // ];

  // List<DropdownMenuItem<String>> _getFontMenuItems() {
  //   List<DropdownMenuItem<String>> items = List.empty(growable: true);

  //   for (var font in _fontOptions) {
  //     items.add(
  //       DropdownMenuItem(
  //         child: Text(
  //           font,
  //           style: GoogleFonts.getFont(font)
  //         ),
  //       )
  //     );
  //   }

  //   return items;
  // }

  List<DropdownMenuItem<int>> _getAutosaveTimes() {
    List<DropdownMenuItem<int>> items = List.empty(growable: true);

    items.addAll([
      DropdownMenuItem(value: 15,child: Text('15 seconds'),),  
      DropdownMenuItem(value: 30,child: Text('30 seconds'),),
      DropdownMenuItem(value: 60,child: Text('1 minute'),),  
    ]);

    return items;
  }

  String get contactEmail => 'info@rosestudio.com';

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
          child: Padding(
            padding: EdgeInsets.only(left: 16.0, right: 16, top: MediaQuery.viewInsetsOf(context).top + 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 8,
              children: [
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
                SidedrawerCard(
                  title: 'Save Directory:',
                  child: StatefulBuilder(
                    builder: (context, setState) {
                      return InkWell(
                        child: ConstrainedBox(
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
                        ),
                      );
                    },
                  ),
                ),
                SidedrawerCard(title: 'Autosave Interval:',
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    runAlignment: WrapAlignment.center,
                    alignment: WrapAlignment.center,
                    children: [
                      ChoiceChip.elevated(
                        label: Text('15 Seconds',
                          style: TextStyle(
                            color: dataController.autosaveIncrement == Duration(seconds: 15) ? colorScheme.onPrimary : colorScheme.onSecondaryContainer
                          ),
                        ),
                        checkmarkColor: dataController.autosaveIncrement == Duration(seconds: 15) ? colorScheme.onPrimary : colorScheme.onSecondaryContainer,
                        selectedColor: colorScheme.primary,
                        backgroundColor: colorScheme.secondaryContainer,
                        onSelected: (val) {
                          dataController.updateAutosaveIncrement(15);
                        },
                        selected:
                          dataController.autosaveIncrement == Duration(seconds: 15),
                        // rotate: false,
                      ),
                      ChoiceChip.elevated(
                        label: Text('30 Seconds',
                          style: TextStyle(
                            color: dataController.autosaveIncrement == Duration(seconds: 30) ? colorScheme.onPrimary : colorScheme.onSecondaryContainer
                          ),
                        ),
                        checkmarkColor: dataController.autosaveIncrement == Duration(seconds: 30) ? colorScheme.onPrimary : colorScheme.onSecondaryContainer,
                        selectedColor: colorScheme.primary,
                        backgroundColor: colorScheme.secondaryContainer,
                        onSelected: (val) {
                          dataController.updateAutosaveIncrement(30);
                        },
                        selected:
                          dataController.autosaveIncrement == Duration(seconds: 30),
                        // rotate: false,
                      ),
                      ChoiceChip.elevated(
                        label: Text('60 Seconds',
                          style: TextStyle(
                            color: dataController.autosaveIncrement == Duration(seconds: 60) ? colorScheme.onPrimary : colorScheme.onSecondaryContainer
                          ),
                        ),
                        checkmarkColor: dataController.autosaveIncrement == Duration(seconds: 60) ? colorScheme.onPrimary : colorScheme.onSecondaryContainer,
                        selectedColor: colorScheme.primary,
                        backgroundColor: colorScheme.secondaryContainer,
                        onSelected: (val) {
                          dataController.updateAutosaveIncrement(60);
                        },
                        selected:
                          dataController.autosaveIncrement == Duration(seconds: 60),
                        // rotate: false,
                      ),
                    ],
                  )
                ),
                 SidedrawerCard(title: 'Contact:', child: ElevatedButton.icon(
                  icon: Icon(Icons.copy, color: colorScheme.onPrimaryContainer,),
                  style: ElevatedButton.styleFrom(backgroundColor: colorScheme.primaryContainer),
                  label: Text(
                    contactEmail,
                  ),
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: contactEmail));

                    if (!Platform.isAndroid && !Platform.isIOS) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Copied to clipboard',
                            style: TextStyle(
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                          backgroundColor: colorScheme.primaryContainer,
                        )
                      );
                    }
                  },
                 )),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
