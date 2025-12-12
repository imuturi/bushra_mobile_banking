import 'constants/app-error-codes.dart';

class AppException implements Exception {
  final String code;
  final String message;

  AppException(this.code)
      : message = AppErrorCodes.errors[code] ?? 'An error occurred.';

  @override
  String toString() => '$code : $message';
}


