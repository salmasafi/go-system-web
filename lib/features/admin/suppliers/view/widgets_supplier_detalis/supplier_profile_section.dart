import 'package:flutter/material.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/features/admin/suppliers/model/supplier_whis_id_model.dart' as supplier_details;

class SupplierProfileSection extends StatelessWidget {
  final supplier_details.Supplier supplier;

  const SupplierProfileSection({
    super.key,
    required this.supplier,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 20)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryBlue, AppColors.primaryBlue.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 20)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildProfileImage(context),
          SizedBox(height: ResponsiveUI.spacing(context, 16)),
          _buildUsername(context),
          SizedBox(height: ResponsiveUI.spacing(context, 6)),
          _buildCompanyName(context),
        ],
      ),
    );
  }

  Widget _buildProfileImage(BuildContext context) {
    return Container(
      width: ResponsiveUI.value(context, 100),
      height: ResponsiveUI.value(context, 100),
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        image: supplier.image != null
            ? DecorationImage(
          image: NetworkImage(supplier.image!),
          fit: BoxFit.cover,
        )
            : null,
        border: Border.all(color: AppColors.white, width: 4),
      ),
      child: supplier.image == null
          ? Icon(
        Icons.store,
        size: ResponsiveUI.iconSize(context, 48),
        color: AppColors.primaryBlue,
      )
          : null,
    );
  }

  Widget _buildUsername(BuildContext context) {
    return Text(
      supplier.username ?? 'Unknown',
      style: TextStyle(
        fontSize: ResponsiveUI.fontSize(context, 22),
        fontWeight: FontWeight.bold,
        color: AppColors.white,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildCompanyName(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUI.padding(context, 16),
        vertical: ResponsiveUI.padding(context, 8),
      ),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 20)),
      ),
      child: Text(
        supplier.companyName ?? 'No Company',
        style: TextStyle(
          fontSize: ResponsiveUI.fontSize(context, 14),
          color: AppColors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}