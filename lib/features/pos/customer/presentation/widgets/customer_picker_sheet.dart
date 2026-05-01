import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:GoSystem/features/pos/customer/cubit/pos_customer_cubit.dart';
import 'package:GoSystem/features/pos/customer/model/pos_customer_model.dart';

/// Opens the customer picker as a modal bottom sheet.
/// Must be called with a context that has [PosCustomerCubit] in scope.
void showCustomerPickerSheet(BuildContext context) {
  // Fetch customers before opening the sheet
  context.read<PosCustomerCubit>().fetchCustomers();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: context.read<PosCustomerCubit>(),
      child: const CustomerPickerSheet(),
    ),
  );
}

class CustomerPickerSheet extends StatefulWidget {
  const CustomerPickerSheet({super.key});

  @override
  State<CustomerPickerSheet> createState() => _CustomerPickerSheetState();
}

class _CustomerPickerSheetState extends State<CustomerPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// In-memory case-insensitive filter on name and phone number.
  List<PosCustomer> _filter(List<PosCustomer> customers) {
    if (_query.isEmpty) return customers;
    final q = _query.toLowerCase();
    return customers
        .where((c) =>
            c.name.toLowerCase().contains(q) ||
            c.phoneNumber.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PosCustomerCubit, PosCustomerState>(
      builder: (context, state) {
        final cubit = context.read<PosCustomerCubit>();
        final allCustomers =
            state is PosCustomerLoaded ? state.customers : cubit.customers;
        final filtered = _filter(allCustomers);

        return Container(
          height: ResponsiveUI.screenHeight(context) * 0.75,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(ResponsiveUI.borderRadius(context, 24))),
          ),
          child: Column(
            children: [
              // ── Handle ──
              Padding(
                padding: EdgeInsets.symmetric(
                    vertical: ResponsiveUI.padding(context, 12)),
                child: Container(
                  width: ResponsiveUI.value(context, 45),
                  height: ResponsiveUI.value(context, 5),
                  decoration: BoxDecoration(
                    color: AppColors.shadowGray.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 3)),
                  ),
                ),
              ),

              // ── Title ──
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUI.padding(context, 20)),
                child: Row(
                  children: [
                    Text(
                      'Select Customer',
                      style: TextStyle(
                        fontSize: ResponsiveUI.fontSize(context, 18),
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGray,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: ResponsiveUI.spacing(context, 12)),

              // ── Search field ──
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUI.padding(context, 16)),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: 'Search by name or phone',
                    prefixIcon: Icon(Icons.search,
                        color: AppColors.shadowGray),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear,
                                color: AppColors.shadowGray),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.lightBlueBackground,
                    contentPadding: EdgeInsets.symmetric(
                        vertical: ResponsiveUI.padding(context, 12),
                        horizontal: ResponsiveUI.padding(context, 16)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              SizedBox(height: ResponsiveUI.spacing(context, 8)),

              // ── Customer list or empty state ──
              Expanded(
                child: state is PosCustomerLoading
                    ? Center(child: CircularProgressIndicator())
                    : filtered.isEmpty
                        ? _EmptyState(isSearch: _query.isNotEmpty)
                        : ListView.separated(
                        padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveUI.padding(context, 16),
                            vertical: ResponsiveUI.padding(context, 8)),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => Divider(height: ResponsiveUI.value(context, 1)),
                        itemBuilder: (context, index) {
                          final customer = filtered[index];
                          return _CustomerTile(
                            customer: customer,
                            isSelected:
                                cubit.selectedCustomer?.id == customer.id,
                            onTap: () {
                              cubit.selectCustomer(customer);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CustomerTile extends StatelessWidget {
  final PosCustomer customer;
  final bool isSelected;
  final VoidCallback onTap;

  const _CustomerTile({
    required this.customer,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor:
            isSelected ? AppColors.primaryBlue : AppColors.lightBlueBackground,
        child: Text(
          customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
          style: TextStyle(
            color: isSelected ? AppColors.white : AppColors.primaryBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        customer.name,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: ResponsiveUI.fontSize(context, 14),
          color: AppColors.darkGray,
        ),
      ),
      subtitle: Text(
        customer.phoneNumber,
        style: TextStyle(
          fontSize: ResponsiveUI.fontSize(context, 12),
          color: AppColors.shadowGray,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: AppColors.primaryBlue)
          : null,
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isSearch;

  const _EmptyState({required this.isSearch});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSearch ? Icons.search_off : Icons.people_outline,
            size: ResponsiveUI.iconSize(context, 56),
            color: AppColors.shadowGray,
          ),
          SizedBox(height: ResponsiveUI.value(context, 12)),
          Text(
            isSearch
                ? 'No customers match your search'
                : 'No customers available',
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 14),
              color: AppColors.shadowGray,
            ),
          ),
        ],
      ),
    );
  }
}
