import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_so.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('so')
  ];

  /// The name of the app
  ///
  /// In en, this message translates to:
  /// **'Bushra Mobile'**
  String get appName;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'LOGIN'**
  String get login;

  /// No description provided for @signup.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signup;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @accounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get accounts;

  /// No description provided for @transfers.
  ///
  /// In en, this message translates to:
  /// **'Transfers'**
  String get transfers;

  /// No description provided for @payments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get payments;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'LOGOUT'**
  String get logout;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'SUBMIT'**
  String get submit;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'SUCCESS'**
  String get success;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'RETRY'**
  String get retry;

  /// No description provided for @noInternet.
  ///
  /// In en, this message translates to:
  /// **'No Internet Connection'**
  String get noInternet;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'TRY AGAIN!'**
  String get tryAgain;

  /// No description provided for @pleaseUpdateToContinueNn.
  ///
  /// In en, this message translates to:
  /// **'Please update to continue. \\n\\n'**
  String get pleaseUpdateToContinueNn;

  /// No description provided for @aNewVersionOfTheAppIsAvailable.
  ///
  /// In en, this message translates to:
  /// **'A new version of the app is available.'**
  String get aNewVersionOfTheAppIsAvailable;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'UPDATE'**
  String get update;

  /// No description provided for @loanSchedule.
  ///
  /// In en, this message translates to:
  /// **'Loan schedule'**
  String get loanSchedule;

  /// No description provided for @outstanding.
  ///
  /// In en, this message translates to:
  /// **'Outstanding'**
  String get outstanding;

  /// No description provided for @paidAmount.
  ///
  /// In en, this message translates to:
  /// **'Paid Amount'**
  String get paidAmount;

  /// No description provided for @amountDisbursed.
  ///
  /// In en, this message translates to:
  /// **'Amount Disbursed'**
  String get amountDisbursed;

  /// No description provided for @dueAmount.
  ///
  /// In en, this message translates to:
  /// **'Due Amount'**
  String get dueAmount;

  /// No description provided for @dueDate.
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get dueDate;

  /// No description provided for @selectTheLoan.
  ///
  /// In en, this message translates to:
  /// **'Select the loan'**
  String get selectTheLoan;

  /// No description provided for @pleaseEnterYourPinToContinue.
  ///
  /// In en, this message translates to:
  /// **'Please enter your PIN to continue.'**
  String get pleaseEnterYourPinToContinue;

  /// No description provided for @scanToVisitOurWebsite.
  ///
  /// In en, this message translates to:
  /// **'Scan to visit our website'**
  String get scanToVisitOurWebsite;

  /// No description provided for @totalAmountPaid.
  ///
  /// In en, this message translates to:
  /// **'Total Amount Paid:'**
  String get totalAmountPaid;

  /// No description provided for @enterPin.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN'**
  String get enterPin;

  /// No description provided for @httpswwwbbbankso.
  ///
  /// In en, this message translates to:
  /// **'https://www.bbbank.so'**
  String get httpswwwbbbankso;

  /// No description provided for @selectLoanAccount.
  ///
  /// In en, this message translates to:
  /// **'Select loan account'**
  String get selectLoanAccount;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @selectLoanType.
  ///
  /// In en, this message translates to:
  /// **'Select loan type'**
  String get selectLoanType;

  /// No description provided for @eg31012025.
  ///
  /// In en, this message translates to:
  /// **'Eg 31-01-2025'**
  String get eg31012025;

  /// No description provided for @egCurrentAc0001111.
  ///
  /// In en, this message translates to:
  /// **'Eg. Current AC #0001*****111'**
  String get egCurrentAc0001111;

  /// No description provided for @action.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get action;

  /// No description provided for @selectStartDate.
  ///
  /// In en, this message translates to:
  /// **'Select start date'**
  String get selectStartDate;

  /// No description provided for @debitFrom.
  ///
  /// In en, this message translates to:
  /// **'Debit from'**
  String get debitFrom;

  /// No description provided for @eg01012025.
  ///
  /// In en, this message translates to:
  /// **'Eg 01-01-2025'**
  String get eg01012025;

  /// No description provided for @loans.
  ///
  /// In en, this message translates to:
  /// **'Loans'**
  String get loans;

  /// No description provided for @enterTransferAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter Transfer Amount'**
  String get enterTransferAmount;

  /// No description provided for @pay.
  ///
  /// In en, this message translates to:
  /// **'PAY'**
  String get pay;

  /// No description provided for @howMuchWouldYouLikeToRepay.
  ///
  /// In en, this message translates to:
  /// **'How much would you like to repay ?'**
  String get howMuchWouldYouLikeToRepay;

  /// No description provided for @theMinimumTransferAmountIs01.
  ///
  /// In en, this message translates to:
  /// **'The minimum transfer amount is 0.1'**
  String get theMinimumTransferAmountIs01;

  /// No description provided for @selectEndDate.
  ///
  /// In en, this message translates to:
  /// **'Select end date'**
  String get selectEndDate;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @egLoanAccount.
  ///
  /// In en, this message translates to:
  /// **'Eg. Loan account'**
  String get egLoanAccount;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort By:'**
  String get sortBy;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @noTransactionsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No transactions available'**
  String get noTransactionsAvailable;

  /// No description provided for @postingLoanRepaymentNPleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Posting loan repayment \\n Please Wait...'**
  String get postingLoanRepaymentNPleaseWait;

  /// No description provided for @loanStatements.
  ///
  /// In en, this message translates to:
  /// **'Loan Statements'**
  String get loanStatements;

  /// No description provided for @monthlyInstalment.
  ///
  /// In en, this message translates to:
  /// **'Monthly Instalment'**
  String get monthlyInstalment;

  /// No description provided for @loansNotSelected.
  ///
  /// In en, this message translates to:
  /// **'Loans not selected'**
  String get loansNotSelected;

  /// No description provided for @outstandingLoan.
  ///
  /// In en, this message translates to:
  /// **'Outstanding Loan'**
  String get outstandingLoan;

  /// No description provided for @selectALoan.
  ///
  /// In en, this message translates to:
  /// **'Select a loan'**
  String get selectALoan;

  /// No description provided for @pressBackAgainToExitTheApp.
  ///
  /// In en, this message translates to:
  /// **'Press back again to exit the app'**
  String get pressBackAgainToExitTheApp;

  /// No description provided for @yyyymmdd.
  ///
  /// In en, this message translates to:
  /// **'YYYY-MM-DD'**
  String get yyyymmdd;

  /// No description provided for @fullstatements.
  ///
  /// In en, this message translates to:
  /// **'Full-statements'**
  String get fullstatements;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTransactions;

  /// No description provided for @generateFullStatement.
  ///
  /// In en, this message translates to:
  /// **'GENERATE FULL STATEMENT'**
  String get generateFullStatement;

  /// No description provided for @ministatements.
  ///
  /// In en, this message translates to:
  /// **'Mini-statements'**
  String get ministatements;

  /// No description provided for @searchByAccountNameDate.
  ///
  /// In en, this message translates to:
  /// **'Search by Account, Name, Date'**
  String get searchByAccountNameDate;

  /// No description provided for @fullStatements.
  ///
  /// In en, this message translates to:
  /// **'Full Statements'**
  String get fullStatements;

  /// No description provided for @actualBalance.
  ///
  /// In en, this message translates to:
  /// **'Actual Balance'**
  String get actualBalance;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @statements.
  ///
  /// In en, this message translates to:
  /// **'Statements'**
  String get statements;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @out.
  ///
  /// In en, this message translates to:
  /// **'Out'**
  String get out;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'YES'**
  String get yes;

  /// No description provided for @activateBiometric.
  ///
  /// In en, this message translates to:
  /// **'Activate Biometric'**
  String get activateBiometric;

  /// No description provided for @areYouSureYouWantToLogout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout ?.'**
  String get areYouSureYouWantToLogout;

  /// No description provided for @notification.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notification;

  /// No description provided for @activateYourBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Activate your Biometrics'**
  String get activateYourBiometrics;

  /// No description provided for @byConfirmingYesYouWillBeLoggedOutAndByNoYouWillRemainLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'By confirming (YES) you will be logged out and by (NO) you will remain logged in'**
  String get byConfirmingYesYouWillBeLoggedOutAndByNoYouWillRemainLoggedIn;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'NOT NOW'**
  String get notNow;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @activate.
  ///
  /// In en, this message translates to:
  /// **'ACTIVATE'**
  String get activate;

  /// No description provided for @deactivate.
  ///
  /// In en, this message translates to:
  /// **'DE-ACTIVATE'**
  String get deactivate;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'NO'**
  String get no;

  /// No description provided for @byConfirmingYesYouWillBeYouWillBeRedirectedToChangeYourPinAndByNoYouWillRemainLoggedWithCurrent.
  ///
  /// In en, this message translates to:
  /// **'By confirming (YES) you will be you will be redirected to change your PIN and by (NO) you will remain logged with current'**
  String get byConfirmingYesYouWillBeYouWillBeRedirectedToChangeYourPinAndByNoYouWillRemainLoggedWithCurrent;

  /// No description provided for @transactionAlert.
  ///
  /// In en, this message translates to:
  /// **'Transaction Alert'**
  String get transactionAlert;

  /// No description provided for @noBiometricsEnrolledPleaseSetUpInSettings.
  ///
  /// In en, this message translates to:
  /// **'No biometrics enrolled, please set up in Settings'**
  String get noBiometricsEnrolledPleaseSetUpInSettings;

  /// No description provided for @pleaseConfirmIfYouWantToDeactivateBiometricsOnYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Please confirm if you want to de-activate Biometrics on your account.'**
  String get pleaseConfirmIfYouWantToDeactivateBiometricsOnYourAccount;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @deactivateYourBiometrics.
  ///
  /// In en, this message translates to:
  /// **'De-Activate your Biometrics'**
  String get deactivateYourBiometrics;

  /// No description provided for @areYouSureYouWantToChangeYourPin.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to change your PIN ?.'**
  String get areYouSureYouWantToChangeYourPin;

  /// No description provided for @youDontHaveAnyFingerprintOrFaceIdActivatedYetOnYourAccount.
  ///
  /// In en, this message translates to:
  /// **'You don’t have any Fingerprint or Face ID activated yet on your account.'**
  String get youDontHaveAnyFingerprintOrFaceIdActivatedYetOnYourAccount;

  /// No description provided for @biometricsNotSupportedOnThisDevice.
  ///
  /// In en, this message translates to:
  /// **'Biometrics not supported on this device'**
  String get biometricsNotSupportedOnThisDevice;

  /// No description provided for @noCustomerDetailsFound.
  ///
  /// In en, this message translates to:
  /// **'No customer details found'**
  String get noCustomerDetailsFound;

  /// No description provided for @changePin.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get changePin;

  /// No description provided for @noInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'No Internet Connection'**
  String get noInternetConnection;

  /// No description provided for @viewMore.
  ///
  /// In en, this message translates to:
  /// **'View More'**
  String get viewMore;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back 👋'**
  String get welcomeBack;

  /// No description provided for @scanToPay.
  ///
  /// In en, this message translates to:
  /// **'Scan to pay'**
  String get scanToPay;

  /// No description provided for @beneficiaries.
  ///
  /// In en, this message translates to:
  /// **'Beneficiaries'**
  String get beneficiaries;

  /// No description provided for @frequents.
  ///
  /// In en, this message translates to:
  /// **'Frequents'**
  String get frequents;

  /// No description provided for @noBeneficiariesFound.
  ///
  /// In en, this message translates to:
  /// **'No Beneficiaries found'**
  String get noBeneficiariesFound;

  /// No description provided for @fundTransfer.
  ///
  /// In en, this message translates to:
  /// **'Fund transfer'**
  String get fundTransfer;

  /// No description provided for @pleaseSelectABeneficiaryRadioButton.
  ///
  /// In en, this message translates to:
  /// **'Please select a beneficiary radio button'**
  String get pleaseSelectABeneficiaryRadioButton;

  /// No description provided for @sendingTo.
  ///
  /// In en, this message translates to:
  /// **'Sending to'**
  String get sendingTo;

  /// No description provided for @selectTheCountry.
  ///
  /// In en, this message translates to:
  /// **'Select the country'**
  String get selectTheCountry;

  /// No description provided for @foreignRemittance.
  ///
  /// In en, this message translates to:
  /// **'Foreign Remittance'**
  String get foreignRemittance;

  /// No description provided for @fee.
  ///
  /// In en, this message translates to:
  /// **'Fee'**
  String get fee;

  /// No description provided for @paymentMode.
  ///
  /// In en, this message translates to:
  /// **'Payment mode'**
  String get paymentMode;

  /// No description provided for @selectTheCountryYouAreSendingMoneyTo.
  ///
  /// In en, this message translates to:
  /// **'Select the country you are sending money to'**
  String get selectTheCountryYouAreSendingMoneyTo;

  /// No description provided for @exchangeRate.
  ///
  /// In en, this message translates to:
  /// **'Exchange rate'**
  String get exchangeRate;

  /// No description provided for @recipientGets.
  ///
  /// In en, this message translates to:
  /// **'Recipient gets'**
  String get recipientGets;

  /// No description provided for @selectTheReceiverPaymentMode.
  ///
  /// In en, this message translates to:
  /// **'Select the receiver payment mode'**
  String get selectTheReceiverPaymentMode;

  /// No description provided for @howMuchWouldYouLikeToTransfer.
  ///
  /// In en, this message translates to:
  /// **'How much would you like to transfer?'**
  String get howMuchWouldYouLikeToTransfer;

  /// No description provided for @egP2MOrP2M.
  ///
  /// In en, this message translates to:
  /// **'Eg P2M or P2M'**
  String get egP2MOrP2M;

  /// No description provided for @selectTransferType.
  ///
  /// In en, this message translates to:
  /// **'Select transfer type'**
  String get selectTransferType;

  /// No description provided for @selectAccountFrom.
  ///
  /// In en, this message translates to:
  /// **'Select account from'**
  String get selectAccountFrom;

  /// No description provided for @egBaroda.
  ///
  /// In en, this message translates to:
  /// **'Eg Baroda'**
  String get egBaroda;

  /// No description provided for @beneficiaryAccountName.
  ///
  /// In en, this message translates to:
  /// **'Beneficiary Account Name'**
  String get beneficiaryAccountName;

  /// No description provided for @enterBeneficiaryAccountNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter Beneficiary Account Number'**
  String get enterBeneficiaryAccountNumber;

  /// No description provided for @selectDebitAccount.
  ///
  /// In en, this message translates to:
  /// **'Select debit account'**
  String get selectDebitAccount;

  /// No description provided for @addToFavourite.
  ///
  /// In en, this message translates to:
  /// **'Add to favourite'**
  String get addToFavourite;

  /// No description provided for @sps.
  ///
  /// In en, this message translates to:
  /// **'SPS'**
  String get sps;

  /// No description provided for @transfer.
  ///
  /// In en, this message translates to:
  /// **'TRANSFER'**
  String get transfer;

  /// No description provided for @selectProvidedBank.
  ///
  /// In en, this message translates to:
  /// **'Select provided bank'**
  String get selectProvidedBank;

  /// No description provided for @accountFrom.
  ///
  /// In en, this message translates to:
  /// **'Account from'**
  String get accountFrom;

  /// No description provided for @accountTo.
  ///
  /// In en, this message translates to:
  /// **'Account to'**
  String get accountTo;

  /// No description provided for @ownTransfer.
  ///
  /// In en, this message translates to:
  /// **'Own transfer'**
  String get ownTransfer;

  /// No description provided for @recipientMobileNo.
  ///
  /// In en, this message translates to:
  /// **'Recipient Mobile No'**
  String get recipientMobileNo;

  /// No description provided for @searchCountry.
  ///
  /// In en, this message translates to:
  /// **'Search Country'**
  String get searchCountry;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @pleaseConfirmYouAreMakingRemittanceTransfer.
  ///
  /// In en, this message translates to:
  /// **'Please confirm you are making Remittance Transfer'**
  String get pleaseConfirmYouAreMakingRemittanceTransfer;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'CONFIRM'**
  String get confirm;

  /// No description provided for @confirmTransfer.
  ///
  /// In en, this message translates to:
  /// **'CONFIRM TRANSFER'**
  String get confirmTransfer;

  /// No description provided for @accountNumber.
  ///
  /// In en, this message translates to:
  /// **'Account Number'**
  String get accountNumber;

  /// No description provided for @myNumber.
  ///
  /// In en, this message translates to:
  /// **'My number'**
  String get myNumber;

  /// No description provided for @mobileMoney.
  ///
  /// In en, this message translates to:
  /// **'Mobile money'**
  String get mobileMoney;

  /// No description provided for @selectNetwork.
  ///
  /// In en, this message translates to:
  /// **'Select Network'**
  String get selectNetwork;

  /// No description provided for @selectMno.
  ///
  /// In en, this message translates to:
  /// **'Select MNO'**
  String get selectMno;

  /// No description provided for @otherPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Other phone number'**
  String get otherPhoneNumber;

  /// No description provided for @selectAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Select an account'**
  String get selectAnAccount;

  /// No description provided for @beneficiaryName.
  ///
  /// In en, this message translates to:
  /// **'Beneficiary Name'**
  String get beneficiaryName;

  /// No description provided for @otherAccounts.
  ///
  /// In en, this message translates to:
  /// **'Other accounts'**
  String get otherAccounts;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGallery;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @profileInformation.
  ///
  /// In en, this message translates to:
  /// **'Profile information'**
  String get profileInformation;

  /// No description provided for @takeAPhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get takeAPhoto;

  /// No description provided for @profileChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile changed successfully'**
  String get profileChangedSuccessfully;

  /// No description provided for @pleaseSelectAnImage.
  ///
  /// In en, this message translates to:
  /// **'Please select an image'**
  String get pleaseSelectAnImage;

  /// No description provided for @yourProfileDetailsHaveBeenUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Your profile details have been updated successfully.'**
  String get yourProfileDetailsHaveBeenUpdatedSuccessfully;

  /// No description provided for @securityAlert.
  ///
  /// In en, this message translates to:
  /// **'Security Alert'**
  String get securityAlert;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'EXIT'**
  String get exit;

  /// No description provided for @thisDeviceAppearsToBeRootedOrJailbrokennn.
  ///
  /// In en, this message translates to:
  /// **'This device appears to be rooted or jailbroken.\\n\\n'**
  String get thisDeviceAppearsToBeRootedOrJailbrokennn;

  /// No description provided for @viewStatement.
  ///
  /// In en, this message translates to:
  /// **'View Statement'**
  String get viewStatement;

  /// No description provided for @checkBalance.
  ///
  /// In en, this message translates to:
  /// **'Check Balance'**
  String get checkBalance;

  /// No description provided for @ibanCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'IBAN copied to clipboard'**
  String get ibanCopiedToClipboard;

  /// No description provided for @availableBalance.
  ///
  /// In en, this message translates to:
  /// **'Available Balance'**
  String get availableBalance;

  /// No description provided for @myAccounts.
  ///
  /// In en, this message translates to:
  /// **'My Accounts'**
  String get myAccounts;

  /// No description provided for @walletAccounts.
  ///
  /// In en, this message translates to:
  /// **'Wallet Accounts'**
  String get walletAccounts;

  /// No description provided for @normalAccounts.
  ///
  /// In en, this message translates to:
  /// **'Normal Accounts'**
  String get normalAccounts;

  /// No description provided for @callbackRequest.
  ///
  /// In en, this message translates to:
  /// **'Callback request'**
  String get callbackRequest;

  /// No description provided for @moreServices.
  ///
  /// In en, this message translates to:
  /// **'More Services'**
  String get moreServices;

  /// No description provided for @userInformationIsNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'User information is not available'**
  String get userInformationIsNotAvailable;

  /// No description provided for @confirmTheDateForCallback.
  ///
  /// In en, this message translates to:
  /// **'Confirm the date for callback'**
  String get confirmTheDateForCallback;

  /// No description provided for @scanFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Scan From Gallery'**
  String get scanFromGallery;

  /// No description provided for @noPermission.
  ///
  /// In en, this message translates to:
  /// **'No Permission'**
  String get noPermission;

  /// No description provided for @scanAQrCode.
  ///
  /// In en, this message translates to:
  /// **'Scan a QR Code'**
  String get scanAQrCode;

  /// No description provided for @scanNow.
  ///
  /// In en, this message translates to:
  /// **'Scan Now'**
  String get scanNow;

  /// No description provided for @noQrCodeFoundInThisImage.
  ///
  /// In en, this message translates to:
  /// **'No QR code found in this image'**
  String get noQrCodeFoundInThisImage;

  /// No description provided for @qrCodeImageSavedToGallerySuccessfully.
  ///
  /// In en, this message translates to:
  /// **'QR Code Image Saved to gallery successfully'**
  String get qrCodeImageSavedToGallerySuccessfully;

  /// No description provided for @selectAnAccountToGenerateQr.
  ///
  /// In en, this message translates to:
  /// **'Select an account to generate QR'**
  String get selectAnAccountToGenerateQr;

  /// No description provided for @myQrCode.
  ///
  /// In en, this message translates to:
  /// **'My QR Code'**
  String get myQrCode;

  /// No description provided for @scanMyQrCodeForPayments.
  ///
  /// In en, this message translates to:
  /// **'Scan my QR code for payments'**
  String get scanMyQrCodeForPayments;

  /// No description provided for @selectYourAccountToViewQr.
  ///
  /// In en, this message translates to:
  /// **'Select your account to view QR'**
  String get selectYourAccountToViewQr;

  /// No description provided for @merchantName.
  ///
  /// In en, this message translates to:
  /// **'Merchant Name:'**
  String get merchantName;

  /// No description provided for @merchantDetails.
  ///
  /// In en, this message translates to:
  /// **'Merchant details'**
  String get merchantDetails;

  /// No description provided for @marchantId.
  ///
  /// In en, this message translates to:
  /// **'Marchant ID:'**
  String get marchantId;

  /// No description provided for @payUsingQrCode.
  ///
  /// In en, this message translates to:
  /// **'Pay using QR code'**
  String get payUsingQrCode;

  /// No description provided for @iban.
  ///
  /// In en, this message translates to:
  /// **'IBAN:'**
  String get iban;

  /// No description provided for @receiverName.
  ///
  /// In en, this message translates to:
  /// **'Receiver Name:'**
  String get receiverName;

  /// No description provided for @beneficiaryDetails.
  ///
  /// In en, this message translates to:
  /// **'Beneficiary Details'**
  String get beneficiaryDetails;

  /// No description provided for @termDeposit.
  ///
  /// In en, this message translates to:
  /// **'Term Deposit'**
  String get termDeposit;

  /// No description provided for @forTermDepositPleaseCreateOne.
  ///
  /// In en, this message translates to:
  /// **'For term deposit please create one.'**
  String get forTermDepositPleaseCreateOne;

  /// No description provided for @oopsSorryCurrentlyYouDontHaveAnyRecords.
  ///
  /// In en, this message translates to:
  /// **'Oops! Sorry currently you don\'t have any records'**
  String get oopsSorryCurrentlyYouDontHaveAnyRecords;

  /// No description provided for @transferDone.
  ///
  /// In en, this message translates to:
  /// **'Transfer Done'**
  String get transferDone;

  /// No description provided for @totalTransaction.
  ///
  /// In en, this message translates to:
  /// **'Total Transaction'**
  String get totalTransaction;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @egMonthly.
  ///
  /// In en, this message translates to:
  /// **'Eg Monthly'**
  String get egMonthly;

  /// No description provided for @acceptTermsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Accept Terms and Conditions'**
  String get acceptTermsAndConditions;

  /// No description provided for @selectMaturityTenure.
  ///
  /// In en, this message translates to:
  /// **'Select maturity tenure'**
  String get selectMaturityTenure;

  /// No description provided for @payoutAccount.
  ///
  /// In en, this message translates to:
  /// **'Payout Account'**
  String get payoutAccount;

  /// No description provided for @termDepositType.
  ///
  /// In en, this message translates to:
  /// **'Term deposit type'**
  String get termDepositType;

  /// No description provided for @createTermDeposit.
  ///
  /// In en, this message translates to:
  /// **'Create term Deposit'**
  String get createTermDeposit;

  /// No description provided for @maturityInstructions.
  ///
  /// In en, this message translates to:
  /// **'Maturity Instructions'**
  String get maturityInstructions;

  /// No description provided for @selectBiller.
  ///
  /// In en, this message translates to:
  /// **'Select biller'**
  String get selectBiller;

  /// No description provided for @howMuchWouldYouLikeToPay.
  ///
  /// In en, this message translates to:
  /// **'How much would you like to pay?'**
  String get howMuchWouldYouLikeToPay;

  /// No description provided for @enterTheNameYouRegisteredWithenterYourCompanyName.
  ///
  /// In en, this message translates to:
  /// **'Enter the name you registered with/enter your company name'**
  String get enterTheNameYouRegisteredWithenterYourCompanyName;

  /// No description provided for @narration.
  ///
  /// In en, this message translates to:
  /// **'Narration'**
  String get narration;

  /// No description provided for @selectGovernmentPayment.
  ///
  /// In en, this message translates to:
  /// **'Select Government Payment'**
  String get selectGovernmentPayment;

  /// No description provided for @governmentPayment.
  ///
  /// In en, this message translates to:
  /// **'Government payment'**
  String get governmentPayment;

  /// No description provided for @noBillersFound.
  ///
  /// In en, this message translates to:
  /// **'No billers found.'**
  String get noBillersFound;

  /// No description provided for @payWater.
  ///
  /// In en, this message translates to:
  /// **'Pay water'**
  String get payWater;

  /// No description provided for @selectYourWaterProviderCompany.
  ///
  /// In en, this message translates to:
  /// **'Select your water provider company'**
  String get selectYourWaterProviderCompany;

  /// No description provided for @selectInternetProviderCompany.
  ///
  /// In en, this message translates to:
  /// **'Select internet provider company'**
  String get selectInternetProviderCompany;

  /// No description provided for @enterYourRegisteredInternetId.
  ///
  /// In en, this message translates to:
  /// **'Enter your registered Internet ID'**
  String get enterYourRegisteredInternetId;

  /// No description provided for @payInternet.
  ///
  /// In en, this message translates to:
  /// **'Pay Internet'**
  String get payInternet;

  /// No description provided for @payTv.
  ///
  /// In en, this message translates to:
  /// **'Pay TV'**
  String get payTv;

  /// No description provided for @enterYourReceiverNumberForYourTv.
  ///
  /// In en, this message translates to:
  /// **'Enter your receiver number for your TV'**
  String get enterYourReceiverNumberForYourTv;

  /// No description provided for @selectTvYouUse.
  ///
  /// In en, this message translates to:
  /// **'Select TV you use'**
  String get selectTvYouUse;

  /// No description provided for @scheduleReminder.
  ///
  /// In en, this message translates to:
  /// **'Schedule reminder'**
  String get scheduleReminder;

  /// No description provided for @selectElectricityCompany.
  ///
  /// In en, this message translates to:
  /// **'Select electricity company'**
  String get selectElectricityCompany;

  /// No description provided for @startsOn.
  ///
  /// In en, this message translates to:
  /// **'Starts on'**
  String get startsOn;

  /// No description provided for @payElectricity.
  ///
  /// In en, this message translates to:
  /// **'Pay electricity'**
  String get payElectricity;

  /// No description provided for @repeatOn.
  ///
  /// In en, this message translates to:
  /// **'Repeat on'**
  String get repeatOn;

  /// No description provided for @noFavouritesFound.
  ///
  /// In en, this message translates to:
  /// **'No favourites found.'**
  String get noFavouritesFound;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @paybill.
  ///
  /// In en, this message translates to:
  /// **'Paybill'**
  String get paybill;

  /// No description provided for @scanQrCode.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get scanQrCode;

  /// No description provided for @merchantNameTasimaKumasi.
  ///
  /// In en, this message translates to:
  /// **'Merchant Name: Tasima Kumasi'**
  String get merchantNameTasimaKumasi;

  /// No description provided for @actualBalancenusd800000.
  ///
  /// In en, this message translates to:
  /// **'Actual Balance\\nUSD 8,000.00'**
  String get actualBalancenusd800000;

  /// No description provided for @ac12346789.
  ///
  /// In en, this message translates to:
  /// **'A/C #1234******6789'**
  String get ac12346789;

  /// No description provided for @availableBalancenusd700000.
  ///
  /// In en, this message translates to:
  /// **'Available Balance\\nUSD 7,000.00'**
  String get availableBalancenusd700000;

  /// No description provided for @currentAccountAc12346789.
  ///
  /// In en, this message translates to:
  /// **'Current Account - A/C #1234******6789'**
  String get currentAccountAc12346789;

  /// No description provided for @merchantId2345678.
  ///
  /// In en, this message translates to:
  /// **'Merchant ID: 2345678'**
  String get merchantId2345678;

  /// No description provided for @aj.
  ///
  /// In en, this message translates to:
  /// **'AJ'**
  String get aj;

  /// No description provided for @setAndAnswerTheFollowingQuestions.
  ///
  /// In en, this message translates to:
  /// **'Set and answer the following questions'**
  String get setAndAnswerTheFollowingQuestions;

  /// No description provided for @q2WhatsYourFavouriteCar.
  ///
  /// In en, this message translates to:
  /// **'Q2. Whats your favourite car ?'**
  String get q2WhatsYourFavouriteCar;

  /// No description provided for @giveYourAnswerHere.
  ///
  /// In en, this message translates to:
  /// **'Give your answer here'**
  String get giveYourAnswerHere;

  /// No description provided for @q1WhatsYourPetName.
  ///
  /// In en, this message translates to:
  /// **'Q1. Whats your pet name ?'**
  String get q1WhatsYourPetName;

  /// No description provided for @setSecurityQuestion.
  ///
  /// In en, this message translates to:
  /// **'Set security question'**
  String get setSecurityQuestion;

  /// No description provided for @securityQuestionSetSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Security question set successfully'**
  String get securityQuestionSetSuccessfully;

  /// No description provided for @q3WhatsTheNameOfYourBestFriend.
  ///
  /// In en, this message translates to:
  /// **'Q3. Whats the name of your best friend ?'**
  String get q3WhatsTheNameOfYourBestFriend;

  /// No description provided for @youHaveSuccessfullySetYourSecurityQuestionsPleasePressContinueButtonToProceed.
  ///
  /// In en, this message translates to:
  /// **'You have successfully set your security questions. Please press continue button to proceed ..'**
  String get youHaveSuccessfullySetYourSecurityQuestionsPleasePressContinueButtonToProceed;

  /// No description provided for @selectAQuestionHere.
  ///
  /// In en, this message translates to:
  /// **'Select a question here'**
  String get selectAQuestionHere;

  /// No description provided for @pleaseProvideTheFollowingSecurityQuestionsToFinaliseActivation.
  ///
  /// In en, this message translates to:
  /// **'Please provide the following security questions to finalise activation.'**
  String get pleaseProvideTheFollowingSecurityQuestionsToFinaliseActivation;

  /// No description provided for @idNumberPassportNumber.
  ///
  /// In en, this message translates to:
  /// **'ID Number / Passport Number'**
  String get idNumberPassportNumber;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'REGISTER'**
  String get register;

  /// No description provided for @selectDocumentType.
  ///
  /// In en, this message translates to:
  /// **'Select Document Type'**
  String get selectDocumentType;

  /// No description provided for @accountFoundSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Account found successfully'**
  String get accountFoundSuccessfully;

  /// No description provided for @weFoundTheAccountWithTheDetailsYouProvidedToUsPleaseClickActivateButtonToContinue.
  ///
  /// In en, this message translates to:
  /// **'We found the account with the details you provided to us. Please click activate button to continue'**
  String get weFoundTheAccountWithTheDetailsYouProvidedToUsPleaseClickActivateButtonToContinue;

  /// No description provided for @pleaseProvideTheFollowingDetails.
  ///
  /// In en, this message translates to:
  /// **'Please provide the following details.'**
  String get pleaseProvideTheFollowingDetails;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// No description provided for @createYourNewPin.
  ///
  /// In en, this message translates to:
  /// **'Create your New PIN'**
  String get createYourNewPin;

  /// No description provided for @pleaseEnterA6DigitPin.
  ///
  /// In en, this message translates to:
  /// **'Please enter a 6-digit PIN'**
  String get pleaseEnterA6DigitPin;

  /// No description provided for @thisKeepsYourAccountSecure.
  ///
  /// In en, this message translates to:
  /// **'This keeps your account secure'**
  String get thisKeepsYourAccountSecure;

  /// No description provided for @setYourPersonal6DigitCodeItWillBeUsedForSecureAndLastSignin.
  ///
  /// In en, this message translates to:
  /// **'Set your personal 6-digit code, it will be used for secure and last sign-in.'**
  String get setYourPersonal6DigitCodeItWillBeUsedForSecureAndLastSignin;

  /// No description provided for @eg.
  ///
  /// In en, this message translates to:
  /// **'Eg. *****'**
  String get eg;

  /// No description provided for @activationCode.
  ///
  /// In en, this message translates to:
  /// **'Activation Code'**
  String get activationCode;

  /// No description provided for @activateMobileBanking.
  ///
  /// In en, this message translates to:
  /// **'Activate Mobile Banking'**
  String get activateMobileBanking;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'ACCEPT'**
  String get accept;

  /// No description provided for @termConditions.
  ///
  /// In en, this message translates to:
  /// **'Term & conditions'**
  String get termConditions;

  /// No description provided for @lastUpdatedJan30Th2024.
  ///
  /// In en, this message translates to:
  /// **'Last updated Jan 30TH 2024'**
  String get lastUpdatedJan30Th2024;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'DECLINE'**
  String get decline;

  /// No description provided for @confirmYourNewPin.
  ///
  /// In en, this message translates to:
  /// **'Confirm your New PIN'**
  String get confirmYourNewPin;

  /// No description provided for @pleaseEnterA6DigitPinThatMatchesTheOtherToCompleteRegistration.
  ///
  /// In en, this message translates to:
  /// **'Please enter a 6-digit PIN that matches the other to complete registration'**
  String get pleaseEnterA6DigitPinThatMatchesTheOtherToCompleteRegistration;

  /// No description provided for @areYouRegisteredWithOurMobileBanking.
  ///
  /// In en, this message translates to:
  /// **'Are you registered with our mobile banking?'**
  String get areYouRegisteredWithOurMobileBanking;

  /// No description provided for @pleasePressTheYesButtonToContinueOrPressNoButtonToRegisterToOurMobileBanking.
  ///
  /// In en, this message translates to:
  /// **'Please press the (YES) button to continue or press (NO) button to register to our mobile banking.'**
  String get pleasePressTheYesButtonToContinueOrPressNoButtonToRegisterToOurMobileBanking;

  /// No description provided for @toHaveABetterExperienceWithOurProductngivePermissionToTheFollowing.
  ///
  /// In en, this message translates to:
  /// **'To have a better experience with our product\\nGive permission to the following'**
  String get toHaveABetterExperienceWithOurProductngivePermissionToTheFollowing;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'GET STARTED'**
  String get getStarted;

  /// No description provided for @grantPermission.
  ///
  /// In en, this message translates to:
  /// **'Grant Permission'**
  String get grantPermission;

  /// No description provided for @callCenter.
  ///
  /// In en, this message translates to:
  /// **'Call Center'**
  String get callCenter;

  /// No description provided for @bankDirection.
  ///
  /// In en, this message translates to:
  /// **'Bank Direction'**
  String get bankDirection;

  /// No description provided for @weAreHereTonsupportYou.
  ///
  /// In en, this message translates to:
  /// **'We Are Here to\\nSupport You'**
  String get weAreHereTonsupportYou;

  /// No description provided for @youWillFindBusinessAccountProductsThatAreTailoredForBusinessThatFollowAccountLaws.
  ///
  /// In en, this message translates to:
  /// **'You will find Business Account products that are tailored for Business that follow account laws'**
  String get youWillFindBusinessAccountProductsThatAreTailoredForBusinessThatFollowAccountLaws;

  /// No description provided for @youWillFindInvestmentAccountProductsThatAreTailoredForBusinessThatFollowAccountLaws.
  ///
  /// In en, this message translates to:
  /// **'You will find Investment Account products that are tailored for Business that follow account laws'**
  String get youWillFindInvestmentAccountProductsThatAreTailoredForBusinessThatFollowAccountLaws;

  /// No description provided for @loremIpsumDolorSitAmetConsecteturAdipiscingElitAeneanRhoncusPlaceratEratFusceMalesuadaVelitEtEfficiturConsequatNisiNislPharetraNequeUtTristiqueLigulaTurpisInNisiLoremIpsumDolorSitAmetConsecteturAdipiscingElit.
  ///
  /// In en, this message translates to:
  /// **'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean rhoncus placerat erat. Fusce malesuada, velit et efficitur consequat, nisi nisl pharetra neque, ut tristique ligula turpis in nisi. Lorem ipsum dolor sit amet, consectetur adipiscing elit.'**
  String get loremIpsumDolorSitAmetConsecteturAdipiscingElitAeneanRhoncusPlaceratEratFusceMalesuadaVelitEtEfficiturConsequatNisiNislPharetraNequeUtTristiqueLigulaTurpisInNisiLoremIpsumDolorSitAmetConsecteturAdipiscingElit;

  /// No description provided for @accountOpening.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT OPENING'**
  String get accountOpening;

  /// No description provided for @businessAccount.
  ///
  /// In en, this message translates to:
  /// **'Business Account'**
  String get businessAccount;

  /// No description provided for @islamicAccounts.
  ///
  /// In en, this message translates to:
  /// **'Islamic Accounts'**
  String get islamicAccounts;

  /// No description provided for @studentsAccounts.
  ///
  /// In en, this message translates to:
  /// **'Students Accounts'**
  String get studentsAccounts;

  /// No description provided for @youWillFindStudentsAccountsProductsThatAreTailoredForBusinessThatFollowAccountLaws.
  ///
  /// In en, this message translates to:
  /// **'You will find Students Accounts products that are tailored for Business that follow account laws'**
  String get youWillFindStudentsAccountsProductsThatAreTailoredForBusinessThatFollowAccountLaws;

  /// No description provided for @youWillFindIslamicProductsThatAreTailoredForMuslimsThatFollowShariaLaws.
  ///
  /// In en, this message translates to:
  /// **'You will find Islamic products that are tailored for Muslims that follow Sharia laws'**
  String get youWillFindIslamicProductsThatAreTailoredForMuslimsThatFollowShariaLaws;

  /// No description provided for @investmentAccount.
  ///
  /// In en, this message translates to:
  /// **'Investment Account'**
  String get investmentAccount;

  /// No description provided for @yourPersonalBank.
  ///
  /// In en, this message translates to:
  /// **'Your Personal Bank'**
  String get yourPersonalBank;

  /// No description provided for @enjoyYourPersonalBankAccountYourPhoneIsYourBank.
  ///
  /// In en, this message translates to:
  /// **'Enjoy your personal bank account, your phone is your bank.'**
  String get enjoyYourPersonalBankAccountYourPhoneIsYourBank;

  /// No description provided for @takeASelfieOfYourself.
  ///
  /// In en, this message translates to:
  /// **'Take a selfie of yourself'**
  String get takeASelfieOfYourself;

  /// No description provided for @takeASelfieAndWeWillDoAFaceMatchWithThePhotoOnYourNationalId.
  ///
  /// In en, this message translates to:
  /// **'Take a selfie and we will do a face match with the photo on your National ID.'**
  String get takeASelfieAndWeWillDoAFaceMatchWithThePhotoOnYourNationalId;

  /// No description provided for @takeSelfie.
  ///
  /// In en, this message translates to:
  /// **'Take selfie'**
  String get takeSelfie;

  /// No description provided for @takeAPhotoOfTheFrontSideAndBackSideOfYourIdAndWeWillDoAFaceMatchOfYourPhotoAndId.
  ///
  /// In en, this message translates to:
  /// **'Take a photo of the front side and back side of your ID and we will do a face match of your photo and ID.'**
  String get takeAPhotoOfTheFrontSideAndBackSideOfYourIdAndWeWillDoAFaceMatchOfYourPhotoAndId;

  /// No description provided for @takeAPhotoOfYourId.
  ///
  /// In en, this message translates to:
  /// **'Take a photo of your ID'**
  String get takeAPhotoOfYourId;

  /// No description provided for @scanIdentification.
  ///
  /// In en, this message translates to:
  /// **'Scan identification'**
  String get scanIdentification;

  /// No description provided for @verifyIdentity.
  ///
  /// In en, this message translates to:
  /// **'Verify identity'**
  String get verifyIdentity;

  /// No description provided for @idNumber.
  ///
  /// In en, this message translates to:
  /// **'ID Number'**
  String get idNumber;

  /// No description provided for @provideYourId.
  ///
  /// In en, this message translates to:
  /// **'Provide your ID'**
  String get provideYourId;

  /// No description provided for @tapToSeeNationalIdnfrontBack.
  ///
  /// In en, this message translates to:
  /// **'Tap to see National ID\\n(Front & Back)'**
  String get tapToSeeNationalIdnfrontBack;

  /// No description provided for @tapToTakeASelfie.
  ///
  /// In en, this message translates to:
  /// **'Tap to take a selfie'**
  String get tapToTakeASelfie;

  /// No description provided for @youWillHaveToCaptureYourIdAndTakeASelfieOfYourselfForFaceMatching.
  ///
  /// In en, this message translates to:
  /// **'You will have to capture your ID and take a selfie of yourself for face matching.'**
  String get youWillHaveToCaptureYourIdAndTakeASelfieOfYourselfForFaceMatching;

  /// No description provided for @yourAccountHasBeenSetUpPleaseWaitAsWeShareYourAccountDetailsThankYou.
  ///
  /// In en, this message translates to:
  /// **'Your account has been set up. Please wait as we share your account details. Thank you.'**
  String get yourAccountHasBeenSetUpPleaseWaitAsWeShareYourAccountDetailsThankYou;

  /// No description provided for @retakeSelfie.
  ///
  /// In en, this message translates to:
  /// **'RE-TAKE SELFIE'**
  String get retakeSelfie;

  /// No description provided for @accountSuccessfullyRegistered.
  ///
  /// In en, this message translates to:
  /// **'Account successfully registered'**
  String get accountSuccessfullyRegistered;

  /// No description provided for @youWillHaveToCaptureYourIdAndTakeASelfieOfYourselfForMatching.
  ///
  /// In en, this message translates to:
  /// **'You will have to capture your ID and take a selfie of yourself for matching.'**
  String get youWillHaveToCaptureYourIdAndTakeASelfieOfYourselfForMatching;

  /// No description provided for @scanIdentificationCard.
  ///
  /// In en, this message translates to:
  /// **'SCAN IDENTIFICATION CARD'**
  String get scanIdentificationCard;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'GOT IT'**
  String get gotIt;

  /// No description provided for @placeTheCameraToFitInTheFrameAndScanIdToGetDetailsOfTheIdentificationCard.
  ///
  /// In en, this message translates to:
  /// **'Place the camera to fit in the frame and scan ID to get details of the Identification card'**
  String get placeTheCameraToFitInTheFrameAndScanIdToGetDetailsOfTheIdentificationCard;

  /// No description provided for @previewIdCard.
  ///
  /// In en, this message translates to:
  /// **'Preview ID Card'**
  String get previewIdCard;

  /// No description provided for @iAgreeToTheTermsConditions.
  ///
  /// In en, this message translates to:
  /// **'I agree to the terms & conditions:'**
  String get iAgreeToTheTermsConditions;

  /// No description provided for @openAccount.
  ///
  /// In en, this message translates to:
  /// **'Open Account'**
  String get openAccount;

  /// No description provided for @eg4DigitPin.
  ///
  /// In en, this message translates to:
  /// **'Eg 4-digit PIN'**
  String get eg4DigitPin;

  /// No description provided for @usd.
  ///
  /// In en, this message translates to:
  /// **'USD'**
  String get usd;

  /// No description provided for @oldPin.
  ///
  /// In en, this message translates to:
  /// **'Old PIN'**
  String get oldPin;

  /// No description provided for @statementType.
  ///
  /// In en, this message translates to:
  /// **'Statement type'**
  String get statementType;

  /// No description provided for @confirmPin.
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get confirmPin;

  /// No description provided for @egMinistatement.
  ///
  /// In en, this message translates to:
  /// **'Eg Mini-statement'**
  String get egMinistatement;

  /// No description provided for @blockreportStolenCard.
  ///
  /// In en, this message translates to:
  /// **'Block/Report stolen card'**
  String get blockreportStolenCard;

  /// No description provided for @cvcn256.
  ///
  /// In en, this message translates to:
  /// **'CVC\\n256'**
  String get cvcn256;

  /// No description provided for @validDaten0626.
  ///
  /// In en, this message translates to:
  /// **'Valid Date\\n06/26'**
  String get validDaten0626;

  /// No description provided for @egLostCard.
  ///
  /// In en, this message translates to:
  /// **'Eg Lost Card'**
  String get egLostCard;

  /// No description provided for @virtualCard.
  ///
  /// In en, this message translates to:
  /// **'Virtual Card'**
  String get virtualCard;

  /// No description provided for @masterWallet.
  ///
  /// In en, this message translates to:
  /// **'Master Wallet'**
  String get masterWallet;

  /// No description provided for @reason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reason;

  /// No description provided for @newPin.
  ///
  /// In en, this message translates to:
  /// **'New PIN'**
  String get newPin;

  /// No description provided for @miniFullStatement.
  ///
  /// In en, this message translates to:
  /// **'Mini / Full statement'**
  String get miniFullStatement;

  /// No description provided for @estimatedBalance.
  ///
  /// In en, this message translates to:
  /// **'Estimated Balance'**
  String get estimatedBalance;

  /// No description provided for @pleaseConfirmYourNewPinToContinue.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your new PIN to continue.'**
  String get pleaseConfirmYourNewPinToContinue;

  /// No description provided for @forgotPin.
  ///
  /// In en, this message translates to:
  /// **'Forgot PIN?'**
  String get forgotPin;

  /// No description provided for @pinChange.
  ///
  /// In en, this message translates to:
  /// **'PIN CHANGE'**
  String get pinChange;

  /// No description provided for @confirmYourPin.
  ///
  /// In en, this message translates to:
  /// **'Confirm Your PIN'**
  String get confirmYourPin;

  /// No description provided for @pleaseEnterYourNewPinToContinue.
  ///
  /// In en, this message translates to:
  /// **'Please enter your new PIN to continue.'**
  String get pleaseEnterYourNewPinToContinue;

  /// No description provided for @newPinCannotBeTheSameAsTheOldPin.
  ///
  /// In en, this message translates to:
  /// **'New PIN cannot be the same as the old PIN.'**
  String get newPinCannotBeTheSameAsTheOldPin;

  /// No description provided for @setNewPin.
  ///
  /// In en, this message translates to:
  /// **'Set New PIN'**
  String get setNewPin;

  /// No description provided for @enterOldPin.
  ///
  /// In en, this message translates to:
  /// **'Enter Old PIN'**
  String get enterOldPin;

  /// No description provided for @oldPinChange.
  ///
  /// In en, this message translates to:
  /// **'OLD PIN CHANGE'**
  String get oldPinChange;

  /// No description provided for @pleaseEnterYourOldPinToContinue.
  ///
  /// In en, this message translates to:
  /// **'Please enter your old PIN to continue.'**
  String get pleaseEnterYourOldPinToContinue;

  /// No description provided for @accountLookup.
  ///
  /// In en, this message translates to:
  /// **'Account lookup'**
  String get accountLookup;

  /// No description provided for @answerTheFollowingQuestionsWithTheAnswersYouGaveDuringRegistration.
  ///
  /// In en, this message translates to:
  /// **'Answer the following questions with the answers you gave during registration'**
  String get answerTheFollowingQuestionsWithTheAnswersYouGaveDuringRegistration;

  /// No description provided for @pleaseProvideAnswersToTheFollowingQuestions.
  ///
  /// In en, this message translates to:
  /// **'Please provide answers to the following questions.'**
  String get pleaseProvideAnswersToTheFollowingQuestions;

  /// No description provided for @weAreVerifyingYourAnswerNPleaseWait.
  ///
  /// In en, this message translates to:
  /// **'We are verifying your answer \\n Please Wait...'**
  String get weAreVerifyingYourAnswerNPleaseWait;

  /// No description provided for @securityQuestion.
  ///
  /// In en, this message translates to:
  /// **'Security question'**
  String get securityQuestion;

  /// No description provided for @youCanNowProceedChangeYourPinDetails.
  ///
  /// In en, this message translates to:
  /// **'You can now proceed change your PIN details'**
  String get youCanNowProceedChangeYourPinDetails;

  /// No description provided for @verificationSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Verification successfully'**
  String get verificationSuccessfully;

  /// No description provided for @ifYouForgotYourPinSelectOneOfTheMethodsToUseToResetYourMobileBankingPin.
  ///
  /// In en, this message translates to:
  /// **'If you forgot your pin select one of the methods to use to Reset your mobile banking PIN.'**
  String get ifYouForgotYourPinSelectOneOfTheMethodsToUseToResetYourMobileBankingPin;

  /// No description provided for @pleaseEnterA6DigitPinThatMatchesTheOtherToCompleteChange.
  ///
  /// In en, this message translates to:
  /// **'Please enter a 6-digit PIN that matches the other to complete change'**
  String get pleaseEnterA6DigitPinThatMatchesTheOtherToCompleteChange;

  /// No description provided for @standingOrder.
  ///
  /// In en, this message translates to:
  /// **'Standing Order'**
  String get standingOrder;

  /// No description provided for @recurringStandingOrder.
  ///
  /// In en, this message translates to:
  /// **'RECURRING STANDING ORDER'**
  String get recurringStandingOrder;

  /// No description provided for @hereAreYourCurrentStandingOrders.
  ///
  /// In en, this message translates to:
  /// **'Here are your current standing orders'**
  String get hereAreYourCurrentStandingOrders;

  /// No description provided for @newStandingOrder.
  ///
  /// In en, this message translates to:
  /// **'NEW STANDING ORDER'**
  String get newStandingOrder;

  /// No description provided for @forStandingOrderPleaseCreateOne.
  ///
  /// In en, this message translates to:
  /// **'For standing order please create one.'**
  String get forStandingOrderPleaseCreateOne;

  /// No description provided for @createNewStandingOrder.
  ///
  /// In en, this message translates to:
  /// **'Create new standing order'**
  String get createNewStandingOrder;

  /// No description provided for @beneficiaryAccountNumberiban.
  ///
  /// In en, this message translates to:
  /// **'Beneficiary Account Number/IBAN'**
  String get beneficiaryAccountNumberiban;

  /// No description provided for @frequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get frequency;

  /// No description provided for @paymentFrequency.
  ///
  /// In en, this message translates to:
  /// **'PAYMENT FREQUENCY'**
  String get paymentFrequency;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// No description provided for @request.
  ///
  /// In en, this message translates to:
  /// **'Request'**
  String get request;

  /// No description provided for @approveFundsYouHaveBeenRequestedToSendForAmount100000Usd.
  ///
  /// In en, this message translates to:
  /// **'Approve funds you have been requested to send for amount 1000.00 USD'**
  String get approveFundsYouHaveBeenRequestedToSendForAmount100000Usd;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @noRequestForFundsAtTheMoment.
  ///
  /// In en, this message translates to:
  /// **'No request for funds at the moment'**
  String get noRequestForFundsAtTheMoment;

  /// No description provided for @approveFundsRequested.
  ///
  /// In en, this message translates to:
  /// **'Approve funds requested'**
  String get approveFundsRequested;

  /// No description provided for @notificationDismissed.
  ///
  /// In en, this message translates to:
  /// **'Notification dismissed'**
  String get notificationDismissed;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'APPROVE'**
  String get approve;

  /// No description provided for @alerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alerts;

  /// No description provided for @youCanNowProceedLoginToYourAccount.
  ///
  /// In en, this message translates to:
  /// **'You can now proceed login to your account'**
  String get youCanNowProceedLoginToYourAccount;

  /// No description provided for @pleaseSelectASecurityQuestion.
  ///
  /// In en, this message translates to:
  /// **'Please select a security question'**
  String get pleaseSelectASecurityQuestion;

  /// No description provided for @selectAQuestion.
  ///
  /// In en, this message translates to:
  /// **'Select a question'**
  String get selectAQuestion;

  /// No description provided for @pleaseSelectAndAnswerOneOfYourSecurityQuestions.
  ///
  /// In en, this message translates to:
  /// **'Please select and answer one of your security questions.'**
  String get pleaseSelectAndAnswerOneOfYourSecurityQuestions;

  /// No description provided for @pleaseProvideYourAnswer.
  ///
  /// In en, this message translates to:
  /// **'Please provide your answer'**
  String get pleaseProvideYourAnswer;

  /// No description provided for @loginWithFaceId.
  ///
  /// In en, this message translates to:
  /// **'Login with face ID'**
  String get loginWithFaceId;

  /// No description provided for @useBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Use Biometrics'**
  String get useBiometrics;

  /// No description provided for @loginWithFingerprint.
  ///
  /// In en, this message translates to:
  /// **'Login with fingerprint'**
  String get loginWithFingerprint;

  /// No description provided for @getDirection.
  ///
  /// In en, this message translates to:
  /// **'GET DIRECTION'**
  String get getDirection;

  /// No description provided for @dearCustomerWeHaveNoticedADeviceChangen.
  ///
  /// In en, this message translates to:
  /// **'Dear customer we have noticed a device change\\n'**
  String get dearCustomerWeHaveNoticedADeviceChangen;

  /// No description provided for @callCustomerCare.
  ///
  /// In en, this message translates to:
  /// **'CALL CUSTOMER CARE'**
  String get callCustomerCare;

  /// No description provided for @deviceChange.
  ///
  /// In en, this message translates to:
  /// **'Device Change'**
  String get deviceChange;

  /// No description provided for @okay.
  ///
  /// In en, this message translates to:
  /// **'OKAY'**
  String get okay;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// No description provided for @thisFeatureIsComingSoonNPleaseCheckBackLater.
  ///
  /// In en, this message translates to:
  /// **'This feature is coming soon. \\n Please check back later.'**
  String get thisFeatureIsComingSoonNPleaseCheckBackLater;

  /// No description provided for @pleaseCheckYourInternetConnectionAndTryRestartingTheApp.
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection and try restarting the app.'**
  String get pleaseCheckYourInternetConnectionAndTryRestartingTheApp;

  /// No description provided for @unableToConnectToInternet.
  ///
  /// In en, this message translates to:
  /// **'Unable to connect to Internet'**
  String get unableToConnectToInternet;

  /// No description provided for @resend.
  ///
  /// In en, this message translates to:
  /// **'RESEND'**
  String get resend;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'so'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'so': return AppLocalizationsSo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
