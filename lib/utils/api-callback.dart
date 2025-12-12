import 'package:bushra_mobile/utils/util-api-service.dart';

import 'api_module.dart';

class ApiCallback{

  final apiService = ApiService();
  static const String _callBackEndpoint = '/bb/mobile/customer/callrequest/1.0.0';

  Future<dynamic> postCallBack(String phoneNumber, String email, String callbackDateTime) async {
    return apiService.makeApiCall(
      _callBackEndpoint,
      ApiModule.system,
      method: 'POST',
      body: {
        'phoneNumber': phoneNumber,
        'email': email,
        'callbackDateTime': callbackDateTime,
      },
    );
  }

}