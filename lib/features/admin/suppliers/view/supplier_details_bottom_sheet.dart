import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:GoSystem/core/widgets/custom_loading/custom_loading_state.dart';
import 'package:GoSystem/features/admin/suppliers/cubit/supplier_cubit.dart';
import 'package:GoSystem/features/admin/suppliers/cubit/supplier_state.dart';
import 'package:GoSystem/features/admin/suppliers/view/widgets_supplier_detalis/supplier_details_content.dart';
import '../../../../core/widgets/custom_snack_bar/custom_snackbar.dart';
import '../../../../generated/locale_keys.g.dart';

class SupplierDetailsBottomSheet extends StatelessWidget {
  final String supplierId;

  const SupplierDetailsBottomSheet({super.key, required this.supplierId});

  static void show(BuildContext context, String supplierId) {
    if (supplierId.isEmpty) {
      CustomSnackbar.showError(
        context,
        LocaleKeys.invalid_supplier_id.tr(),
      );
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
            _buildHandleBar(context),
            _buildHeader(context),
            Divider(height: ResponsiveUI.value(context, 1), color: AppColors.lightGray),
            Expanded(child: _buildContent(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildHandleBar(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: ResponsiveUI.spacing(context, 12)),
      width: ResponsiveUI.value(context, 40),
      height: ResponsiveUI.value(context, 4),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(
          ResponsiveUI.borderRadius(context, 2),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 20)),
      child: Row(
        children: [
          Text(
            LocaleKeys.supplier_details_title.tr(),
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
    );
  }

  Widget _buildContent(BuildContext context) {
    return BlocConsumer<SupplierCubit, SupplierStates>(
      listener: (context, state) {
        if (state is SupplierError) {
          CustomSnackbar.showError(context, state.message);
        }
      },
      builder: (context, state) {
        if (state is SupplierLoading) {
          return Center(
            child: CustomLoadingState(),
          );
        }

        if (state is SupplierError) {
          return _buildErrorState(context, state.message);
        }

        if (state is SupplierSuccess) {
          final supplier = context.read<SupplierCubit>().currentSupplier;

          if (supplier == null) {
            return _buildEmptyState(context);
          }

          return SupplierDetailsContent(supplier: supplier);
        }

        return SizedBox();
      },
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
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
            message,
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
            icon: Icon(Icons.refresh),
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

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: ResponsiveUI.iconSize(context, 48),
            color: AppColors.darkGray.withValues(alpha: 0.5),
          ),
          SizedBox(height: ResponsiveUI.spacing(context, 16)),
          Text(
            LocaleKeys.no_supplier_data.tr(),
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 14),
              color: AppColors.darkGray,
            ),
          ),
        ],
      ),
    );
  }
}

