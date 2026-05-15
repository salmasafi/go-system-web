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
import 'package:GoSystem/features/admin/reports/models/financial_report_model.dart';
import '../widgets/report_summary_card.dart';
import '../widgets/report_data_table.dart';
import '../widgets/date_range_filter.dart';

/// Financial Report Screen
/// Displays financial data including POS sales, revenues, expenses, and taxes
class FinancialReportScreen extends StatefulWidget {
  const FinancialReportScreen({super.key});

  @override
  State<FinancialReportScreen> createState() => _FinancialReportScreenState();
}

class _FinancialReportScreenState extends State<FinancialReportScreen> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    // Load current month's data by default
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, 1);
    _endDate = now;
    _loadData();
  }

  void _loadData() {
    context.read<ReportsCubit>().loadFinancialReport(
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
      appBar: appBarWithActions(context, title: 'التقرير المالي'.tr()),
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

          if (state is FinancialReportLoaded) {
            return _buildReportContent(state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildReportContent(FinancialReportLoaded state) {
    final summary = state.summary;
    final transactions = state.transactions;

    return RefreshIndicator(
      onRefresh: _refresh,
      color: AppColors.primaryBlue,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Date Range Filter
          DateRangeFilter(
            startDate: _startDate,
            endDate: _endDate,
            onChanged: _onDateRangeChanged,
          ),
          const SizedBox(height: 16),

          // Summary Cards
          if (summary != null) ...[
            _buildSummaryCards(summary),
            const SizedBox(height: 16),
          ],

          // Monthly Breakdown
          if (summary?.monthlyData.isNotEmpty == true) ...[
            _buildMonthlyBreakdown(summary!.monthlyData),
            const SizedBox(height: 16),
          ],

          // Bank Accounts
          if (summary?.bankAccounts.isNotEmpty == true) ...[
            _buildBankAccountsCard(summary!.bankAccounts),
            const SizedBox(height: 16),
          ],

          // Transactions Data Table
          ReportDataTable(
            title: 'تفاصيل المعاملات'.tr(),
            columns: [
              DataColumn(label: Text('التاريخ'.tr())),
              DataColumn(label: Text('النوع'.tr())),
              DataColumn(label: Text('الفئة'.tr())),
              DataColumn(label: Text('المبلغ'.tr()), numeric: true),
              DataColumn(label: Text('الحساب البنكي'.tr())),
            ],
            rows: transactions.map((tx) {
              return DataRow(
                cells: [
                  DataCell(Text(
                    DateFormat('yyyy-MM-dd').format(tx.date),
                  )),
                  DataCell(_buildTransactionTypeChip(tx.type)),
                  DataCell(Text(tx.categoryName ?? tx.referenceType ?? '-')),
                  DataCell(Text(
                    NumberFormat.currency(symbol: '').format(tx.amount),
                  )),
                  DataCell(Text(tx.bankAccountName ?? '-')),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(FinancialSummary summary) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        ReportSummaryCard(
          title: 'إجمالي الإيرادات'.tr(),
          value: NumberFormat.currency(symbol: '').format(summary.totalRevenue),
          icon: Icons.trending_up,
          color: AppColors.successGreen,
        ),
        ReportSummaryCard(
          title: 'إجمالي المصروفات'.tr(),
          value: NumberFormat.currency(symbol: '').format(summary.totalExpenses),
          icon: Icons.trending_down,
          color: AppColors.red,
        ),
        ReportSummaryCard(
          title: 'صافي الدخل'.tr(),
          value: NumberFormat.currency(symbol: '').format(summary.netIncome),
          icon: Icons.account_balance_wallet,
          color: AppColors.primaryBlue,
        ),
        ReportSummaryCard(
          title: 'الضرائب المحصلة'.tr(),
          value: NumberFormat.currency(symbol: '').format(summary.totalTaxCollected),
          icon: Icons.receipt_long,
          color: AppColors.warningOrange,
        ),
      ],
    );
  }

  Widget _buildMonthlyBreakdown(List<MonthlyFinancialData> monthlyData) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'البيانات الشهرية'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...monthlyData.map((month) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      month.month,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'إيرادات: ${NumberFormat.compactCurrency(symbol: '').format(month.revenue)}',
                      style: TextStyle(color: AppColors.successGreen, fontSize: 12),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'مصروفات: ${NumberFormat.compactCurrency(symbol: '').format(month.expenses)}',
                      style: TextStyle(color: AppColors.red, fontSize: 12),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      NumberFormat.compactCurrency(symbol: '').format(month.profit),
                      style: TextStyle(
                        color: month.profit >= 0 ? AppColors.successGreen : AppColors.red,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildBankAccountsCard(List<BankAccountBalance> accounts) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الحسابات البنكية'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...accounts.map((account) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.account_balance, size: 18, color: AppColors.primaryBlue),
                      const SizedBox(width: 8),
                      Text(
                        account.name,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  Text(
                    NumberFormat.currency(symbol: '').format(account.balance),
                    style: TextStyle(
                      color: account.balance >= 0 ? AppColors.successGreen : AppColors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTypeChip(String type) {
    Color color;
    String label;

    switch (type.toLowerCase()) {
      case 'revenue':
        color = AppColors.successGreen;
        label = 'إيراد';
        break;
      case 'expense':
        color = AppColors.red;
        label = 'مصروف';
        break;
      default:
        color = AppColors.primaryBlue;
        label = type;
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
