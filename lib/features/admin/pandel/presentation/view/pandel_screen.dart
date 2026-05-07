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
import 'package:GoSystem/features/admin/pandel/cubit/pandel_cubit.dart';
import 'package:GoSystem/features/admin/pandel/presentation/view/create_pandel_screen.dart';
import 'package:GoSystem/features/admin/pandel/presentation/widgets/pandels_list.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';
import '../../../../../core/widgets/custom_snack_bar/custom_snackbar.dart';

class PandelScreen extends StatefulWidget {
  const PandelScreen({super.key});

  @override
  State<PandelScreen> createState() => _PandelScreenState();
}

class _PandelScreenState extends State<PandelScreen> {
  // String _selectedFilter = 'all'; // 'all', 'active', 'upcoming'
  
  void pandelsInit() async {
    context.read<PandelCubit>().getAllPandels();
  }

  @override
  void initState() {
    super.initState();
    pandelsInit();
  }

  Future<void> _refresh() async {
    pandelsInit();
  }

 

  Widget _buildListContent() {
  return BlocConsumer<PandelCubit, PandelState>(
    listener: (context, state) {
      if (state is GetPandelsError) {
        CustomSnackbar.showError(context, state.error);
      } else if (state is DeletePandelError) {
        CustomSnackbar.showError(context, state.error);
        pandelsInit();
      } else if (state is DeletePandelSuccess) {
        CustomSnackbar.showSuccess(context, state.message);
        pandelsInit();
      } else if (state is CreatePandelSuccess) {
        CustomSnackbar.showSuccess(context, state.message);
        pandelsInit();
      } else if (state is UpdatePandelSuccess) {
        CustomSnackbar.showSuccess(context, state.message);
        pandelsInit();
      }
    },
    builder: (context, state) {
      if (state is GetPandelsLoading || state is DeletePandelLoading) {
        return RefreshIndicator(
          onRefresh: _refresh,
          color: AppColors.primaryBlue,
          child: CustomLoadingShimmer(
            padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
          ),
        );
      }

      if (state is GetPandelsSuccess) {
        if (state.pandels.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: _refresh,
          color: AppColors.primaryBlue,
          child: PandelsList(pandels: state.pandels),
        );
      }

      return _buildEmptyState();
    },
  );
}


  Widget _buildEmptyState() {
    String title, message;
    
    // switch (_selectedFilter) {
    //   case 'active':
    //     title = LocaleKeys.no_active_pandels_title.tr();
    //     message = LocaleKeys.no_active_pandels_message.tr();
    //     break;
    //   case 'upcoming':
    //     title = LocaleKeys.no_upcoming_pandels_title.tr();
    //     message = LocaleKeys.no_upcoming_pandels_message.tr();
    //     break;
    //   default:
    //     title = LocaleKeys.no_pandels_title.tr();
    //     message = LocaleKeys.no_pandels_message.tr();
    // }

    title = LocaleKeys.no_pandels_title.tr();
        message = LocaleKeys.no_pandels_message.tr();

    return CustomEmptyState(
      icon: Icons.collections_bookmark,
      title: title,
      message: message,
      onRefresh: _refresh,
      actionLabel: LocaleKeys.retry.tr(),
      onAction: _refresh,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Scale down for web
    Widget screenContent = Scaffold(
      backgroundColor: AppColors.lightBlueBackground,
      appBar: appBarWithActions(
        context,
        title: LocaleKeys.pandels_title.tr(),
        showActions: true,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreatePandelScreen()),
          );
          if (result == true && mounted) {
            pandelsInit();
          }
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
