import 'package:flutter/material.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/features/admin/suppliers/model/supplier_whis_id_model.dart'
    as supplier_details;
import 'package:systego/generated/locale_keys.g.dart';
import 'supplier_details_widgets.dart';
import 'package:easy_localization/easy_localization.dart';

class SupplierLocationSection extends StatelessWidget {
  final supplier_details.Supplier supplier;

  const SupplierLocationSection({
    super.key,
    required this.supplier,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          title: LocaleKeys.location_details.tr(),
          icon: Icons.location_on,
        ),
        SizedBox(height: ResponsiveUI.spacing(context, 12)),
        Row(
          children: [
            Expanded(
              child: LocationCard(
                icon: Icons.public,
                title: LocaleKeys.country.tr(),
                value: supplier.countryId?.name ?? LocaleKeys.not_available.tr(),
              ),
            ),
            SizedBox(width: ResponsiveUI.spacing(context, 12)),
            Expanded(
              child: LocationCard(
                icon: Icons.location_city,
                title: LocaleKeys.city.tr(),
                value: supplier.cityId?.name ?? LocaleKeys.not_available.tr(),
              ),
            ),
          ],
        ),
        if (supplier.cityId?.shipingCost != null) ...[
          SizedBox(height: ResponsiveUI.spacing(context, 12)),
          _buildShippingCost(context),
        ],
      ],
    );
  }

  Widget _buildShippingCost(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
      decoration: BoxDecoration(
        color: AppColors.lightBlueBackground,
        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 16)),
        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_shipping_outlined,
            color: AppColors.primaryBlue,
            size: ResponsiveUI.iconSize(context, 24),
          ),
          SizedBox(width: ResponsiveUI.spacing(context, 12)),
          Text(
            LocaleKeys.shipping_cost.tr(),
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 14),
              color: AppColors.darkGray.withValues(alpha: 0.7),
            ),
          ),
          Text(
            '${supplier.cityId!.shipingCost} EGP',
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 16),
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }
}

