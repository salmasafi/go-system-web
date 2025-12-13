import 'package:systego/features/admin/discount/model/discount_model.dart';
import '../../home/model/pos_models.dart';
import 'checkout_models.dart';

class RecieptData {
  List<CartItem> cartItems;
  double totalAmount;
  double taxAmount;
  Tax? selectedTax;
  double discountAmount;
  DiscountModel? selectedDiscount;
  double paidAmount;
  double change;
  String reference;
  int pointsEarned;
  PaymentMethod paymentMethod;
  bool includeLogo = true;

  RecieptData({
    required this.cartItems,
    required this.totalAmount,
    required this.taxAmount,
    this.selectedTax,
    required this.discountAmount,
    this.selectedDiscount,
    required this.paidAmount,
    required this.change,
    required this.reference,
    required this.pointsEarned,
    required this.paymentMethod,
    this.includeLogo = true,
  });
}