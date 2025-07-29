import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:fleather/fleather.dart';
import 'package:flutter/material.dart';
import 'package:linkpad/data/data_controller.dart';
import 'package:linkpad/data/data_model.dart';
import 'package:linkpad/data/datetime_parse.dart';
import 'package:linkpad/widgets/document_page.dart';

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
      final String docContent = dataController.loadDocumentFromDoc(doc);
      final width =
          MediaQuery.sizeOf(context).width -
          (crossAxisCount * 8 + 24) / crossAxisCount;

      ParchmentDocument parchment;

      if (docContent.isEmpty) {
        parchment = ParchmentDocument();
      } else {
        parchment = ParchmentDocument.fromJson(jsonDecode(docContent));
      }

      if (displayType == DocumentDisplayType.Grid) {
        tiles.add(
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (context) => DocumentPage(
                    document: doc,
                    parchment: parchment,
                    dataController: dataController,
                  ),
                ),
              );
            },
            onLongPress: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Delete Document'),
                    content: Text(
                      'Are you sure you want to delete ${doc.title}?',
                    ),
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
                },
              );
            },
            borderRadius: BorderRadius.circular(8),
            child: GridTile(
              footer: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Flex(
                  direction: Axis.vertical,
                  // backgroundColor: colorScheme.primaryContainer,
                  children: [
                    AutoSizeText(
                      doc.title,
                      maxLines: 2,
                      maxFontSize:
                          TextTheme.of(context).titleLarge?.fontSize ?? 20,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    AutoSizeText(
                      dateTimeIntToReadableString(doc.lastModified),
                      textAlign: TextAlign.center,
                      softWrap: true,
                      maxLines: 2,
                      style: TextStyle(
                        color: colorScheme.onPrimaryContainer,
                        fontSize: TextTheme.of(context).labelSmall?.fontSize,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              child: Container(
                height: width * 2,
                width: width,
                foregroundDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primaryContainer.withAlpha(250),
                      colorScheme.primaryContainer.withAlpha(100),
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
                      color: colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 4,
                  ),
                ),
              ),
            ),
          ),
        );
      } else {
        tiles.add(
          ListTile(
            title: Text(doc.title),
            subtitle: Text(dateTimeIntToReadableString(doc.lastModified)),
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
                  builder: (context) => DocumentPage(
                    document: doc,
                    parchment: parchment,
                    dataController: dataController,
                  ),
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
                  child: Opacity(
                    opacity: 0.2,
                    child: Image.asset(
                      'assets/pages_holed.png',
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withAlpha(200),
                      fit: BoxFit.cover,
                      colorBlendMode: BlendMode.modulate,
                      width: MediaQuery.sizeOf(context).width,
                      height: MediaQuery.sizeOf(context).width,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    'No documents found.',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withAlpha(120),
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
