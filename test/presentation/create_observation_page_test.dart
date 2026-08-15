import 'dart:async';

import 'package:cognote/src/observation/domain/image_observation_exceptions.dart';
import 'package:cognote/src/presentation/create_observation_page.dart';
import 'package:cognote/src/presentation/observation_image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('rejects blank text without calling the application', (
    tester,
  ) async {
    var createCalls = 0;
    await _pumpPage(
      tester,
      onCreateText: ({required rawText, required timezoneOffset}) async {
        createCalls++;
        return 'text-id';
      },
    );

    await tester.enterText(find.byKey(const Key('create_text_input')), '   ');
    await tester.tap(find.byKey(const Key('save_observation')));
    await tester.pump();

    expect(find.text('请先写下一些内容'), findsOneWidget);
    expect(createCalls, 0);
  });

  testWidgets('creates text once and returns to the timeline host', (
    tester,
  ) async {
    final pending = Completer<String>();
    var createCalls = 0;
    await _pumpPage(
      tester,
      onCreateText: ({required rawText, required timezoneOffset}) {
        expect(rawText, '今天看见一朵云');
        expect(timezoneOffset, inInclusiveRange(-840, 840));
        createCalls++;
        return pending.future;
      },
    );

    await tester.enterText(
      find.byKey(const Key('create_text_input')),
      '今天看见一朵云',
    );
    await tester.tap(find.byKey(const Key('save_observation')));
    await tester.pump();
    await tester.tap(
      find.byKey(const Key('save_observation')),
      warnIfMissed: false,
    );
    await tester.pump();

    expect(createCalls, 1);
    expect(find.text('正在保存文字'), findsOneWidget);
    pending.complete('text-id');
    await tester.pumpAndSettle();
    expect(find.text('result:text-id'), findsOneWidget);
  });

  testWidgets('image cancellation keeps the page editable', (tester) async {
    await _pumpPage(tester, picker: const _FakePicker(null));
    await _switchToImage(tester);

    await tester.tap(find.byKey(const Key('pick_observation_image')));
    await tester.pumpAndSettle();

    expect(find.text('选择一张图片'), findsOneWidget);
    expect(find.byKey(const Key('create_observation_status')), findsNothing);
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('save_observation')))
          .onPressed,
      isNotNull,
    );
  });

  testWidgets('creates a selected image and reports prepare/save phases', (
    tester,
  ) async {
    final pending = Completer<String>();
    var createCalls = 0;
    await _pumpPage(
      tester,
      picker: const _FakePicker(
        PickedObservationImage(
          path: '/cache/flower.png',
          mimeType: 'image/png',
          displayName: 'flower.png',
        ),
      ),
      onCreateImage:
          ({
            required image,
            required caption,
            required timezoneOffset,
            required onPrepared,
          }) {
            createCalls++;
            expect(image.path, '/cache/flower.png');
            expect(caption, '路边的小花');
            onPrepared();
            return pending.future;
          },
    );
    await _switchToImage(tester);
    await tester.tap(find.byKey(const Key('pick_observation_image')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('create_image_caption')),
      '路边的小花',
    );

    await tester.tap(find.byKey(const Key('save_observation')));
    await tester.pump();

    expect(createCalls, 1);
    expect(find.text('正在保存图片'), findsOneWidget);
    pending.complete('image-id');
    await tester.pumpAndSettle();
    expect(find.text('result:image-id'), findsOneWidget);
  });

  testWidgets('discards an unsubmitted image when leaving the page', (
    tester,
  ) async {
    final picker = _TrackingPicker(
      const PickedObservationImage(
        path: '/cache/unused.png',
        mimeType: 'image/png',
        displayName: 'unused.png',
      ),
    );
    await _pumpPage(tester, picker: picker);
    await _switchToImage(tester);
    await tester.tap(find.byKey(const Key('pick_observation_image')));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(picker.discardedPaths, ['/cache/unused.png']);
  });

  testWidgets('discards a delayed picker result after route disposal', (
    tester,
  ) async {
    final pending = Completer<PickedObservationImage?>();
    final picker = _DelayedPicker(pending.future);
    await _pumpPage(tester, picker: picker);
    await _switchToImage(tester);

    await tester.tap(find.byKey(const Key('pick_observation_image')));
    await tester.pump();
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    pending.complete(
      const PickedObservationImage(
        path: '/cache/delayed.png',
        mimeType: 'image/png',
        displayName: 'delayed.png',
      ),
    );
    await tester.pump();

    expect(picker.discardedPaths, ['/cache/delayed.png']);
  });

  testWidgets(
    'replacement cleanup does not leak or delete either image twice',
    (tester) async {
      final discardPending = Completer<void>();
      final picker = _ReplacementPicker(discardPending);
      await _pumpPage(tester, picker: picker);
      await _switchToImage(tester);
      await tester.tap(find.byKey(const Key('pick_observation_image')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('pick_observation_image')));
      await tester.pump();
      expect(picker.discardedPaths, ['/cache/first.png']);
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      discardPending.complete();
      await tester.pump();

      expect(picker.discardedPaths, ['/cache/first.png', '/cache/second.png']);
    },
  );

  for (final mode in ['text', 'image']) {
    testWidgets('blocks back navigation while $mode save is in flight', (
      tester,
    ) async {
      final pending = Completer<String>();
      final picker = _TrackingPicker(
        const PickedObservationImage(
          path: '/cache/in-flight.png',
          mimeType: 'image/png',
          displayName: 'in-flight.png',
        ),
      );
      await _pumpPage(
        tester,
        picker: picker,
        onCreateText: ({required rawText, required timezoneOffset}) =>
            pending.future,
        onCreateImage:
            ({
              required image,
              required caption,
              required timezoneOffset,
              required onPrepared,
            }) => pending.future,
      );
      if (mode == 'image') {
        await _switchToImage(tester);
        await tester.tap(find.byKey(const Key('pick_observation_image')));
        await tester.pumpAndSettle();
      } else {
        await tester.enterText(
          find.byKey(const Key('create_text_input')),
          'in flight',
        );
      }

      await tester.tap(find.byKey(const Key('save_observation')));
      await tester.pump();
      await tester.tap(find.byType(BackButton));
      await tester.pump();

      expect(find.text('记录此刻'), findsOneWidget);
      expect(picker.discardedPaths, isEmpty);
      pending.complete('$mode-id');
      await tester.pumpAndSettle();
      expect(find.text('result:$mode-id'), findsOneWidget);
    });
  }

  for (final entry in <(String, String)>[
    ('unavailable', '系统图片选择器不可用，请稍后重试'),
    ('busy', '图片选择器正在使用，请稍后重试'),
    ('unsupported', '请选择有效的 JPEG、PNG 或静态 WebP 图片'),
    ('storage', '本地存储失败，请检查设备空间后重试'),
    ('unreadable', '无法读取所选图片，请重新选择'),
    ('invalid_result', '无法读取所选图片，请重新选择'),
    ('too_large', '图片不能超过 25 MiB'),
  ]) {
    testWidgets('maps picker ${entry.$1} to actionable guidance', (
      tester,
    ) async {
      await _pumpPage(
        tester,
        picker: _ThrowingPicker(ObservationImagePickerException(entry.$1)),
      );
      await _switchToImage(tester);
      await tester.tap(find.byKey(const Key('pick_observation_image')));
      await tester.pumpAndSettle();

      expect(find.text(entry.$2), findsOneWidget);
    });
  }

  testWidgets('shows picker, image validation, and persistence failures', (
    tester,
  ) async {
    await _pumpPage(
      tester,
      picker: const _ThrowingPicker(
        ObservationImagePickerException('unreadable'),
      ),
    );
    await _switchToImage(tester);
    await tester.tap(find.byKey(const Key('pick_observation_image')));
    await tester.pumpAndSettle();
    expect(find.text('无法读取所选图片，请重新选择'), findsOneWidget);

    await _pumpPage(
      tester,
      picker: const _FakePicker(
        PickedObservationImage(
          path: '/cache/bad.png',
          mimeType: 'image/png',
          displayName: 'bad.png',
        ),
      ),
      onCreateImage:
          ({
            required image,
            required caption,
            required timezoneOffset,
            required onPrepared,
          }) async => throw UnsupportedImageException(),
    );
    await _switchToImage(tester);
    await tester.tap(find.byKey(const Key('pick_observation_image')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('save_observation')));
    await tester.pumpAndSettle();
    expect(find.text('请选择有效的 JPEG、PNG 或静态 WebP 图片'), findsOneWidget);

    await _pumpPage(
      tester,
      onCreateText: ({required rawText, required timezoneOffset}) async {
        throw StateError('database unavailable');
      },
    );
    await tester.enterText(find.byKey(const Key('create_text_input')), '保存失败');
    await tester.tap(find.byKey(const Key('save_observation')));
    await tester.pumpAndSettle();
    expect(find.text('保存失败，请重试'), findsOneWidget);
  });
}

Future<void> _pumpPage(
  WidgetTester tester, {
  ObservationImagePicker picker = const _FakePicker(null),
  CreateTextRecord? onCreateText,
  CreateImageRecord? onCreateImage,
}) async {
  await tester.pumpWidget(
    _PageHost(
      key: UniqueKey(),
      picker: picker,
      onCreateText:
          onCreateText ??
          ({required rawText, required timezoneOffset}) async => 'text-id',
      onCreateImage:
          onCreateImage ??
          ({
            required image,
            required caption,
            required timezoneOffset,
            required onPrepared,
          }) async {
            onPrepared();
            return 'image-id';
          },
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

Future<void> _switchToImage(WidgetTester tester) async {
  await tester.tap(find.text('图片'));
  await tester.pumpAndSettle();
}

class _PageHost extends StatefulWidget {
  const _PageHost({
    super.key,
    required this.picker,
    required this.onCreateText,
    required this.onCreateImage,
  });

  final ObservationImagePicker picker;
  final CreateTextRecord onCreateText;
  final CreateImageRecord onCreateImage;

  @override
  State<_PageHost> createState() => _PageHostState();
}

class _PageHostState extends State<_PageHost> {
  String? result;

  @override
  Widget build(BuildContext context) => MaterialApp(
    home: Builder(
      builder: (context) => Scaffold(
        body: Column(
          children: [
            TextButton(
              onPressed: () async {
                final value = await Navigator.of(context).push<String>(
                  MaterialPageRoute(
                    builder: (_) => CreateObservationPage(
                      imagePicker: widget.picker,
                      onCreateText: widget.onCreateText,
                      onCreateImage: widget.onCreateImage,
                    ),
                  ),
                );
                if (!mounted) return;
                setState(() => result = value);
              },
              child: const Text('open'),
            ),
            Text('result:${result ?? '-'}'),
          ],
        ),
      ),
    ),
  );
}

class _FakePicker implements ObservationImagePicker {
  const _FakePicker(this.result);

  final PickedObservationImage? result;

  @override
  Future<PickedObservationImage?> pickImage() async => result;

  @override
  Future<void> discardImage(PickedObservationImage image) async {}
}

class _ThrowingPicker implements ObservationImagePicker {
  const _ThrowingPicker(this.error);

  final Object error;

  @override
  Future<PickedObservationImage?> pickImage() async => throw error;

  @override
  Future<void> discardImage(PickedObservationImage image) async {}
}

class _TrackingPicker implements ObservationImagePicker {
  _TrackingPicker(this.result);

  final PickedObservationImage result;
  final List<String> discardedPaths = [];

  @override
  Future<PickedObservationImage?> pickImage() async => result;

  @override
  Future<void> discardImage(PickedObservationImage image) async {
    discardedPaths.add(image.path);
  }
}

class _DelayedPicker implements ObservationImagePicker {
  _DelayedPicker(this.future);

  final Future<PickedObservationImage?> future;
  final List<String> discardedPaths = [];

  @override
  Future<PickedObservationImage?> pickImage() => future;

  @override
  Future<void> discardImage(PickedObservationImage image) async {
    discardedPaths.add(image.path);
  }
}

class _ReplacementPicker implements ObservationImagePicker {
  _ReplacementPicker(this.discardPending);

  final Completer<void> discardPending;
  final List<String> discardedPaths = [];
  var pickCount = 0;

  @override
  Future<PickedObservationImage?> pickImage() async {
    pickCount++;
    return PickedObservationImage(
      path: '/cache/${pickCount == 1 ? 'first' : 'second'}.png',
      mimeType: 'image/png',
      displayName: '${pickCount == 1 ? 'first' : 'second'}.png',
    );
  }

  @override
  Future<void> discardImage(PickedObservationImage image) async {
    discardedPaths.add(image.path);
    if (image.path.endsWith('first.png')) await discardPending.future;
  }
}
