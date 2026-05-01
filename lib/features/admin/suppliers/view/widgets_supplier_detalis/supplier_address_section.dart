import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/features/admin/suppliers/model/supplier_whis_id_model.dart' as supplier_details;
import 'package:systego/generated/locale_keys.g.dart';
import 'supplier_details_widgets.dart';

class SupplierAddressSection extends StatelessWidget {
  final supplier_details.Supplier supplier;

  const SupplierAddressSection({
    super.key,
    required this.supplier,
  });

  @override
  Widget build(BuildContext context) {
    if (supplier.address == null || supplier.address!.isEmpty) {
      return SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          title: LocaleKeys.address.tr(),
          icon: Icons.home_outlined,
        ),
        SizedBox(height: ResponsiveUI.spacing(context, 12)),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
          decoration: BoxDecoration(
            color: AppColors.lightBlueBackground,
            borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 16)),
            border: Border.all(color: AppColors.lightGray),
          ),
          child: Text(
            supplier.address!,
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 14),
              color: AppColors.darkGray,
              height: ResponsiveUI.value(context, 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
