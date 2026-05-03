import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/widgets/app_bar_widgets.dart';
import 'package:GoSystem/core/widgets/custom_error/custom_empty_state.dart';
import 'package:GoSystem/core/widgets/custom_loading/custom_loading_state_with_shimmer.dart';
import 'package:GoSystem/features/admin/reports/cubit/reports_cubit.dart';
import 'package:GoSystem/features/admin/reports/cubit/reports_state.dart';
import 'package:GoSystem/features/admin/reports/models/sales_report_model.dart';
import '../widgets/report_summary_card.dart';
import '../widgets/report_data_table.dart';
import '../widgets/date_range_filter.dart';

/// Sales Report Screen
/// Displays sales data with filtering capabilities
class SalesReportScreen extends StatefulWidget {
  const SalesReportScreen({super.key});

  @override
  State<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen> {
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
    context.read<ReportsCubit>().loadSalesReport(
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
      appBar: appBarWithActions(context, title: 'تقرير المبيعات'.tr()),
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
              actionLabel: 'Retry'.tr(),
              onAction: _refresh,
              onRefresh: _refresh,
            );
          }

          if (state is SalesReportLoaded) {
            return _buildReportContent(state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildReportContent(SalesReportLoaded state) {
    final summary = state.summary;
    final sales = state.sales;

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

          // Sales Data Table
          ReportDataTable(
            title: 'تفاصيل المبيعات'.tr(),
            columns: [
              DataColumn(label: Text('التاريخ'.tr())),
              DataColumn(label: Text('المرجع'.tr())),
              DataColumn(label: Text('العميل'.tr())),
              DataColumn(label: Text('المستودع'.tr())),
              DataColumn(label: Text('الإجمالي'.tr()), numeric: true),
              DataColumn(label: Text('الحالة'.tr())),
            ],
            rows: sales.map((sale) {
              return DataRow(
                cells: [
                  DataCell(Text(
                    DateFormat('yyyy-MM-dd').format(sale.date),
                  )),
                  DataCell(Text(sale.reference)),
                  DataCell(Text(sale.customerName ?? '-')),
                  DataCell(Text(sale.warehouseName)),
                  DataCell(Text(
                    NumberFormat.currency(symbol: '').format(sale.grandTotal),
                  )),
                  DataCell(_buildStatusChip(sale.saleStatus)),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(SalesSummary summary) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        ReportSummaryCard(
          title: 'إجمالي المبيعات'.tr(),
          value: NumberFormat.currency(symbol: '').format(summary.totalSales),
          icon: Icons.point_of_sale,
          color: AppColors.primaryBlue,
        ),
        ReportSummaryCard(
          title: 'عدد الطلبات'.tr(),
          value: NumberFormat.compact().format(summary.totalOrders),
          icon: Icons.shopping_cart,
          color: AppColors.successGreen,
        ),
        ReportSummaryCard(
          title: 'متوسط قيمة الطلب'.tr(),
          value: NumberFormat.currency(symbol: '').format(summary.averageOrderValue),
          icon: Icons.analytics,
          color: AppColors.warningOrange,
        ),
        ReportSummaryCard(
          title: 'إجمالي الخصومات'.tr(),
          value: NumberFormat.currency(symbol: '').format(summary.totalDiscounts),
          icon: Icons.discount,
          color: AppColors.red,
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    IconData icon;
    String label;

    switch (status.toLowerCase()) {
      case 'completed':
        color = AppColors.successGreen;
        icon = Icons.check_circle;
        label = 'مكتمل';
        break;
      case 'pending':
        color = AppColors.warningOrange;
        icon = Icons.pending;
        label = 'معلق';
        break;
      case 'cancelled':
        color = AppColors.red;
        icon = Icons.cancel;
        label = 'ملغي';
        break;
      default:
        color = AppColors.primaryBlue;
        icon = Icons.info;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
