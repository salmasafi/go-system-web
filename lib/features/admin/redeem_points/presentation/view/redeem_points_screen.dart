import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/animation/animated_element.dart';
import 'package:systego/core/widgets/app_bar_widgets.dart';
import 'package:systego/core/widgets/custom_error/custom_empty_state.dart';
import 'package:systego/core/widgets/custom_loading/custom_loading_state_with_shimmer.dart';
import 'package:systego/core/widgets/custom_snack_bar/custom_snackbar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:systego/generated/locale_keys.g.dart';
import '../../cubit/redeem_points_cubit.dart';
import '../widgets/add_redeem_points_dialog.dart';
import '../widgets/redeem_points_card.dart';

class RedeemPointsScreen extends StatefulWidget {
  const RedeemPointsScreen({super.key});

  @override
  State<RedeemPointsScreen> createState() => _RedeemPointsScreenState();
}

class _RedeemPointsScreenState extends State<RedeemPointsScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<RedeemPointsCubit>().getRedeemPoints();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    _searchController.clear();
    context.read<RedeemPointsCubit>().search('');
    await context.read<RedeemPointsCubit>().getRedeemPoints();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWithActions(
        context,
        title: LocaleKeys.redeem_points_title.tr(),
        showActions: true,
        onPressed: () => showDialog(
          context: context,
          builder: (_) => BlocProvider.value(
            value: context.read<RedeemPointsCubit>(),
            child: const AddRedeemPointsDialog(),
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: ResponsiveUI.contentMaxWidth(context),
          ),
          child: Column(
            children: [
              // ── Search bar ──
              Padding(
                padding: EdgeInsets.fromLTRB(
                  ResponsiveUI.padding(context, 16),
                  ResponsiveUI.padding(context, 12),
                  ResponsiveUI.padding(context, 16),
                  0,
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) =>
                      context.read<RedeemPointsCubit>().search(v),
                  decoration: InputDecoration(
                    hintText: LocaleKeys.search_hint.tr(),
                    hintStyle: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 13),
                      color: AppColors.shadowGray,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: AppColors.shadowGray,
                      size: ResponsiveUI.iconSize(context, 20),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.close_rounded,
                                color: AppColors.shadowGray),
                            onPressed: () {
                              _searchController.clear();
                              context.read<RedeemPointsCubit>().search('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.white,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: ResponsiveUI.padding(context, 16),
                      vertical: ResponsiveUI.padding(context, 12),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveUI.borderRadius(context, 12),
                      ),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveUI.borderRadius(context, 12),
                      ),
                      borderSide: BorderSide(
                        color: AppColors.lightGray.withValues(alpha: 0.5),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveUI.borderRadius(context, 12),
                      ),
                      borderSide: BorderSide(
                        color: const Color(0xFFE65100),
                        width: ResponsiveUI.value(context, 1.5),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: ResponsiveUI.spacing(context, 8)),

              // ── List ──
              Expanded(child: _buildList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList() {
    return BlocConsumer<RedeemPointsCubit, RedeemPointsState>(
      listener: (context, state) {
        if (state is GetRedeemPointsError) {
          CustomSnackbar.showError(context, state.error);
        } else if (state is CreateRedeemPointsSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
        } else if (state is CreateRedeemPointsError) {
          CustomSnackbar.showError(context, state.error);
        } else if (state is UpdateRedeemPointsSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
        } else if (state is UpdateRedeemPointsError) {
          CustomSnackbar.showError(context, state.error);
        } else if (state is DeleteRedeemPointsSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
        } else if (state is DeleteRedeemPointsError) {
          CustomSnackbar.showError(context, state.error);
        }
      },
      builder: (context, state) {
        if (state is GetRedeemPointsLoading) {
          return RefreshIndicator(
            onRefresh: _refresh,
            color: const Color(0xFFE65100),
            child: CustomLoadingShimmer(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
            ),
          );
        }

        if (state is GetRedeemPointsSuccess) {
          final redeemPoints = state.redeemPoints;

          if (redeemPoints.isEmpty) {
            return CustomEmptyState(
              icon: Icons.redeem_rounded,
              title: _searchController.text.isNotEmpty
                  ? LocaleKeys.no_matching_brands.tr() // Reusing available key
                  : LocaleKeys.no_brands_available.tr(), // Reusing available key
              message: _searchController.text.isNotEmpty
                  ? LocaleKeys.try_adjusting_search.tr()
                  : 'No redeem points configurations found',
              onRefresh: _refresh,
              actionLabel: 'Retry',
              onAction: _refresh,
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            color: const Color(0xFFE65100),
            child: AnimatedElement(
              delay: const Duration(milliseconds: 100),
              child: ListView.builder(
                padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
                itemCount: redeemPoints.length,
                itemBuilder: (context, index) => RedeemPointsCard(
                  redeemPoint: redeemPoints[index],
                  index: index,
                ),
              ),
            ),
          );
        }

        return CustomEmptyState(
          icon: Icons.redeem_rounded,
          title: LocaleKeys.no_brands_available.tr(),
          message: 'Pull to refresh or check your connection',
          onRefresh: _refresh,
          actionLabel: 'Retry',
          onAction: _refresh,
        );
      },
    );
  }
}
