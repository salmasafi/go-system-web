import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/widgets/app_bar_widgets.dart';
import 'package:GoSystem/core/widgets/custom_error/custom_empty_state.dart';
import 'package:GoSystem/core/widgets/custom_loading/custom_loading_state_with_shimmer.dart';
import 'package:GoSystem/features/admin/reports/cubit/reports_cubit.dart';
import 'package:GoSystem/features/admin/reports/cubit/reports_state.dart';
import 'package:GoSystem/features/admin/reports/models/product_report_model.dart';
import '../widgets/report_summary_card.dart';
import '../widgets/report_data_table.dart';

/// Product Report Screen
/// Displays product performance and inventory data
class ProductReportScreen extends StatefulWidget {
  const ProductReportScreen({super.key});

  @override
  State<ProductReportScreen> createState() => _ProductReportScreenState();
}

class _ProductReportScreenState extends State<ProductReportScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<ReportsCubit>().loadProductReport();
  }

  Future<void> _refresh() async {
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.shadowGray[50],
      appBar: appBarWithActions(context, title: 'تقرير المنتجات'.tr()),
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

          if (state is ProductReportLoaded) {
            return _buildReportContent(state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildReportContent(ProductReportLoaded state) {
    final summary = state.summary;
    final products = state.products;

    return RefreshIndicator(
      onRefresh: _refresh,
      color: AppColors.primaryBlue,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary Cards
          if (summary != null) ...[
            _buildSummaryCards(summary),
            const SizedBox(height: 16),
          ],

          // Top Selling Products
          if (summary?.topSellingProducts.isNotEmpty == true) ...[
            _buildTopProductsCard(
              title: 'المنتجات الأكثر مبيعاً'.tr(),
              products: summary!.topSellingProducts,
              isQuantity: true,
            ),
            const SizedBox(height: 16),
          ],

          // Products Data Table
          ReportDataTable(
            title: 'تفاصيل المنتجات'.tr(),
            columns: [
              DataColumn(label: Text('الكود'.tr())),
              DataColumn(label: Text('الاسم'.tr())),
              DataColumn(label: Text('الفئة'.tr())),
              DataColumn(label: Text('المخزون'.tr()), numeric: true),
              DataColumn(label: Text('المباع'.tr()), numeric: true),
              DataColumn(label: Text('الإيرادات'.tr()), numeric: true),
              DataColumn(label: Text('الحالة'.tr())),
            ],
            rows: products.map((product) {
              return DataRow(
                cells: [
                  DataCell(Text(product.code)),
                  DataCell(Text(product.name)),
                  DataCell(Text(product.categoryName ?? '-')),
                  DataCell(Text(product.totalQuantity.toString())),
                  DataCell(Text(product.totalSold.toString())),
                  DataCell(Text(
                    NumberFormat.currency(symbol: '').format(product.totalRevenue),
                  )),
                  DataCell(_buildStockStatus(product)),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(ProductPerformanceSummary summary) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        ReportSummaryCard(
          title: 'إجمالي المنتجات'.tr(),
          value: NumberFormat.compact().format(summary.totalProducts),
          icon: Icons.inventory_2,
          color: AppColors.primaryBlue,
        ),
        ReportSummaryCard(
          title: 'قيمة المخزون'.tr(),
          value: NumberFormat.currency(symbol: '').format(summary.totalInventoryValue),
          icon: Icons.account_balance_wallet,
          color: AppColors.successGreen,
        ),
        ReportSummaryCard(
          title: 'منخفض المخزون'.tr(),
          value: summary.lowStockProducts.toString(),
          icon: Icons.warning,
          color: AppColors.warningOrange,
        ),
        ReportSummaryCard(
          title: 'نفد من المخزون'.tr(),
          value: summary.outOfStockProducts.toString(),
          icon: Icons.error,
          color: AppColors.red,
        ),
      ],
    );
  }

  Widget _buildTopProductsCard({
    required String title,
    required List<TopProduct> products,
    required bool isQuantity,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...products.take(5).map((product) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      isQuantity
                          ? '${product.quantity} units'
                          : NumberFormat.currency(symbol: '').format(product.revenue),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStockStatus(ProductReportModel product) {
    if (product.totalQuantity == 0) {
      return _buildStatusBadge('نفد', AppColors.red);
    } else if (product.totalQuantity <= product.lowStock) {
      return _buildStatusBadge('منخفض', AppColors.warningOrange);
    } else {
      return _buildStatusBadge('متوفر', AppColors.successGreen);
    }
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
