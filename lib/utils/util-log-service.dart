import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

class LoggerService {

  static void reportApiError(DioException err) {
    FirebaseCrashlytics.instance.recordError(
      err,
      err.stackTrace,
      reason: 'Dio API Error: ${err.requestOptions.uri}',
      fatal: false,
    );
  }

  static void reportHttpError(http.Response response, Uri uri, String method) {
    FirebaseCrashlytics.instance.log('HTTP $method ${uri.toString()} failed');
    FirebaseCrashlytics.instance.recordError(
      'Status: ${response.statusCode}, Body: ${response.body}',
      null,
      reason: 'HTTP Error: $method ${uri.toString()}',
      fatal: false,
    );
  }

  static void reportUnexpectedError(Object error, StackTrace stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: false);
  }

  static void reportGenericTraces(String message) {
    FirebaseCrashlytics.instance.log(message);
  }
}
