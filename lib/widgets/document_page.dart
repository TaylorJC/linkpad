import 'dart:async';

import 'package:fleather/fleather.dart' hide kToolbarHeight;
import 'package:flutter/material.dart';
import 'package:linkpad/data/data_controller.dart';
import 'package:linkpad/widgets/document_app_bar.dart';
import 'package:linkpad/widgets/document_drawer.dart';
import 'package:linkpad/widgets/document_toolbar.dart';
import 'package:linkpad/widgets/hero_title.dart';

import '../data/data_model.dart';

class DocumentPage extends StatefulWidget {
  DocumentPage({
    super.key,
    required this.document,
    required this.parchment,
    required this.dataController,
  });

  final Document document;
  final ParchmentDocument parchment;
  final DataController dataController;

  @override
  State<DocumentPage> createState() => _DocumentPageState();
}

class _DocumentPageState extends State<DocumentPage> {
  late TextEditingController titleController = TextEditingController(text: widget.document.title);

  late FleatherController editorController = FleatherController(
    document: widget.parchment,
  );

  final FocusNode editorFocusNode = FocusNode();

  final ScrollController scrollController = ScrollController();

  late Timer timer;

  @override
  void initState() {
    super.initState();
    
    timer = Timer.periodic(widget.dataController.autosaveIncrement, (timer) {
      widget.document.saveDocument(titleController, editorController, widget.dataController);
      print('Autosaved');

      }
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    editorController.dispose();
    editorFocusNode.dispose();
    scrollController.dispose();
    timer.cancel();


    super.dispose();
  }

  void toggleAttribute(ParchmentAttribute attr) {
    if (editorController.getSelectionStyle().containsSame(attr)) {
      editorController.formatSelection(attr.unset);
    } else {
      editorController.formatSelection(attr);
    }
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final DataController dataController = DataProvider.require(context);

    // timer = Timer.periodic(dataController.autosaveIncrement, (timer) {
    //   widget.document.saveDocument(titleController, editorController, dataController);
    //   print('Autosaved');

    //   // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Autosaved'),));
    // });

    return FocusTraversalGroup(
      policy: ReadingOrderTraversalPolicy(),
      child: Scaffold(
        endDrawer: SizedBox(
          height: MediaQuery.sizeOf(context).height,
          width: MediaQuery.sizeOf(context).width * 0.8,
          child: DocumentDrawer(document: widget.document)),
        appBar: DocumentAppBar(
          titleController: titleController, 
          focusNode: editorFocusNode, 
          editorController: editorController, 
          document: widget.document,
          dataController: dataController,
        ),
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
                  autofocus: widget.document.title != '',
                  contextMenuBuilder: (context, editorState) {
                    final List<ContextMenuButtonItem> buttonItems =
                      editorState.contextMenuButtonItems;
                    
                    buttonItems.addAll([
                      ContextMenuButtonItem(onPressed: () { toggleAttribute(ParchmentAttribute.bold); editorState.hideToolbar(); }, label: 'Bold'),
                      ContextMenuButtonItem(onPressed: () { toggleAttribute(ParchmentAttribute.italic); editorState.hideToolbar(); }, label: 'Italicize'),
                      ContextMenuButtonItem(onPressed: () { toggleAttribute(ParchmentAttribute.underline); editorState.hideToolbar(); }, label: 'Underline'),
                      ContextMenuButtonItem(onPressed: () { toggleAttribute(ParchmentAttribute.strikethrough); editorState.hideToolbar(); }, label: 'Strike-through'),
                      ContextMenuButtonItem(onPressed: () { toggleAttribute(ParchmentAttribute.inlineCode); editorState.hideToolbar(); }, label: 'Inline-Code'),
                    ]);

                    return AdaptiveTextSelectionToolbar.buttonItems(
                      anchors: editorState.contextMenuAnchors,
                      buttonItems: buttonItems,
                    );
                  },
                  padding: EdgeInsetsGeometry.all(12),
                  focusNode: editorFocusNode,
                  controller: editorController,
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: DocumentToolbar(fleatherController: editorController),
                // child: Scrollbar(
                //   controller: scrollController,
                //   thumbVisibility: true,
                //   child: SingleChildScrollView(
                //     scrollDirection: Axis.horizontal,
                //     controller: scrollController,
                //     child: FleatherToolbar.basic(controller:editorController, hideHeadingStyle: true,)),
                // )
              ),
            ],
          ),
        ),
      ),
    );
  }
}
