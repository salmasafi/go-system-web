import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:GoSystem/core/widgets/custom_image_card.dart';
import '../../features/admin/warehouses/model/ware_house_model.dart';
import '../../features/admin/warehouses/view/widgets/custom_detail_tile.dart';
import '../constants/app_colors.dart';
import 'custom_detail_section.dart';
import '../../features/admin/warehouses/view/widgets/custom_drag_handle.dart';
import 'custom_gradient_divider.dart';
import '../../features/admin/warehouses/view/warehouse_products_screen.dart';

class CustomWarehouseDetailsSheet extends StatelessWidget {
  final Warehouses warehouse;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CustomWarehouseDetailsSheet({
    super.key,
    required this.warehouse,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightBlueBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(ResponsiveUI.borderRadius(context, 30))),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: EdgeInsets.all(ResponsiveUI.padding(context, 24)),
          children: [
            CustomDragHandle(),
            SizedBox(height: ResponsiveUI.value(context, 20)),
            _buildDetailHeader(),
            SizedBox(height: ResponsiveUI.value(context, 24)),
            CustomGradientDivider(height: ResponsiveUI.value(context, 2)),
            SizedBox(height: ResponsiveUI.value(context, 20)),
            CustomDetailSection(
              title: 'Location Information',
              icon: Icons.location_on,
              iconColor: AppColors.red,
              children: [
                CustomDetailTile(
                  label: 'Address',
                  value: warehouse.address ?? 'N/A',
                  icon: Icons.location_city,
                ),
              ],
            ),
            SizedBox(height: ResponsiveUI.value(context, 20)),
            CustomDetailSection(
              title: 'Contact Information',
              icon: Icons.contact_phone,
              iconColor: AppColors.successGreen,
              children: [
                CustomDetailTile(
                  label: 'Phone',
                  value: warehouse.phone ?? 'N/A',
                  icon: Icons.phone,
                ),
                CustomDetailTile(
                  label: 'Email',
                  value: warehouse.email ?? 'N/A',
                  icon: Icons.email,
                ),
              ],
            ),
            SizedBox(height: ResponsiveUI.value(context, 20)),
            CustomDetailSection(
              title: 'Inventory Statistics',
              icon: Icons.inventory,
              iconColor: AppColors.linkBlue,
              children: [
                CustomDetailTile(
                  label: 'Products',
                  value: '${warehouse.numberOfProducts ?? 0}',
                  icon: Icons.category,
                ),
                CustomDetailTile(
                  label: 'Stock',
                  value: '${warehouse.stockQuantity ?? 0}',
                  icon: Icons.storage,
                ),
              ],
            ),
            SizedBox(height: ResponsiveUI.value(context, 24)),
            _buildActionButtons(context),
            SizedBox(height: ResponsiveUI.value(context, 16)),
            _buildViewProductsButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailHeader() {
    return Row(
      children: [
        CustomImageContainer(
          icon: Icons.warehouse,
          size: 36,
          gradient: LinearGradient(
            colors: [AppColors.primaryBlue, AppColors.darkBlue],
          ),
          padding: 16,
          image: null,
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                warehouse.name,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGray,
                ),
              ),
              Text(
                'Warehouse Details',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.darkGray.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        if (onEdit != null)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                onEdit!();
                _showInfoSnackbar(context, 'Edit feature coming soon!');
              },
              icon: Icon(Icons.edit),
              label: const Text('Edit'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: ResponsiveUI.padding(context, 16)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 16)),
                ),
              ),
            ),
          ),
        if (onEdit != null && onDelete != null) SizedBox(width: ResponsiveUI.value(context, 12)),
        if (onDelete != null)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                onDelete!();
              },
              icon: Icon(Icons.delete),
              label: const Text('Delete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: ResponsiveUI.padding(context, 16)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 16)),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildViewProductsButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => WarehouseProductsScreen(warehouse: warehouse),
            ),
          );
        },
        icon: Icon(Icons.inventory_2),
        label: const Text('View Products'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.successGreen,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: ResponsiveUI.padding(context, 16)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 16)),
          ),
        ),
      ),
    );
  }

  void _showInfoSnackbar(BuildContext context, String message) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: 'Info',
        message: message,
        contentType: ContentType.help,
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}

