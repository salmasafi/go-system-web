import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/generated/locale_keys.g.dart';
import '../../../../../core/widgets/custom_snack_bar/custom_snackbar.dart';
import '../../../warehouses/view/widgets/custom_delete_dialog.dart';
import '../../cubit/payment_method_cubit.dart';
import '../../model/payment_method_model.dart';
import 'animated_payment_method_card.dart';
import 'payment_method_form_dialog.dart';

class PaymentMethodsList extends StatelessWidget {
  final List<PaymentMethodModel> paymentMethods;
  const PaymentMethodsList({super.key, required this.paymentMethods});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.only(
        right: ResponsiveUI.padding(context, 16),
        left: ResponsiveUI.padding(context, 16),
        top: ResponsiveUI.padding(context, 16),
      ),
      itemCount: paymentMethods.length,
      itemBuilder: (context, index) {
        return AnimatedPaymentMethodCard(
          paymentMethod: paymentMethods[index],
          index: index,
          onDelete: () => _showDeleteDialog(context, paymentMethods[index]),
          onEdit: () => _showEditDialog(context, paymentMethods[index]),
          //onTap: () => _showSelectDialog(context, PaymentMethods[index]),
        );
      },
    );
  }

  void _showEditDialog(
    BuildContext context,
    PaymentMethodModel paymentMethod,
  ) {
    showDialog(
      context: context,
      builder: (context) => PaymentMethodFormDialog(paymentMethod: paymentMethod, existingImageUrl: paymentMethod.icon,),
    );
  }

  void _showDeleteDialog(BuildContext context, PaymentMethodModel paymentMethod) {
    if (paymentMethod.id.isEmpty) {
      CustomSnackbar.showError(context,  LocaleKeys.invalid_payment_method_id.tr());
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => CustomDeleteDialog(
        title: LocaleKeys.delete_payment_method.tr(),
        message: '${LocaleKeys.delete_payment_method_message.tr()}\n"${paymentMethod.name}"',
        onDelete: () {
          Navigator.pop(dialogContext);
          context.read<PaymentMethodCubit>().deletePaymentMethod(paymentMethod.id);
        },
      ),
    );
  }

  // void _showSelectDialog(BuildContext context, PaymentMethodModel PaymentMethod) {
  //   if (PaymentMethod.id.isEmpty) {
  //     CustomSnackbar.showError(context, 'Invalid PaymentMethod ID');
  //     return;
  //   }

  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (dialogContext) => CustomDeleteDialog(
  //       title: 'Select PaymentMethod',
  //       message:
  //           'Are you sure you want to select this PaymentMethod as the default?\n"${PaymentMethod.name}"',
  //       icon: Icons.check_circle_rounded,
  //       iconColor: AppColors.primaryBlue,
  //       deleteText: 'Select',
  //       onDelete: () {
  //         Navigator.pop(dialogContext);
  //         context.read<PaymentMethodCubit>().selectPaymentMethod(PaymentMethod.id, PaymentMethod.name);
  //       },
  //     ),
  //   );
  // }

}
