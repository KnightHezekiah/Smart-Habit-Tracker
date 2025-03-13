import 'package:universal_html/html.dart' as html;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Initialize any web-specific configuration needed for Flutter web
void initializeFlutterWeb() {
  if (!kIsWeb) return;

  // Output information to console
  html.window.console.info('Flutter web application initialized');

  // You can add additional web-specific initialization here
  // For example, setting up interop with JavaScript libraries

  // Tell the parent iframe (if any) that Flutter app is loaded
  html.window.parent.postMessage('flutter-app-loaded', '*');
}
