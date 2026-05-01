import 'package:GoSystem/core/utils/responsive_ui.dart';
// lib/features/pos/home/presentation/widgets/receipt_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:GoSystem/features/pos/checkout/cubit/checkout_cubit/checkout_cubit.dart';
import 'package:GoSystem/features/pos/checkout/model/reciept_data.dart';
import 'package:GoSystem/features/pos/checkout/presentation/view/reciept_screen.dart';
import 'package:GoSystem/features/pos/home/cubit/pos_home_cubit.dart';

class POSReceiptDialog extends StatefulWidget {
  //final List<CartItem> cartItems;
  final RecieptData recieptData;
  // final double totalAmount; // هنا بيبقى Subtotal فقط
  // final double taxAmount; // قيمة الضريبة
  // final Tax? selectedTax; // الضريبة المختارة (لعرض الاسم)
  // final double paidAmount;
  // final double change;
  // final String reference;
  // final int pointsEarned;
  // final PaymentMethod paymentMethod;

  const POSReceiptDialog({
    super.key,
    required this.recieptData,
    //required this.cartItems,
    // required this.totalAmount,
    // required this.taxAmount,
    // required this.selectedTax,
    // required this.paidAmount,
    // required this.change,
    // required this.reference,
    // required this.pointsEarned,
    // required this.paymentMethod,
  });

  @override
  State<POSReceiptDialog> createState() => _POSReceiptDialogState();
}

class _POSReceiptDialogState extends State<POSReceiptDialog> {
  String _formatDateTime() {
    return DateFormat('yyyy-MM-dd HH:mm:ss', 'en_US').format(DateTime.now());
  }

  // String _formatAmount(double amount, String type) {
  //   if (type == 'percentage') {
  //     return '${(amount * 100).toStringAsFixed(0)}%';
  //   } else {
  //     return '\$${amount.toStringAsFixed(2)}';
  //   }
  // }

  // String _amountInWords(double amount) {
  //   int dollars = amount.floor();
  //   int cents = ((amount - dollars) * 100).round();

  //   const ones = [
  //     '',
  //     'One',
  //     'Two',
  //     'Three',
  //     'Four',
  //     'Five',
  //     'Six',
  //     'Seven',
  //     'Eight',
  //     'Nine',
  //     'Ten',
  //     'Eleven',
  //     'Twelve',
  //     'Thirteen',
  //     'Fourteen',
  //     'Fifteen',
  //     'Sixteen',
  //     'Seventeen',
  //     'Eighteen',
  //     'Nineteen',
  //   ];
  //   const tens = [
  //     '',
  //     '',
  //     'Twenty',
  //     'Thirty',
  //     'Forty',
  //     'Fifty',
  //     'Sixty',
  //     'Seventy',
  //     'Eighty',
  //     'Ninety',
  //   ];

  //   String convert(int n) {
  //     if (n == 0) return '';
  //     if (n < 20) return ones[n];
  //     if (n < 100) return '${tens[n ~/ 10]} ${ones[n % 10]}'.trim();
  //     if (n < 1000)
  //       return '${ones[n ~/ 100]} Hundred ${convert(n % 100)}'.trim();
  //     return '$n';
  //   }

  //   String result = convert(dollars);
  //   if (result.isEmpty) result = 'Zero';
  //   result += ' USD';
  //   if (cents > 0) result += ' and ${convert(cents)} Cents';
  //   return result.trim();
  // }

  double get grandTotal =>
      widget.recieptData.totalAmount -
      widget.recieptData.discountAmount +
      widget.recieptData.taxAmount;
  @override
  void initState() {
    // needs to clear cart list
    context.read<CheckoutCubit>().updateCartWithEmptyList();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isCash = true;
    // widget.recieptData.paymentMethod.name.toLowerCase().contains(
    //   'cash',
    // );

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: ResponsiveUI.padding(context, 16),
        vertical: ResponsiveUI.padding(context, 24),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
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
            _buildHeader(),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(ResponsiveUI.padding(context, 24)),
                child: Column(
                  children: [
                    _buildReceiptHeader(),
                    SizedBox(height: ResponsiveUI.value(context, 20)),
                    _buildDivider(),
                    SizedBox(height: ResponsiveUI.value(context, 16)),
                    _buildItemsTable(),
                    SizedBox(height: ResponsiveUI.value(context, 16)),
                    _buildDivider(),
                    SizedBox(height: ResponsiveUI.value(context, 16)),
                    _buildTotalSection(),
                    if (isCash && widget.recieptData.paidAmount > 0) ...[
                      SizedBox(height: ResponsiveUI.value(context, 16)),
                      _buildCashDetails(),
                    ],
                    // if (widget.recieptData.pointsEarned > 0) ...[
                    //   SizedBox(height: ResponsiveUI.value(context, 20)),
                    //   _buildPointsEarned(),
                    // ],
                    SizedBox(height: ResponsiveUI.value(context, 20)),
                    _buildDivider(),
                    SizedBox(height: ResponsiveUI.value(context, 16)),
                    _buildFooter(),
                  ],
                ),
              ),
            ),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 20)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.successGreen,
            AppColors.successGreen.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ResponsiveUI.borderRadius(context, 20)),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(ResponsiveUI.padding(context, 10)),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
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
          SizedBox(width: ResponsiveUI.value(context, 16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sale Completed',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: ResponsiveUI.fontSize(context, 22),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Reference: ${widget.recieptData.reference}',
                  style: TextStyle(
                    color: AppColors.white.withValues(alpha: 0.9),
                    fontSize: ResponsiveUI.fontSize(context, 13),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: AppColors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptHeader() {
    return Column(
      children: [
        Text(
          'GoSystem',
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 28),
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
          ),
        ),
        // Text(
        //   'The Solution',
        //   style: TextStyle(
        //     fontSize: ResponsiveUI.fontSize(context, 16),
        //     color: AppColors.shadowGray,
        //     fontStyle: FontStyle.italic,
        //   ),
        // ),
        //SizedBox(height: ResponsiveUI.value(context, 12)),
        //_buildInfoRow(Icons.location_on_outlined, 'Address:', 'London'),
        //_buildInfoRow(Icons.phone_outlined, 'Phone:', '+970 599 123456'),
        SizedBox(height: ResponsiveUI.value(context, 12)),
        Container(
          padding: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
          decoration: BoxDecoration(
            color: AppColors.lightBlueBackground,
            borderRadius: BorderRadius.circular(
              ResponsiveUI.borderRadius(context, 12),
            ),
            border: Border.all(
              color: AppColors.primaryBlue.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              _buildRow('Date:', _formatDateTime()),
              _buildRow('Reference:', widget.recieptData.reference),
              // _buildRow(
              //   'Payment Method:',
              //   widget.recieptData.paymentMethod.name,
              // ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget _buildInfoRow(IconData icon, String label, String value) {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: [
  //       Icon(icon, size: ResponsiveUI.iconSize(context, 16), color: AppColors.primaryBlue),
  //       SizedBox(width: ResponsiveUI.value(context, 6)),
  //       Text(
  //         '$label ',
  //         style: TextStyle(
  //           fontSize: ResponsiveUI.fontSize(context, 13),
  //           color: AppColors.shadowGray,
  //           fontWeight: FontWeight.w600,
  //         ),
  //       ),
  //       Text(
  //         value,
  //         style: TextStyle(
  //           fontSize: ResponsiveUI.fontSize(context, 13),
  //           color: AppColors.darkGray,
  //           fontWeight: FontWeight.w600,
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: ResponsiveUI.padding(context, 4)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 13),
              color: AppColors.shadowGray,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 13),
              color: AppColors.darkGray,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() => Container(
    height: ResponsiveUI.value(context, 1),
    color: AppColors.primaryBlue.withValues(alpha: 0.3),
  );

  Widget _buildItemsTable() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            vertical: ResponsiveUI.padding(context, 10),
            horizontal: ResponsiveUI.padding(context, 12),
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.1),
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
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...widget.recieptData.cartItems.asMap().entries.map((e) {
          final item = e.value;
          final isEven = e.key % 2 == 0;
          return Container(
            padding: EdgeInsets.symmetric(
              vertical: ResponsiveUI.padding(context, 12),
              horizontal: ResponsiveUI.padding(context, 12),
            ),
            color: isEven
                ? AppColors.lightBlueBackground.withValues(alpha: 0.3)
                : null,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    item.product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 12),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '${item.quantity}',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Expanded(
                  child: Text(
                    '\$${item.effectivePrice.toStringAsFixed(2)}',
                    textAlign: TextAlign.right,
                  ),
                ),
                Expanded(
                  child: Text(
                    '\$${(item.effectivePrice * item.quantity).toStringAsFixed(2)}',
                    textAlign: TextAlign.right,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTotalSection() {
    String taxDisplay = '';
    if (widget.recieptData.selectedTax != null) {
      if (widget.recieptData.selectedTax!.type == 'percentage') {
        taxDisplay =
            '${(widget.recieptData.selectedTax!.amount * 100).toStringAsFixed(0)}%';
      } else {
        taxDisplay =
            '\$${widget.recieptData.selectedTax!.amount.toStringAsFixed(2)}';
      }
    } else {
      taxDisplay = '\$${widget.recieptData.taxAmount.toStringAsFixed(2)}';
    }

    String discountDisplay = '';
    if (widget.recieptData.selectedDiscount != null) {
      if (widget.recieptData.selectedDiscount!.type == 'percentage') {
        discountDisplay =
            '${(widget.recieptData.selectedDiscount!.amount * 100).toStringAsFixed(0)}%';
      } else {
        discountDisplay =
            '\$${widget.recieptData.selectedDiscount!.amount.toStringAsFixed(2)}';
      }
    } else {
      discountDisplay =
          '\$${widget.recieptData.discountAmount.toStringAsFixed(2)}';
    }

    return Container(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryBlue.withValues(alpha: 0.05),
            AppColors.shadowGray.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(
          ResponsiveUI.borderRadius(context, 12),
        ),
        border: Border.all(
          color: AppColors.primaryBlue.withValues(alpha: 0.3),
          width: ResponsiveUI.value(context, 1.5),
        ),
      ),
      child: Column(
        children: [
          _totalRow('Subtotal:', widget.recieptData.totalAmount, false),
          if (widget.recieptData.discountAmount > 0) ...[
            SizedBox(height: ResponsiveUI.value(context, 8)),
            _totalRow(
              '${widget.recieptData.selectedDiscount?.name ?? 'Discount'} ($discountDisplay):',
              -widget.recieptData.discountAmount,
              false,
            ),
          ],
          if (widget.recieptData.taxAmount > 0) ...[
            SizedBox(height: ResponsiveUI.value(context, 8)),
            _totalRow(
              '${widget.recieptData.selectedTax?.name ?? 'Tax'} ($taxDisplay):',
              widget.recieptData.taxAmount,
              false,
            ),
          ],
          SizedBox(height: ResponsiveUI.value(context, 12)),
          Container(
            height: ResponsiveUI.value(context, 1),
            color: AppColors.primaryBlue.withValues(alpha: 0.2),
          ),
          SizedBox(height: ResponsiveUI.value(context, 12)),
          _totalRow('Grand Total:', grandTotal, true),

          // SizedBox(height: ResponsiveUI.value(context, 16)),
          // Container(
          //   padding: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
          //   decoration: BoxDecoration(
          //     color: AppColors.white,
          //     borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 8)),
          //     border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.2)),
          //   ),
          //   child: Row(
          //     children: [
          //       Text(
          //         'In Words: ',
          //         style: TextStyle(
          //           color: AppColors.shadowGray,
          //           fontWeight: FontWeight.w600,
          //         ),
          //       ),
          //       Expanded(
          //         child: Text(
          //           _amountInWords(grandTotal),
          //           style: TextStyle(
          //             color: AppColors.primaryBlue,
          //             fontWeight: FontWeight.bold,
          //             fontStyle: FontStyle.italic,
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _totalRow(String label, double amount, bool bold) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: bold ? 16 : 14,
            fontWeight: bold ? FontWeight.bold : FontWeight.w600,
            color: AppColors.darkGray,
          ),
        ),
        Text(
          amount >= 0
              ? '\$${amount.toStringAsFixed(2)}'
              : '-\$${(-amount).toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: bold ? 18 : 15,
            fontWeight: FontWeight.bold,
            color: bold
                ? AppColors.primaryBlue
                : (amount < 0 ? AppColors.successGreen : AppColors.darkGray),
          ),
        ),
      ],
    );
  }

  Widget _buildCashDetails() {
    return Container(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
      decoration: BoxDecoration(
        color: AppColors.successGreen.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(
          ResponsiveUI.borderRadius(context, 12),
        ),
        border: Border.all(
          color: AppColors.successGreen.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Paid Amount:',
                style: TextStyle(color: AppColors.shadowGray),
              ),
              Text(
                '\$${widget.recieptData.paidAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.successGreen,
                ),
              ),
            ],
          ),
          if (widget.recieptData.change > 0) ...[
            SizedBox(height: ResponsiveUI.value(context, 8)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Change:', style: TextStyle(color: AppColors.shadowGray)),
                Text(
                  '\$${widget.recieptData.change.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.warningOrange,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // Widget _buildPointsEarned() {
  //   return Container(
  //     padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
  //     decoration: BoxDecoration(
  //       color: AppColors.holdBeige.withValues(alpha: 0.1),
  //       borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
  //       border: Border.all(color: AppColors.holdBeige.withValues(alpha: 0.3)),
  //     ),
  //     child: Row(
  //       children: [
  //         Icon(Icons.star, color: AppColors.holdBeige),
  //         SizedBox(width: ResponsiveUI.value(context, 12)),
  //         Expanded(
  //           child: Text.rich(
  //             TextSpan(
  //               children: [
  //                 TextSpan(
  //                   text: 'Congratulations! You earned ',
  //                   style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 14)),
  //                 ),
  //                 TextSpan(
  //                   text: '${widget.recieptData.pointsEarned} points',
  //                   style: TextStyle(
  //                     fontWeight: FontWeight.bold,
  //                     color: AppColors.holdBeige,
  //                     fontSize: ResponsiveUI.fontSize(context, 16),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //         //Text('Congratulations! You earned ', style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 14))),
  //         // Text(
  //         //   '${widget.pointsEarned} points',
  //         //   style: TextStyle(
  //         //     fontWeight: FontWeight.bold,
  //         //     color: AppColors.holdBeige,
  //         //     fontSize: ResponsiveUI.fontSize(context, 16),
  //         //   ),
  //         // ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildFooter() {
    return Column(
      children: [
        Icon(
          Icons.check_circle,
          color: AppColors.successGreen,
          size: ResponsiveUI.iconSize(context, 48),
        ),
        SizedBox(height: ResponsiveUI.value(context, 12)),
        Text(
          'Thank You For Shopping With Us!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 16),
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
          ),
        ),
        Text(
          'Powered by GoSystem POS',
          style: TextStyle(
            color: AppColors.shadowGray,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 20)),
      decoration: BoxDecoration(
        color: AppColors.shadowGray[50],
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(ResponsiveUI.borderRadius(context, 20)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                context.read<CheckoutCubit>().updateCartWithEmptyList();
                context.read<PosCubit>().refreshCartProducts();

                Navigator.popUntil(context, (route) => route.isFirst);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ReceiptPreviewScreen(recieptData: widget.recieptData),
                  ),
                );
              },
              icon: Icon(Icons.print),
              label: Text('Print'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryBlue,
                side: BorderSide(
                  color: AppColors.primaryBlue,
                  width: ResponsiveUI.value(context, 1.5),
                ),
              ),
            ),
          ),
          SizedBox(width: ResponsiveUI.value(context, 12)),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                context.read<CheckoutCubit>().updateCartWithEmptyList();
                context.read<PosCubit>().refreshCartProducts();

                Navigator.popUntil(context, (route) => route.isFirst);
              },
              icon: Icon(Icons.done_all),
              label: Text(
                'Done',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.successGreen,
                foregroundColor: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
