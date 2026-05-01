import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/widgets/custom_loading/custom_loading_state.dart';
import 'package:GoSystem/features/pos/history/model/sale_model.dart';
import 'package:GoSystem/features/pos/history/presentation/views/sale_details_screen.dart';
import '../../cubit/history_cubit.dart';
import '../../cubit/history_state.dart';

class SalesTab extends StatefulWidget {
  const SalesTab({super.key});
  @override
  State<SalesTab> createState() => _SalesTabState();
}

class _SalesTabState extends State<SalesTab> {
  String _searchQuery = '';
  DateTime? _selectedDate;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<HistoryCubit>().getAllSales();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<SaleItemModel> _filter(List<SaleItemModel> sales) {
    return sales.where((s) {
      final q = _searchQuery.toLowerCase();
      final matchSearch = q.isEmpty ||
          s.reference.toLowerCase().contains(q) ||
          s.customerName.toLowerCase().contains(q);

      final matchDate = _selectedDate == null ||
          (s.date.isNotEmpty &&
              _isSameDay(DateTime.tryParse(s.date), _selectedDate!));

      return matchSearch && matchDate;
    }).toList();
  }

  bool _isSameDay(DateTime? a, DateTime b) {
    if (a == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primaryBlue),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HistoryCubit, HistoryState>(
      buildWhen: (p, c) =>
          c is SalesLoading || c is SalesLoaded || c is HistoryError,
      builder: (context, state) {
        return Column(
          children: [
            _FilterBar(
              searchCtrl: _searchCtrl,
              selectedDate: _selectedDate,
              onSearchChanged: (v) => setState(() => _searchQuery = v),
              onDateTap: _pickDate,
              onClearDate: () => setState(() => _selectedDate = null),
            ),
            _TableHeader(),
            Expanded(
              child: _buildBody(state),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBody(HistoryState state) {
    if (state is SalesLoading) {
      return Center(child: CustomLoadingState());
    }
    if (state is HistoryError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: AppColors.red, size: ResponsiveUI.iconSize(context, 40)),
            SizedBox(height: ResponsiveUI.value(context, 8)),
            Text(state.message, style: TextStyle(color: AppColors.shadowGray)),
            SizedBox(height: ResponsiveUI.value(context, 12)),
            TextButton.icon(
              onPressed: () => context.read<HistoryCubit>().getAllSales(),
              icon: Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (state is SalesLoaded) {
      final filtered = _filter(state.sales);
      if (filtered.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long_outlined, size: ResponsiveUI.iconSize(context, 52), color: AppColors.shadowGray.withValues(alpha: 0.4)),
              SizedBox(height: ResponsiveUI.value(context, 12)),
              Text(
                _selectedDate != null || _searchQuery.isNotEmpty
                    ? 'No orders found for this filter.'
                    : 'No orders yet.',
                style: TextStyle(color: AppColors.shadowGray, fontSize: ResponsiveUI.fontSize(context, 14)),
              ),
            ],
          ),
        );
      }
      return RefreshIndicator(
        color: AppColors.primaryBlue,
        onRefresh: () => context.read<HistoryCubit>().getAllSales(),
        child: ListView.builder(
          padding: EdgeInsets.only(bottom: ResponsiveUI.padding(context, 16)),
          itemCount: filtered.length,
          itemBuilder: (ctx, i) => _OrderRow(sale: filtered[i]),
        ),
      );
    }
    return SizedBox();
  }
}

// ─── Filter Bar ───────────────────────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  final TextEditingController searchCtrl;
  final DateTime? selectedDate;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onDateTap;
  final VoidCallback onClearDate;

  const _FilterBar({
    required this.searchCtrl,
    required this.selectedDate,
    required this.onSearchChanged,
    required this.onDateTap,
    required this.onClearDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Row(
        children: [
          // Search
          Expanded(
            child: SizedBox(
              height: ResponsiveUI.value(context, 40),
              child: TextField(
                controller: searchCtrl,
                onChanged: onSearchChanged,
                style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 13)),
                decoration: InputDecoration(
                  hintText: 'Search by order #, name...',
                  hintStyle: TextStyle(fontSize: ResponsiveUI.fontSize(context, 12), color: AppColors.shadowGray),
                  prefixIcon: Icon(Icons.search, size: ResponsiveUI.iconSize(context, 18), color: AppColors.shadowGray),
                  contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: ResponsiveUI.padding(context, 8)),
                  filled: true,
                  fillColor: const Color(0xFFF5F6FA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 10)),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: searchCtrl.text.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            searchCtrl.clear();
                            onSearchChanged('');
                          },
                          child: Icon(Icons.close, size: ResponsiveUI.iconSize(context, 16), color: AppColors.shadowGray),
                        )
                      : null,
                ),
              ),
            ),
          ),
          SizedBox(width: ResponsiveUI.value(context, 8)),
          // Date Picker
          GestureDetector(
            onTap: onDateTap,
            child: Container(
              height: ResponsiveUI.value(context, 40),
              padding: EdgeInsets.symmetric(horizontal: ResponsiveUI.padding(context, 10)),
              decoration: BoxDecoration(
                color: selectedDate != null
                    ? AppColors.primaryBlue.withValues(alpha: 0.1)
                    : const Color(0xFFF5F6FA),
                borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 10)),
                border: Border.all(
                  color: selectedDate != null
                      ? AppColors.primaryBlue.withValues(alpha: 0.4)
                      : Colors.transparent,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: ResponsiveUI.iconSize(context, 16),
                    color: selectedDate != null ? AppColors.primaryBlue : AppColors.shadowGray,
                  ),
                  SizedBox(width: ResponsiveUI.value(context, 6)),
                  Text(
                    selectedDate != null
                        ? DateFormat('MM/dd/yyyy').format(selectedDate!)
                        : 'Date',
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 12),
                      color: selectedDate != null ? AppColors.primaryBlue : AppColors.shadowGray,
                      fontWeight: selectedDate != null ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  if (selectedDate != null) ...[
                    SizedBox(width: ResponsiveUI.value(context, 4)),
                    GestureDetector(
                      onTap: onClearDate,
                      child: Icon(Icons.close, size: ResponsiveUI.iconSize(context, 14), color: AppColors.primaryBlue),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Table Header ─────────────────────────────────────────────────────────────

class _TableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF0F2F5),
      padding: EdgeInsets.symmetric(horizontal: ResponsiveUI.padding(context, 16), vertical: ResponsiveUI.padding(context, 10)),
      child: Row(
        children: [
          Expanded(flex: 3, child: _HeaderCell('Order #')),
          Expanded(flex: 2, child: _HeaderCell('Amount')),
          Expanded(flex: 3, child: _HeaderCell('Date/Time')),
          SizedBox(width: ResponsiveUI.value(context, 36), child: _HeaderCell('Print', center: true)),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  final bool center;
  const _HeaderCell(this.text, {this.center = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: center ? TextAlign.center : TextAlign.start,
      style: TextStyle(
        fontSize: ResponsiveUI.fontSize(context, 12),
        fontWeight: FontWeight.w700,
        color: Color(0xFF555E6D),
        letterSpacing: 0.2,
      ),
    );
  }
}

// ─── Order Row ────────────────────────────────────────────────────────────────

class _OrderRow extends StatelessWidget {
  final SaleItemModel sale;
  const _OrderRow({required this.sale});

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('yyyy-MM-dd\nHH:mm').format(dt);
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SaleDetailsScreen(saleId: sale.id)),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: ResponsiveUI.padding(context, 16), vertical: ResponsiveUI.padding(context, 12)),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border(bottom: BorderSide(color: Color(0xFFF0F2F5), width: ResponsiveUI.value(context, 1))),
        ),
        child: Row(
          children: [
            // Order # + customer
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sale.reference,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: ResponsiveUI.fontSize(context, 13),
                      color: AppColors.darkGray,
                    ),
                  ),
                  SizedBox(height: ResponsiveUI.value(context, 2)),
                  Text(
                    sale.customerName,
                    style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 11), color: AppColors.shadowGray),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Amount
            Expanded(
              flex: 2,
              child: Text(
                '${sale.grandTotal.toStringAsFixed(2)}\nEGP',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: ResponsiveUI.fontSize(context, 13),
                  color: AppColors.successGreen,
                  height: ResponsiveUI.value(context, 1.3),
                ),
              ),
            ),
            // Date/Time
            Expanded(
              flex: 3,
              child: Text(
                _formatDate(sale.date),
                style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 11), color: AppColors.shadowGray, height: ResponsiveUI.value(context, 1.4)),
              ),
            ),
            // Print
            SizedBox(
              width: ResponsiveUI.value(context, 36),
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(Icons.print_outlined, size: ResponsiveUI.iconSize(context, 20), color: AppColors.primaryBlue),
                onPressed: () => _printReceipt(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _printReceipt(BuildContext context) {
    // Navigate to details screen which has the print button
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SaleDetailsScreen(saleId: sale.id)),
    );
  }
}
