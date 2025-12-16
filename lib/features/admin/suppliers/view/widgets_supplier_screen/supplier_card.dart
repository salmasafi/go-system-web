import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/features/admin/suppliers/cubit/supplier_cubit.dart';
import 'package:systego/features/admin/suppliers/view/supplier_details_bottom_sheet.dart';
import 'package:systego/generated/locale_keys.g.dart';
import '../../../../../core/widgets/custom_gradient_divider.dart';
import '../../../../../core/widgets/custom_popup_menu.dart';
import '../../model/supplier_model.dart';
import '../suppplier_add_edit/supplier_dialog.dart';
import 'supplier_card_widgets.dart';

class SupplierCard extends StatelessWidget {
  final Suppliers supplier;

  const SupplierCard({
    super.key,
    required this.supplier,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveUI.spacing(context, 16)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveUI.borderRadius(context, 20),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowGray.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(
            ResponsiveUI.borderRadius(context, 20),
          ),
          onTap: () {
            SupplierDetailsBottomSheet.show(context, supplier.id ?? '');
          },
          child: Padding(
            padding: EdgeInsets.all(ResponsiveUI.padding(context, 18)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                SizedBox(height: ResponsiveUI.spacing(context, 16)),
                CustomGradientDivider(
                  height: 1,
                  colors: [
                    AppColors.lightGray,
                    AppColors.primaryBlue,
                    AppColors.lightGray,
                  ],
                ),
                SizedBox(height: ResponsiveUI.spacing(context, 16)),
                _buildContactInfo(context),
                SizedBox(height: ResponsiveUI.spacing(context, 12)),
                _buildLocationInfo(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        SupplierImage(supplier: supplier),
        SizedBox(width: ResponsiveUI.spacing(context, 14)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                supplier.username ?? LocaleKeys.unknown_supplier.tr(),
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 16),
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGray,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: ResponsiveUI.spacing(context, 4)),
              Text(
                supplier.companyName ?? LocaleKeys.no_company.tr(),
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 13),
                  color: AppColors.darkGray.withOpacity(0.6),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        CustomPopupMenu(
          onEdit: () {
            SupplierDialog.show(context, supplier: supplier);
          },
          onDelete: () async {
            final confirmed = await _showDeleteConfirmation(context);
            if (confirmed == true && context.mounted) {
              await context.read<SupplierCubit>().deleteSupplier(
                supplier.id ?? '',
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildContactInfo(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SupplierInfoItem(
            icon: Icons.email_outlined,
            text: supplier.email ?? 'N/A',
          ),
        ),
        SizedBox(width: ResponsiveUI.spacing(context, 10)),
        Expanded(
          child: SupplierInfoItem(
            icon: Icons.phone_outlined,
            text: supplier.phoneNumber ?? 'N/A',
          ),
        ),
      ],
    );
  }

  Widget _buildLocationInfo(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SupplierLocationTag(
            icon: Icons.location_city,
            text: supplier.cityId?.name ?? 'N/A',
          ),
        ),
        SizedBox(width: ResponsiveUI.spacing(context, 8)),
        Expanded(
          child: SupplierLocationTag(
            icon: Icons.public,
            text: supplier.countryId?.name ?? 'N/A',
          ),
        ),
      ],
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            ResponsiveUI.borderRadius(context, 16),
          ),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_rounded,
              color: Colors.red,
              size: ResponsiveUI.iconSize(context, 28),
            ),
            SizedBox(width: ResponsiveUI.spacing(context, 12)),
            Text(LocaleKeys.delete_supplier_title.tr()),
          ],
        ),
        content: Text(LocaleKeys.delete_supplier_message.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.darkGray,
                fontSize: ResponsiveUI.fontSize(context, 14),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  ResponsiveUI.borderRadius(context, 8),
                ),
              ),
            ),
            child: Text(
              'Delete',
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 14),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
