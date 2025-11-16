// lib/features/pos/home/presentation/widgets/receipt_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:intl/intl.dart';
import 'package:systego/features/pos/home/cubit/pos_home_cubit.dart';
import '../../model/pos_models.dart';

class POSReceiptDialog extends StatefulWidget {
  final double totalAmount;
  final PaymentMethod paymentMethod;
  final String? paymentReceiver;
  final String? paymentNote;
  final String? saleNote;
  final String? staffNote;
  final double? cashReceived;
  final double? change;

  const POSReceiptDialog({
    super.key,
    required this.totalAmount,
    required this.paymentMethod,
    this.paymentReceiver,
    this.paymentNote,
    this.saleNote,
    this.staffNote,
    this.cashReceived,
    this.change,
  });

  @override
  State<POSReceiptDialog> createState() => _POSReceiptDialogState();
}

class _POSReceiptDialogState extends State<POSReceiptDialog> {
  String _generateReference() {
    final now = DateTime.now();
    final dateFormat = DateFormat('yyyyMMdd-HHmmss');
    return 'SYGO${dateFormat.format(now)}';
  }

  String _formatDateTime() {
    final now = DateTime.now();
    final format = DateFormat('yyyy-MM-dd HH:mm:ss');
    return format.format(now);
  }

  String _numberToWords(int number) {
    if (number == 0) return 'Zero';

    final ones = [
      '',
      'One',
      'Two',
      'Three',
      'Four',
      'Five',
      'Six',
      'Seven',
      'Eight',
      'Nine',
    ];
    final teens = [
      'Ten',
      'Eleven',
      'Twelve',
      'Thirteen',
      'Fourteen',
      'Fifteen',
      'Sixteen',
      'Seventeen',
      'Eighteen',
      'Nineteen',
    ];
    final tens = [
      '',
      '',
      'Twenty',
      'Thirty',
      'Forty',
      'Fifty',
      'Sixty',
      'Seventy',
      'Eighty',
      'Ninety',
    ];
    final thousands = ['', 'Thousand', 'Million', 'Billion'];

    if (number < 10) return ones[number];
    if (number < 20) return teens[number - 10];
    if (number < 100) {
      return '${tens[number ~/ 10]} ${ones[number % 10]}'.trim();
    }
    if (number < 1000) {
      return '${ones[number ~/ 100]} Hundred ${_numberToWords(number % 100)}'
          .trim();
    }

    for (int i = 0; i < thousands.length; i++) {
      int divisor = 1000 * (i + 1);
      if (number < divisor) {
        return '${_numberToWords(number ~/ (divisor ~/ 1000))} ${thousands[i]} ${_numberToWords(number % (divisor ~/ 1000))}'
            .trim();
      }
    }
    return number.toString();
  }

  String _amountInWords(double amount) {
    int dollars = amount.floor();
    int cents = ((amount - dollars) * 100).round();

    String result = 'USD ${_numberToWords(dollars)}';
    if (cents > 0) {
      result += ' and ${_numberToWords(cents)} Cents';
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: ResponsiveUI.padding(context, 16),
        vertical: ResponsiveUI.padding(context, 24),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: ResponsiveUI.screenHeight(context) * 0.9,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(
            ResponsiveUI.borderRadius(context, 20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(ResponsiveUI.padding(context, 24)),
                child: Column(
                  children: [
                    _buildReceiptHeader(context),
                    SizedBox(height: ResponsiveUI.spacing(context, 20)),
                    _buildDivider(context),
                    SizedBox(height: ResponsiveUI.spacing(context, 16)),
                    _buildItemsTable(context),
                    SizedBox(height: ResponsiveUI.spacing(context, 16)),
                    _buildDivider(context),
                    SizedBox(height: ResponsiveUI.spacing(context, 16)),
                    _buildTotalSection(context),
                    if (widget.cashReceived != null) ...[
                      SizedBox(height: ResponsiveUI.spacing(context, 16)),
                      _buildPaymentDetails(context),
                    ],
                    SizedBox(height: ResponsiveUI.spacing(context, 20)),
                    _buildDivider(context),
                    SizedBox(height: ResponsiveUI.spacing(context, 16)),
                    _buildFooter(context),
                  ],
                ),
              ),
            ),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 20)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.successGreen,
            AppColors.successGreen.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(ResponsiveUI.borderRadius(context, 20)),
          topRight: Radius.circular(ResponsiveUI.borderRadius(context, 20)),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(ResponsiveUI.padding(context, 10)),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(
                ResponsiveUI.borderRadius(context, 12),
              ),
            ),
            child: Icon(
              Icons.receipt_long,
              color: AppColors.white,
              size: ResponsiveUI.iconSize(context, 28),
            ),
          ),
          SizedBox(width: ResponsiveUI.spacing(context, 16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sale Receipt',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: ResponsiveUI.fontSize(context, 22),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Transaction completed successfully',
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.9),
                    fontSize: ResponsiveUI.fontSize(context, 13),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              color: AppColors.white,
              size: ResponsiveUI.iconSize(context, 24),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptHeader(BuildContext context) {
    return Column(
      children: [
        // Company Name
        Text(
          'SYSTEGO',
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 28),
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
            letterSpacing: 2,
          ),
        ),
        SizedBox(height: ResponsiveUI.spacing(context, 4)),
        Text(
          'The Solution',
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 16),
            color: AppColors.shadowGray,
            fontStyle: FontStyle.italic,
          ),
        ),
        SizedBox(height: ResponsiveUI.spacing(context, 12)),

        // Address & Phone
        _buildInfoRow(
          context,
          Icons.location_on_outlined,
          'Address:',
          'London',
        ),
        SizedBox(height: ResponsiveUI.spacing(context, 4)),
        _buildInfoRow(context, Icons.phone_outlined, 'Phone:', '97090998'),
        SizedBox(height: ResponsiveUI.spacing(context, 12)),

        // Date & Reference
        Container(
          padding: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
          decoration: BoxDecoration(
            color: AppColors.lightBlueBackground,
            borderRadius: BorderRadius.circular(
              ResponsiveUI.borderRadius(context, 12),
            ),
            border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Date:',
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 13),
                      color: AppColors.shadowGray,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _formatDateTime(),
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 13),
                      color: AppColors.darkGray,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: ResponsiveUI.spacing(context, 6)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Reference:',
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 13),
                      color: AppColors.shadowGray,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _generateReference(),
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 13),
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: ResponsiveUI.iconSize(context, 16),
          color: AppColors.primaryBlue,
        ),
        SizedBox(width: ResponsiveUI.spacing(context, 6)),
        Text(
          label,
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 13),
            color: AppColors.shadowGray,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(width: ResponsiveUI.spacing(context, 6)),
        Text(
          value,
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 13),
            color: AppColors.darkGray,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            AppColors.primaryBlue.withOpacity(0.3),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildItemsTable(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: EdgeInsets.symmetric(
            vertical: ResponsiveUI.padding(context, 10),
            horizontal: ResponsiveUI.padding(context, 12),
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(
              ResponsiveUI.borderRadius(context, 8),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  'Product',
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 13),
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Qty',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 13),
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Price',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 13),
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Total',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 13),
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Items
        ...context.read<PosCubit>().cartItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isEven = index % 2 == 0;

          return Container(
            padding: EdgeInsets.symmetric(
              vertical: ResponsiveUI.padding(context, 12),
              horizontal: ResponsiveUI.padding(context, 12),
            ),
            decoration: BoxDecoration(
              color: isEven
                  ? AppColors.lightBlueBackground.withOpacity(0.3)
                  : Colors.transparent,
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    item.product.name,
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 12),
                      color: AppColors.darkGray,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  child: Text(
                    '${item.quantity}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 12),
                      color: AppColors.darkGray,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '\$${item.product.price.toStringAsFixed(2)}',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 12),
                      color: AppColors.darkGray,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '\$${(item.product.price * item.quantity).toStringAsFixed(2)}',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 12),
                      color: AppColors.darkGray,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildTotalSection(BuildContext context) {
    final subtotal = widget.totalAmount;
    final tax = 0.0; // You can calculate tax if needed
    final grandTotal = subtotal + tax;

    return Container(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryBlue.withOpacity(0.05),
            AppColors.linkBlue.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(
          ResponsiveUI.borderRadius(context, 12),
        ),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          _buildTotalRow(context, 'Subtotal:', subtotal, false),
          if (tax > 0) ...[
            SizedBox(height: ResponsiveUI.spacing(context, 8)),
            _buildTotalRow(context, 'Tax (10%):', tax, false),
          ],
          SizedBox(height: ResponsiveUI.spacing(context, 12)),
          Container(height: 1, color: AppColors.primaryBlue.withOpacity(0.2)),
          SizedBox(height: ResponsiveUI.spacing(context, 12)),
          _buildTotalRow(context, 'Grand Total:', grandTotal, true),
          SizedBox(height: ResponsiveUI.spacing(context, 16)),

          // Amount in words
          Container(
            padding: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(
                ResponsiveUI.borderRadius(context, 8),
              ),
              border: Border.all(color: AppColors.primaryBlue.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Text(
                  'In Words: ',
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 12),
                    color: AppColors.shadowGray,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Expanded(
                  child: Text(
                    _amountInWords(grandTotal),
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 12),
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(
    BuildContext context,
    String label,
    double amount,
    bool isBold,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, isBold ? 16 : 14),
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: AppColors.darkGray,
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, isBold ? 18 : 15),
            fontWeight: FontWeight.bold,
            color: isBold ? AppColors.primaryBlue : AppColors.darkGray,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentDetails(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
      decoration: BoxDecoration(
        color: AppColors.successGreen.withOpacity(0.05),
        borderRadius: BorderRadius.circular(
          ResponsiveUI.borderRadius(context, 12),
        ),
        border: Border.all(color: AppColors.successGreen.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.payment,
                color: AppColors.successGreen,
                size: ResponsiveUI.iconSize(context, 20),
              ),
              SizedBox(width: ResponsiveUI.spacing(context, 8)),
              Text(
                'Payment Method: ${widget.paymentMethod.name}',
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 14),
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGray,
                ),
              ),
            ],
          ),
          if (widget.cashReceived != null) ...[
            SizedBox(height: ResponsiveUI.spacing(context, 12)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cash Received:',
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 13),
                    color: AppColors.shadowGray,
                  ),
                ),
                Text(
                  '\$${widget.cashReceived!.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 14),
                    fontWeight: FontWeight.bold,
                    color: AppColors.successGreen,
                  ),
                ),
              ],
            ),
            if (widget.change != null && widget.change! > 0) ...[
              SizedBox(height: ResponsiveUI.spacing(context, 8)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Change:',
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 13),
                      color: AppColors.shadowGray,
                    ),
                  ),
                  Text(
                    '\$${widget.change!.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 14),
                      fontWeight: FontWeight.bold,
                      color: AppColors.warningOrange,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.check_circle,
          color: AppColors.successGreen,
          size: ResponsiveUI.iconSize(context, 48),
        ),
        SizedBox(height: ResponsiveUI.spacing(context, 12)),
        Text(
          'Thank You For Shopping With Us!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 16),
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
          ),
        ),
        SizedBox(height: ResponsiveUI.spacing(context, 8)),
        Text(
          'Powered by SYSTEGO POS',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 12),
            color: AppColors.shadowGray,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 20)),
      decoration: BoxDecoration(
        color: AppColors.shadowGray[50],
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(ResponsiveUI.borderRadius(context, 20)),
          bottomRight: Radius.circular(ResponsiveUI.borderRadius(context, 20)),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowGray.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: Implement print functionality
              },
              icon: Icon(Icons.print, size: ResponsiveUI.iconSize(context, 20)),
              label: Text(
                'Print',
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 15),
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryBlue,
                padding: EdgeInsets.symmetric(
                  vertical: ResponsiveUI.padding(context, 14),
                ),
                side: BorderSide(color: AppColors.primaryBlue, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    ResponsiveUI.borderRadius(context, 12),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: ResponsiveUI.spacing(context, 12)),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                while (context.read<PosCubit>().cartItems.isNotEmpty) {
                  context.read<PosCubit>().cartItems.removeAt(0);
                }
                setState(() {});

                context.read<PosCubit>().refreshCartProducts();

                Navigator.pop(context); // Close receipt
                Navigator.pop(context); // Close checkout dialog
                Navigator.pop(context); // Close checkout dialog
              },
              icon: Icon(Icons.check, size: ResponsiveUI.iconSize(context, 20)),
              label: Text(
                'Done',
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 15),
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.successGreen,
                foregroundColor: AppColors.white,
                padding: EdgeInsets.symmetric(
                  vertical: ResponsiveUI.padding(context, 14),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    ResponsiveUI.borderRadius(context, 12),
                  ),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
