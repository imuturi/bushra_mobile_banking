class LoanSchedules {
  final String branchCode;
  final double amountDue;
  final double amountOutStanding;
  final String loanAccount;
  final String dueDate;
  final double amountSettled;

  LoanSchedules({
    required this.branchCode,
    required this.amountDue,
    required this.amountOutStanding,
    required this.loanAccount,
    required this.dueDate,
    required this.amountSettled,
  });

  factory LoanSchedules.fromJson(Map<String, dynamic> json) {
    return LoanSchedules(
      branchCode: json['branchCode'] ?? '',
      amountDue: _toDouble(json['amountDue']),
      amountOutStanding: _toDouble(json['amountOutStanding']),
      loanAccount: json['loanAccount'] ?? '',
      dueDate: json['dueDate'] ?? '',
      amountSettled: _toDouble(json['amountSettled']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
