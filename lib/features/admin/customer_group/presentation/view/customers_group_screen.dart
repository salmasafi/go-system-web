import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:GoSystem/core/widgets/animation/animated_element.dart';
import 'package:GoSystem/core/widgets/app_bar_widgets.dart';
import 'package:GoSystem/core/widgets/custom_error/custom_empty_state.dart';
import 'package:GoSystem/core/widgets/custom_loading/custom_loading_state_with_shimmer.dart';
import 'package:GoSystem/core/widgets/custom_snack_bar/custom_snackbar.dart';
import 'package:GoSystem/features/admin/customer/cubit/customer_cubit.dart';
import 'package:GoSystem/features/admin/customer_group/presentation/widgets/customer_group_animated_card.dart';
import 'package:GoSystem/features/admin/customer_group/presentation/widgets/customer_group_form_dialog.dart';
import 'package:GoSystem/features/admin/customer_group/presentation/widgets/customer_groups_list.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';

class CustomerGroupsScreen extends StatefulWidget {
  const CustomerGroupsScreen({super.key});

  @override
  State<CustomerGroupsScreen> createState() => _CustomerGroupsScreenState();
}

class _CustomerGroupsScreenState extends State<CustomerGroupsScreen> {
  void customerGroupsInit() async {
    context.read<CustomerCubit>().getAllCustomerGroups();
  }

  @override
  void initState() {
    super.initState();
    customerGroupsInit();
  }

  Future<void> _refresh() async {
    customerGroupsInit();
  }

  Widget _buildListContent() {
    return BlocConsumer<CustomerCubit, CustomerState>(
      listener: (context, state) {
        if (state is GetCustomerGroupsError) {
          CustomSnackbar.showError(context, state.error);
        } else if (state is CreateCustomerGroupSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          customerGroupsInit();
        } else if (state is CreateCustomerGroupError) {
          CustomSnackbar.showError(context, state.error);
        } else if (state is UpdateCustomerGroupSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          customerGroupsInit();
        } else if (state is UpdateCustomerGroupError) {
          CustomSnackbar.showError(context, state.error);
        } else if (state is DeleteCustomerGroupSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          customerGroupsInit();
        } else if (state is DeleteCustomerGroupError) {
          CustomSnackbar.showError(context, state.error);
          customerGroupsInit();
        }
      },
      builder: (context, state) {
        if (state is GetCustomerGroupsLoading ||
            state is DeleteCustomerGroupLoading) {
          return RefreshIndicator(
            onRefresh: _refresh,
            color: AppColors.primaryBlue,
            child: CustomLoadingShimmer(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
            ),
          );
        } else if (state is GetCustomerGroupsSuccess) {
          final customerGroups = state.groups;

          if (customerGroups.isEmpty) {
            String title = customerGroups.isEmpty
                ? LocaleKeys.no_customer_groups.tr()
                : LocaleKeys.no_matching_customer_groups.tr();
            String message = customerGroups.isEmpty
                ? LocaleKeys.customer_groups_all_caught_up.tr()
                : LocaleKeys.customer_groups_try_adjusting_filters.tr();
            return CustomEmptyState(
              icon: Icons.group_rounded,
              title: title,
              message: message,
              onRefresh: _refresh,
              actionLabel: LocaleKeys.retry.tr(),
              onAction: _refresh,
            );
          } else {
            return RefreshIndicator(
              onRefresh: _refresh,
              color: AppColors.primaryBlue,
              child: CustomerGroupList(customerGroups: customerGroups),
            );
          }
        } else {
          return CustomEmptyState(
            icon: Icons.group_rounded,
            title: LocaleKeys.no_customer_groups.tr(),
            message: LocaleKeys.empty_connection.tr(),
            onRefresh: _refresh,
            actionLabel: LocaleKeys.retry.tr(),
            onAction: _refresh,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Scale down for web
    Widget screenContent = Scaffold(
      backgroundColor: AppColors.lightBlueBackground,
      appBar: appBarWithActions(
        context,
        title: LocaleKeys.customer_groups_title.tr(),
        showActions: true,
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const CustomerGroupFormDialog(),
          );
        },
      ),
      body: SafeArea(
        child: _buildListContent(),
      ),
    );
    if (kIsWeb) {
      screenContent = MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: const TextScaler.linear(0.55),
        ),
        child: screenContent,
      );
    }
    return screenContent;
  }
}
