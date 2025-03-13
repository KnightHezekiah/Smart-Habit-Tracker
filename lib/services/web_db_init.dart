import 'dart:async';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Initialize the web database connection
Future<void> initializeWebDatabase() async {
  if (!kIsWeb) return;

  // Log initialization
  print('Initializing web database connection');

  try {
    // Check if API is available
    final completer = Completer<bool>();

    final request = html.HttpRequest();
    request.open('GET', '/api/status', async: true);

    request.onLoad.listen((event) {
      if (request.status >= 200 && request.status < 300) {
        print('API connection successful: ${request.responseText}');
        completer.complete(true);
      } else {
        print('API connection failed with status: ${request.status}');
        completer.complete(false);
      }
    });

    request.onError.listen((event) {
      print('API connection error: $event');
      completer.complete(false);
    });

    request.send();

    final success = await completer.future;

    if (success) {
      print('Web database initialized successfully');
    } else {
      print('Failed to initialize web database, will retry later');

      // Try again after a delay
      Timer(const Duration(seconds: 5), () {
        initializeWebDatabase();
      });
    }
  } catch (e) {
    print('Error initializing web database: $e');
  }
}
