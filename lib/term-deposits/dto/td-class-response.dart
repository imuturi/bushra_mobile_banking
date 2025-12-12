class TermDepositClass {
  final String accountClass;
  final String description;
  final String profitRate;
  //final String statementCycle;
  //final String months;

  TermDepositClass({
    required this.accountClass,
    required this.description,
    required this.profitRate,
    //required this.statementCycle,
    //required this.months,
  });

  factory TermDepositClass.fromJson(Map<String, dynamic> json) {
    return TermDepositClass(
      accountClass: json['account_class']?.toString() ?? '',
      description: json['description'] ?? '',
      profitRate: json['rate']?.toString() ?? '',
      //statementCycle: json['statementCycle'] ?? '',
      //months: json['months']?.toString() ?? '',
    );
  }
}