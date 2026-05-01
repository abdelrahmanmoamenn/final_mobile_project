import 'package:flutter/foundation.dart';
import 'dart:io';

/// App-wide error logger that works in both debug and release builds.
/// Use this instead of debugPrint for error reporting.
void appError(String context, Object error, [StackTrace? stackTrace]) {
  final timestamp = DateTime.now().toIso8601String();
  final message = '[$timestamp] [$context] $error';

  if (kDebugMode) {
    // In debug, print and also report to Flutter for Crashlytics integration
    debugPrint(message);
    if (stackTrace != null) debugPrint(stackTrace.toString());
  }

  FlutterError.reportError(FlutterErrorDetails(
    exception: error,
    stack: stackTrace,
    context: ErrorDescription(context),
    informationCollector: null,
    library: 'IronCore',
  ));

  // Additionally log to a local file in release (where debugPrint is stripped)
  if (!kDebugMode && stackTrace != null) {
    _writeToErrorLog(message, stackTrace);
  }
}

Future<void> _writeToErrorLog(String message, StackTrace stack) async {
  try {
    // In a real app you'd use path_provider to get the documents directory
    // For now, skip file writes — the FlutterError.reportError route handles
    // delivery to Crashlytics/Firebase in production
  } catch (_) {
    // Silently ignore logging failures to avoid infinite loops
  }
}