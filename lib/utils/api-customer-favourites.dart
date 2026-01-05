import 'dart:io';

import 'package:bushra_mobile/utils/reference-generator.dart';
import 'package:bushra_mobile/utils/util-api-service.dart';

import '../models/dto/favourites-add-request.dart';
import '../models/dto/favourites-get-request.dart';
import 'api_module.dart';


class ApiCustomerFavourites{

  static const String _getCustomerFavouritesEndpoint = '/bb/mobile/favourites/get/1.0.0';
  static const String _createCustomerFavouritesEndpoint = '/bb/mobile/favourites/add/1.0.0';
  static const String _deleteCustomerFavouritesEndpoint = '/bb/mobile/delete/favorites/1.0.0';

  final apiService = ApiService();
  final referenceGenerator = ReferenceGenerator();

  Future<dynamic> getCustomerFavourites(GetFavoritesRequest request) async {
    return apiService.makeApiCall(
      _getCustomerFavouritesEndpoint,
      ApiModule.fundsTransfer,
      method: 'POST',
      body: request.toJson(),
    );
  }

  Future<dynamic> postCustomerFavourites(TransactionRequest request) async {
    return apiService.makeApiCall(
      _createCustomerFavouritesEndpoint,
      ApiModule.fundsTransfer,
      method: 'POST',
      body: request.toJson(),
    );
  }

  Future<dynamic> addCustomerFavourites({
    required String imei,
    required String phone,
    required String category,
    required Map<String, dynamic> favoriteData,
  }) async {
    return apiService.makeApiCall(
      _createCustomerFavouritesEndpoint,
      ApiModule.fundsTransfer,
      method: 'POST',
      body: {
        "xref": referenceGenerator.generateUniqueReference(false),
        "txntimestamp": DateTime.now().toUtc().toIso8601String(),
        "transactionDetails": {
          "direction": "0200",
          "transactionType": "ADDFAVORITES",
          "transactionCode": "ADDFAVORITES",
          "hostCode": "MOBILE",
          "debitAccount": phone,
          "phoneNumber": phone,
          "category": category,
          ...favoriteData, // Spread the favorite data
        },
        "channelDetails": {
          "host": "IP",
          "geolocation": "1.2921, 36.8219",
          "userAgent": Platform.isAndroid ? "Android" : (Platform.isIOS ? "iOS" : "Unknown"),
          "userAgentVersion": "1.0",
          "channel": "MOBILE",
          "clientId": "client123",
          "deviceId": imei,
        },
      },
    );
  }

  Future<dynamic> deleteCustomerFavourites(String imei, String phone, String favouriteType, String favouriteId) async {
    return apiService.makeApiCall(
      _deleteCustomerFavouritesEndpoint,
      ApiModule.fundsTransfer,
      method: 'POST',
      body: {
        "xref": referenceGenerator.generateUniqueReference(false),
        "txntimestamp": DateTime.now().toUtc().toIso8601String(),
        "transactionDetails": {
          "direction": "0200",
          "transactionType": "REMOVEFAVORITES",
          "transactionCode": "REMOVEFAVORITES",
          "hostCode": "MOBILE",
          "debitAccount": phone,
          "phoneNumber": phone,
          "category": favouriteType,
          "id": favouriteId,
        },
        "channelDetails": {
          "host": "IP",
          "geolocation": "1.2921, 36.8219",
          "userAgent": Platform.isAndroid ? "Android" : (Platform.isIOS ? "iOS" : "Unknown"),
          "userAgentVersion": "1.0",
          "channel": "MOBILE",
          "clientId": "client123",
          "deviceId": imei
        }
      },
    );
  }

}