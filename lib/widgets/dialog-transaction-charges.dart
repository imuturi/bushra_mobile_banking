import 'package:flutter/material.dart';

class ConfirmTransferDialog extends StatelessWidget {
  final String dialogDescription;
  final String amount;
  final String recipientAccount;
  final String sourceAccount;
  final String charges;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;

  const ConfirmTransferDialog({
    super.key,
    required this.dialogDescription,
    required this.amount,
    required this.recipientAccount,
    required this.sourceAccount,
    required this.charges,
    this.onCancel,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {

    final bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      insetPadding: EdgeInsets.symmetric(
        horizontal: screenWidth > 600 ? 50 : 12,
        vertical: screenHeight < 600 ? 10 : 20, // Adjusted for small screens
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: screenHeight * 0.8, // Prevent overflow
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(isLandscape ? 16.0 : 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitleSection(isLandscape),
                const SizedBox(height: 8),
                isLandscape ? _buildLandscapeLayout() : _buildPortraitLayout(),
                const SizedBox(height: 8),
                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleSection(bool isLandscape) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "CONFIRM TRANSFER",
          style: TextStyle(
            fontSize: isLandscape ? 16 : 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          dialogDescription,
          style: TextStyle(
            fontSize: isLandscape ? 12 : 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildPortraitLayout() {
    return Column(
      children: [
        _buildDetailRow("Amount", amount),
        _buildDetailRow("Recipient Acc number", 'A/C #${recipientAccount.substring(0, 4)}****${recipientAccount.substring(recipientAccount.length - 4)}'),
        //"A/C #${recipientAccount.substring(0, 4)}****${recipientAccount.substring(recipientAccount.length - 4)}";
        _buildDetailRow("Transfer from", sourceAccount),
        _buildDetailRow("Charges", charges),
      ],
    );
  }

  Widget _buildLandscapeLayout() {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1.5),
        1: FlexColumnWidth(2),
      },
      children: [
        _buildTableRow("Amount", amount),
        _buildTableRow("Recipient Acc", recipientAccount),
        _buildTableRow("Transfer from", sourceAccount),
        _buildTableRow("Charges", charges),
      ],
    );
  }

  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onCancel?.call();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo.shade900,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "CANCEL",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
        ),
        const SizedBox(width: 14),
        Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onConfirm?.call();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade900,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "CONFIRM",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}