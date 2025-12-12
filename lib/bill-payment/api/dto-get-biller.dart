
class Biller {
  final String billerId;
  final String description;
  final String billerAccount;
  final String category;

  Biller({
    required this.billerId,
    required this.description,
    required this.billerAccount,
    required this.category,
  });

  factory Biller.fromJson(Map<String, dynamic> json) {
    return Biller(
      billerId: json['billerId'],
      description: json['description'],
      billerAccount: json['billercollectionaccount'],
      category: json['category'],
    );
  }
}