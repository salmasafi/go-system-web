import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/widgets/custom_loading/custom_loading_state.dart';
import 'package:GoSystem/core/widgets/custom_snack_bar/custom_snackbar.dart';
import 'package:GoSystem/features/pos/history/cubit/history_cubit.dart';
import 'package:GoSystem/features/pos/history/cubit/history_state.dart';
import 'package:GoSystem/features/pos/history/model/sale_model.dart';
import 'package:GoSystem/features/pos/history/presentation/widgets/pay_due_dialog.dart';
import 'package:GoSystem/features/pos/home/cubit/pos_home_cubit.dart';

class DuesScreen extends StatefulWidget {
  const DuesScreen({super.key});

  @override
  State<DuesScreen> createState() => _DuesScreenState();
}

class _DuesScreenState extends State<DuesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HistoryCubit>().getAllDues();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBlueBackground,
      appBar: AppBar(
        title: Text(
          'Due Users',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: ResponsiveUI.fontSize(context, 18)),
        ),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.darkGray,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: ResponsiveUI.value(context, 1), color: AppColors.lightGray),
        ),
      ),
      body: BlocConsumer<HistoryCubit, HistoryState>(
        listener: (context, state) {
          if (state is DuesPaySuccess) {
            CustomSnackbar.showSuccess(context, 'Payment recorded successfully');
            context.read<HistoryCubit>().getAllDues();
          } else if (state is DuesPayError) {
            CustomSnackbar.showError(context, state.message);
          }
        },
        buildWhen: (prev, curr) =>
            curr is DuesLoading ||
            curr is DuesLoaded ||
            curr is DuesPayLoading ||
            curr is DuesPaySuccess ||
            curr is HistoryError,
        builder: (context, state) {
          if (state is DuesLoading) {
            return Center(child: CustomLoadingState());
          }

          if (state is HistoryError) {
            return _ErrorView(
              message: state.message,
              onRetry: () => context.read<HistoryCubit>().getAllDues(),
            );
          }

          if (state is DuesLoaded) {
            if (state.customers.isEmpty) {
              return const _EmptyView();
            }
            return _DuesContent(
              customers: state.customers,
              totalDue: state.totalDueAmount,
            );
          }

          return SizedBox();
        },
      ),
    );
  }
}

// ─── Content ──────────────────────────────────────────────────────────────────

class _DuesContent extends StatelessWidget {
  final List<CustomerDueModel> customers;
  final double totalDue;

  const _DuesContent({required this.customers, required this.totalDue});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primaryBlue,
      onRefresh: () => context.read<HistoryCubit>().getAllDues(),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _TotalBanner(totalDue: totalDue)),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _CustomerDueCard(customer: customers[index]),
                childCount: customers.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Total Banner ─────────────────────────────────────────────────────────────

class _TotalBanner extends StatelessWidget {
  final double totalDue;
  const _TotalBanner({required this.totalDue});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
      padding: EdgeInsets.symmetric(horizontal: ResponsiveUI.padding(context, 20), vertical: ResponsiveUI.padding(context, 16)),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryBlue, AppColors.darkBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 16)),
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
            child: Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: ResponsiveUI.iconSize(context, 24)),
          ),
          SizedBox(width: ResponsiveUI.value(context, 14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Outstanding',
                  style: TextStyle(color: Colors.white70, fontSize: ResponsiveUI.fontSize(context, 12), fontWeight: FontWeight.w500),
                ),
                SizedBox(height: ResponsiveUI.value(context, 2)),
                Text(
                  '${totalDue.toStringAsFixed(2)} EGP',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ResponsiveUI.fontSize(context, 22),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: ResponsiveUI.padding(context, 10), vertical: ResponsiveUI.padding(context, 5)),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 20)),
            ),
            child: Icon(Icons.warning_amber_rounded, color: Colors.white, size: ResponsiveUI.iconSize(context, 18)),
          ),
        ],
      ),
    );
  }
}

// ─── Customer Due Card ────────────────────────────────────────────────────────

class _CustomerDueCard extends StatelessWidget {
  final CustomerDueModel customer;
  const _CustomerDueCard({required this.customer});

  static const _purple = AppColors.primaryBlue;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HistoryCubit, HistoryState>(
      builder: (context, state) {
        final isPaying = state is DuesPayLoading &&
            customer.sales.any((s) => s.id == state.saleId);

        return Container(
          margin: EdgeInsets.only(bottom: ResponsiveUI.padding(context, 12)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Name + Avatar ──
                Row(
                  children: [
                    Container(
                      width: ResponsiveUI.value(context, 44),
                      height: ResponsiveUI.value(context, 44),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primaryBlue, AppColors.darkBlue],
                        ),
                        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
                      ),
                      child: Center(
                        child: Text(
                          customer.customerName.isNotEmpty
                              ? customer.customerName[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: ResponsiveUI.fontSize(context, 18),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: ResponsiveUI.value(context, 12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customer.customerName,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: ResponsiveUI.fontSize(context, 16),
                              color: AppColors.darkGray,
                            ),
                          ),
                          if (customer.phone.isNotEmpty)
                            Row(
                              children: [
                                Icon(Icons.phone_outlined,
                                    size: ResponsiveUI.iconSize(context, 12), color: AppColors.shadowGray),
                                SizedBox(width: ResponsiveUI.value(context, 4)),
                                Text(
                                  customer.phone,
                                  style: TextStyle(
                                      fontSize: ResponsiveUI.fontSize(context, 12),
                                      color: AppColors.shadowGray),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    // Sales count badge
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveUI.padding(context, 8), vertical: ResponsiveUI.padding(context, 4)),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 8)),
                      ),
                      child: Text(
                        '${customer.sales.length} sale${customer.sales.length > 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: ResponsiveUI.fontSize(context, 11),
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkBlue,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ResponsiveUI.value(context, 14)),
                Divider(height: ResponsiveUI.value(context, 1), color: AppColors.primaryBlue.withValues(alpha: 0.08)),
                SizedBox(height: ResponsiveUI.value(context, 12)),
                // ── Total Due ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Due:',
                      style: TextStyle(
                          fontSize: ResponsiveUI.fontSize(context, 14), color: AppColors.shadowGray),
                    ),
                    Text(
                      '${customer.totalDue.toStringAsFixed(2)} EGP',
                      style: TextStyle(
                        fontSize: ResponsiveUI.fontSize(context, 16),
                        fontWeight: FontWeight.w800,
                        color: _purple,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ResponsiveUI.value(context, 14)),
                // ── Pay Button ──
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isPaying
                        ? null
                        : () => _showPayDialog(context, customer),
                    icon: isPaying
                        ? SizedBox(
                            width: ResponsiveUI.value(context, 16),
                            height: ResponsiveUI.value(context, 16),
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Icon(Icons.payment_rounded, size: ResponsiveUI.iconSize(context, 18)),
                    label: Text(
                      isPaying ? 'Processing...' : 'Pay Now',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: ResponsiveUI.fontSize(context, 14)),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _purple,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: ResponsiveUI.padding(context, 12)),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12))),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPayDialog(BuildContext context, CustomerDueModel customer) {
    // Show dialog for the first due sale of this customer
    final due = customer.sales.first;

    showDialog(
      context: context,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<HistoryCubit>()),
          BlocProvider.value(value: context.read<PosCubit>()),
        ],
        child: PayDueDialog(due: due),
      ),
    );
  }
}

// ─── Empty View ───────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(ResponsiveUI.padding(context, 24)),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_circle_outline_rounded, size: ResponsiveUI.iconSize(context, 56), color: AppColors.primaryBlue),
          ),
          SizedBox(height: ResponsiveUI.value(context, 20)),
          Text(
            'No Dues',
            style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 20), fontWeight: FontWeight.w700, color: AppColors.darkGray),
          ),
          SizedBox(height: ResponsiveUI.value(context, 8)),
          Text(
            'All customers are up to date',
            style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 14), color: AppColors.shadowGray),
          ),
        ],
      ),
    );
  }
}

// ─── Error View ───────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: ResponsiveUI.iconSize(context, 48), color: AppColors.red),
          SizedBox(height: ResponsiveUI.value(context, 12)),
          Text(message, textAlign: TextAlign.center, style: TextStyle(color: AppColors.shadowGray)),
          SizedBox(height: ResponsiveUI.value(context, 16)),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 10))),
            ),
          ),
        ],
      ),
    );
  }
}

