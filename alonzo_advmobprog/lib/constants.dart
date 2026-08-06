import 'package:flutter_dotenv/flutter_dotenv.dart';

// Host for API requests. Uses .env HOST if provided, otherwise falls back to
// a sample placeholder. We expose `host` as a getter so the value is resolved
// at runtime (after dotenv.load()) and tests can initialize dotenv before
// accessing the value.

String get host {
	try {
		return dotenv.env['HOST'] ?? 'https://example.com';
	} catch (_) {
		return 'https://example.com';
	}
}
