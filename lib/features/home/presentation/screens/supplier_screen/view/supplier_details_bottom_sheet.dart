import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/features/home/presentation/screens/supplier_screen/cubit/supplier_cubit.dart';
import 'package:systego/features/home/presentation/screens/supplier_screen/cubit/supplier_state.dart';
import 'package:systego/features/home/presentation/screens/supplier_screen/model/supplier_whis_id_model.dart' as supplier_details;

import '../../../../../../core/widgets/custom_snck_bar/custom_snackbar.dart';

class SupplierDetailsBottomSheet extends StatelessWidget {
  final String supplierId;

  const SupplierDetailsBottomSheet({
    super.key,
    required this.supplierId,
  });

  static void show(BuildContext context, String supplierId) {
    if (supplierId.isEmpty) {
      CustomSnackbar.showError(context, 'Invalid supplier ID');
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SupplierDetailsBottomSheet(supplierId: supplierId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<SupplierCubit>()..getSupplierById(supplierId),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(ResponsiveUI.borderRadius(context, 28)),
            topRight: Radius.circular(ResponsiveUI.borderRadius(context, 28)),
          ),
        ),
        child: Column(
          children: [
            // Handle Bar
            Container(
              margin: EdgeInsets.only(top: ResponsiveUI.spacing(context, 12)),
              width: ResponsiveUI.value(context, 40),
              height: ResponsiveUI.value(context, 4),
              decoration: BoxDecoration(
                color: AppColors.lightGray,
                borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 2)),
              ),
            ),

            // Header
            Padding(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 20)),
              child: Row(
                children: [
                  Text(
                    'Supplier Details',
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 20),
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGray,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      size: ResponsiveUI.iconSize(context, 24),
                      color: AppColors.darkGray,
                    ),
                  ),
                ],
              ),
            ),

            Divider(height: 1, color: AppColors.lightGray),

            // Content
            Expanded(
              child: BlocConsumer<SupplierCubit, SupplierStates>(
                listener: (context, state) {
                  if (state is SupplierError) {
                    CustomSnackbar.showError(context, state.message);
                  }
                },
                builder: (context, state) {
                  if (state is SupplierLoading) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryBlue,
                      ),
                    );
                  }

                  if (state is SupplierError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: ResponsiveUI.iconSize(context, 48),
                            color: AppColors.red,
                          ),
                          SizedBox(height: ResponsiveUI.spacing(context, 16)),
                          Text(
                            state.message,
                            style: TextStyle(
                              fontSize: ResponsiveUI.fontSize(context, 14),
                              color: AppColors.darkGray,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: ResponsiveUI.spacing(context, 16)),
                          ElevatedButton.icon(
                            onPressed: () {
                              context.read<SupplierCubit>().getSupplierById(supplierId);
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is SupplierSuccess) {
                    final supplier = context.read<SupplierCubit>().currentSupplier;

                    if (supplier == null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: ResponsiveUI.iconSize(context, 48),
                              color: AppColors.darkGray.withOpacity(0.5),
                            ),
                            SizedBox(height: ResponsiveUI.spacing(context, 16)),
                            Text(
                              'No supplier data available',
                              style: TextStyle(
                                fontSize: ResponsiveUI.fontSize(context, 14),
                                color: AppColors.darkGray,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      padding: EdgeInsets.all(ResponsiveUI.padding(context, 20)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProfileSection(context, supplier),
                          SizedBox(height: ResponsiveUI.spacing(context, 24)),
                          _buildContactSection(context, supplier),
                          SizedBox(height: ResponsiveUI.spacing(context, 24)),
                          _buildLocationSection(context, supplier),
                          SizedBox(height: ResponsiveUI.spacing(context, 24)),
                          _buildAddressSection(context, supplier),
                        ],
                      ),
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, supplier_details.Supplier supplier) {
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
          // Profile Image
          Container(
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
          ),
          SizedBox(height: ResponsiveUI.spacing(context, 16)),

          // Username
          Text(
            supplier.username ?? 'Unknown',
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 22),
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ResponsiveUI.spacing(context, 6)),

          // Company Name
          Container(
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
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(BuildContext context, supplier_details.Supplier supplier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Contact Information', Icons.contact_phone),
        SizedBox(height: ResponsiveUI.spacing(context, 12)),
        _buildContactItem(
          context,
          icon: Icons.email_outlined,
          title: 'Email',
          value: supplier.email ?? 'N/A',
        ),
        SizedBox(height: ResponsiveUI.spacing(context, 12)),
        _buildContactItem(
          context,
          icon: Icons.phone_outlined,
          title: 'Phone Number',
          value: supplier.phoneNumber ?? 'N/A',
        ),
      ],
    );
  }

  Widget _buildLocationSection(BuildContext context, supplier_details.Supplier supplier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Location Details', Icons.location_on),
        SizedBox(height: ResponsiveUI.spacing(context, 12)),
        Row(
          children: [
            Expanded(
              child: _buildLocationCard(
                context,
                icon: Icons.public,
                title: 'Country',
                value: supplier.countryId?.name ?? 'N/A',
              ),
            ),
            SizedBox(width: ResponsiveUI.spacing(context, 12)),
            Expanded(
              child: _buildLocationCard(
                context,
                icon: Icons.location_city,
                title: 'City',
                value: supplier.cityId?.name ?? 'N/A',
              ),
            ),
          ],
        ),
        if (supplier.cityId?.shipingCost != null) ...[
          SizedBox(height: ResponsiveUI.spacing(context, 12)),
          Container(
            padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
            decoration: BoxDecoration(
              color: AppColors.lightBlueBackground,
              borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 16)),
              border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
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
                  'Shipping Cost: ',
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 14),
                    color: AppColors.darkGray.withOpacity(0.7),
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
          ),
        ],
      ],
    );
  }

  Widget _buildAddressSection(BuildContext context, supplier_details.Supplier supplier) {
    if (supplier.address == null || supplier.address!.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Address', Icons.home_outlined),
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
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(ResponsiveUI.padding(context, 8)),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 10)),
          ),
          child: Icon(
            icon,
            size: ResponsiveUI.iconSize(context, 20),
            color: AppColors.primaryBlue,
          ),
        ),
        SizedBox(width: ResponsiveUI.spacing(context, 12)),
        Text(
          title,
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 16),
            fontWeight: FontWeight.bold,
            color: AppColors.darkGray,
          ),
        ),
      ],
    );
  }

  Widget _buildContactItem(BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
      decoration: BoxDecoration(
        color: AppColors.lightBlueBackground,
        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 16)),
        border: Border.all(color: AppColors.lightGray),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(ResponsiveUI.padding(context, 10)),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
            ),
            child: Icon(
              icon,
              size: ResponsiveUI.iconSize(context, 22),
              color: AppColors.primaryBlue,
            ),
          ),
          SizedBox(width: ResponsiveUI.spacing(context, 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 12),
                    color: AppColors.darkGray.withOpacity(0.6),
                  ),
                ),
                SizedBox(height: ResponsiveUI.spacing(context, 4)),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 14),
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkGray,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 16)),
        border: Border.all(color: AppColors.lightGray),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowGray.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: ResponsiveUI.iconSize(context, 32),
            color: AppColors.primaryBlue,
          ),
          SizedBox(height: ResponsiveUI.spacing(context, 8)),
          Text(
            title,
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 12),
              color: AppColors.darkGray.withOpacity(0.6),
            ),
          ),
          SizedBox(height: ResponsiveUI.spacing(context, 4)),
          Text(
            value,
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 14),
              fontWeight: FontWeight.bold,
              color: AppColors.darkGray,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}