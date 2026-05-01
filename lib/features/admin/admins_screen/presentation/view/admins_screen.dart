import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:systego/features/admin/admins_screen/cubit/admins_cubit.dart';
import 'package:systego/features/admin/admins_screen/presentation/widgets/admin_form_dialog.dart';
import 'package:systego/features/admin/admins_screen/presentation/widgets/admins_list.dart';
import 'package:systego/generated/locale_keys.g.dart';

import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/animation/animated_element.dart';
import 'package:systego/core/widgets/app_bar_widgets.dart';
import 'package:systego/core/widgets/custom_error/custom_empty_state.dart';
import 'package:systego/core/widgets/custom_loading/custom_loading_state_with_shimmer.dart';
import 'package:systego/core/widgets/custom_snack_bar/custom_snackbar.dart';


class AdminsScreen extends StatefulWidget {
  const AdminsScreen({super.key});

  @override
  State<AdminsScreen> createState() => _AdminsScreenState();
}

class _AdminsScreenState extends State<AdminsScreen> {
  void adminsInit() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminsCubit>().getAdmins();
    });
  }

  @override
  void initState() {
    super.initState();
    adminsInit();
  }

  Future<void> _refresh() async {
    adminsInit();
  }

  Widget _buildListContent() {
    return BlocConsumer<AdminsCubit, AdminsState>(
      listener: (context, state) {
        if (state is GetAdminsError) {
          CustomSnackbar.showError(context, state.error);
        } else if (state is DeleteAdminError) {
          CustomSnackbar.showError(context, state.error);
          adminsInit();
        } else if (state is DeleteAdminSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          adminsInit();
        } else if (state is CreateAdminSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          adminsInit();
        } else if (state is UpdateAdminSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          adminsInit();
        }
      },
      builder: (context, state) {
        if (state is GetAdminsLoading ||
            state is DeleteAdminLoading) {
          return RefreshIndicator(
            onRefresh: _refresh,
            color: AppColors.primaryBlue,
            child: CustomLoadingShimmer(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
            ),
          );
        } else if (state is GetAdminsSuccess) {
          final admins = state.admins;

          if (admins.isEmpty) {
            return CustomEmptyState(
              icon: Icons.supervised_user_circle,
              title: LocaleKeys.no_admins.tr(),
              message: LocaleKeys.no_admins.tr(),
              onRefresh: _refresh,
              actionLabel: LocaleKeys.retry.tr(),
              onAction: _refresh,
            );
          } else {
            return RefreshIndicator(
              onRefresh: _refresh,
              color: AppColors.primaryBlue,
              child: AdminsList(admins: admins)
            );
          }
        } else {
          return CustomEmptyState(
            icon: Icons.supervised_user_circle,
            title: LocaleKeys.no_admins.tr(),
            message: LocaleKeys.empty_message_connection.tr(),
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
        title: LocaleKeys.admins.tr(),
        showActions: true,
        onPressed: () => showDialog(
          context: context,
          builder: (context) => const AdminFormDialog(),
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
