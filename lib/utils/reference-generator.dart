
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class ReferenceGenerator{

  String generateUniqueReference(bool isSps) {
    // Get current timestamp in milliseconds
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    // Generate a random number
    String randomPart = Random().nextInt(999999).toString().padLeft(6, '0');
    // Combine timestamp and random number
    String rawId = "$timestamp$randomPart";
    // Hash to get a unique, consistent length
    String hash = sha256.convert(utf8.encode(rawId)).toString();
    // Take first 15 characters of the hash for uniqueness
    if(isSps) {
      // For SPS, we use the first 15 characters of the hash
      String response = "MBSP${hash.substring(0, 11).toUpperCase()}";
      return response;
    }else{
      // For non-SPS, we use the first 15 characters of the hash
      String response = "MB${hash.substring(0, 13).toUpperCase()}";
      return response;
    }
  }

}