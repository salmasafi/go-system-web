import 'package:flutter/material.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/features/suppliers/model/supplier_whis_id_model.dart' as supplier_details;
import 'supplier_profile_section.dart';
import 'supplier_contact_section.dart';
import 'supplier_location_section.dart';
import 'supplier_address_section.dart';

class SupplierDetailsContent extends StatelessWidget {
  final supplier_details.Supplier supplier;

  const SupplierDetailsContent({
    super.key,
    required this.supplier,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SupplierProfileSection(supplier: supplier),
          SizedBox(height: ResponsiveUI.spacing(context, 24)),
          SupplierContactSection(supplier: supplier),
          SizedBox(height: ResponsiveUI.spacing(context, 24)),
          SupplierLocationSection(supplier: supplier),
          SizedBox(height: ResponsiveUI.spacing(context, 24)),
          SupplierAddressSection(supplier: supplier),
        ],
      ),
    );
  }
}