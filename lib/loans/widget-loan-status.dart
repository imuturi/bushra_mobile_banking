import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import 'dto/loan-accounts-response.dart';

class LoanDetailsWidget extends StatefulWidget {
  final String hintText;
  final List<LoanAccount> loanAccountsList;
  const LoanDetailsWidget({super.key, this.hintText = 'Select the loan', required this.loanAccountsList,});
  @override
  State<LoanDetailsWidget> createState() => _LoanDetailsWidgetState();
}

class _LoanDetailsWidgetState extends State<LoanDetailsWidget> {
  LoanAccount? selectedLoan;

  @override
  void initState() {
    super.initState();
  }

  String parseDateTimeStringToDate(String? input) {
    if (input == null || input.isEmpty) {
      return input ?? '0000-00-00';
    }
    try {
      final parsed = DateTime.parse(input);
      final String date = "${parsed.year.toString().padLeft(4, '0')}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}";
      return date;
    } catch (e) {
      return input;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<LoanAccount>(
            dropdownColor: Colors.white,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              labelText: widget.hintText,
              floatingLabelBehavior: FloatingLabelBehavior.auto,
              labelStyle: TextStyle(
                fontSize: 12.0,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.normal,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(color: Colors.black, width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(color: Colors.black, width: 1.0),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            value: selectedLoan,
            items: [
               DropdownMenuItem<LoanAccount>(
                value: null,
                child: Text(
                  AppLocalizations.of(context)!.selectALoan,
                  style: TextStyle(
                    color: Colors.black,
                    fontStyle: FontStyle.italic,
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              ...widget.loanAccountsList.map((loan) {
                return DropdownMenuItem<LoanAccount>(
                  value: loan,
                  child: Text(
                    loan.loanAccount,
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.normal),
                  ),
                );
              }),
            ],
            onChanged: (LoanAccount? newValue) {
              setState(() {
                selectedLoan = newValue;
              });
            },
          ),
          const SizedBox(height: 20),
          _buildLoanDetailsContent(),
        ],
      ),
    );
  }

  Widget _buildLoanDetailsContent() {
    if (selectedLoan == null) {
      return  Center(
        child: Text(
            AppLocalizations.of(context)!.loansNotSelected,
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return Card(
      color: Colors.grey.shade100,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    NumberFormat("#,##0.00").format(double.tryParse(selectedLoan!.amountDue) ?? 0),
                    style: TextStyle(
                      color: Colors.red.shade900,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                   Text(
                    AppLocalizations.of(context)!.outstandingLoan,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(3),
              },
              children: [
                _buildTableRow('Booking Date', parseDateTimeStringToDate(selectedLoan!.bookingDate)),
                _buildTableRow('Maturity Date', parseDateTimeStringToDate(selectedLoan!.maturityDate)),
                _buildTableRow('Disbursed Amount', NumberFormat("#,##0.00").format(double.tryParse(selectedLoan!.amountFinanced)?? 0)),
                _buildTableRow('Profit Rate', NumberFormat("#,##0.00").format(double.tryParse(selectedLoan!.interestRate)?? 0)),
                _buildTableRow('Total Outstanding', NumberFormat("#,##0.00").format(double.tryParse(selectedLoan!.overdueAmount)?? 0)),
                _buildTableRow('Total Amount Due', NumberFormat("#,##0.00").format(double.tryParse(selectedLoan!.amountDue)?? 0)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}