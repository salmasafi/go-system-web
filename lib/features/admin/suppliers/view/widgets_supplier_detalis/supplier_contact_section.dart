
import 'package:flutter/material.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/features/admin/suppliers/model/supplier_whis_id_model.dart' as supplier_details;
import 'supplier_details_widgets.dart';

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
          title: 'Contact Information',
          icon: Icons.contact_phone,
        ),
        SizedBox(height: ResponsiveUI.spacing(context, 12)),
        ContactItem(
          icon: Icons.email_outlined,
          title: 'Email',
          value: supplier.email ?? 'N/A',
        ),
        SizedBox(height: ResponsiveUI.spacing(context, 12)),
        ContactItem(
          icon: Icons.phone_outlined,
          title: 'Phone Number',
          value: supplier.phoneNumber ?? 'N/A',
        ),
      ],
    );
  }
}