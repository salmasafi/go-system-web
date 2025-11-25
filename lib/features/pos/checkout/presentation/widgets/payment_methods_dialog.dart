// Updated Payment Methods Dialog with callback
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/features/POS/home/cubit/pos_home_cubit.dart';
import 'package:systego/features/POS/home/cubit/pos_home_state.dart';
import 'package:systego/features/POS/home/model/pos_models.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/responsive_ui.dart';
import '../../../../../core/widgets/custom_error/custom_empty_state.dart';
import '../../../home/presentation/widgets/selection_option.dart';

class POSPaymentMethodsDialog extends StatelessWidget {
  final Function(PaymentMethod) onMethodSelected;

  const POSPaymentMethodsDialog({super.key, required this.onMethodSelected});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          ResponsiveUI.borderRadius(context, 20),
        ),
      ),
      title: Row(
        children: [
          const Icon(Icons.payment, color: AppColors.primaryBlue),
          SizedBox(width: ResponsiveUI.spacing(context, 12)),
          Text(
            'Select Payment Method',
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 18),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.5,
        child: BlocBuilder<PosCubit, PosState>(
          builder: (context, state) {
            final cubit = context.read<PosCubit>();
            final paymentMethods = cubit.paymentMethods;

            if (paymentMethods.isEmpty) {
              return CustomEmptyState(
                icon: Icons.attach_money_rounded,
                title: 'No Payment Methods Found',
                message: 'Pull to refresh or check your connection',
                actionLabel: 'Retry',
                onAction: () => cubit.loadPosData(),
              );
            }

            return ListView.builder(
              itemCount: paymentMethods.length,
              itemBuilder: (context, index) {
                final paymentMethod = paymentMethods[index];
                return POSSelectionOption(
                  label: paymentMethod.name,
                  icon: Icons.attach_money_rounded,
                  onTap: () {
                    cubit.changePaymentMethodValue(paymentMethod);
                    onMethodSelected(paymentMethod);
                  },
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: AppColors.black)),
        ),
      ],
    );
  }
}
