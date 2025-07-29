import 'package:fleather/fleather.dart';
import 'package:flutter/material.dart';

class DocumentToolbar extends StatelessWidget {
  DocumentToolbar({super.key, required this.fleatherController});

  final FleatherController fleatherController;
  final ScrollController _scrollController = ScrollController();

  void toggleAttribute(ParchmentAttribute attr) {
    if (fleatherController.getSelectionStyle().containsSame(attr)) {
      fleatherController.formatSelection(attr.unset);
    } else {
      fleatherController.formatSelection(attr);
    }
  }

  @override
  Widget build(BuildContext context) {
    // final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scrollbar(
      controller: _scrollController,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewPaddingOf(context).bottom + 4,
        ),
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        child: Row(
          spacing: 2,
          children: [
            SquareIconButton(
              icon: Icons.format_bold_outlined,
              onPressed: () => toggleAttribute(ParchmentAttribute.bold)
            ),
            SquareIconButton(
              icon: Icons.format_italic_outlined,
              onPressed: () => toggleAttribute(ParchmentAttribute.italic)
            ),
            SquareIconButton(
              icon: Icons.format_underline_outlined,
              onPressed: () => toggleAttribute(ParchmentAttribute.underline)
            ),
            SquareIconButton(
              icon: Icons.format_strikethrough_outlined,
              onPressed: () => toggleAttribute(ParchmentAttribute.strikethrough)
            ),
            VerticalDivider(),
            // PopupMenuButton(
            //   shape: RoundedRectangleBorder(
            //     borderRadius: BorderRadiusGeometry.circular(8),
            //   ),
            //   icon: Icon(Icons.text_format_outlined),
            //   tooltip: 'Font Style',
            //   borderRadius: BorderRadius.circular(8),
            //   constraints: BoxConstraints(maxWidth: 50),
            //   itemBuilder: (context) {
            //     return List<PopupMenuItem>.from([
            //       PopupMenuItem(
            //         child: Align(
            //           alignment: Alignment.center,
            //           child: Icon(Icons.format_bold_outlined),
            //         ),
            //         onTap: () => toggleAttribute(ParchmentAttribute.bold),
            //       ),
            //       PopupMenuItem(
            //         child: Align(
            //           alignment: Alignment.center,
            //           child: Icon(Icons.format_italic_outlined),
            //         ),
            //         onTap: () => toggleAttribute(ParchmentAttribute.italic),
            //       ),
            //       PopupMenuItem(
            //         child: Align(
            //           alignment: Alignment.center,
            //           child: Icon(Icons.format_underline_outlined),
            //         ),
            //         onTap: () => toggleAttribute(ParchmentAttribute.underline),
            //       ),
            //       PopupMenuItem(
            //         child: Align(
            //           alignment: Alignment.center,
            //           child: Icon(Icons.format_strikethrough_outlined),
            //         ),
            //         onTap: () =>
            //             toggleAttribute(ParchmentAttribute.strikethrough),
            //       ),
            //     ]);
            //   },
            // ),
            // VerticalDivider(),
            // SquareIconButton(
            //   icon: Icons.check_box,
            //   onPressed: () => toggleAttribute(ParchmentAttribute.cl)
            // ),
            // SquareIconButton(
            //   icon: Icons.format_list_numbered,
            //   onPressed: () => toggleAttribute(ParchmentAttribute.ol)
            // ),
            // SquareIconButton(
            //   icon: Icons.format_list_bulleted,
            //   onPressed: () => toggleAttribute(ParchmentAttribute.ul)
            // ),
            PopupMenuButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(8),
              ),
              icon: Icon(Icons.format_list_numbered_outlined),
              tooltip: 'List',
              constraints: BoxConstraints(maxWidth: 50),
              popUpAnimationStyle: AnimationStyle(
                curve: Curves.easeIn,
                duration: Durations.short3,
              ),
              itemBuilder: (context) {
                return List<PopupMenuItem>.from([
                  PopupMenuItem(
                    child: Align(
                      alignment: Alignment.center,
                      child: Icon(Icons.check_box_outlined),
                    ),
                    onTap: () => toggleAttribute(ParchmentAttribute.cl),
                  ),
                  PopupMenuItem(
                    child: Align(
                      alignment: Alignment.center,
                      child: Icon(Icons.format_list_numbered_outlined),
                    ),
                    onTap: () => toggleAttribute(ParchmentAttribute.ol),
                  ),
                  PopupMenuItem(
                    child: Align(
                      alignment: Alignment.center,
                      child: Icon(Icons.format_list_bulleted_outlined),
                    ),
                    onTap: () => toggleAttribute(ParchmentAttribute.ul),
                  ),
                ]);
              },
            ),
            PopupMenuButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(8),
              ),
              borderRadius: BorderRadius.circular(8),
              icon: Icon(Icons.format_align_center),
              tooltip: 'Alignment',
              constraints: BoxConstraints(maxWidth: 50),
              itemBuilder: (context) {
                return List<PopupMenuItem>.from([
                  PopupMenuItem(
                    child: Align(
                      alignment: Alignment.center,
                      child: Icon(Icons.format_align_left_outlined),
                    ),
                    onTap: () =>
                        toggleAttribute(ParchmentAttribute.alignment.unset),
                  ),
                  PopupMenuItem(
                    child: Align(
                      alignment: Alignment.center,
                      child: Icon(Icons.format_align_center_outlined),
                    ),
                    onTap: () =>
                        toggleAttribute(ParchmentAttribute.alignment.center),
                  ),
                  PopupMenuItem(
                    child: Align(
                      alignment: Alignment.center,
                      child: Icon(Icons.format_align_right_outlined),
                    ),
                    onTap: () =>
                        toggleAttribute(ParchmentAttribute.alignment.right),
                  ),
                ]);
              },
            ),
            // SquareIconButton(
            //   icon: Icons.format_align_left_outlined,
            //   onPressed: () => toggleAttribute(ParchmentAttribute.alignment.unset)
            //   ),
            // SquareIconButton(
            //   icon: Icons.format_align_center_outlined,
            //   onPressed: () => toggleAttribute(ParchmentAttribute.alignment.center)
            // ),
            // SquareIconButton(
            //   icon: Icons.format_align_right_outlined,
            //   onPressed: () => toggleAttribute(ParchmentAttribute.alignment.right)
            // ),
            VerticalDivider(),
            SquareIconButton(
              icon: Icons.code,
              onPressed: () => toggleAttribute(ParchmentAttribute.code),
            ),
            SquareIconButton(
              icon: Icons.format_quote_outlined,
              onPressed: () => toggleAttribute(ParchmentAttribute.bq),
            ),
          ],
        ),
      ),
    );
  }
}

class SquareIconButton extends StatelessWidget {
  const SquareIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      style: IconButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(8),
        ),
      ),
      onPressed: () => onPressed(),
    );
  }
}
