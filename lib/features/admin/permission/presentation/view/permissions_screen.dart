import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/animation/animated_element.dart';
import 'package:systego/core/widgets/app_bar_widgets.dart';
import 'package:systego/core/widgets/custom_error/custom_empty_state.dart';
import 'package:systego/core/widgets/custom_loading/custom_loading_state_with_shimmer.dart';
import 'package:systego/core/widgets/custom_snack_bar/custom_snackbar.dart';
import 'package:systego/features/admin/permission/cubit/permission_cubit.dart';
import 'package:systego/features/admin/permission/presentation/view/create_permission_screen.dart';
import 'package:systego/features/admin/permission/presentation/widgets/permissions_list.dart';


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
    return Scaffold(
      appBar: appBarWithActions(
        context,
        title: 'Permissions',
        showActions: true,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreatePermissionScreen()),
          );
          if (result == true && mounted) {
            permissionsInit();
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
