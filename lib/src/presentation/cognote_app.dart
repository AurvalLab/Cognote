import 'dart:async';

import 'package:flutter/widgets.dart';

import '../application/cognote_application.dart';

class CognoteApp extends StatefulWidget {
  const CognoteApp({required this.application, super.key});

  final CognoteApplication application;

  @override
  State<CognoteApp> createState() => _CognoteAppState();
}

class _CognoteAppState extends State<CognoteApp> {
  @override
  void dispose() {
    unawaited(widget.application.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
