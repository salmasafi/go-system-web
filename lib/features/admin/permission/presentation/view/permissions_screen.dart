import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:GoSystem/core/widgets/animation/animated_element.dart';
import 'package:GoSystem/core/widgets/app_bar_widgets.dart';
import 'package:GoSystem/core/widgets/custom_error/custom_empty_state.dart';
import 'package:GoSystem/core/widgets/custom_loading/custom_loading_state_with_shimmer.dart';
import 'package:GoSystem/core/widgets/custom_snack_bar/custom_snackbar.dart';
import 'package:GoSystem/features/admin/permission/cubit/permission_cubit.dart';
import 'package:GoSystem/features/admin/permission/presentation/view/create_permission_screen.dart';
import 'package:GoSystem/features/admin/permission/presentation/widgets/permissions_list.dart';


class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  void permissionsInit() async {
    context.read<PermissionCubit>().getAllPermissions();
  }

  @override
  void initState() {
    super.initState();
    permissionsInit();
  }

  Future<void> _refresh() async {
    permissionsInit();
  }

  Widget _buildListContent() {
    return BlocConsumer<PermissionCubit, PermissionState>(
      listener: (context, state) {
        if (state is GetPermissionsError) {
          CustomSnackbar.showError(context, state.error);

        } else if (state is DeletePermissionError) {
          CustomSnackbar.showError(context, state.error);
          permissionsInit();

        } else if (state is DeletePermissionSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          permissionsInit();

        } else if (state is CreatePermissionSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          permissionsInit();

        } else if (state is UpdatePermissionSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          permissionsInit();
        }
      },
      builder: (context, state) {
        if (state is GetPermissionsLoading || state is DeletePermissionLoading) {
          return RefreshIndicator(
            onRefresh: _refresh,
            color: AppColors.primaryBlue,
            child: CustomLoadingShimmer(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
            ),
          );
        }

        else if (state is GetPermissionsSuccess) {
          final permissions = state.permissions;

          if (permissions.isEmpty) {
            return CustomEmptyState(
              icon: Icons.policy,
              title: 'No Permissions',
              message: 'You have not added any permissions yet.',
              onRefresh: _refresh,
              actionLabel: 'Retry',
              onAction: _refresh,
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            color: AppColors.primaryBlue,
            child: PermissionsList(permissions: permissions),
          );
        }

        return CustomEmptyState(
          icon: Icons.policy,
          title: 'No Permissions',
          message: 'Pull to refresh or check your connection',
          onRefresh: _refresh,
          actionLabel: 'Retry',
          onAction: _refresh,
        );
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
        title: LocaleKeys.permissions.tr(),
        showActions: true,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreatePermissionScreen()),
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
