import 'dart:convert';

import 'package:fleather/fleather.dart' hide kToolbarHeight;
import 'package:flutter/material.dart';
import 'package:linkpad/data/data_controller.dart';
import 'package:linkpad/widgets/document_page.dart';
import 'package:linkpad/widgets/rotating_icon_button.dart';

enum FilterType {
  All,
  Titles,
  Links,
}

class LinkpadAppbar extends StatelessWidget implements PreferredSizeWidget {
  LinkpadAppbar({
    super.key,
  });

  final SearchController titleController = SearchController();
  FilterType filterType = FilterType.Links;

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
                builder: (context) => DocumentPage(document: suggestions[index], parchment: parchment,),
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
    // final dataController = DataProvider.require(context);

    return AppBar(
      backgroundColor: colorScheme.surfaceContainerHighest,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.menu, color: colorScheme.onSurface,),
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
      ),
      title: SearchAnchor.bar(
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
                  case FilterType.All:
                    trailingIcon = Icons.article;
                    break;
                  case FilterType.Titles:
                    trailingIcon = Icons.title;
                    break;
                  case FilterType.Links:
                    trailingIcon = Icons.link;
                    break;
                }
              
              return RotatingIconButton(icon: trailingIcon, onPressed: () {
                // Toggle filter type
                if (filterType == FilterType.Titles) {
                  setState(() {
                    filterType = FilterType.Links;
                  });
                } else if (filterType == FilterType.Links) {
                  setState(() {
                  filterType = FilterType.All;
                  });
                } else {
                  setState(() {
                  filterType = FilterType.Titles;
                  });
                }
              });
            }
          ),
        ],
        barElevation: WidgetStatePropertyAll(0),
        shrinkWrap: true,
        searchController: titleController,
        // onTap: () {
        //   titleController.openView();
        // },
        onSubmitted: (value) {
          if (titleController.isOpen) {
            titleController.clear();
            titleController.closeView(value);
          }
        },
        suggestionsBuilder: _buildSuggestions,
      )
    );
  }
  
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
