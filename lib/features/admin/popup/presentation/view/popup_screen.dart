import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:GoSystem/core/widgets/animation/animated_element.dart';
import 'package:GoSystem/core/widgets/app_bar_widgets.dart';
import 'package:GoSystem/core/widgets/custom_error/custom_empty_state.dart';
import 'package:GoSystem/core/widgets/custom_loading/custom_loading_state_with_shimmer.dart';
import 'package:GoSystem/features/admin/popup/cubit/popup_cubit.dart';
import 'package:GoSystem/features/admin/popup/presentation/view/create_popup_screen.dart';
import 'package:GoSystem/features/admin/popup/presentation/widgets/popups_list.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';
import '../../../../../core/widgets/custom_snack_bar/custom_snackbar.dart';

class PopupScreen extends StatefulWidget {
  const PopupScreen({super.key});

  @override
  State<PopupScreen> createState() => _PopupScreenState();
}

class _PopupScreenState extends State<PopupScreen> {
  void popupsInit() async {
    context.read<PopupCubit>().getAllPopups();
  }

  @override
  void initState() {
    super.initState();
    popupsInit();
  }

  Future<void> _refresh() async {
    popupsInit();
  }

  Widget _buildListContent() {
    return BlocConsumer<PopupCubit, PopupState>(
      listener: (context, state) {
        if (state is GetPopupsError) {
          CustomSnackbar.showError(context, state.error);
        } else if (state is DeletePopupError) {
          CustomSnackbar.showError(context, state.error);
          popupsInit();
        } else if (state is DeletePopupSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          popupsInit();
        } else if (state is CreatePopupSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          popupsInit();
        } else if (state is UpdatePopupSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          popupsInit();
        }
      },
      builder: (context, state) {
        if (state is GetPopupsLoading ||
            state is DeletePopupLoading) {
          return RefreshIndicator(
            onRefresh: _refresh,
            color: AppColors.primaryBlue,
            child: CustomLoadingShimmer(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
            ),
          );
        } else if (state is GetPopupsSuccess) {
          final popups = state.popups;
   
          if (popups.isEmpty) {
            return CustomEmptyState(
              icon: Icons.open_in_new,
              title: LocaleKeys.no_popups_title.tr(),
              message: LocaleKeys.no_popups_message.tr(),
              onRefresh: _refresh,
              actionLabel: LocaleKeys.retry.tr(),
              onAction: _refresh,
            );
          } else {
            return RefreshIndicator(
              onRefresh: _refresh,
              color: AppColors.primaryBlue,
              child: PopupsList(popups: popups),
            );
          }
        } else {
          return CustomEmptyState(
            icon: Icons.open_in_new,
            title: LocaleKeys.no_popups_title.tr(),
            message: LocaleKeys.no_popups_default_message.tr(),
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
        title: LocaleKeys.popups_title.tr(),
        showActions: true,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreatePopupScreen()),
          );
          if (result == true && mounted) {
            popupsInit();
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
