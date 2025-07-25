import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:fleather/fleather.dart';
import 'package:flutter/material.dart';
import 'package:linkpad/data/data_controller.dart';
import 'package:linkpad/data/data_model.dart';
import 'package:linkpad/data/datetime_parse.dart';
import 'package:linkpad/widgets/document_page.dart';

enum DocumentDisplayType {
  List,
  Grid,
}

class DocumentDisplay extends StatelessWidget {
  const DocumentDisplay({
    super.key,
    required this.displayType,
    required this.crossAxisCount,
  });

  final DocumentDisplayType displayType;
  final int crossAxisCount;

  List<Widget> getDocTiles(List<Document> docs, BuildContext context) {
    List<Widget> tiles = List.empty(growable: true);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final DataController dataController = DataProvider.require(context);

    docs.sort((a, b) => b.lastModified.compareTo(a.lastModified));

    for (var doc in docs) {
      var docContent = dataController.loadDocumentFromDoc(doc);
      ParchmentDocument parchment;

      if (docContent.isEmpty) {
        parchment = ParchmentDocument();
      } else {
        parchment = ParchmentDocument.fromJson(jsonDecode(docContent));
      }

      if (displayType == DocumentDisplayType.Grid) {
        final width = MediaQuery.sizeOf(context).width - (crossAxisCount * 8 + 24) / crossAxisCount;

        tiles.add(
          InkWell(
            onTap: () {
              var docContent = dataController.loadDocumentFromDoc(doc);
              ParchmentDocument parchment;

              if (docContent.isEmpty) {
                parchment = ParchmentDocument();
              } else {
                parchment = ParchmentDocument.fromJson(jsonDecode(docContent));
              }

              Navigator.of(context).push(
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (context) => DocumentPage(document: doc, parchment: parchment),
                ),
              );
            },
            onLongPress: () {
              showDialog(context: context, builder: (context) {
                return AlertDialog(
                  title: Text('Delete Document'),
                  content: Text('Are you sure you want to delete ${doc.title}?'),
                  actions: [
                    TextButton(
                      onPressed: () async {
                        await dataController.removeItem(doc);
                        Navigator.of(context).pop();
                      },
                      child: Text('Delete'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Cancel'),
                    ),
                  ],
                );
              });
            },
            borderRadius: BorderRadius.circular(8),
            child: GridTile(
              footer: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Flex(
                  direction: Axis.vertical,
                  // backgroundColor: colorScheme.primaryContainer,
                  children: [AutoSizeText(doc.title, 
                  maxLines: 2,
                  maxFontSize: TextTheme.of(context).titleLarge?.fontSize ?? 20,
                  textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  AutoSizeText(dateTimeIntToReadableString(doc.lastModified), 
                  textAlign: TextAlign.center,
                  softWrap: true,
                  maxLines: 2,
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer, 
                      fontSize: TextTheme.of(context).labelSmall?.fontSize, 
                      fontWeight: FontWeight.w400,
                    ),
                  ),],
                ),
              ),
              child: Container(
                height: width * 2,
                width: width,
                foregroundDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primaryContainer.withAlpha(150),
                      colorScheme.primaryContainer.withAlpha(0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    parchment.toPlainText(),
                    style: TextStyle(
                      fontSize: TextTheme.of(context).bodySmall?.fontSize,
                      color: colorScheme.onSurface.withAlpha(150),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                  ),
                ),
              ),
            ),
          )
        );
      } else {
        tiles.add(
          ListTile(
            title: Text(doc.title),
            onTap: () {
              var docContent = dataController.loadDocumentFromDoc(doc);
              ParchmentDocument parchment;

              if (docContent.isEmpty) {
                parchment = ParchmentDocument();
              } else {
                parchment = ParchmentDocument.fromJson(jsonDecode(docContent));
              }

              Navigator.of(context).push(
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (context) => DocumentPage(document: doc, parchment: parchment),
                ),
              );
            },
          ),
        );
      }
    }

    return tiles;
  } 

  @override
  Widget build(BuildContext context) {
    final DataController dataController = DataProvider.require(context);

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: dataController.items.isEmpty
          ? Stack(
            children: [
              Center(
                child: Image.asset('assets/pages.png',
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(20),
                  fit: BoxFit.cover,
                  width: 400,
                  height: 400,
                ),
              ),
              Center(
                child: Text(
                  'No documents found.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
                    fontSize: TextTheme.of(context).titleLarge?.fontSize,
                  ),
                ),
              ),
            ],
          )
          : (displayType == DocumentDisplayType.List
              ? ListView.builder(
                  itemCount: dataController.items.length,
                  itemBuilder: (context, index) {
                    return getDocTiles(dataController.items, context)[index];
                  },
                )
              : GridView.count(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  children: getDocTiles(dataController.items, context),
                )),
    );
  }
}