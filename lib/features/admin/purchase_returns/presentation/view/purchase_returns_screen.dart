import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:GoSystem/core/widgets/animation/animated_element.dart';
import 'package:GoSystem/core/widgets/app_bar_widgets.dart';
import 'package:GoSystem/core/widgets/custom_error/custom_empty_state.dart';
import 'package:GoSystem/core/widgets/custom_loading/custom_loading_state_with_shimmer.dart';
import 'package:GoSystem/core/widgets/custom_snack_bar/custom_snackbar.dart';
import 'package:GoSystem/features/admin/bank_account/cubit/bank_account_cubit.dart';
import 'package:GoSystem/features/admin/purchase_returns/cubit/purchase_return_cubit.dart';
import 'package:GoSystem/features/admin/purchase_returns/model/purchase_return_model.dart';
import 'package:GoSystem/features/admin/purchase_returns/presentation/widgets/add_purchase_return_dialog.dart';
import 'package:GoSystem/features/admin/purchase_returns/presentation/widgets/purchase_return_card.dart';
import 'package:GoSystem/features/admin/purchase_returns/presentation/widgets/purchase_return_form_dialog.dart';
import 'package:GoSystem/features/admin/warehouses/view/widgets/custom_delete_dialog.dart';

class PurchaseReturnsScreen extends StatefulWidget {
  const PurchaseReturnsScreen({super.key});

  @override
  State<PurchaseReturnsScreen> createState() => _PurchaseReturnsScreenState();
}

class _PurchaseReturnsScreenState extends State<PurchaseReturnsScreen> {
  void _init() => context.read<PurchaseReturnCubit>().getReturns();

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<PurchaseReturnCubit>()),
          BlocProvider.value(value: context.read<BankAccountCubit>()),
        ],
        child: const AddPurchaseReturnDialog(),
      ),
    );
  }

  void _showEditDialog(PurchaseReturnModel r) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<PurchaseReturnCubit>(),
        child: PurchaseReturnFormDialog(returnModel: r),
      ),
    );
  }

  void _showDeleteDialog(PurchaseReturnModel r) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => CustomDeleteDialog(
        title: 'Delete Return',
        message: 'Are you sure you want to delete return #${r.reference}?',
        onDelete: () {
          Navigator.pop(ctx);
          context.read<PurchaseReturnCubit>().deleteReturn(r.id);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWithActions(
        context,
        title: 'Purchase Returns',
        showActions: true,
        onPressed: _showAddDialog,
      ),
      body: BlocConsumer<PurchaseReturnCubit, PurchaseReturnState>(
        listener: (context, state) {
          if (state is GetReturnsError) {
            CustomSnackbar.showError(context, state.error);
          } else if (state is DeleteReturnSuccess) {
            CustomSnackbar.showSuccess(context, state.message);
          } else if (state is DeleteReturnError) {
            CustomSnackbar.showError(context, state.error);
          } else if (state is CreateReturnSuccess) {
            CustomSnackbar.showSuccess(context, state.message);
          } else if (state is UpdateReturnSuccess) {
            CustomSnackbar.showSuccess(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is GetReturnsLoading ||
              state is DeleteReturnLoading ||
              state is CreateReturnLoading) {
            return RefreshIndicator(
              onRefresh: () => context.read<PurchaseReturnCubit>().getReturns(),
              color: AppColors.primaryBlue,
              child: CustomLoadingShimmer(
                padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
              ),
            );
          }

          if (state is GetReturnsSuccess) {
            final returns = state.data.returns;

            // ── Summary banner ──
            final summaryBanner = _SummaryBanner(
              totalReturns: state.data.totalReturns,
              totalAmount: state.data.totalAmount,
            );

            if (returns.isEmpty) {
              return Column(
                children: [
                  summaryBanner,
                  Expanded(
                    child: CustomEmptyState(
                      icon: Icons.assignment_return_rounded,
                      title: 'No Returns',
                      message: 'No purchase returns found.',
                      onRefresh: () => context.read<PurchaseReturnCubit>().getReturns(),
                      actionLabel: 'Retry',
                      onAction: _init,
                    ),
                  ),
                ],
              );
            }

            return RefreshIndicator(
              onRefresh: () => context.read<PurchaseReturnCubit>().getReturns(),
              color: AppColors.primaryBlue,
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: ResponsiveUI.contentMaxWidth(context)),
                  child: AnimatedElement(
                    delay: const Duration(milliseconds: 200),
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(child: summaryBanner),
                        SliverPadding(
                          padding: EdgeInsets.symmetric(
                              horizontal: ResponsiveUI.padding(context, 16)),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (_, i) => PurchaseReturnCard(
                                returnModel: returns[i],
                                index: i,
                                onEdit: () => _showEditDialog(returns[i]),
                                onDelete: () =>
                                    _showDeleteDialog(returns[i]),
                              ),
                              childCount: returns.length,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          return CustomEmptyState(
            icon: Icons.assignment_return_rounded,
            title: 'No Returns',
            message: 'Could not load returns.',
            onRefresh: () => context.read<PurchaseReturnCubit>().getReturns(),
            actionLabel: 'Retry',
            onAction: _init,
          );
        },
      ),
    );
  }
}

// ─── Summary Banner ───────────────────────────────────────────────────────────

class _SummaryBanner extends StatelessWidget {
  final int totalReturns;
  final double totalAmount;
  const _SummaryBanner(
      {required this.totalReturns, required this.totalAmount});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUI.padding(context, 20),
        vertical: ResponsiveUI.padding(context, 16),
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryBlue, Color(0xFF0056CC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius:
            BorderRadius.circular(ResponsiveUI.borderRadius(context, 16)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(ResponsiveUI.padding(context, 10)),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
            ),
            child: Icon(Icons.assignment_return_rounded,
                color: Colors.white, size: ResponsiveUI.iconSize(context, 24)),
          ),
          SizedBox(width: ResponsiveUI.spacing(context, 14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$totalReturns Returns',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: ResponsiveUI.fontSize(context, 12),
                        fontWeight: FontWeight.w500)),
                Text(
                  '${totalAmount.toStringAsFixed(2)} EGP',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: ResponsiveUI.fontSize(context, 22),
                      fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
