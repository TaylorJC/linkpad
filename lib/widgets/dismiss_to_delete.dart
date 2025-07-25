import 'package:flutter/material.dart';

class DismissToDelete extends StatelessWidget {
  const DismissToDelete({
    super.key,
    required this.child,
    required this.onDelete,
  });

  final Widget child;
  final Function() onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.startToEnd,
      background: Container(
        padding: const EdgeInsets.only(left: 16),
        width: MediaQuery.sizeOf(context).width,
        color: colorScheme.errorContainer,
        child: Align(
          alignment: Alignment.centerLeft, 
          child: Icon(Icons.delete_forever, color: colorScheme.onErrorContainer,),
        ),
      ),
      onDismissed: (direction) {
        onDelete();
      },
      child: child,
    );
  }
}
