import 'dart:convert';

import 'package:fleather/fleather.dart' hide kToolbarHeight;
import 'package:flutter/material.dart';
import 'package:linkpad/data/data_controller.dart';
import 'package:linkpad/data/data_model.dart';
import 'package:linkpad/widgets/document_page.dart';
import 'package:linkpad/widgets/rotating_icon_button.dart';
import 'package:linkpad/widgets/toggle_icon_button.dart';

enum FilterType {
  all,
  titles,
  links,
}

class LinkpadAppbar extends StatelessWidget implements PreferredSizeWidget {
  LinkpadAppbar({
    super.key,
  });

  final SearchController titleController = SearchController();
  FilterType filterType = FilterType.all;

  List<ListTile> _buildSuggestions(BuildContext context, SearchController controller) {
    final dataController = DataProvider.require(context);
    final suggestions = dataController.searchItems(controller.text, filterType);

    return List<ListTile>.generate(
      suggestions.length,
      (index) {
        return ListTile(
          title: Text(
            suggestions[index].title,
            style: TextStyle(
              fontSize: TextTheme.of(context).titleMedium?.fontSize,
            )
          ),
          subtitle: Wrap(
            direction: Axis.horizontal,
            spacing: 4,
            runSpacing: 4,
            children: List<Chip>.generate(
              suggestions[index].links.length,
              (linkIndex) => Chip(
                label: Text(
                  suggestions[index].links[linkIndex],
                  style: TextStyle(
                    fontSize: TextTheme.of(context).labelSmall?.fontSize,
                  )
                ),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                labelStyle: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),
              ),
            ),
          ),
          onTap: () {
            titleController.clear();
            titleController.closeView(null);

            var docContent = dataController.loadDocumentFromDoc(suggestions[index]);
            ParchmentDocument parchment;

              if (docContent.isEmpty) {
                parchment = ParchmentDocument();
              } else {
                parchment = ParchmentDocument.fromJson(jsonDecode(docContent));
              }

            Navigator.of(context).push(
              MaterialPageRoute(
                fullscreenDialog: true,
                builder: (context) => DocumentPage(document: suggestions[index], parchment: parchment, dataController: dataController,),
              ),
            );
          },
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dataController = DataProvider.require(context);

    return AppBar(
      backgroundColor: colorScheme.surfaceContainerHighest,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.menu, color: colorScheme.onSurface, size: 28,),
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
      ),
      title: Hero(
        tag: 'textField',
        child: SearchAnchor.bar(
          barHintText: 'Linkpad',
          barHintStyle: WidgetStatePropertyAll(
            TextStyle(
              color: colorScheme.onSurface.withAlpha(150),
              fontStyle: FontStyle.italic,
              fontSize: TextTheme.of(context).titleLarge?.fontSize,
            ),
          ),
          viewTrailing: [
            StatefulBuilder(
              builder: (context, setState) {
                  IconData trailingIcon;
        
                  switch (filterType) {
                    case FilterType.all:
                      trailingIcon = Icons.article;
                      break;
                    case FilterType.titles:
                      trailingIcon = Icons.title;
                      break;
                    case FilterType.links:
                      trailingIcon = Icons.link;
                      break;
                  }
                
                return RotatingIconButton(icon: trailingIcon, onPressed: () {
                  // Toggle filter type
                  if (filterType == FilterType.titles) {
                    setState(() {
                      filterType = FilterType.links;
                    });
                  } else if (filterType == FilterType.links) {
                    setState(() {
                    filterType = FilterType.all;
                    });
                  } else {
                    setState(() {
                    filterType = FilterType.links;
                    });
                  }
                });
              }
            ),
          ],
          barElevation: WidgetStatePropertyAll(0),
          shrinkWrap: true,
          searchController: titleController,
          onSubmitted: (value) {
            if (titleController.isOpen) {
              titleController.clear();
              titleController.closeView(value);
            }
          },
          suggestionsBuilder: _buildSuggestions,
        ),
      ),
      actions: [
        ToggleIconButton(
          icon: Icons.list, 
          selectedIcon: Icons.grid_on,
          selected: dataController.displayType == DocumentDisplayType.grid,
          onPressed: () {
          if (dataController.displayType == DocumentDisplayType.grid) {
            dataController.updateDisplayType(DocumentDisplayType.list);
          } else {
            dataController.updateDisplayType(DocumentDisplayType.grid);
          }
        }),
      ],
    );
  }
  
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
