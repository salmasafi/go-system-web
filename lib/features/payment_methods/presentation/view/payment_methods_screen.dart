import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/animation/animated_element.dart';
import 'package:systego/core/widgets/app_bar_widgets.dart';
import 'package:systego/core/widgets/custom_error/custom_empty_state.dart';
import 'package:systego/core/widgets/custom_loading/custom_loading_state_with_shimmer.dart';
import '../../../../core/widgets/custom_snck_bar/custom_snackbar.dart';
import '../../cubit/payment_method_cubit.dart';
import '../../cubit/payment_method_state.dart';
import '../widgets/payment_method_form_dialog.dart';
import '../widgets/payment_methods_list.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  void paymentMethodsInit() async {
    context.read<PaymentMethodCubit>().getPaymentMethods();
  }

  @override
  void initState() {
    super.initState();
    paymentMethodsInit();
  }

  Future<void> _refresh() async {
    paymentMethodsInit();
  }

  Widget _buildListContent() {
    return BlocConsumer<PaymentMethodCubit, PaymentMethodState>(
      listener: (context, state) {
        if (state is GetPaymentMethodsError) {
          CustomSnackbar.showError(context, state.error);
        } else if (state is DeletePaymentMethodError) {
          CustomSnackbar.showError(context, state.error);
          paymentMethodsInit();
        } else if (state is DeletePaymentMethodSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          paymentMethodsInit();
        } else if (state is SelectPaymentMethodError) {
          CustomSnackbar.showError(context, state.error);
          paymentMethodsInit();
        } else if (state is SelectPaymentMethodSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          paymentMethodsInit();
        } else if (state is CreatePaymentMethodSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          paymentMethodsInit();
        } else if (state is UpdatePaymentMethodSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          paymentMethodsInit();
        }
      },
      builder: (context, state) {
        if (state is GetPaymentMethodsLoading ||
            state is DeletePaymentMethodLoading ||
            state is SelectPaymentMethodLoading) {
          return RefreshIndicator(
            onRefresh: _refresh,
            color: AppColors.primaryBlue,
            child: CustomLoadingShimmer(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
            ),
          );
        } else if (state is GetPaymentMethodsSuccess) {
          final paymentMethods = state.paymentMethods;

          if (paymentMethods.isEmpty) {
            String title = paymentMethods.isEmpty ? 'No Payment Methods' : 'No Matching Payment Methods';
            String message = paymentMethods.isEmpty
                ? 'You\'re all caught up!'
                : 'Try adjusting your filters';
            return CustomEmptyState(
              icon: Icons.monetization_on_rounded,
              title: title,
              message: message,
              onRefresh: _refresh,
              actionLabel: 'Retry',
              onAction: _refresh,
            );
          } else {
            return RefreshIndicator(
              onRefresh: _refresh,
              color: AppColors.primaryBlue,
              child: PaymentMethodsList(paymentMethods: paymentMethods),
            );
          }
        } else {
          return CustomEmptyState(
            icon: Icons.monetization_on_rounded,
            title: 'No Payment Methods',
            message: 'Pull to refresh or check your connection',
            onRefresh: _refresh,
            actionLabel: 'Retry',
            onAction: _refresh,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWithActions(
        context,
        title: 'Payment Methods',
        showActions: true,
        onPressed: () => showDialog(
          context: context,
          builder: (context) => PaymentMethodFormDialog(),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: ResponsiveUI.contentMaxWidth(context),
          ),
          child: AnimatedElement(
            delay: const Duration(milliseconds: 200),
            child: _buildListContent(),
          ),
        ),
      ),
    );
  }
}
