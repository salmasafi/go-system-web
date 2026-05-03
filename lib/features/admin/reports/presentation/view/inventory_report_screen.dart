import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/widgets/app_bar_widgets.dart';
import 'package:GoSystem/core/widgets/custom_error/custom_empty_state.dart';
import 'package:GoSystem/core/widgets/custom_loading/custom_loading_state_with_shimmer.dart';
import 'package:GoSystem/features/admin/reports/cubit/reports_cubit.dart';
import 'package:GoSystem/features/admin/reports/cubit/reports_state.dart';
import 'package:GoSystem/features/admin/reports/models/inventory_report_model.dart';
import '../widgets/report_summary_card.dart';
import '../widgets/report_data_table.dart';

/// Inventory Report Screen
/// Displays inventory movements and stock data
class InventoryReportScreen extends StatefulWidget {
  const InventoryReportScreen({super.key});

  @override
  State<InventoryReportScreen> createState() => _InventoryReportScreenState();
}

class _InventoryReportScreenState extends State<InventoryReportScreen> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<ReportsCubit>().loadInventoryReport();
  }

  Future<void> _refresh() async {
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.shadowGray[50],
      appBar: appBarWithActions(context, title: 'تقرير المخزون'.tr()),
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

          if (state is InventoryReportLoaded) {
            return _buildReportContent(state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildReportContent(InventoryReportLoaded state) {
    final summary = state.summary;

    return RefreshIndicator(
      onRefresh: _refresh,
      color: AppColors.primaryBlue,
      child: Column(
        children: [
          // Tab Selector
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildTabButton(0, 'الحركات'.tr()),
                _buildTabButton(1, 'المستودعات'.tr()),
              ],
            ),
          ),

          // Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                // Summary Cards
                if (summary != null) ...[
                  _buildSummaryCards(summary),
                  const SizedBox(height: 16),
                ],

                // Tab Content
                if (_selectedTab == 0)
                  _buildMovementsTab(state)
                else
                  _buildWarehousesTab(state),
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

  Widget _buildSummaryCards(InventoryMovementSummary summary) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        ReportSummaryCard(
          title: 'إجمالي التعديلات'.tr(),
          value: summary.totalAdjustments.toString(),
          icon: Icons.tune,
          color: AppColors.primaryBlue,
        ),
        ReportSummaryCard(
          title: 'إجمالي التحويلات'.tr(),
          value: summary.totalTransfers.toString(),
          icon: Icons.swap_horiz,
          color: AppColors.successGreen,
        ),
        ReportSummaryCard(
          title: 'الوارد'.tr(),
          value: summary.stockIn.toString(),
          icon: Icons.arrow_downward,
          color: AppColors.primaryBlue,
        ),
        ReportSummaryCard(
          title: 'الصادر'.tr(),
          value: summary.stockOut.toString(),
          icon: Icons.arrow_upward,
          color: AppColors.warningOrange,
        ),
      ],
    );
  }

  Widget _buildMovementsTab(InventoryReportLoaded state) {
    return ReportDataTable(
      title: 'حركات المخزون'.tr(),
      columns: [
        DataColumn(label: Text('التاريخ'.tr())),
        DataColumn(label: Text('المرجع'.tr())),
        DataColumn(label: Text('النوع'.tr())),
        DataColumn(label: Text('المنتج'.tr())),
        DataColumn(label: Text('الكمية'.tr()), numeric: true),
        DataColumn(label: Text('المستودع'.tr())),
      ],
      rows: state.movements.map((movement) {
        return DataRow(
          cells: [
            DataCell(Text(
              DateFormat('yyyy-MM-dd').format(movement.date),
            )),
            DataCell(Text(movement.reference)),
            DataCell(_buildMovementTypeChip(movement.type)),
            DataCell(Text(movement.productName)),
            DataCell(Text(movement.quantity.toString())),
            DataCell(Text(movement.warehouseName)),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildWarehousesTab(InventoryReportLoaded state) {
    final warehouses = state.warehouseReports ?? [];

    if (warehouses.isEmpty) {
      return CustomEmptyState(
        icon: Icons.warehouse_outlined,
        title: 'لا توجد بيانات'.tr(),
        message: 'لا توجد مستودعات لعرضها'.tr(),
      );
    }

    return Column(
      children: warehouses.map((warehouse) {
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
                      warehouse.warehouseName,
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
                        '${warehouse.totalProducts} منتج',
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildWarehouseStat(
                      'إجمالي الكمية',
                      warehouse.totalQuantity.toString(),
                      Icons.inventory,
                    ),
                    _buildWarehouseStat(
                      'القيمة',
                      NumberFormat.currency(symbol: '').format(warehouse.totalValue),
                      Icons.account_balance_wallet,
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

  Widget _buildWarehouseStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primaryBlue, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppColors.darkGray.withAlpha(150),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildMovementTypeChip(String type) {
    Color color;
    String label;

    switch (type.toLowerCase()) {
      case 'addition':
        color = AppColors.successGreen;
        label = 'إضافة';
        break;
      case 'subtraction':
        color = AppColors.red;
        label = 'خصم';
        break;
      case 'transfer':
        color = AppColors.primaryBlue;
        label = 'تحويل';
        break;
      default:
        color = AppColors.darkGray;
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
