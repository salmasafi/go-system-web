class DuePaymentReceiptData {
  final String customerName;
  final String phone;
  final String saleReference;
  final double grandTotal;
  final double previouslyPaid;
  final double paidNow;
  final double remainingAfter;
  final String paymentAccount;
  final DateTime date;

  DuePaymentReceiptData({
    required this.customerName,
    required this.phone,
    required this.saleReference,
    required this.grandTotal,
    required this.previouslyPaid,
    required this.paidNow,
    required this.remainingAfter,
    required this.paymentAccount,
    DateTime? date,
  }) : date = date ?? DateTime.now();
}
