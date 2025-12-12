class Transaction {
  final String transactionType;
  final double transactionAmount;
  final String narration;
  final dynamic transactionRef;
  final String? transactionDescription;
  final String transactionDate;
  final dynamic externalRef;
  final double runningBalance;

  Transaction({
    required this.transactionType,
    required this.transactionAmount,
    required this.narration,
    required this.transactionRef,
    this.transactionDescription,
    required this.transactionDate,
    required this.externalRef,
    required this.runningBalance,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      transactionType: json['transactionType'],
      transactionAmount: json['transactionAmount'].toDouble(),
      narration: json['narration'],
      transactionRef: json['transactionRef'],
      transactionDescription: json['transactionDescription'],
      transactionDate: json['transactionDate'],
      externalRef: json['externalRef'],
      runningBalance: json['runningBalance'].toDouble(),
    );
  }
}