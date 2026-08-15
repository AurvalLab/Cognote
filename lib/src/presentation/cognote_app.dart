import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../application/cognote_application.dart';
import '../product_identity.dart';
import 'create_observation_page.dart';
import 'deleted_observations_page.dart';
import 'observation_image_picker.dart';
import 'observation_detail_page.dart';
import 'observation_search_page.dart';
import 'timeline_page.dart';

class CognoteApp extends StatefulWidget {
  const CognoteApp({
    required this.application,
    this.imagePicker = const AndroidObservationImagePicker(),
    this.closeApplicationOnDispose = true,
    super.key,
  });

  final CognoteApplication application;
  final ObservationImagePicker imagePicker;
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
    title: productDisplayName,
    home: Builder(
      builder: (context) => TimelinePage(
        timeline: widget.application.watchTimeline(),
        onOpenObservation: (observationId) {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ObservationDetailPage(
                detail: widget.application.getObservationDetail(observationId),
                resolveLocalFile: widget.application.resolveLocalAsset,
                onDelete: () =>
                    widget.application.deleteObservation(observationId),
              ),
            ),
          );
        },
        onOpenDeletedObservations: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => DeletedObservationsPage(
                observations: widget.application.watchDeletedTimeline(),
                onRestore: widget.application.restoreObservation,
              ),
            ),
          );
        },
        onOpenSearch: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ObservationSearchPage(
                watchSearch: widget.application.watchSearch,
                onOpenObservation: (observationId) {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ObservationDetailPage(
                        detail: widget.application.getObservationDetail(
                          observationId,
                        ),
                        resolveLocalFile: widget.application.resolveLocalAsset,
                        onDelete: () =>
                            widget.application.deleteObservation(observationId),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
        onCreateObservation: () {
          Navigator.of(context).push(
            MaterialPageRoute<String>(
              builder: (_) => CreateObservationPage(
                imagePicker: widget.imagePicker,
                onCreateText:
                    ({required rawText, required timezoneOffset}) async {
                      final command = widget.application.prepareTextObservation(
                        rawText: rawText,
                        timezoneOffset: timezoneOffset,
                      );
                      final observation = await widget.application
                          .createTextObservation(command);
                      return observation.id;
                    },
                onCreateImage:
                    ({
                      required image,
                      required caption,
                      required timezoneOffset,
                      required onPrepared,
                    }) async {
                      final command = await widget.application
                          .prepareImageObservationFromTemporaryFile(
                            file: File(image.path),
                            declaredMimeType: image.mimeType,
                            caption: caption,
                            timezoneOffset: timezoneOffset,
                          );
                      onPrepared();
                      final aggregate = await widget.application
                          .createPreparedImageObservation(command);
                      return aggregate.observation.id;
                    },
              ),
            ),
          );
        },
      ),
    ),
  );
}
