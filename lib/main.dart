import 'package:flutter/material.dart';

import 'data/data_controller.dart';
import 'widgets/linkpad.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final DataController dataController = DataController();
  await dataController.init();

  runApp(LinkPad(dataController: dataController));
}
