import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/animation/animated_element.dart';
import 'package:systego/core/widgets/app_bar_widgets.dart';
import 'package:systego/core/widgets/custom_error/custom_empty_state.dart';
import 'package:systego/core/widgets/custom_loading/custom_loading_state_with_shimmer.dart';
import 'package:systego/features/admin/pandel/cubit/pandel_cubit.dart';
import 'package:systego/features/admin/pandel/presentation/view/create_pandel_screen.dart';
import 'package:systego/features/admin/pandel/presentation/widgets/pandels_list.dart';
import 'package:systego/generated/locale_keys.g.dart';
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

  // List<PandelModel> _filterPandels(List<PandelModel> pandels) {
  //   switch (_selectedFilter) {
  //     case 'active':
  //       final now = DateTime.now();
  //       return pandels.where((pandel) => 
  //         now.isAfter(pandel.startDate) && now.isBefore(pandel.endDate)
  //       ).toList();
  //     case 'upcoming':
  //       final now = DateTime.now();
  //       return pandels.where((pandel) => pandel.startDate.isAfter(now)).toList();
  //     default:
  //       return pandels;
  //   }
  // }

  // Widget _buildFilterChips() {
  //   return Padding(
  //     padding: EdgeInsets.symmetric(
  //       horizontal: ResponsiveUI.padding(context, 16),
  //       vertical: ResponsiveUI.padding(context, 8),
  //     ),
  //     child: Wrap(
  //       spacing: ResponsiveUI.padding(context, 8),
  //       children: [
  //         _buildFilterChip('all', LocaleKeys.all_pandels.tr()),
  //         _buildFilterChip('active', LocaleKeys.active_pandels.tr()),
  //         _buildFilterChip('upcoming', LocaleKeys.upcoming_pandels.tr()),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildFilterChip(String value, String label) {
  //   return FilterChip(
  //     selected: _selectedFilter == value,
  //     onSelected: (selected) {
  //       setState(() {
  //         _selectedFilter = value;
  //       });
  //     },
  //     label: Text(label),
  //     selectedColor: AppColors.primaryBlue.withOpacity(0.2),
  //     checkmarkColor: AppColors.primaryBlue,
  //     labelStyle: TextStyle(
  //       color: _selectedFilter == value ? AppColors.primaryBlue : Colors.grey[700],
  //       fontWeight: _selectedFilter == value ? FontWeight.bold : FontWeight.normal,
  //     ),
  //   );
  // }

  // Widget _buildListContent() {
  //   return BlocConsumer<PandelCubit, PandelState>(
  //     listener: (context, state) {
  //       if (state is GetPandelsError) {
  //         CustomSnackbar.showError(context, state.error);
  //       } else if (state is DeletePandelError) {
  //         CustomSnackbar.showError(context, state.error);
  //         pandelsInit();
  //       } else if (state is DeletePandelSuccess) {
  //         CustomSnackbar.showSuccess(context, state.message);
  //         pandelsInit();
  //       } else if (state is CreatePandelSuccess) {
  //         CustomSnackbar.showSuccess(context, state.message);
  //         pandelsInit();
  //       } else if (state is UpdatePandelSuccess) {
  //         CustomSnackbar.showSuccess(context, state.message);
  //         pandelsInit();
  //       }
  //     },
  //     builder: (context, state) {
  //       if (state is GetPandelsLoading || state is DeletePandelLoading) {
  //         return RefreshIndicator(
  //           onRefresh: _refresh,
  //           color: AppColors.primaryBlue,
  //           child: Column(
  //             children: [
  //               _buildFilterChips(),
  //               Expanded(
  //                 child: CustomLoadingShimmer(
  //                   padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         );
  //       } else if (state is GetPandelsSuccess) {
  //         final pandels = _filterPandels(state.pandels);

  //         if (pandels.isEmpty) {
  //           return Column(
  //             children: [
  //               _buildFilterChips(),
  //               Expanded(
  //                 child: _buildEmptyState(),
  //               ),
  //             ],
  //           );
  //         } else {
  //           return RefreshIndicator(
  //             onRefresh: _refresh,
  //             color: AppColors.primaryBlue,
  //             child: Column(
  //               children: [
  //                 _buildFilterChips(),
  //                 Expanded(
  //                   child: PandelsList(pandels: pandels),
  //                 ),
  //               ],
  //             ),
  //           );
  //         }
  //       } else {
  //         return Column(
  //           children: [
  //             _buildFilterChips(),
  //             Expanded(
  //               child: _buildEmptyState(),
  //             ),
  //           ],
  //         );
  //       }
  //     },
  //   );
  // }

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
    return Scaffold(
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