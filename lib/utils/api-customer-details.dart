import 'package:bushra_mobile/utils/util-api-service.dart';

import 'api_module.dart';

class ApiCustomerDetails{

  final apiService = ApiService();
  static const String _customerDetailsEndpoint = '/bb/customer/details/1.0.0/';

  Future<dynamic> fetchCustomerDetails(String customerId) async {
    return apiService.makeApiCall(
      _customerDetailsEndpoint + customerId,
      ApiModule.inquiries,
      method: 'GET',
    );
  }



}