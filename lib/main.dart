import 'package:flutter/widgets.dart';

import 'src/application/cognote_application.dart';
import 'src/presentation/cognote_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final application = await CognoteApplication.bootstrap();

  runApp(CognoteApp(application: application));
}
