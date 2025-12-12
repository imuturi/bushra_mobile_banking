class LoanAccount {
  final String overdueAmount;
  final String maturityDate;
  final String bookingDate;
  final String interestRate;
  final String accountType;
  final String productCategoty;
  final String interestAmount;
  final String applicantName;
  final String accountStatus;
  final String productDesc;
  final String totalSalesValue;
  final String amountDue;
  final String branchCode;
  final String amountFinanced;
  final String loanAccount;
  final String productCode;
  final String loanStatus;
  final String currency;

  LoanAccount({
    required this.overdueAmount,
    required this.maturityDate,
    required this.bookingDate,
    required this.interestRate,
    required this.accountType,
    required this.productCategoty,
    required this.interestAmount,
    required this.applicantName,
    required this.accountStatus,
    required this.productDesc,
    required this.totalSalesValue,
    required this.amountDue,
    required this.branchCode,
    required this.amountFinanced,
    required this.loanAccount,
    required this.productCode,
    required this.loanStatus,
    required this.currency,
  });

  factory LoanAccount.fromJson(Map<String, dynamic> json) {
    return LoanAccount(
      interestRate: json['interestRate']?.toString() ?? '0.00',
      accountType: json['accountType'] ?? '',
      productCategoty: json['productCategoty'] ?? '',
      interestAmount: json['interestAmount']?.toString() ?? '',
      applicantName: json['applicantName'] ?? '',
      accountStatus: json['accountStatus'] ?? '',
      productDesc: json['productDesc'] ?? '',
      totalSalesValue: json['totalSalesValue']?.toString() ?? '0.00',
      amountDue: json['amountDue']?.toString() ?? '0.00',
      branchCode: json['branchCode'] ?? '',
      amountFinanced: json['amountFinanced']?.toString() ?? '0.00',
      loanAccount: json['loanAccount'] ?? '',
      productCode: json['productCode'] ?? '',
      loanStatus: json['loanStatus'] ?? '',
      currency: json['currency'] ?? '',
      maturityDate: json['maturityDate'] ?? '',
      bookingDate: json['bookingDate'] ?? '',
      overdueAmount: json['overdueAmount']?.toString() ?? '0.00',
    );
  }
}