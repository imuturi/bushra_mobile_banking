enum ApiModule {
  inquiries,
  billPayments,
  loans,
  fundsTransfer,
  system,
  profile,
  qrcode,
  otp,
}

extension ApiModuleExt on ApiModule {
  String get prefix {
    switch (this) {
      case ApiModule.inquiries:
        return 'INQ';
      case ApiModule.billPayments:
        return 'BILL';
      case ApiModule.loans:
        return 'LOAN';
      case ApiModule.fundsTransfer:
        return 'FT';
      case ApiModule.system:
        return 'SYS';
      case ApiModule.profile:
        return 'PROF';
      case ApiModule.qrcode:
        return 'QRC';
      case ApiModule.otp:
        return 'OTP';
    }
  }
}
