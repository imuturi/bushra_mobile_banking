class TermDeposits {
  final String interestRate;
  final String accountClass;
  final String accountName;
  final String tdaccount;
  final String maturityDate;
  final String description;
  final String currency;
  final String statementCycle;
  final String branch;
  final String tdAmount;

  TermDeposits({
    required this.interestRate,
    required this.accountClass,
    required this.accountName,
    required this.tdaccount,
    required this.maturityDate,
    required this.description,
    required this.currency,
    required this.statementCycle,
    required this.branch,
    required this.tdAmount,
  });

  factory TermDeposits.fromJson(Map<String, dynamic> json) {
    return TermDeposits(
      interestRate: json['interestRate']?.toString() ?? '',
      accountClass: json['accountClass'] ?? '',
      accountName: json['accountName'] ?? '',
      tdaccount: json['tdaccount']?.toString() ?? '',
      maturityDate: json['maturityDate'] ?? '',
      description: json['description'] ?? '',
      currency: json['currency'] ?? '',
      statementCycle: json['statementCycle']?.toString() ?? '',
      branch: json['branch']?.toString() ?? '',
      tdAmount: json['tdAmount'] ?? '',
    );
  }
}