import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../utils/api-customer-loans.dart';
import '../utils/providers/provider-session.dart';
import '../utils/util-get-imei.dart';
import '../utils/util-log-service.dart';
import 'dto/loan-accounts-response.dart';
import 'dto/loan-accounts-schedule-response.dart';

class LoanScheduleScreen extends StatefulWidget {
  final String loanAccount;
  final List<LoanAccount> loanAccountsList;

  const LoanScheduleScreen({super.key, required this.loanAccountsList, required this.loanAccount});

  @override
  State<LoanScheduleScreen> createState() => _LoanScheduleScreenState();
}

class _LoanScheduleScreenState extends State<LoanScheduleScreen> {
  LoanAccount? selectedLoanAccount;
  final apiCustomerLoans = ApiCustomerLoans();
  String _deviceId = "Fetching..";
  bool isLoading = false;
  List<LoanSchedules> loanSchedulesList = [];

  @override
  void initState() {
    super.initState();
    _deviceInit();
    _setDefaultLoan();
  }

  void _deviceInit() async {
    _deviceId = await DeviceIdentifier.getDeviceIdentifier();
  }

  void _setDefaultLoan() {
    if (widget.loanAccountsList.isEmpty) {
      selectedLoanAccount = null;
      return;
    }
    selectedLoanAccount = widget.loanAccountsList.firstWhere(
          (loan) => loan.loanAccount == widget.loanAccount,
      orElse: () => widget.loanAccountsList[0],
    );
    _fetchLoansRepaymentSchedule(selectedLoanAccount!.loanAccount);
  }

  void showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 10),
        backgroundColor: color,
        action: SnackBarAction(
          label: "DISMISS",
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  Future<void> _fetchLoansRepaymentSchedule(String loanAccount) async {
    try {
      final response = await apiCustomerLoans.loanPaymentSchedule(loanAccount);
      if (response['data']['response_code'] == '00') {
        final loans = response['data']['repayment_schedule']['loanschedule'] as List<dynamic>;
        setState(() {
          loanSchedulesList = loans.map((loan) => LoanSchedules.fromJson(loan)).toList();
        });
      } else {
        showSnackBar(context, response['data']['response'] ?? 'Unknown error', Colors.orange);
      }
    } catch (error, stack) {
      LoggerService.reportUnexpectedError(error, stack);
      showSnackBar(context, 'Error Loading Loans: ${error.toString()}', Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    final index = widget.loanAccountsList.indexWhere((loan) => loan.loanAccount == selectedLoanAccount?.loanAccount);
    final amountFinanced = index != -1 ? widget.loanAccountsList[index].amountFinanced : '';
    final amountDue = index != -1 ? widget.loanAccountsList[index].amountDue : '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: BackButton(),
        title: Text('Loan schedule'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            DropdownButtonFormField<LoanAccount>(
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(18.0)),
                labelText: 'Select the loan',
              ),
              value: selectedLoanAccount,
              items: widget.loanAccountsList.map((loan) {
                return DropdownMenuItem<LoanAccount>(
                  value: loan,
                  child: Text(loan.loanAccount,
                    style: TextStyle(
                    fontSize: 12,),
                  ),
                );
              }).toList(),
              onChanged: (LoanAccount? newLoan) {
                if (newLoan == null) return;
                setState(() {
                  selectedLoanAccount = newLoan;
                  loanSchedulesList.clear();
                });
                _fetchLoansRepaymentSchedule(newLoan.loanAccount);
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Amount Disbursed', style: TextStyle(fontSize: 12, color: Colors.blue.shade900, fontWeight: FontWeight.bold)),
                Text('\$$amountFinanced', style: TextStyle(fontSize: 12, color: Colors.blue.shade900, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Outstanding', style: TextStyle(fontSize: 12, color: Colors.blue.shade900, fontWeight: FontWeight.bold)),
                Text('\$$amountDue', style: TextStyle(fontSize: 12, color: Colors.blue.shade900, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 18),
            const Divider(),
            const SizedBox(height: 16),
            Container(
              color: Colors.red.shade900,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  Expanded(child: Center(child: Text('Due Date', style: TextStyle(color: Colors.white)))),
                  Expanded(child: Center(child: Text('Outstanding', style: TextStyle(color: Colors.white)))),
                  Expanded(child: Center(child: Text('Due Amount', style: TextStyle(color: Colors.white)))),
                  Expanded(child: Center(child: Text('Paid Amount', style: TextStyle(color: Colors.white)))),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: loanSchedulesList.length,
                itemBuilder: (context, index) {
                  final row = loanSchedulesList[index];
                  final backgroundColor = index % 2 == 0 ? Colors.white : Colors.grey.shade100;
                  return Container(
                    color: backgroundColor,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(child: Center(child: Text(_formatDate(row.dueDate), style: TextStyle(fontSize: 11,)))),
                        Expanded(child: Center(child: Text('\$${row.amountOutStanding.toStringAsFixed(2)}', style: TextStyle(fontSize: 11,)))),
                        Expanded(child: Center(child: Text('\$${row.amountDue.toStringAsFixed(2)}', style: TextStyle(fontSize: 11,)))),
                        Expanded(child: Center(child: Text('\$${row.amountSettled.toStringAsFixed(2)}', style: TextStyle(fontSize: 11,)))),
                      ],
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (_) {
      return '';
    }
  }
}
