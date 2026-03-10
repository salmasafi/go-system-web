import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/widgets/custom_loading/custom_loading_state.dart';
import 'package:systego/core/widgets/custom_snack_bar/custom_snackbar.dart';

// Cubits
import '../../../checkout/presentation/widgets/checkout_dialog.dart';
import '../../cubit/history_cubit.dart';
import '../../cubit/history_state.dart';
import 'package:systego/features/POS/checkout/cubit/checkout_cubit/checkout_cubit.dart';
import 'package:systego/features/POS/home/cubit/pos_home_cubit.dart';

// Models
import '../../model/pending_sale_details_model.dart';
import 'package:systego/features/POS/home/model/pos_models.dart'; // For Product & PriceVariation models

class PendingSaleDetailsScreen extends StatelessWidget {
  final String saleId;
  const PendingSaleDetailsScreen({super.key, required this.saleId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HistoryCubit()..getPendingSaleDetails(saleId),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("Pending Sale"),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: BlocConsumer<HistoryCubit, HistoryState>(
          listener: (context, state) {
            if (state is HistoryError) {
              CustomSnackbar.showError(context, state.message);
            }
          },
          builder: (context, state) {
            if (state is SaleDetailsLoading) {
              return const CustomLoadingState();
            } else if (state is PendingDetailsSuccess) {
              return _buildContent(context, state.details);
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, PendingSaleDetailsModel details) {
    return Column(
      children: [
        // Top Info Card
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.orange.withOpacity(0.05),
          child: Column(
            children: [
              _row("Reference", details.reference, isBold: true),
              _row("Customer", details.customer.name),
              _row("Phone", details.customer.phone),
              _row("Warehouse", details.warehouse.name),
              const Divider(),
              _row("Status", "PENDING", color: Colors.orange, isBold: true),
            ],
          ),
        ),

        const SizedBox(height: 10),
        
        // Products Header
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.shopping_cart_outlined, size: 20, color: Colors.grey),
              SizedBox(width: 8),
              Text("Products", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ),

        // Items List
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: details.products.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = details.products[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 4),
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    image: item.productImage.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(item.productImage),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: item.productImage.isEmpty
                      ? const Icon(Icons.image, color: Colors.grey)
                      : null,
                ),
                title: Text(item.productName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: Text("${item.quantity} x ${item.price} EGP", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                trailing: Text("${item.subtotal} EGP", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              );
            },
          ),
        ),

        // Bottom Action Area
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              )
            ],
          ),
          child: Column(
            children: [
              // Totals
              _row("Subtotal", "${details.subTotal}"), // Using subtotal from response or calc
              if(details.taxAmount > 0) _row("Tax", "+${details.taxAmount}"),
              if(details.discount > 0) _row("Discount", "-${details.discount}", color: Colors.red),
              const Divider(height: 24),
              _row("Total to Pay", "${details.grandTotal} EGP", isBold: true, size: 18, color: AppColors.primaryBlue),

              const SizedBox(height: 20),

              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _restoreSaleAndCheckout(context, details);
                  },
                  icon: const Icon(Icons.restore),
                  label: const Text("Resume Sale"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  // ─── Logic to Restore Sale ───
  void _restoreSaleAndCheckout(BuildContext context, PendingSaleDetailsModel details) {
    final checkoutCubit = context.read<CheckoutCubit>();
    final posCubit = context.read<PosCubit>();

    // 1. Clear current cart
    checkoutCubit.updateCartWithEmptyList();

    // 2. Restore items to cart
    for (var item in details.products) {
      // Create Product object
      // Note: We might be missing some details like 'code' or full 'description' 
      // but 'id', 'name', 'price', 'image' are usually enough for the cart/checkout display.
      final product = Product(
        id: item.productId,
        name: item.productName,
        code: '', // Not provided in this specific response usually, okay to be empty for cart logic
        description: '',
        price: item.price, // Use price from sale record
        image: item.productImage,
        differentPrice: item.productPriceId != null, // If it has a specific price ID, assume variation logic
      );

      // Create PriceVariation if needed (dummy wrapper to pass ID)
      PriceVariation? variation;
      if (item.productPriceId != null) {
          variation = PriceVariation(
            id: item.productPriceId!, 
            productId: item.productId, 
            price: item.price, 
            code: '', 
            gallery: [], 
            quantity: 0, 
            variations: []
          );
      }

      // Add to cart with specific quantity
      // Since addToCart increments by 1, we add once and then update quantity if needed
      checkoutCubit.addToCart(product, variation: variation);
      
      // Correct the quantity
      if (item.quantity > 1) {
         // The item is added at the end of the list
         checkoutCubit.updateQuantity(checkoutCubit.cartItems.length - 1, item.quantity - 1);
      }
    }

    // 3. Restore Customer (If possible to select by ID in PosCubit)
    // You might need a method in PosCubit like: selectCustomerById(String id)
    // For now, we assume the user might need to re-select or we just proceed with payment
    
    // 4. Navigate back to POS Home and open Checkout
    Navigator.popUntil(context, (route) => route.isFirst); 

    // Open Checkout Dialog Immediately
    showDialog(
      context: context,
      builder: (_) => POSCheckoutDialog(
        totalAmount: details.grandTotal, // Pass the total directly or let it recalc from cart
        cartItems: checkoutCubit.cartItems,
        selectedPaymentMethod: posCubit.paymentMethods.isNotEmpty 
            ? posCubit.paymentMethods.first 
            : PaymentMethod(id: '0', name: 'Cash'), // Default fallback
      ),
    );
  }

  Widget _row(String label, String value, {Color? color, bool isBold = false, double size = 14}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: size, color: Colors.grey[700])),
          Text(value, style: TextStyle(fontSize: size, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: color ?? Colors.black)),
        ],
      ),
    );
  }
}