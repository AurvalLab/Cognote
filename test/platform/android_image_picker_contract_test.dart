import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android picker copies unknown provider MIME for content detection', () {
    final source = File(
      'android/app/src/main/kotlin/com/cognote/cognote/MainActivity.kt',
    ).readAsStringSync();

    expect(
      source,
      contains('val mimeTypeHint = normalizedMimeTypeHint(providerMimeType)'),
    );
    expect(source, contains('"image/jpeg", "image/jpg" -> "image/jpeg"'));
    expect(source, contains('else -> null'));
    expect(source, contains('else -> ".img"'));
    expect(
      source,
      contains('providerIo { contentResolver.openInputStream(uri) }'),
    );
    expect(
      source,
      contains(
        'storageIo { File.createTempFile("picked-", extension, directory) }',
      ),
    );
    expect(source, contains('storageIo { FileOutputStream(outputFile) }'));
    expect(
      RegExp(r'contentResolver\.getType\(uri\)\s*\?:\s*throw').hasMatch(source),
      isFalse,
    );
    expect(
      source,
      isNot(contains('else -> throw PickedImageException("unsupported")')),
    );
  });

  test(
    'classifies provider and cache stream failures by executable seam',
    () async {
      final output = await Directory.systemTemp.createTemp(
        'cng111-picker-contract-',
      );
      try {
        final compile = await Process.run('javac', [
          '-d',
          output.path,
          'android/app/src/main/java/com/cognote/cognote/PickedImageStreamCopier.java',
          'android/app/src/test/java/com/cognote/cognote/PickedImageStreamCopierContract.java',
        ]);
        expect(
          compile.exitCode,
          0,
          reason: 'javac failed:\n${compile.stdout}\n${compile.stderr}',
        );

        final execute = await Process.run('java', [
          '-cp',
          output.path,
          'com.cognote.cognote.PickedImageStreamCopierContract',
        ]);
        expect(
          execute.exitCode,
          0,
          reason: 'contract failed:\n${execute.stdout}\n${execute.stderr}',
        );
      } finally {
        await output.delete(recursive: true);
      }
    },
  );
}
