import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:GoSystem/core/widgets/custom_loading/custom_loading_state.dart';
import 'package:GoSystem/features/admin/reports/cubit/reports_cubit.dart';
import 'package:GoSystem/features/admin/reports/cubit/reports_state.dart';

class CashierRevenueReportScreen extends StatefulWidget {
  const CashierRevenueReportScreen({super.key});

  @override
  State<CashierRevenueReportScreen> createState() =>
      _CashierRevenueReportScreenState();
}

class _CashierRevenueReportScreenState
    extends State<CashierRevenueReportScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() =>
      context.read<ReportsCubit>().loadCashierDailyRevenue(date: _selectedDate);

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.primaryBlue,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      _load();
    }
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBlueBackground,
      appBar: AppBar(
        title: const Text(
          'إيرادات الكاشير اليومية',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.darkGray,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined),
            tooltip: 'اختر تاريخ',
            onPressed: _pickDate,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<ReportsCubit, ReportsState>(
        builder: (context, state) {
          if (state is ReportsLoading) return const CustomLoadingState();

          if (state is ReportsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: ResponsiveUI.iconSize(context, 48),
                      color: AppColors.red),
                  SizedBox(height: ResponsiveUI.spacing(context, 12)),
                  Text(state.message,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.shadowGray)),
                  SizedBox(height: ResponsiveUI.spacing(context, 16)),
                  ElevatedButton.icon(
                    onPressed: _load,
                    icon: const Icon(Icons.refresh),
                    label: const Text('إعادة المحاولة'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white),
                  ),
                ],
              ),
            );
          }

          if (state is CashierDailyRevenueLoaded) {
            return _buildContent(state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(CashierDailyRevenueLoaded state) {
    if (state.totals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.point_of_sale_outlined,
                size: ResponsiveUI.iconSize(context, 64),
                color: AppColors.lightGray),
            SizedBox(height: ResponsiveUI.spacing(context, 16)),
            Text(
              'لا توجد مبيعات في ${_formatDate(_selectedDate)}',
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 16),
                color: AppColors.shadowGray,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
      children: [
        // Date header
        _DateHeader(date: _selectedDate, onTap: _pickDate),
        SizedBox(height: ResponsiveUI.spacing(context, 16)),

        // Grand total
        _GrandTotalCard(totals: state.totals),
        SizedBox(height: ResponsiveUI.spacing(context, 20)),

        // Per-cashier cards
        ...state.totals.map((t) {
          final breakdown = state.entries
              .where((e) => e.cashierId == t.cashierId)
              .toList();
          return _CashierCard(
            total: t,
            breakdown: breakdown,
          );
        }),
      ],
    );
  }
}

// ── Date header ──────────────────────────────────────────────────────────────
class _DateHeader extends StatelessWidget {
  final DateTime date;
  final VoidCallback onTap;
  const _DateHeader({required this.date, required this.onTap});

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUI.padding(context, 16),
          vertical: ResponsiveUI.padding(context, 10),
        ),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withValues(alpha: 0.1),
          borderRadius:
              BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
          border: Border.all(
              color: AppColors.primaryBlue.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_outlined,
                color: AppColors.primaryBlue,
                size: ResponsiveUI.iconSize(context, 18)),
            SizedBox(width: ResponsiveUI.spacing(context, 8)),
            Text(
              'تقرير يوم ${_fmt(date)}',
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w600,
                fontSize: ResponsiveUI.fontSize(context, 15),
              ),
            ),
            SizedBox(width: ResponsiveUI.spacing(context, 6)),
            Icon(Icons.edit_calendar_outlined,
                color: AppColors.primaryBlue,
                size: ResponsiveUI.iconSize(context, 16)),
          ],
        ),
      ),
    );
  }
}

// ── Grand total card ─────────────────────────────────────────────────────────
class _GrandTotalCard extends StatelessWidget {
  final List<CashierDailyTotal> totals;
  const _GrandTotalCard({required this.totals});

  @override
  Widget build(BuildContext context) {
    final grandTotal = totals.fold(0.0, (s, t) => s + t.totalAmount);
    final totalSales = totals.fold(0, (s, t) => s + t.saleCount);

    return Container(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryBlue, AppColors.darkBlue],
        ),
        borderRadius:
            BorderRadius.circular(ResponsiveUI.borderRadius(context, 16)),
      ),
      child: Row(
        children: [
          Icon(Icons.monetization_on_outlined,
              color: Colors.white,
              size: ResponsiveUI.iconSize(context, 40)),
          SizedBox(width: ResponsiveUI.spacing(context, 16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إجمالي إيرادات اليوم',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: ResponsiveUI.fontSize(context, 13),
                  ),
                ),
                Text(
                  '${grandTotal.toStringAsFixed(2)} ج.م',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: ResponsiveUI.fontSize(context, 24),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$totalSales بيعة',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: ResponsiveUI.fontSize(context, 16),
                ),
              ),
              Text(
                '${totals.length} كاشير',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: ResponsiveUI.fontSize(context, 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Per-cashier card ─────────────────────────────────────────────────────────
class _CashierCard extends StatelessWidget {
  final CashierDailyTotal total;
  final List<CashierRevenueEntry> breakdown;
  const _CashierCard({required this.total, required this.breakdown});

  Color _paymentColor(String type) {
    final t = type.toLowerCase();
    if (t.contains('كاش') || t.contains('cash')) return AppColors.successGreen;
    if (t.contains('كارت') || t.contains('card') || t.contains('فيزا'))
      return AppColors.primaryBlue;
    if (t.contains('محفظة') || t.contains('wallet')) return AppColors.warningOrange;
    return AppColors.shadowGray;
  }

  IconData _paymentIcon(String type) {
    final t = type.toLowerCase();
    if (t.contains('كاش') || t.contains('cash')) return Icons.payments_outlined;
    if (t.contains('كارت') || t.contains('card') || t.contains('فيزا'))
      return Icons.credit_card_outlined;
    if (t.contains('محفظة') || t.contains('wallet'))
      return Icons.account_balance_wallet_outlined;
    return Icons.payment_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveUI.spacing(context, 12)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius:
            BorderRadius.circular(ResponsiveUI.borderRadius(context, 14)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Cashier header
          Container(
            padding: EdgeInsets.all(ResponsiveUI.padding(context, 14)),
            decoration: BoxDecoration(
              color: AppColors.lightBlueBackground,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(ResponsiveUI.borderRadius(context, 14)),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: ResponsiveUI.value(context, 20),
                  backgroundColor: AppColors.primaryBlue,
                  child: Text(
                    total.cashierName.isNotEmpty
                        ? total.cashierName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: ResponsiveUI.spacing(context, 12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        total.cashierName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: ResponsiveUI.fontSize(context, 15),
                          color: AppColors.darkGray,
                        ),
                      ),
                      Text(
                        '${total.saleCount} بيعة',
                        style: TextStyle(
                          fontSize: ResponsiveUI.fontSize(context, 12),
                          color: AppColors.shadowGray,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${total.totalAmount.toStringAsFixed(2)} ج.م',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: ResponsiveUI.fontSize(context, 16),
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
          ),

          // Payment breakdown
          if (breakdown.isNotEmpty)
            Padding(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
              child: Column(
                children: breakdown.map((e) {
                  final color = _paymentColor(e.paymentType);
                  final icon = _paymentIcon(e.paymentType);
                  final pct = total.totalAmount > 0
                      ? (e.totalAmount / total.totalAmount * 100)
                      : 0.0;
                  return Padding(
                    padding: EdgeInsets.only(
                        bottom: ResponsiveUI.spacing(context, 8)),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(icon,
                                color: color,
                                size: ResponsiveUI.iconSize(context, 18)),
                            SizedBox(width: ResponsiveUI.spacing(context, 8)),
                            Expanded(
                              child: Text(
                                e.paymentType,
                                style: TextStyle(
                                  fontSize: ResponsiveUI.fontSize(context, 13),
                                  color: AppColors.darkGray,
                                ),
                              ),
                            ),
                            Text(
                              '${e.totalAmount.toStringAsFixed(2)} ج.م',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: ResponsiveUI.fontSize(context, 13),
                                color: color,
                              ),
                            ),
                            SizedBox(width: ResponsiveUI.spacing(context, 8)),
                            SizedBox(
                              width: ResponsiveUI.value(context, 40),
                              child: Text(
                                '${pct.toStringAsFixed(0)}%',
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  fontSize: ResponsiveUI.fontSize(context, 11),
                                  color: AppColors.shadowGray,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: ResponsiveUI.spacing(context, 4)),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: pct / 100,
                            backgroundColor:
                                color.withValues(alpha: 0.15),
                            valueColor:
                                AlwaysStoppedAnimation<Color>(color),
                            minHeight: ResponsiveUI.value(context, 5),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
