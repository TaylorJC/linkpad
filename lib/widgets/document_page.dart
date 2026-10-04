import 'dart:async';

import 'package:fleather/fleather.dart' hide kToolbarHeight;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:linkpad/data/data_controller.dart';
import 'package:linkpad/widgets/document_app_bar.dart';
import 'package:linkpad/widgets/document_drawer.dart';
import 'package:linkpad/widgets/document_toolbar.dart';
import 'package:linkpad/widgets/hero_title.dart';

import '../data/data_model.dart';

class DocumentPage extends StatefulWidget {
  const DocumentPage({
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
  late TextEditingController titleController = TextEditingController(
    text: widget.document.title,
  );

  late FleatherController editorController = FleatherController(
    document: widget.parchment,
  );

  final FocusNode editorFocusNode = FocusNode();

  final ScrollController scrollController = ScrollController();

  late Timer timer;
  Future<void>? _saveInProgress;
  bool _isHandlingPop = false;
  bool _allowPop = false;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(widget.dataController.autosaveIncrement, (
      timer,
    ) async {
      try {
        await _saveDocument();
      } catch (error, stackTrace) {
        _reportSaveFailure(error, stackTrace);
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
    titleController.dispose();
    editorController.dispose();
    editorFocusNode.dispose();
    scrollController.dispose();

    super.dispose();
  }

  Future<void> _saveDocument() {
    final inProgress = _saveInProgress;
    if (inProgress != null) return inProgress;

    late final Future<void> save;
    save = widget.document
        .saveDocument(titleController, editorController, widget.dataController)
        .then<void>((_) {})
        .whenComplete(() {
          if (identical(_saveInProgress, save)) {
            _saveInProgress = null;
          }
        });
    _saveInProgress = save;
    return save;
  }

  Future<void> _saveBeforePop() async {
    if (_isHandlingPop) return;
    _isHandlingPop = true;

    try {
      final inProgress = _saveInProgress;
      if (inProgress != null) await inProgress;

      if (titleController.text.trim().isEmpty &&
          editorController.plainTextEditingValue.text.trim().isEmpty) {
        await widget.dataController.removeItem(widget.document);
      } else {
        await _saveDocument();
      }

      if (mounted) {
        setState(() => _allowPop = true);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) Navigator.of(context).pop();
        });
      }
    } catch (error, stackTrace) {
      _reportSaveFailure(error, stackTrace);
    } finally {
      _isHandlingPop = false;
    }
  }

  void _reportSaveFailure(Object error, StackTrace stackTrace) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'linkpad',
        context: ErrorDescription(
          'while saving a document before leaving its page',
        ),
      ),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save document. Please try again.'),
        ),
      );
    }
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

    return PopScope<void>(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _saveBeforePop();
      },
      child: FocusTraversalGroup(
        policy: ReadingOrderTraversalPolicy(),
        child: Scaffold(
          endDrawer: SizedBox(
            height: MediaQuery.sizeOf(context).height,
            width: MediaQuery.sizeOf(context).width * 0.8,
            child: DocumentDrawer(document: widget.document),
          ),
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
                HeroTitle(
                  document: widget.document,
                  focusNode: editorFocusNode,
                  titleController: titleController,
                ),
                Expanded(
                  child: FleatherEditor(
                    autofocus: widget.document.title != '',
                    contextMenuBuilder: (context, editorState) {
                      final List<ContextMenuButtonItem> buttonItems =
                          editorState.contextMenuButtonItems;

                      buttonItems.addAll([
                        ContextMenuButtonItem(
                          onPressed: () {
                            toggleAttribute(ParchmentAttribute.bold);
                            editorState.hideToolbar();
                          },
                          label: 'Bold',
                        ),
                        ContextMenuButtonItem(
                          onPressed: () {
                            toggleAttribute(ParchmentAttribute.italic);
                            editorState.hideToolbar();
                          },
                          label: 'Italicize',
                        ),
                        ContextMenuButtonItem(
                          onPressed: () {
                            toggleAttribute(ParchmentAttribute.underline);
                            editorState.hideToolbar();
                          },
                          label: 'Underline',
                        ),
                        ContextMenuButtonItem(
                          onPressed: () {
                            toggleAttribute(ParchmentAttribute.strikethrough);
                            editorState.hideToolbar();
                          },
                          label: 'Strike-through',
                        ),
                        ContextMenuButtonItem(
                          onPressed: () {
                            toggleAttribute(ParchmentAttribute.inlineCode);
                            editorState.hideToolbar();
                          },
                          label: 'Inline-Code',
                        ),
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
                ).animate(effects: [SlideEffect(begin: Offset(0, 1))]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
