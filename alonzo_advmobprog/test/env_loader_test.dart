import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/env_loader.dart';

void main() {
  test('loadAppEnvironment finds the project .env from a parent directory', () async {
    final tempDir = await Directory.systemTemp.createTemp('env_loader_test');
    final projectDir = Directory('${tempDir.path}/alonzo_advmobprog');
    await projectDir.create(recursive: true);
    final envFile = File('${projectDir.path}/.env');
    await envFile.writeAsString('HOST=https://dummyjson.com\n');

    try {
      await loadAppEnvironment(startDirectory: tempDir.path);
      expect(dotenv.env['HOST'], 'https://dummyjson.com');
    } finally {
      await tempDir.delete(recursive: true);
    }
  });
}
