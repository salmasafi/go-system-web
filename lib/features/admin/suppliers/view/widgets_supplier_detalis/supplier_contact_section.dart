import 'package:flutter/material.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:GoSystem/features/admin/suppliers/model/supplier_whis_id_model.dart'
    as supplier_details;
import 'package:GoSystem/generated/locale_keys.g.dart';
import 'supplier_details_widgets.dart';
import 'package:easy_localization/easy_localization.dart';

class SupplierContactSection extends StatelessWidget {
  final supplier_details.Supplier supplier;

  const SupplierContactSection({
    super.key,
    required this.supplier,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          title: LocaleKeys.contact_information.tr(),
          icon: Icons.contact_phone,
        ),
        SizedBox(height: ResponsiveUI.spacing(context, 12)),
        ContactItem(
          icon: Icons.email_outlined,
          title: LocaleKeys.email.tr(),
          value: supplier.email ?? LocaleKeys.not_available.tr(),
        ),
        SizedBox(height: ResponsiveUI.spacing(context, 12)),
        ContactItem(
          icon: Icons.phone_outlined,
          title: LocaleKeys.phone_number.tr(),
          value: supplier.phoneNumber ?? LocaleKeys.not_available.tr(),
        ),
      ],
    );
  }
}
