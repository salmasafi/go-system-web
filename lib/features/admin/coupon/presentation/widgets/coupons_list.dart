import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/features/admin/coupon/cubit/coupon_cubit.dart';
import 'package:systego/features/admin/coupon/model/coupon_model.dart';
import 'package:systego/features/admin/coupon/presentation/widgets/animated_coupon_card.dart';
import 'package:systego/features/admin/coupon/presentation/widgets/coupon_form_dialog.dart';
import 'package:systego/generated/locale_keys.g.dart';
import '../../../../../core/widgets/custom_snack_bar/custom_snackbar.dart';
import '../../../warehouses/view/widgets/custom_delete_dialog.dart';

class CouponsList extends StatelessWidget {
  final List<CouponModel> coupons;
  const CouponsList({super.key, required this.coupons});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.only(
        right: ResponsiveUI.padding(context, 16),
        left: ResponsiveUI.padding(context, 16),
        top: ResponsiveUI.padding(context, 16),
      ),
      itemCount: coupons.length,
      itemBuilder: (context, index) {
        return AnimatedCouponCard(
          coupon: coupons[index],
          index: index,
          onDelete: () => _showDeleteDialog(context, coupons[index]),
          onEdit: () => _showEditDialog(context, coupons[index]),
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, CouponModel coupon) {
    showDialog(
      context: context,
      builder: (context) => CouponFormDialog(coupon: coupon),
    );
  }

  void _showDeleteDialog(BuildContext context, CouponModel coupon) {
    if (coupon.id.isEmpty) {
      CustomSnackbar.showError(context, LocaleKeys.invalid_coupon_id.tr());
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => CustomDeleteDialog(
        title: LocaleKeys.delete_coupon.tr(),
        message:
            '${LocaleKeys.delete_coupon_message.tr()} \n"${coupon.couponCode}"',
        onDelete: () {
          Navigator.pop(dialogContext);
          context.read<CouponsCubit>().deleteCoupon(coupon.id);
        },
      ),
    );
  }

}
