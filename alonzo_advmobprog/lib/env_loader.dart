import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> loadAppEnvironment({String? startDirectory}) async {
  final root = startDirectory != null ? Directory(startDirectory) : Directory.current;
  var current = root;

  while (current.existsSync()) {
    final envFile = File('${current.path}/.env');
    if (envFile.existsSync()) {
      final contents = await envFile.readAsString();
      dotenv.testLoad(fileInput: contents);
      return;
    }

    final parent = current.parent;
    if (parent.path == current.path) {
      break;
    }
    current = parent;
  }

  try {
    await dotenv.load(isOptional: true);
  } catch (_) {}
}
