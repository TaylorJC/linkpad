import 'dart:convert';

import 'package:fleather/fleather.dart' hide kToolbarHeight;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:linkpad/data/data_controller.dart';
import 'package:linkpad/data/datetime_parse.dart';
import 'package:linkpad/widgets/document_app_bar.dart';
import 'package:linkpad/widgets/document_drawer.dart';
import 'package:linkpad/widgets/hero_title.dart';

import '../data/data_model.dart';

class DocumentPage extends StatefulWidget {
  DocumentPage({
    super.key,
    required this.document,
    required this.parchment,
  });

  final Document document;
  final ParchmentDocument parchment;

  @override
  State<DocumentPage> createState() => _DocumentPageState();
}

class _DocumentPageState extends State<DocumentPage> {
  late TextEditingController titleController = TextEditingController(text: widget.document.title);

  late FleatherController editorController = FleatherController(
    document: widget.parchment,
  );

  final FocusNode editorFocusNode = FocusNode();

  // String readDoc(BuildContext context) {
  //   final DataController dataController = DataProvider.require(context);

  //   return dataController.loadDocumentFromDoc(widget.document);
  // }

  @override
  void initState() {
    // if (widget.document.title != 'Untitled') {
    //   titleController.text = widget.document.title;
    // }

    // final doc = readDoc(context);

    // if (doc.isEmpty) {
    //   editorController = FleatherController(
    //     document: ParchmentDocument(),
    //   );
    // } else {
    //   // If the document is in JSON format, parse it
    //   editorController = FleatherController(
    //     document: ParchmentDocument.fromJson(jsonDecode(doc)),
    //   );
    // }

    super.initState();
  }

  @override
  void dispose() {
    titleController.dispose();
    editorController.dispose();
    editorFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return FocusTraversalGroup(
      policy: ReadingOrderTraversalPolicy(),
      child: Scaffold(
        endDrawer: SizedBox(
          height: MediaQuery.sizeOf(context).height,
          width: MediaQuery.sizeOf(context).width * 0.8,
          child: DocumentDrawer(document: widget.document)),
        appBar: DocumentAppBar(titleController: titleController, focusNode: editorFocusNode, editorController: editorController, document: widget.document),
        backgroundColor: colorScheme.surfaceContainerHighest,
        body: Padding(
          padding: EdgeInsets.only(
            // bottom: MediaQuery.viewPaddingOf(context).bottom,
            left: 8.0,
            right: 8.0,
          ),
          child: Column(
            children: [
              HeroTitle(document: widget.document, focusNode: editorFocusNode, titleController: titleController),
              
              Expanded(
                child: FleatherEditor(
                  spellCheckConfiguration: SpellCheckConfiguration(
                    spellCheckService: DefaultSpellCheckService(),
                    misspelledTextStyle: TextStyle(
                      color: colorScheme.error,
                      decoration: TextDecoration.underline,
                      decorationColor: colorScheme.error,
                    ),
                  ),
                  padding: EdgeInsetsGeometry.all(12),
                  focusNode: editorFocusNode,
                  controller: editorController,
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: FleatherToolbar.basic(controller:editorController, hideHeadingStyle: true,))),
            ],
          ),
        ),
      ),
    );
  }
}
