import 'package:flutter_dotenv/flutter_dotenv.dart';

String get host {
  try {
    return dotenv.env['HOST'] ?? 'https://dummyjson.com';
  } catch (_) {
    return 'https://dummyjson.com';
  }
}