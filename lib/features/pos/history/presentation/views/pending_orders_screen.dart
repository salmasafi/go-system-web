import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/widgets/custom_loading/custom_loading_state.dart';
import 'package:GoSystem/features/pos/history/cubit/history_cubit.dart';
import 'package:GoSystem/features/pos/history/cubit/history_state.dart';
import 'package:GoSystem/features/pos/history/model/sale_model.dart';
import 'package:GoSystem/features/pos/history/presentation/views/pending_sale_details_screen.dart';

class PendingOrdersScreen extends StatefulWidget {
  const PendingOrdersScreen({super.key});

  @override
  State<PendingOrdersScreen> createState() => _PendingOrdersScreenState();
}

class _PendingOrdersScreenState extends State<PendingOrdersScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HistoryCubit>().getPendingSales();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.access_time_rounded, color: AppColors.primaryBlue, size: ResponsiveUI.iconSize(context, 22)),
            SizedBox(width: ResponsiveUI.value(context, 8)),
            Text(
              'Pending Orders',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: ResponsiveUI.fontSize(context, 18),
                color: AppColors.darkGray,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.darkGray),
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: ResponsiveUI.value(context, 1), color: AppColors.lightGray),
        ),
      ),
      body: BlocBuilder<HistoryCubit, HistoryState>(
        buildWhen: (prev, curr) =>
            curr is PendingLoading ||
            curr is PendingLoaded ||
            curr is HistoryError,
        builder: (context, state) {
          if (state is PendingLoading) {
            return Center(child: CustomLoadingState());
          }
          if (state is HistoryError) {
            return _ErrorView(
              message: state.message,
              onRetry: () => context.read<HistoryCubit>().getPendingSales(),
            );
          }
          if (state is PendingLoaded) {
            if (state.pendingSales.isEmpty) {
              return const _EmptyView();
            }
            return RefreshIndicator(
              color: AppColors.primaryBlue,
              onRefresh: () => context.read<HistoryCubit>().getPendingSales(),
              child: ListView.builder(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 24),
                itemCount: state.pendingSales.length,
                itemBuilder: (context, index) =>
                    _PendingCard(sale: state.pendingSales[index]),
              ),
            );
          }
          return SizedBox();
        },
      ),
    );
  }
}

// ─── Pending Card ─────────────────────────────────────────────────────────────

class _PendingCard extends StatelessWidget {
  final PendingSaleModel sale;
  const _PendingCard({required this.sale});

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return '${dt.day.toString().padLeft(2, '0')}/'
          '${dt.month.toString().padLeft(2, '0')}/'
          '${dt.year} '
          '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}:'
          '${dt.second.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusLabel = _statusLabel(sale.status);
    final statusColor = _statusColor(sale.status);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PendingSaleDetailsScreen(saleId: sale.id),
        ),
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: ResponsiveUI.padding(context, 12)),
        padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 14)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Row 1: Reference + Status badge ──
            Row(
              children: [
                Text(
                  'Order #${sale.reference}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: ResponsiveUI.fontSize(context, 15),
                    color: AppColors.darkGray,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: ResponsiveUI.padding(context, 10), vertical: ResponsiveUI.padding(context, 4)),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 20)),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 12),
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: ResponsiveUI.value(context, 4)),

            // ── Date ──
            Text(
              _formatDate(sale.date),
              style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 12), color: AppColors.shadowGray),
            ),
            SizedBox(height: ResponsiveUI.value(context, 12)),

            // ── Info rows ──
            _InfoRow(label: 'Customer:', value: sale.customerName),
            SizedBox(height: ResponsiveUI.value(context, 4)),
            if (sale.warehouseName.isNotEmpty) ...[
              _InfoRow(label: 'Warehouse:', value: sale.warehouseName),
              SizedBox(height: ResponsiveUI.value(context, 4)),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total:',
                  style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 13), color: AppColors.shadowGray),
                ),
                Text(
                  '${sale.grandTotal.toStringAsFixed(2)} EGP',
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 14),
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),

            // ── Bottom dot indicator ──
            SizedBox(height: ResponsiveUI.value(context, 10)),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                width: ResponsiveUI.value(context, 8),
                height: ResponsiveUI.value(context, 8),
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'processed':
        return 'Processed';
      case 'pending':
        return 'Pending';
      case 'completed':
        return 'Completed';
      default:
        return status.isNotEmpty
            ? '${status[0].toUpperCase()}${status.substring(1)}'
            : 'Pending';
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'processed':
        return AppColors.darkGray;
      case 'completed':
        return AppColors.successGreen;
      case 'pending':
      default:
        return AppColors.warningOrange;
    }
  }
}

// ─── Info Row ─────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 13), color: AppColors.shadowGray)),
        Text(value,
            style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 13),
                fontWeight: FontWeight.w600,
                color: AppColors.darkGray)),
      ],
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
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.pending_actions_rounded,
                size: ResponsiveUI.iconSize(context, 52), color: AppColors.primaryBlue),
          ),
          SizedBox(height: ResponsiveUI.value(context, 20)),
          Text(
            'No Pending Orders',
            style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 18),
                fontWeight: FontWeight.w700,
                color: AppColors.darkGray),
          ),
          SizedBox(height: ResponsiveUI.value(context, 8)),
          Text(
            'All orders have been processed',
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
          Text(message,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.shadowGray)),
          SizedBox(height: ResponsiveUI.value(context, 16)),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 10))),
            ),
          ),
        ],
      ),
    );
  }
}
