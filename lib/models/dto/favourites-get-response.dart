class GetFavoritesResponse {
  final String xref;
  final String txntimestamp;
  final ResponseData data;

  GetFavoritesResponse({
    required this.xref,
    required this.txntimestamp,
    required this.data,
  });

  factory GetFavoritesResponse.fromJson(Map<String, dynamic> json) {
    return GetFavoritesResponse(
      xref: json["xref"],
      txntimestamp: json["txntimestamp"],
      data: ResponseData.fromJson(json["data"]),
    );
  }
}

class ResponseData {
  final String responseCode;
  final String response;
  final Favourite favourites;

  ResponseData({
    required this.responseCode,
    required this.response,
    required this.favourites,
  });

  factory ResponseData.fromJson(Map<String, dynamic> json) {
    return ResponseData(
      responseCode: json["response_code"] ?? '',
      response: json["response"] ?? '',
      favourites: Favourite.fromJson(json["favourites"] ?? {}),
    );
  }
}

class Favourite {
  final List<TransactionItem> ift;
  final List<TransactionItem> billpayment;
  final List<TransactionItem> sps;
  final List<TransactionItem> beneficiary;

  Favourite({
    required this.ift,
    required this.billpayment,
    required this.sps,
    required this.beneficiary,
  });

  factory Favourite.fromJson(Map<String, dynamic> json) {
    return Favourite(
      ift: (json["ift"] as List? ?? [])
          .map<TransactionItem>((item) => TransactionItem.fromJson(item))
          .toList(),
      billpayment: (json["billpayment"] as List? ?? [])
          .map<TransactionItem>((item) => TransactionItem.fromJson(item))
          .toList(),
      sps: (json["sps"] as List? ?? [])
          .map<TransactionItem>((item) => TransactionItem.fromJson(item))
          .toList(),
      beneficiary: (json["beneficiary"] as List? ?? [])
          .map<TransactionItem>((item) => TransactionItem.fromJson(item))
          .toList(),
    );
  }
}

class TransactionItem {
  final String id;
  final String name;
  final String bankcode;
  final String type;
  final String amount;
  final String recipient;

  TransactionItem({
    required this.id,
    required this.name,
    required this.bankcode,
    required this.type,
    required this.amount,
    required this.recipient,
  });

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      id: json["id"] ?? '',
      name: json["name"] ?? '',
      bankcode: json["bankcode"] ?? '',
      type: json["type"] ?? '',
      amount: json["amount"] ?? '',
      recipient: json["recipient"] ?? '',
    );
  }
}
