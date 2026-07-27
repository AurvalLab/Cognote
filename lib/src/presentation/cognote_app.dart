import 'dart:async';

import 'package:flutter/material.dart';

import '../application/cognote_application.dart';
import 'observation_detail_page.dart';
import 'timeline_page.dart';

class CognoteApp extends StatefulWidget {
  const CognoteApp({
    required this.application,
    this.closeApplicationOnDispose = true,
    super.key,
  });

  final CognoteApplication application;
  final bool closeApplicationOnDispose;

  @override
  State<CognoteApp> createState() => _CognoteAppState();
}

class _CognoteAppState extends State<CognoteApp> {
  @override
  void dispose() {
    if (widget.closeApplicationOnDispose) {
      unawaited(widget.application.close());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    home: Builder(
      builder: (context) => TimelinePage(
        timeline: widget.application.watchTimeline(),
        onOpenObservation: (observationId) {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ObservationDetailPage(
                detail: widget.application.getObservationDetail(observationId),
                resolveLocalFile: widget.application.resolveLocalAsset,
              ),
            ),
          );
        },
      ),
    ),
  );
}
