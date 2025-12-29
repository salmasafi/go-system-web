import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/animation/animated_element.dart';
import 'package:systego/core/widgets/app_bar_widgets.dart';
import 'package:systego/core/widgets/custom_error/custom_empty_state.dart';
import 'package:systego/core/widgets/custom_loading/custom_loading_state_with_shimmer.dart';
import 'package:systego/core/widgets/custom_snack_bar/custom_snackbar.dart';
import 'package:systego/features/admin/customer/cubit/customer_cubit.dart';
import 'package:systego/features/admin/customer/presentation/view/create_customer_screen.dart';
import 'package:systego/features/admin/customer/presentation/widgets/customers_list.dart';
import 'package:systego/generated/locale_keys.g.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  void customersInit() async {
    context.read<CustomerCubit>().getAllCustomers();
  }

  @override
  void initState() {
    super.initState();
    customersInit();
  }

  Future<void> _refresh() async {
    customersInit();
  }

  Widget _buildListContent() {
    return BlocConsumer<CustomerCubit, CustomerState>(
      listener: (context, state) {
        if (state is GetCustomersError) {
          CustomSnackbar.showError(context, state.error);
        } else if (state is DeleteCustomerError) {
          CustomSnackbar.showError(context, state.error);
          customersInit();
        } else if (state is DeleteCustomerSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          customersInit();
        } else if (state is CreateCustomerSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          customersInit();
        } else if (state is UpdateCustomerSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          customersInit();
        }
      },
      builder: (context, state) {
        if (state is GetCustomersLoading || state is DeleteCustomerLoading) {
          return RefreshIndicator(
            onRefresh: _refresh,
            color: AppColors.primaryBlue,
            child: CustomLoadingShimmer(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
            ),
          );
        }

        if (state is GetCustomersSuccess) {
          if (state.customers.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            color: AppColors.primaryBlue,
            child: CustomersList(customers: state.customers),
          );
        }

        return _buildEmptyState();
      },
    );
  }

  Widget _buildEmptyState() {
    return CustomEmptyState(
      icon: Icons.person_outline,
      title: LocaleKeys.no_customers_title.tr(),
      message: LocaleKeys.no_customers_message.tr(),
      onRefresh: _refresh,
      actionLabel: LocaleKeys.retry.tr(),
      onAction: _refresh,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWithActions(
        context,
        title: LocaleKeys.customers_title.tr(),
        showActions: true,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateCustomerScreen()),
          );
          if (result == true && mounted) {
            customersInit();
          }
        },
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