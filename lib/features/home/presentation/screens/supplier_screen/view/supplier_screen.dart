import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/app_bar_widgets.dart';
import 'package:systego/features/home/presentation/screens/supplier_screen/cubit/supplier_cubit.dart';
import 'package:systego/features/home/presentation/screens/supplier_screen/cubit/supplier_state.dart';
import 'package:systego/features/home/presentation/screens/supplier_screen/view/supplier_details_bottom_sheet.dart';

import '../../../../../../core/widgets/custom_error/custom_empty_state.dart';
import '../../../../../../core/widgets/custom_error/custom_error_state.dart';
import '../../../../../../core/widgets/custom_gradient_divider.dart';
import '../../../../../../core/widgets/custom_loading/custom_loading_state_with_shimmer.dart';
import '../../../../../../core/widgets/custom_popup_menu.dart';
import '../../../../../../core/widgets/custom_snck_bar/custom_snackbar.dart';
import '../../../../../../core/widgets/simple_fadein_animation_widget.dart';
import '../model/supplier_model.dart';


class SupplierScreen extends StatefulWidget {
  const SupplierScreen({super.key});

  @override
  State<SupplierScreen> createState() => _SupplierScreenState();
}

class _SupplierScreenState extends State<SupplierScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCountry;
  String? _selectedCity;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SupplierCubit()..getSuppliers(),
      child: Scaffold(
        backgroundColor: AppColors.lightBlueBackground,
        appBar: appBarWithActions(
          context,
          'Suppliers',
              () {},
          showActions: true,
        ),
        body: BlocConsumer<SupplierCubit, SupplierStates>(
          listener: (context, state) {
            if (state is SupplierError) {
              CustomSnackbar.showError(context, state.message);
            }
          },
          builder: (context, state) {
            if (state is SupplierLoading) {
              return CustomLoadingShimmer(
                itemCount: 6,
                padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
              );
            }

            if (state is SupplierError) {
              return CustomErrorState(
                message: state.message,
                onRetry: () {
                  context.read<SupplierCubit>().getSuppliers();
                },
              );
            }

            if (state is SupplierSuccess) {
              final cubit = context.read<SupplierCubit>();
              final suppliers = _getFilteredSuppliers(cubit);

              if (suppliers.isEmpty && _searchQuery.isEmpty && _selectedCountry == null && _selectedCity == null) {
                return CustomEmptyState(
                  icon: Icons.store_outlined,
                  title: 'No Suppliers Yet',
                  message: 'There are no suppliers available at the moment.',
                  onRefresh: () async {
                    await cubit.getSuppliers();
                  },
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  await cubit.getSuppliers();
                },
                color: AppColors.primaryBlue,
                child: Column(
                  children: [
                    _buildSearchAndFilterSection(context, cubit),
                    if (suppliers.isEmpty && (_searchQuery.isNotEmpty || _selectedCountry != null || _selectedCity != null))
                      Expanded(
                        child: CustomEmptyState(
                          icon: Icons.search_off,
                          title: 'No Results Found',
                          message: 'Try adjusting your search or filters.',
                          actionLabel: 'Clear Filters',
                          onAction: () {
                            setState(() {
                              _searchQuery = '';
                              _searchController.clear();
                              _selectedCountry = null;
                              _selectedCity = null;
                            });
                          },
                        ),
                      )
                    else
                      Expanded(
                        child: _buildSuppliersList(context, suppliers),
                      ),
                  ],
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildSearchAndFilterSection(BuildContext context, SupplierCubit cubit) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowGray.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search by name or company...',
              hintStyle: TextStyle(
                color: AppColors.darkGray.withOpacity(0.5),
                fontSize: ResponsiveUI.fontSize(context, 14),
              ),
              prefixIcon: Icon(
                Icons.search,
                color: AppColors.primaryBlue,
                size: ResponsiveUI.iconSize(context, 24),
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                icon: Icon(
                  Icons.clear,
                  color: AppColors.darkGray,
                  size: ResponsiveUI.iconSize(context, 20),
                ),
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                    _searchQuery = '';
                  });
                },
              )
                  : null,
              filled: true,
              fillColor: AppColors.lightBlueBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 16)),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 16)),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 16)),
                borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: ResponsiveUI.padding(context, 16),
                vertical: ResponsiveUI.padding(context, 14),
              ),
            ),
          ),
          SizedBox(height: ResponsiveUI.spacing(context, 12)),

          // Filters Row
          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown(
                  context: context,
                  hint: 'Country',
                  value: _selectedCountry,
                  items: cubit.countries ?? [],
                  onChanged: (value) {
                    setState(() {
                      _selectedCountry = value;
                      _selectedCity = null; // Reset city when country changes
                    });
                  },
                  itemBuilder: (country) => country.name ?? '',
                  valueBuilder: (country) => country.id ?? '',
                ),
              ),
              SizedBox(width: ResponsiveUI.spacing(context, 12)),
              Expanded(
                child: _buildFilterDropdown(
                  context: context,
                  hint: 'City',
                  value: _selectedCity,
                  items: _selectedCountry != null
                      ? (cubit.cities ?? []).where((city) => city.country == _selectedCountry).toList()
                      : cubit.cities ?? [],
                  onChanged: (value) {
                    setState(() {
                      _selectedCity = value;
                    });
                  },
                  itemBuilder: (city) => city.name ?? '',
                  valueBuilder: (city) => city.id ?? '',
                ),
              ),
            ],
          ),

          // Active Filters Chips
          if (_selectedCountry != null || _selectedCity != null) ...[
            SizedBox(height: ResponsiveUI.spacing(context, 12)),
            Wrap(
              spacing: ResponsiveUI.spacing(context, 8),
              children: [
                if (_selectedCountry != null)
                  _buildFilterChip(
                    context,
                    label: cubit.countries?.firstWhere((c) => c.id == _selectedCountry).name ?? '',
                    onDeleted: () {
                      setState(() {
                        _selectedCountry = null;
                        _selectedCity = null;
                      });
                    },
                  ),
                if (_selectedCity != null)
                  _buildFilterChip(
                    context,
                    label: cubit.cities?.firstWhere((c) => c.id == _selectedCity).name ?? '',
                    onDeleted: () {
                      setState(() {
                        _selectedCity = null;
                      });
                    },
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterDropdown<T>({
    required BuildContext context,
    required String hint,
    required String? value,
    required List<T> items,
    required Function(String?) onChanged,
    required String Function(T) itemBuilder,
    required String Function(T) valueBuilder,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: ResponsiveUI.padding(context, 12)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
        border: Border.all(color: AppColors.lightGray),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hint,
            style: TextStyle(
              color: AppColors.darkGray.withOpacity(0.6),
              fontSize: ResponsiveUI.fontSize(context, 14),
            ),
          ),
          isExpanded: true,
          icon: Icon(
            Icons.arrow_drop_down,
            color: AppColors.primaryBlue,
            size: ResponsiveUI.iconSize(context, 24),
          ),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: valueBuilder(item),
              child: Text(
                itemBuilder(item),
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 14),
                  color: AppColors.darkGray,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, {required String label, required VoidCallback onDeleted}) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(
          color: AppColors.white,
          fontSize: ResponsiveUI.fontSize(context, 12),
        ),
      ),
      deleteIcon: Icon(
        Icons.close,
        size: ResponsiveUI.iconSize(context, 16),
        color: AppColors.white,
      ),
      onDeleted: onDeleted,
      backgroundColor: AppColors.primaryBlue,
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUI.padding(context, 8),
        vertical: ResponsiveUI.padding(context, 4),
      ),
    );
  }

  Widget _buildSuppliersList(BuildContext context, List<Suppliers> suppliers) {
    return ListView.builder(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
      itemCount: suppliers.length,
      itemBuilder: (context, index) {
        final supplier = suppliers[index];
        return FadeInAnimation(
          delay: Duration(milliseconds: index * 200),
          child: _buildSupplierCard(context, supplier),
        );
      },
    );
  }

  Widget _buildSupplierCard(BuildContext context, Suppliers supplier) {
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveUI.spacing(context, 16)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 20)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowGray.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 20)),
          onTap: () {
            SupplierDetailsBottomSheet.show(context, supplier.id ?? '');
          },
          child: Padding(
            padding: EdgeInsets.all(ResponsiveUI.padding(context, 18)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    // Supplier Image
                    Container(
                      width: ResponsiveUI.value(context, 58),
                      height: ResponsiveUI.value(context, 58),
                      decoration: BoxDecoration(
                        color: AppColors.lightBlueBackground,
                        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 16)),
                        image: supplier.image != null
                            ? DecorationImage(
                          image: NetworkImage(supplier.image!),
                          fit: BoxFit.cover,
                        )
                            : null,
                      ),
                      child: supplier.image == null
                          ? Icon(
                        Icons.store,
                        size: ResponsiveUI.iconSize(context, 28),
                        color: AppColors.primaryBlue,
                      )
                          : null,
                    ),
                    SizedBox(width: ResponsiveUI.spacing(context, 14)),

                    // Name and Company
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            supplier.username ?? 'Unknown',
                            style: TextStyle(
                              fontSize: ResponsiveUI.fontSize(context, 16),
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkGray,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: ResponsiveUI.spacing(context, 4)),
                          Text(
                            supplier.companyName ?? 'No Company',
                            style: TextStyle(
                              fontSize: ResponsiveUI.fontSize(context, 13),
                              color: AppColors.darkGray.withOpacity(0.6),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Action Button
                    CustomPopupMenu(
                      onEdit: () {
                        CustomSnackbar.showInfo(context, 'Edit supplier functionality coming soon');
                      },
                      onDelete: () {
                        CustomSnackbar.showWarning(context, 'Delete supplier functionality coming soon');
                      },
                    ),
                  ],
                ),

                SizedBox(height: ResponsiveUI.spacing(context, 16)),

                // Divider
                CustomGradientDivider(
                  height: 1,
                  colors: [AppColors.lightGray, AppColors.primaryBlue, AppColors.lightGray],
                ),

                SizedBox(height: ResponsiveUI.spacing(context, 16)),

                // Contact Info Row
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        context,
                        icon: Icons.email_outlined,
                        text: supplier.email ?? 'N/A',
                      ),
                    ),
                    SizedBox(width: ResponsiveUI.spacing(context, 10)),
                    Expanded(
                      child: _buildInfoItem(
                        context,
                        icon: Icons.phone_outlined,
                        text: supplier.phoneNumber ?? 'N/A',
                      ),
                    ),
                  ],
                ),

                SizedBox(height: ResponsiveUI.spacing(context, 12)),

                // Location Info Row
                Row(
                  children: [
                    Expanded(
                      child: _buildLocationTag(
                        context,
                        icon: Icons.location_city,
                        text: supplier.cityId?.name ?? 'N/A',
                      ),
                    ),
                    SizedBox(width: ResponsiveUI.spacing(context, 8)),
                    Expanded(
                      child: _buildLocationTag(
                        context,
                        icon: Icons.public,
                        text: supplier.countryId?.name ?? 'N/A',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, {required IconData icon, required String text}) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 10)),
      decoration: BoxDecoration(
        color: AppColors.lightBlueBackground,
        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: ResponsiveUI.iconSize(context, 18),
            color: AppColors.primaryBlue,
          ),
          SizedBox(width: ResponsiveUI.spacing(context, 8)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 12),
                color: AppColors.darkGray,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationTag(BuildContext context, {required IconData icon, required String text}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUI.padding(context, 10),
        vertical: ResponsiveUI.padding(context, 8),
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 10)),
        border: Border.all(color: AppColors.lightGray),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: ResponsiveUI.iconSize(context, 16),
            color: AppColors.primaryBlue,
          ),
          SizedBox(width: ResponsiveUI.spacing(context, 6)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 12),
                color: AppColors.darkGray,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  List<Suppliers> _getFilteredSuppliers(SupplierCubit cubit) {
    List<Suppliers> suppliers = cubit.suppliers ?? [];

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      suppliers = cubit.searchSuppliers(_searchQuery);
    }

    // Apply country filter
    if (_selectedCountry != null) {
      suppliers = suppliers.where((s) => s.countryId?.id == _selectedCountry).toList();
    }

    // Apply city filter
    if (_selectedCity != null) {
      suppliers = suppliers.where((s) => s.cityId?.id == _selectedCity).toList();
    }

    return suppliers;
  }
}