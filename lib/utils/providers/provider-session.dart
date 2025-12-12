import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../dto/api-response-balance.dart';
import '../dto/api-response-login.dart';
import '../dto/api-response-transactions.dart';

class SessionProvider with ChangeNotifier {

  // -------------------------------- NEW VERSION ------------------------------
  UserModel? _user;
  UserModel? get user => _user;

  TransactionResponse? _balanceResponse;
  TransactionResponse? get balanceResponse => _balanceResponse;

  static String _userToken = '';
  String get userToken => _userToken;

  static String _userLoginId = '';
  String get userLoginId => _userLoginId;

  List<Transaction> _transactions = [];
  List<Transaction> get transactions => _transactions;

  List<Transaction> _fullStatement = [];
  List<Transaction> get fullStatement => _fullStatement;

  void setUserLoginId(String userLoginId) {
    _userLoginId = userLoginId;
    notifyListeners();
  }

  void setMiniStatement(List<Transaction> transactions){
    _transactions = transactions;
    notifyListeners();
  }

  void setFullStatement(List<Transaction> transactions){
    _fullStatement = transactions;
    notifyListeners();
  }

  void setUserToken(String token) {
    _userToken = token;
    notifyListeners();
  }

  void setUserLogin(UserModel details){
    _user = details;
    notifyListeners();
  }

  void setBalance(TransactionResponse details){
    _balanceResponse = details;
    notifyListeners();
  }
  // -------------------------------- NEW VERSION ------------------------------

  Map<String, dynamic>? _customerDetails;
  Map<String, dynamic>? get customerDetails => _customerDetails;

  Map<String, dynamic>? _customerAccounts;
  Map<String, dynamic>? get customerAccounts => _customerAccounts;

  Map<String, dynamic>? _customerAccountBalance;
  Map<String, dynamic>? get customerAccountBalance => _customerAccountBalance;

  Map<String, dynamic>? _loginApiResponse;
  Map<String, dynamic>? get loginApiResponse => _loginApiResponse;

  void setCustomerDetails(Map<String, dynamic> details) {
    _customerDetails = details;
    notifyListeners();
  }

  void setCustomerAccounts(Map<String, dynamic> details) {
    _customerAccounts = details;
    notifyListeners();
  }

  void setCustomerAccountBalance(Map<String, dynamic> details) {
    _customerAccountBalance = details;
    notifyListeners();
  }

  void setLoginApiResponse(Map<String, dynamic> details) {
    _loginApiResponse = details;
    notifyListeners();
  }

  void clearSession() {
    _userToken = '';
    _userLoginId = '';
    _customerDetails = null;
    _customerAccounts = null;
    _customerAccountBalance = null;
    _loginApiResponse = null;
    notifyListeners();
  }

  // -------------------------------- UPGRADED VERSION ------------------------------
  // The following is an upgraded version of the session management
  // that includes user authentication and session management.
  // todo - implement secure storage for user token and details
  bool _loggedIn = true;
  bool get isLoggedIn => _loggedIn;

  void logout() {
    _loggedIn = false;
    _userToken = '';
    // Optional: clear secure storage or token
    // await secureStorage.deleteAll();
    notifyListeners();
    // Navigate to login
    navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (_) => false);
  }
  void login() {
    _loggedIn = true;
    notifyListeners();
  }

}
