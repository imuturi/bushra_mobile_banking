class AppErrorCodes {

  static const Map<String, String> errors = {
    // ===== PROFILE =====
    'PROF001': 'Unable to retrieve customer profile details at the moment.',
    'PROF002': 'Profile information is temporarily unavailable.',
    'PROF003': 'Account information could not be retrieved.',
    'PROF100': 'Unable to connect to customer profile service. Please check your internet.',

    // ===== INQUIRIES =====
    'INQ001': 'Unable to retrieve mini statement at the moment.',
    'INQ002': 'Balance information is temporarily unavailable.',
    'INQ003': 'Account information could not be retrieved.',
    'INQ100': 'Unable to connect to inquiry service. Please check your internet.',

    // ===== BILL PAYMENTS =====
    'BILL001': 'Bill payment could not be processed at the moment.',
    'BILL002': 'Invalid bill details provided.',
    'BILL003': 'Bill payment service is currently unavailable.',
    'BILL100': 'Unable to connect to bill payment service. Please check your internet.',

    // ===== LOANS =====
    'LOAN001': 'Loan request could not be processed.',
    'LOAN002': 'Loan repayment service is currently unavailable.',
    'LOAN003': 'Invalid loan details provided.',
    'LOAN100': 'Unable to connect to loan service. Please check your internet.',

    // ===== FUNDS TRANSFER =====
    'FT001': 'Funds transfer could not be completed.',
    'FT002': 'Invalid transfer details provided.',
    'FT003': 'Transfer service is currently unavailable.',
    'FT100': 'Unable to connect to transfer service. Please check your internet.',

    // ===== SYSTEM / GENERIC =====
    'SYS001': 'An unexpected error occurred.',
    'SYS002': 'Service temporarily unavailable.',
    'SYS003': 'Request could not be completed.',
    'SYS100': 'Unable to connect to the server. Please check your internet.',

    // ===== TOKEN / GENERIC =====
    'SEC001': 'An unexpected error occurred.',
    'SEC002': 'Service temporarily unavailable.',
    'SEC003': 'Request could not be completed.',
    'SEC100': 'Unable to connect to the token server.',
    'SEC101': 'Unauthorized access. Please check your credentials.',

    // ===== TOKEN / GENERIC =====
    'QRC001': 'An unexpected error occurred.',
    'QRC002': 'Service temporarily unavailable.',
    'QRC003': 'Request could not be completed.',
    'QRC100': 'Unable to connect to the server. Please check your internet.',

    // ===== TOKEN / GENERIC =====
    'OTP001': 'An unexpected error occurred.',
    'OTP002': 'Service temporarily unavailable.',
    'OTP003': 'Request could not be completed.',
    'OTP100': 'Unable to connect to the server. Please check your internet.',

    'NET100': 'Network connectivity error. Please check your internet connection.',
    'NET101': 'Request timed out. Please try again later.',
    'API100': 'Invalid response format from the server.',
    'API101': 'HTTP error occurred while processing the request.',
    'API102': 'Client error occurred while processing the request.',

  };
}
