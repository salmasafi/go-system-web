import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/widgets/app_bar_widgets.dart';
import 'package:GoSystem/core/widgets/custom_error/custom_empty_state.dart';
import 'package:GoSystem/core/widgets/custom_loading/custom_loading_state_with_shimmer.dart';
import 'package:GoSystem/features/admin/reports/cubit/reports_cubit.dart';
import 'package:GoSystem/features/admin/reports/cubit/reports_state.dart';
import 'package:GoSystem/features/admin/reports/models/shift_report_model.dart';
import '../widgets/report_summary_card.dart';
import '../widgets/report_data_table.dart';
import '../widgets/date_range_filter.dart';

/// Shift Report Screen
/// Displays cashier shift data, performance, and summaries
class ShiftReportScreen extends StatefulWidget {
  const ShiftReportScreen({super.key});

  @override
  State<ShiftReportScreen> createState() => _ShiftReportScreenState();
}

class _ShiftReportScreenState extends State<ShiftReportScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, 1);
    _endDate = now;
    _loadData();
  }

  void _loadData() {
    context.read<ReportsCubit>().loadShiftReport(
      startDate: _startDate,
      endDate: _endDate,
    );
  }

  void _onDateRangeChanged(DateTime? start, DateTime? end) {
    setState(() {
      _startDate = start;
      _endDate = end;
    });
    _loadData();
  }

  Future<void> _refresh() async {
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.shadowGray[50],
      appBar: appBarWithActions(context, title: 'تقرير الورديات'.tr()),
      body: BlocBuilder<ReportsCubit, ReportsState>(
        builder: (context, state) {
          if (state is ReportsLoading) {
            return const CustomLoadingShimmer();
          }

          if (state is ReportsError) {
            return CustomEmptyState(
              icon: Icons.error_outline,
              title: 'Error'.tr(),
              message: state.message,
              actionLabel: LocaleKeys.retry.tr(),
              onAction: _refresh,
              onRefresh: _refresh,
            );
          }

          if (state is ShiftReportLoaded) {
            return _buildReportContent(state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildReportContent(ShiftReportLoaded state) {
    final summary = state.summary;

    return RefreshIndicator(
      onRefresh: _refresh,
      color: AppColors.primaryBlue,
      child: Column(
        children: [
          // Date Range Filter
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: DateRangeFilter(
              startDate: _startDate,
              endDate: _endDate,
              onChanged: _onDateRangeChanged,
            ),
          ),
          const SizedBox(height: 12),

          // Summary Cards
          if (summary != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildSummaryCards(summary),
            ),
            const SizedBox(height: 12),
          ],

          // Tab Selector
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildTabButton(0, 'الورديات'.tr()),
                _buildTabButton(1, 'أداء الكاشير'.tr()),
              ],
            ),
          ),

          // Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_selectedTab == 0)
                  _buildShiftsTab(state)
                else
                  _buildPerformanceTab(state),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String title) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.darkGray,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(ShiftSummary summary) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        ReportSummaryCard(
          title: 'إجمالي الورديات'.tr(),
          value: summary.totalShifts.toString(),
          icon: Icons.schedule,
          color: AppColors.primaryBlue,
        ),
        ReportSummaryCard(
          title: 'ورديات مفتوحة'.tr(),
          value: summary.openShifts.toString(),
          icon: Icons.lock_open,
          color: AppColors.warningOrange,
        ),
        ReportSummaryCard(
          title: 'إجمالي المبيعات'.tr(),
          value: NumberFormat.currency(symbol: '').format(summary.totalSales),
          icon: Icons.point_of_sale,
          color: AppColors.successGreen,
        ),
        ReportSummaryCard(
          title: 'إجمالي المصروفات'.tr(),
          value: NumberFormat.currency(symbol: '').format(summary.totalExpenses),
          icon: Icons.money_off,
          color: AppColors.red,
        ),
      ],
    );
  }

  Widget _buildShiftsTab(ShiftReportLoaded state) {
    final shifts = state.shifts;

    if (shifts.isEmpty) {
      return CustomEmptyState(
        icon: Icons.schedule_outlined,
        title: 'لا توجد بيانات'.tr(),
        message: 'لا توجد ورديات في الفترة المحددة'.tr(),
      );
    }

    return ReportDataTable(
      title: 'تفاصيل الورديات'.tr(),
      columns: [
        DataColumn(label: Text('الكاشير'.tr())),
        DataColumn(label: Text('البداية'.tr())),
        DataColumn(label: Text('النهاية'.tr())),
        DataColumn(label: Text('المبيعات'.tr()), numeric: true),
        DataColumn(label: Text('المعاملات'.tr()), numeric: true),
        DataColumn(label: Text('الحالة'.tr())),
      ],
      rows: shifts.map((shift) {
        return DataRow(
          cells: [
            DataCell(Text(shift.cashierName)),
            DataCell(Text(
              DateFormat('yyyy-MM-dd HH:mm').format(shift.startTime),
            )),
            DataCell(Text(
              shift.endTime != null
                  ? DateFormat('yyyy-MM-dd HH:mm').format(shift.endTime!)
                  : '-',
            )),
            DataCell(Text(
              NumberFormat.currency(symbol: '').format(shift.totalSaleAmount),
            )),
            DataCell(Text(shift.totalTransactions.toString())),
            DataCell(_buildStatusChip(shift.status)),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildPerformanceTab(ShiftReportLoaded state) {
    final performance = state.performance ?? [];

    if (performance.isEmpty) {
      return CustomEmptyState(
        icon: Icons.people_outline,
        title: 'لا توجد بيانات'.tr(),
        message: 'لا توجد بيانات أداء للكاشير'.tr(),
      );
    }

    return Column(
      children: performance.map((cashier) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      cashier.cashierName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withAlpha(20),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${cashier.totalShifts} وردية',
                        style: const TextStyle(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildPerformanceStat(
                      'إجمالي المبيعات',
                      NumberFormat.currency(symbol: '').format(cashier.totalSales),
                      Icons.point_of_sale,
                      AppColors.successGreen,
                    ),
                    _buildPerformanceStat(
                      'المعاملات',
                      cashier.totalTransactions.toString(),
                      Icons.receipt,
                      AppColors.primaryBlue,
                    ),
                    _buildPerformanceStat(
                      'متوسط المعاملة',
                      NumberFormat.currency(symbol: '').format(cashier.averageTransactionValue),
                      Icons.analytics,
                      AppColors.warningOrange,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPerformanceStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppColors.darkGray.withAlpha(150),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status.toLowerCase()) {
      case 'open':
        color = AppColors.successGreen;
        label = 'مفتوحة';
        break;
      case 'closed':
        color = AppColors.primaryBlue;
        label = 'مغلقة';
        break;
      case 'approved':
        color = AppColors.warningOrange;
        label = 'معتمدة';
        break;
      default:
        color = AppColors.darkGray;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
