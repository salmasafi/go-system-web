import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/animation/animated_element.dart';
import 'package:systego/core/widgets/app_bar_widgets.dart';
import 'package:systego/core/widgets/custom_error/custom_empty_state.dart';
import 'package:systego/core/widgets/custom_loading/custom_loading_state_with_shimmer.dart';
import 'package:systego/features/admin/department/cubit/department_cubit.dart';
import 'package:systego/features/admin/department/presentation/widgets/department_form_dialog.dart';
import 'package:systego/features/admin/department/presentation/widgets/departments_list.dart';
import 'package:systego/generated/locale_keys.g.dart';
import '../../../../../core/widgets/custom_snack_bar/custom_snackbar.dart';

class DepartmentScreen extends StatefulWidget {
  const DepartmentScreen({super.key});

  @override
  State<DepartmentScreen> createState() => _DepartmentScreenState();
}

class _DepartmentScreenState extends State<DepartmentScreen> {
  void departmentsInit() async {
    context.read<DepartmentCubit>().getAllDepartments();
  }

  @override
  void initState() {
    super.initState();
    departmentsInit();
  }

  Future<void> _refresh() async {
    departmentsInit();
  }

  Widget _buildListContent() {
    return BlocConsumer<DepartmentCubit, DepartmentState>(
      listener: (context, state) {
        if (state is GetDepartmentsError) {
          CustomSnackbar.showError(context, state.error);
        } else if (state is DeleteDepartmentError) {
          CustomSnackbar.showError(context, state.error);
          departmentsInit();
        } else if (state is DeleteDepartmentSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          departmentsInit();
        } else if (state is CreateDepartmentSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          departmentsInit();
        } else if (state is UpdateDepartmentSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          departmentsInit();
        }
      },
      builder: (context, state) {
        if (state is GetDepartmentsLoading ||
            state is DeleteDepartmentLoading
           ) {
          return RefreshIndicator(
            onRefresh: _refresh,
            color: AppColors.primaryBlue,
            child: CustomLoadingShimmer(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
            ),
          );
        } else if (state is GetDepartmentsSuccess) {
          final departments = state.departments;

          if (departments.isEmpty) {
            String title = departments.isEmpty
                ? LocaleKeys.no_departments.tr()
                : LocaleKeys.no_matching_departments.tr();
            String message = departments.isEmpty
                ? LocaleKeys.cities_all_caught_up.tr()
                : LocaleKeys.cities_try_adjusting_filters.tr();
            return CustomEmptyState(
              icon: Icons.monetization_on_rounded,
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
              child: DepartmentsList(departments: departments,)
            );
          }
        } else {
          return CustomEmptyState(
            icon: Icons.monetization_on_rounded,
            title: LocaleKeys.no_departments.tr(),
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
    return Scaffold(
      appBar: appBarWithActions(
        context,
        title: LocaleKeys.departments_title.tr(),
        showActions: true,
        onPressed: () => showDialog(
          context: context,
          builder: (context) => DepartmentFormDialog(),
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
