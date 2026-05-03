import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:GoSystem/core/widgets/custom_error/custom_empty_state.dart';
import 'package:GoSystem/core/widgets/custom_loading/custom_loading_state_with_shimmer.dart';
import 'package:GoSystem/features/admin/roloes_and_permissions/cubit/roles_cubit.dart';
import 'package:GoSystem/features/admin/roloes_and_permissions/presentation/widgets/roles_list.dart';
import 'package:GoSystem/core/widgets/app_bar_widgets.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';
import 'create_role_screen.dart';
import '../../../../../core/widgets/custom_snack_bar/custom_snackbar.dart';

class RolesScreen extends StatefulWidget {
  const RolesScreen({super.key});

  @override
  State<RolesScreen> createState() => _RolesScreenState();
}

class _RolesScreenState extends State<RolesScreen> {
  void rolesInit() async {
    context.read<RolesCubit>().getAllRoles();
  }

  @override
  void initState() {
    super.initState();
    rolesInit();
  }

  Future<void> _refresh() async {
    rolesInit();
  }

  Widget _buildListContent() {
    return BlocConsumer<RolesCubit, RolesState>(
      listener: (context, state) {
        if (state is RolesError) {
          CustomSnackbar.showError(context, state.error);
        } else if (state is RolesDeleteError) {
          CustomSnackbar.showError(context, state.error);
          rolesInit();
        } else if (state is RolesDeleteSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          rolesInit();
        } else if (state is RolesCreateSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          rolesInit();
        } else if (state is RolesUpdateSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          rolesInit();
        }
      },
      builder: (context, state) {
        if (state is RolesLoading || state is RolesDeleting) {
          return RefreshIndicator(
            onRefresh: _refresh,
            color: AppColors.primaryBlue,
            child: CustomLoadingShimmer(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
            ),
          );
        } else if (state is RolesLoaded) {
          final roles = state.roles;

          if (roles.isEmpty) {
            String title = roles.isEmpty
                ? LocaleKeys.no_roles.tr()
                : LocaleKeys.no_matching_roles.tr();
            String message = roles.isEmpty
                ? LocaleKeys.roles_all_caught_up.tr()
                : LocaleKeys.roles_try_adjusting_filters.tr();
            return CustomEmptyState(
              icon: Icons.people_rounded,
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
              child: RolesList(roles: roles),
            );
          }
        } else {
          return CustomEmptyState(
            icon: Icons.people_rounded,
            title: LocaleKeys.no_roles.tr(),
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
        title: LocaleKeys.roles_title.tr(),
        showActions: true,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddRoleScreen()),
          );
        },
      ),
      body: SafeArea(
        child: Center(
          child: Text(
            'Roles Screen - Under Development',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
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
