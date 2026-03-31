import 'package:systego/core/utils/responsive_ui.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/widgets/app_bar_widgets.dart';
import 'package:systego/core/widgets/custom_snack_bar/custom_snackbar.dart';
import 'package:systego/features/admin/print_labels/cubit/label_cubit.dart'; // Import your cubit
import 'package:systego/features/admin/print_labels/model/label_model.dart'; // Import your models
import 'package:systego/features/admin/print_labels/presentation/view/print_labels_screen.dart'; // For LabelSelectionItem

class LabelPreviewScreen extends StatelessWidget {
  final List<LabelSelectionItem> selectedItems;

  const LabelPreviewScreen({
    required this.selectedItems,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = LabelCubit();
        // Convert the generic selection items to the specific LabelProductItems for the API
        final labelItems = selectedItems.map((item) {
          return LabelProductItem(
            // Use variation ID if available, otherwise product ID
            productId: item.variation?.id ?? item.product.id, 
            name: item.product.name,
            variationName: item.variation?.code,
            price: item.variation?.price ?? item.product.price,
            image: item.product.image,
            quantity: item.quantity,
          );
        }).toList();
        
        cubit.initProducts(labelItems);
        return cubit;
      },
      child: const _LabelPreviewContent(),
    );
  }
}

class _LabelPreviewContent extends StatelessWidget {
  const _LabelPreviewContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBlueBackground,
      appBar: appBarWithActions(
        context,
        title: 'Label Configuration',
      ),
      body: BlocConsumer<LabelCubit, LabelState>(
        listener: (context, state) {
          if (state is GenerateLabelsSuccess) {
            CustomSnackbar.showSuccess(context, state.message);
            // Handle PDF opening or navigation here
          } else if (state is GenerateLabelsError) {
            CustomSnackbar.showError(context, state.error);
          }
        },
        builder: (context, state) {
          final cubit = context.read<LabelCubit>();
          
          if (cubit.selectedProducts.isEmpty) {
            return Center(child: Text("No items selected"));
          }

          return Column(
            children: [
              // 1. Settings Section (Toggles)
              _buildConfigSection(context, cubit),

              // 2. List of Products with Quantity
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
                  itemCount: cubit.selectedProducts.length,
                  itemBuilder: (context, index) {
                    final item = cubit.selectedProducts[index];
                    return _buildProductLabelCard(context, item, cubit);
                  },
                ),
              ),

              // 3. Bottom Action Bar
              _buildBottomBar(context, state, cubit),
            ],
          );
        },
      ),
    );
  }

  Widget _buildConfigSection(BuildContext context, LabelCubit cubit) {
    return Container(
      color: Colors.white,
      child: ExpansionTile(
        title: const Text(
          "Label Settings",
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkBlue),
        ),
        subtitle: const Text("Customize what appears on the label"),
        initiallyExpanded: true,
        children: [
          SwitchListTile(
            title: const Text("Show Product Name"),
            value: cubit.labelConfig.showProductName,
            activeColor: AppColors.primaryBlue,
            onChanged: (val) => cubit.updateConfig(showProductName: val),
          ),
          SwitchListTile(
            title: const Text("Show Price"),
            value: cubit.labelConfig.showPrice,
            activeColor: AppColors.primaryBlue,
            onChanged: (val) => cubit.updateConfig(showPrice: val),
          ),
          SwitchListTile(
            title: const Text("Show Business Name"),
            value: cubit.labelConfig.showBusinessName,
            activeColor: AppColors.primaryBlue,
            onChanged: (val) => cubit.updateConfig(showBusinessName: val),
          ),
        ],
      ),
    );
  }

  Widget _buildProductLabelCard(BuildContext context, LabelProductItem item, LabelCubit cubit) {
    return Card(
      margin: EdgeInsets.only(bottom: ResponsiveUI.padding(context, 12)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12))),
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
        child: Row(
          children: [
            // Image
            Container(
              width: ResponsiveUI.value(context, 60),
              height: ResponsiveUI.value(context, 60),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 8)),
              ),
              child: item.image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 8)),
                      child: Image.network(
                        item.image!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(Icons.image, color: Colors.grey),
                      ),
                    )
                  : Icon(Icons.qr_code_2, color: Colors.grey),
            ),
            SizedBox(width: ResponsiveUI.value(context, 16)),
            
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: ResponsiveUI.fontSize(context, 16)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.variationName != null)
                    Text(
                      'Var: ${item.variationName}',
                      style: TextStyle(color: Colors.grey[600], fontSize: ResponsiveUI.fontSize(context, 13)),
                    ),
                  Text(
                    '\$${item.price.toStringAsFixed(2)}',
                    style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            // Quantity Editor
            Container(
              decoration: BoxDecoration(
                color: AppColors.lightBlueBackground,
                borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 8)),
                border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.remove, size: ResponsiveUI.iconSize(context, 18), color: AppColors.primaryBlue),
                    onPressed: () {
                      if (item.quantity > 1) {
                        cubit.updateQuantity(item.productId, item.quantity - 1);
                      }
                    },
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    padding: EdgeInsets.zero,
                  ),
                  Text(
                    '${item.quantity}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: ResponsiveUI.fontSize(context, 16)),
                  ),
                  IconButton(
                    icon: Icon(Icons.add, size: ResponsiveUI.iconSize(context, 18), color: AppColors.primaryBlue),
                    onPressed: () {
                      cubit.updateQuantity(item.productId, item.quantity + 1);
                    },
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, LabelState state, LabelCubit cubit) {
    final isLoading = state is GenerateLabelsLoading;
    final totalLabels = cubit.selectedProducts.fold(0, (sum, item) => sum + item.quantity);

    return Container(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 20)),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            padding: EdgeInsets.symmetric(vertical: ResponsiveUI.padding(context, 16)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12))),
          ),
          onPressed: isLoading
              ? null
              : () {
                  cubit.generateLabels();
                },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading) ...[
                SizedBox(
                  width: ResponsiveUI.value(context, 20),
                  height: ResponsiveUI.value(context, 20),
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                ),
                SizedBox(width: ResponsiveUI.value(context, 12)),
                Text("Generating...", style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 18), color: Colors.white)),
              ] else ...[
                Icon(Icons.print, color: Colors.white),
                SizedBox(width: ResponsiveUI.value(context, 8)),
                Text(
                  'Generate $totalLabels Labels',
                  style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 18), color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
