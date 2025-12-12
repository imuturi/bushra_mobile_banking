import 'dart:ui' as ui;
import 'package:bushra_mobile/utils/util-http-client.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

class NetworkImageWithAuth extends ImageProvider<NetworkImageWithAuth> {
  final String url;
  final String token;

  NetworkImageWithAuth(this.url, this.token);

  @override
  Future<NetworkImageWithAuth> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<NetworkImageWithAuth>(this);
  }

  @override
  ImageStreamCompleter load(NetworkImageWithAuth key, ui.Codec Function(Uint8List, {int? cacheWidth, int? cacheHeight}) decode) {
    return OneFrameImageStreamCompleter(_loadAsync(key, decode));
  }

  Future<ImageInfo> _loadAsync(NetworkImageWithAuth key, ui.Codec Function(Uint8List, {int? cacheWidth, int? cacheHeight}) decode) async {
    try {
      // Create a custom HTTP client with the certificate pinning
      final httpClient = await createPinnedHttpClient();
      final ioClient = IOClient(httpClient);
      final response = await ioClient.get(
      //final response = await http.get(
        Uri.parse(key.url),
        headers: {
          'Authorization': 'Bearer ${key.token}',
        },
      );

      print('Response status: ${response.statusCode} ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('HTTP error: ${response.statusCode}');
      }

      final bytes = response.bodyBytes;
      if (bytes.isEmpty) {
        throw Exception('Image bytes are empty');
      }

      final codec = await decode(bytes);
      final frame = await codec.getNextFrame();
      return ImageInfo(image: frame.image, scale: 1.0);
    } catch (e) {
      debugPrint('Image load error: $e');
      rethrow;
    }
  }

  @override
  bool operator ==(Object other) =>
      other is NetworkImageWithAuth && other.url == url && other.token == token;

  @override
  int get hashCode => Object.hash(url, token);
}
