import 'package:fleather/fleather.dart';
import 'package:flex_seed_scheme/flex_seed_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:linkpad/data/data_model.dart';
import 'package:linkpad/widgets/linkpad_appbar.dart';

import '../data/data_controller.dart';
import 'document_display.dart';
import 'document_page.dart';
import 'settings_drawer.dart';

/// Main application
/// Contains the MaterialApp, using the dataController to control the ThemeMode and ColorScheme
class LinkPad extends StatefulWidget {
  const LinkPad({
    super.key,
    required this.dataController,
  });

  /// The controller for all persistant data in the application
  final DataController dataController;

  @override
  State<LinkPad> createState() => _LinkPadState();
}

class _LinkPadState extends State<LinkPad> {
  final ScrollController _scrollController = ScrollController();
  bool _extendFAB = true;

  DocumentDisplayType documentDisplayType = DocumentDisplayType.grid;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        setState(() {
          _extendFAB = _scrollController.position.pixels == _scrollController.position.minScrollExtent;
        });
        
      } else {
        setState(() {
          _extendFAB = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DataProvider(
        dataController: widget.dataController, // Provide the data controller to all children
        child: ListenableBuilder(
          listenable: widget.dataController, // Listen to changes in the data controller to rebuild
          builder: (context, child) {
            return MaterialApp(
              theme: ThemeData.from(
                colorScheme: SeedColorScheme.fromSeeds(
                  brightness: Brightness.light, 
                  tones: FlexTones.candyPop(Brightness.light), 
                  primaryKey: widget.dataController.themeColor,
                  error: Colors.red,
                ),
               ), // Theme from the data controller's saved theme color
              darkTheme: ThemeData.from(colorScheme: SeedColorScheme.fromSeeds(
                brightness: Brightness.dark,
                tones: FlexTones.soft(Brightness.dark), 
                primaryKey: widget.dataController.themeColor,
                error: Colors.red,
              )), // Theme from the data controller's saved theme color
              themeMode: widget.dataController.themeMode, // Theme from the data controller's saved theme mode
              home: Builder(
                builder: (context) {
                  final colorScheme = Theme.of(context).colorScheme;

                  return Padding(
                    padding: EdgeInsets.zero,
                    child: Scaffold(
                      primary: true,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      resizeToAvoidBottomInset: true,
                      drawer: SizedBox(
                        width: MediaQuery.sizeOf(context).width * 0.8, // Set the width of the left drawer to 75% of the screen width
                        child: SettingsDrawer()), // Left drawer for tags and filters// Right drawer for settings
                      appBar: LinkpadAppbar(),
                      body: Padding(
                        padding: EdgeInsets.only(bottom: MediaQuery.viewPaddingOf(context).bottom, 
                        // top: MediaQuery.viewPaddingOf(context).top
                      ), 
                        child:  DocumentDisplay(
                          scrollController: _scrollController,
                          displayType: widget.dataController.displayType, 
                          crossAxisCount: MediaQuery.sizeOf(context).width ~/ 200,
                        ), // List of all documents
                      ),
                      floatingActionButton: FloatingActionButton.extended(
                        extendedIconLabelSpacing: _extendFAB ? 10 : 0,
                        extendedPadding: _extendFAB ? null : const EdgeInsets.all(16),
                        onPressed: () async {
                          var doc = await widget.dataController.addItemByTitle('');

                          ParchmentDocument parchment = ParchmentDocument();

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              fullscreenDialog: true,
                              builder: (context) {
                                return DocumentPage(document: doc, parchment: parchment, dataController: widget.dataController);
                              }
                            )
                          );
                        },
                        label: AnimatedSize(
                          duration: const Duration(milliseconds: 150),
                          child: _extendFAB ? Text(
                            "New Note", style: TextStyle(fontSize: TextTheme.of(context).titleMedium?.fontSize),
                            ) : const SizedBox(),
                        ),
                        icon: const Icon(Icons.add),
                      ) // Quick add new to-dos
                    )
                  );
                }
              ),
            );
          },
        ),
    );
  }
}
