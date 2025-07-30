import 'dart:convert';

import 'package:fleather/fleather.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:linkpad/data/data_controller.dart';
import 'package:linkpad/data/datetime_parse.dart';
import 'package:linkpad/widgets/document_page.dart';

import '../data/data_model.dart';

class DocumentDrawer extends StatelessWidget {
  DocumentDrawer({
    super.key,
    required this.document,
  });

  final Document document;
  final TextEditingController linkController = TextEditingController();
  final SearchController searchAnchorController = SearchController();

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
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              // topRight: Radius.circular(16),
              // bottomRight: Radius.circular(16),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.viewPaddingOf(context).top + 16.0, 
            bottom: MediaQuery.viewPaddingOf(context).bottom + 8,
            left: 16.0,
            right: 16.0,),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16,
              children: [
                SearchAnchor.bar(
                  searchController: searchAnchorController,
                  isFullScreen: false,
                  textCapitalization: TextCapitalization.words,
                  barHintText: 'Add a link',
                  // decoration: InputDecoration(
                  //   hintText: 'Add a link',
                  //   border: OutlineInputBorder(
                  //     borderRadius: BorderRadius.circular(8),
                  //   ),
                  // ),
                  onSubmitted: (value) {
                    if (value.isNotEmpty && !document.links.contains(value)) {
                      document.links.add(value.trim());
                      dataController.updateItem(document);
                      searchAnchorController.clear();
                    }
                  },
                  suggestionsBuilder: (context, controller) {
                    final query = controller.text.toLowerCase();
                    final suggestions = dataController.links.where((link) => link.toLowerCase().contains(query)).toList();
                    return List<ListTile>.generate(
                      suggestions.length,
                      (index) => ListTile(
                        leading: document.links.contains(suggestions[index])
                            ? Icon(Icons.check, color: colorScheme.primary)
                            : null,
                        title: Text(suggestions[index]),
                        
                        onTap: () {
                          controller.text = suggestions[index];
                          if (controller.text.isNotEmpty && !document.links.contains(controller.text.trim())) {
                            document.links.add(controller.text.trim());
                            dataController.updateItem(document);
                          } else if (document.links.contains(controller.text.trim())) {
                            document.links.remove(controller.text.trim());
                            dataController.updateItem(document);
                          }
            
                          controller.clear();
                        },
                      ),
                    );
                  },
                ),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: AnimateList(
                    interval: Durations.short4,
                    effects: [
                      FadeEffect(),
                      SlideEffect(
                        begin: Offset(1, 0),
                      )
                    ],
                    children: document.links.map((link) {
                    return Card(
                      color: colorScheme.surfaceContainerHigh,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          isThreeLine: false,
                          dense: true,
                          visualDensity: VisualDensity.compact,
                          title: Text(link, 
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize)),
                          subtitle: Column(children:
                            dataController.items.where((element) => element.links.contains(link) && element.id != document.id,).map((doc) {
                              return InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => DocumentPage(document: doc, parchment: ParchmentDocument.fromJson(jsonDecode(dataController.loadDocumentFromDoc(doc))), dataController: dataController,),
                                      ),
                                    );
                                    Scaffold.of(context).closeEndDrawer();
                                  },
                                child: ListTile(
                                  minVerticalPadding: 0,
                                  // contentPadding: EdgeInsets.zero,
                                  isThreeLine: false,
                                  dense: true,
                                  visualDensity: VisualDensity.compact,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  leading: Icon(Icons.link, color: colorScheme.primary),
                                  title: Text(doc.title, 
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: colorScheme.onSurface,
                                      fontSize: Theme.of(context).textTheme.labelMedium?.fontSize)
                                  ),
                                  trailing: Text(dateTimeIntToReadableString(doc.lastModified),
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      color: colorScheme.onSurface,
                                      fontSize: Theme.of(context).textTheme.labelSmall?.fontSize,
                                    )
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  ),
                ),
              ]
            ),
          ),
        ),
      ],
    );
  }
}