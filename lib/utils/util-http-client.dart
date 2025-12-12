import 'dart:io';
import 'package:bushra_mobile/utils/util-log-service.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/services.dart';

import '../remote-config-services.dart';

Future<HttpClient> createPinnedHttpClient() async {
  final context = SecurityContext(withTrustedRoots: false);
  if(RemoteConfigService.isProdBuild == 'true') {
    print('-------- USING PROD CERTIFICATES ------------');
    final certData = await rootBundle.load('assets/certs/wso2-prod.pem');
    context.setTrustedCertificatesBytes(certData.buffer.asUint8List());
  } else {
    print('-------- USING DEV CERTIFICATES ------------');
    final certData = await rootBundle.load('assets/certs/wso2-dev.pem');
    context.setTrustedCertificatesBytes(certData.buffer.asUint8List());
  }
  final httpClient = HttpClient(context: context);
  httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) {
    return _isHostValidForCertificate(cert, host);
  };
  return httpClient;
}

Future<Dio> createPinnedDioClient() async {
  final context = SecurityContext(withTrustedRoots: false);
  if(RemoteConfigService.isProdBuild == 'true') {
    print('-------- USING PROD CERTIFICATES ------------');
    final certData = await rootBundle.load('assets/certs/wso2-prod.pem');
    context.setTrustedCertificatesBytes(certData.buffer.asUint8List());
  } else {
    print('-------- USING DEV CERTIFICATES ------------');
    final certData = await rootBundle.load('assets/certs/wso2-dev.pem');
    context.setTrustedCertificatesBytes(certData.buffer.asUint8List());
  }
  final httpClient = HttpClient(context: context);
  httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) {
    return _isHostValidForCertificate(cert, host);
  };
  final dio = Dio();
  dio.interceptors.addAll([
    LoggingInterceptor(), // For debugging
    HeaderSanitizerInterceptor(), // Add our interceptor
  ]);
  dio.httpClientAdapter = IOHttpClientAdapter(createHttpClient: () => httpClient);
  return dio;
}

bool _isHostValidForCertificate(X509Certificate cert, String host) {
  final cnPattern = RegExp(r'CN=([^,\n]+)');
  final match = cnPattern.firstMatch(cert.subject);
  final cnValue = match?.group(1);

  if (RemoteConfigService.isProdBuild == 'true') {
    if (cnValue == null) return false;

    if (cnValue.startsWith('*.')) {
      final domain = cnValue.substring(2); // *.bbank.so → bbank.so
      return host == domain || host.endsWith('.$domain');
    }
    return host == cnValue;
  } else {
    // In dev, allow mismatch as long as cert is pinned
    return true;
  }
}

class LoggingInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    LoggerService.reportApiError(err);
    super.onError(err, handler);
  }
}

class HeaderSanitizerInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    try {
      print("=========== INTERCEPTOR-000 ==== Header parsing error: ${response.headers}");
      response.headers; // Test parsing
      handler.next(response);
    } on DioException {
      // Return response without headers
      handler.resolve(
        Response(
          requestOptions: response.requestOptions,
          data: response.data, // Keep the important part!
          statusCode: response.statusCode,
        ),
      );
    }
  }

  Headers _sanitizeHeaders(Headers original) {
    final newHeaders = Map<String, List<String>>.from(original.map);
    // Remove known problematic headers (e.g., non-RFC-compliant ones)
    newHeaders.removeWhere((key, _) => key.toLowerCase() == 'problematic-header');
    newHeaders.removeWhere((key, _) => key.isEmpty || key.contains(' '));
    newHeaders.removeWhere((key, value) => value.any((v) => v.isEmpty || v.contains(' ')));
    return Headers.fromMap(newHeaders);
  }
}
