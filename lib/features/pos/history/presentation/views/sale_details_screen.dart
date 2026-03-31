import 'package:systego/core/utils/responsive_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/widgets/custom_loading/custom_loading_state.dart';
import 'package:systego/features/POS/checkout/model/reciept_data.dart';
import 'package:systego/features/POS/checkout/presentation/view/reciept_screen.dart';
import 'package:systego/features/POS/home/model/pos_models.dart';
import '../../../checkout/model/checkout_models.dart';
import '../../cubit/history_cubit.dart';
import '../../cubit/history_state.dart';
import '../../model/sale_model.dart';

class SaleDetailsScreen extends StatelessWidget {
  final String saleId;
  const SaleDetailsScreen({super.key, required this.saleId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HistoryCubit()..getCompletedSaleDetails(saleId),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("Sale Details"),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: BlocBuilder<HistoryCubit, HistoryState>(
          builder: (context, state) {
            if (state is SaleDetailsLoading) {
              return const CustomLoadingState();
            } else if (state is HistoryError) {
              return Center(child: Text(state.message));
            } else if (state is SaleDetailsLoaded) {
              return _buildContent(context, state.details);
            }
            return SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, SaleDetailModel details) {
    return Column(
      children: [
        // Summary Header
        Container(
          padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
          color: AppColors.lightBlueBackground, // لون فاتح للخلفية
          child: Column(
            children: [
              _row("Reference", details.reference, isBold: true),
              _row(
                "Customer",
                _parseCustomerName(details),
              ), // دالة مساعدة للاسم
              _row(
                "Warehouse ID",
                details.warehouseId,
              ), // يمكنك جلب الاسم لو الموديل يدعمه
              const Divider(),
              _row("Status", "COMPLETED", color: Colors.green, isBold: true),
            ],
          ),
        ),

        SizedBox(height: ResponsiveUI.value(context, 10)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: ResponsiveUI.padding(context, 16)),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Products",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: ResponsiveUI.fontSize(context, 16)),
            ),
          ),
        ),

        // Items List
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
            itemCount: details.items.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final item = details.items[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: ResponsiveUI.value(context, 50),
                  height: ResponsiveUI.value(context, 50),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 8)),
                    image: item.image != null
                        ? DecorationImage(
                            image: NetworkImage(item.image!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: item.image == null
                      ? Icon(Icons.image, color: AppColors.shadowGray)
                      : null,
                ),
                title: Text(
                  item.productName,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("${item.quantity} x ${item.price} EGP"),
                trailing: Text(
                  "${item.subtotal.toStringAsFixed(2)} EGP",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: ResponsiveUI.fontSize(context, 15),
                  ),
                ),
              );
            },
          ),
        ),

        // Financial Summary Footer
        Container(
          padding: EdgeInsets.all(ResponsiveUI.padding(context, 20)),
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              _row(
                "Subtotal",
                "${details.grandTotal - details.taxAmount + details.discount}",
              ), // تقريبي
              _row("Tax", "+${details.taxAmount}"),
              _row("Discount", "-${details.discount}", color: Colors.red),
              const Divider(),
              _row(
                "Grand Total",
                "${details.grandTotal} EGP",
                isBold: true,
                size: ResponsiveUI.iconSize(context, 18),
                color: AppColors.primaryBlue,
              ),

              SizedBox(height: ResponsiveUI.value(context, 20)),

              // زر الطباعة فقط (لأن البيعة مكتملة)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // 1. تحويل العناصر
                    final List<CartItem>
                    cartItemsForReceipt = details.items.map((item) {
                      // إنشاء منتج وهمي للعرض فقط
                      final dummyProduct = Product(
                        id: item.productId,
                        name: item.productName,
                        price: item.price,
                        code: '', // غير مهم للطباعة
                        description: '',
                        image: item.image,
                      );

                      return CartItem(
                        product: dummyProduct,
                        quantity: item.quantity,
                        // لا نحتاج variation هنا لأن السعر والاسم يأتون جاهزين
                      );
                    }).toList();

                    // 2. تجهيز بيانات الإيصال
                    final receiptData = RecieptData(
                      cartItems: cartItemsForReceipt,
                      totalAmount:
                          details.grandTotal -
                          details.taxAmount +
                          details.discount, // Subtotal تقريبي
                      taxAmount: details.taxAmount,
                      discountAmount: details.discount,
                      paidAmount: details
                          .grandTotal, // نفترض أنه مدفوع بالكامل لأن الحالة Completed
                      change: 0.0,
                      reference: details.reference,
                      // يمكنك تمرير الضريبة والخصم ككائنات إذا أردت عرض أسمائهم
                      // selectedTax: Tax(...),
                    );

                    // 3. الانتقال لصفحة المعاينة
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ReceiptPreviewScreen(recieptData: receiptData),
                      ),
                    );
                  },
                  icon: Icon(Icons.print),
                  label: const Text("Print Receipt"),

                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryBlue,
                    padding: EdgeInsets.symmetric(vertical: ResponsiveUI.padding(context, 14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // مساعدات UI
  Widget _row(
    String label,
    String value, {
    Color? color,
    bool isBold = false,
    double size = 14,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: size, color: Colors.grey[700]),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: size,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color ?? AppColors.black,
            ),
          ),
        ],
      ),
    );
  }

  // لأن الـ API يعيد Customer ID كنص فقط في الـ Details أحياناً
  // إذا كان الـ Model يدعم الاسم، نستخدمه، وإلا نعرض الـ ID
  String _parseCustomerName(SaleDetailModel details) {
    // في موديل الـ Details الحالي customerId هو String
    // لو أردت الاسم، يجب تعديل الموديل ليقبل Map كما فعلنا في الـ Summary
    return details.customerId;
  }
}

