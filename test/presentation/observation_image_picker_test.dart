import 'package:cognote/src/presentation/observation_image_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('test/observation_image_picker');

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('maps a valid platform payload', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          expect(call.method, 'pickImage');
          return {
            'path': r'C:\cache\picked.png',
            'mimeType': 'image/png',
            'displayName': 'picked.png',
          };
        });
    const picker = AndroidObservationImagePicker(channel: channel);

    final image = await picker.pickImage();

    expect(image?.path, r'C:\cache\picked.png');
    expect(image?.mimeType, 'image/png');
    expect(image?.displayName, 'picked.png');
  });

  test('maps cancellation to null', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) async => null);

    expect(
      await const AndroidObservationImagePicker(channel: channel).pickImage(),
      isNull,
    );
  });

  for (final entry in <(Object?, String?)>[
    (null, null),
    ('image/jpg', 'image/jpeg'),
    ('application/octet-stream', null),
  ]) {
    test(
      'treats provider MIME ${entry.$1} as a non-authoritative hint',
      () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
              channel,
              (_) async => {
                'path': r'C:\cache\picked.img',
                'mimeType': entry.$1,
                'displayName': 'picked.img',
              },
            );

        final image = await const AndroidObservationImagePicker(
          channel: channel,
        ).pickImage();

        expect(image?.mimeType, entry.$2);
      },
    );
  }

  test('preserves a platform error code without leaking details', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          channel,
          (_) => throw PlatformException(
            code: 'too_large',
            message: 'private provider details',
          ),
        );

    await expectLater(
      const AndroidObservationImagePicker(channel: channel).pickImage(),
      throwsA(
        isA<ObservationImagePickerException>().having(
          (error) => error.code,
          'code',
          'too_large',
        ),
      ),
    );
  });

  test('rejects malformed platform payloads', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          channel,
          (_) async => {'path': '', 'mimeType': 'image/png'},
        );

    await expectLater(
      const AndroidObservationImagePicker(channel: channel).pickImage(),
      throwsA(
        isA<ObservationImagePickerException>().having(
          (error) => error.code,
          'code',
          'invalid_result',
        ),
      ),
    );
  });
}
