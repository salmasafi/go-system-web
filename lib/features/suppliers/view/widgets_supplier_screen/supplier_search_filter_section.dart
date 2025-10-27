import 'package:flutter/material.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/features/suppliers/cubit/supplier_cubit.dart';

class SupplierSearchFilterSection extends StatelessWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final String? selectedCountry;
  final String? selectedCity;
  final SupplierCubit cubit;
  final Function(String) onSearchChanged;
  final VoidCallback onSearchCleared;
  final Function(String?) onCountryChanged;
  final Function(String?) onCityChanged;
  final VoidCallback onCountryRemoved;
  final VoidCallback onCityRemoved;

  const SupplierSearchFilterSection({
    super.key,
    required this.searchController,
    required this.searchQuery,
    required this.selectedCountry,
    required this.selectedCity,
    required this.cubit,
    required this.onSearchChanged,
    required this.onSearchCleared,
    required this.onCountryChanged,
    required this.onCityChanged,
    required this.onCountryRemoved,
    required this.onCityRemoved,
  });

  @override
  Widget build(BuildContext context) {
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
          _buildSearchField(context),
          SizedBox(height: ResponsiveUI.spacing(context, 12)),
          _buildFilterDropdowns(context),
          if (selectedCountry != null || selectedCity != null) ...[
            SizedBox(height: ResponsiveUI.spacing(context, 12)),
            _buildFilterChips(context),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return TextField(
      controller: searchController,
      onChanged: onSearchChanged,
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
        suffixIcon: searchQuery.isNotEmpty
            ? IconButton(
          icon: Icon(
            Icons.clear,
            color: AppColors.darkGray,
            size: ResponsiveUI.iconSize(context, 20),
          ),
          onPressed: onSearchCleared,
        )
            : null,
        filled: true,
        fillColor: AppColors.lightBlueBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            ResponsiveUI.borderRadius(context, 16),
          ),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            ResponsiveUI.borderRadius(context, 16),
          ),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            ResponsiveUI.borderRadius(context, 16),
          ),
          borderSide: const BorderSide(
            color: AppColors.primaryBlue,
            width: 2,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: ResponsiveUI.padding(context, 16),
          vertical: ResponsiveUI.padding(context, 14),
        ),
      ),
    );
  }

  Widget _buildFilterDropdowns(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildFilterDropdown<dynamic>(
            context: context,
            hint: 'Country',
            value: selectedCountry,
            items: cubit.countries ?? [],
            onChanged: onCountryChanged,
            itemBuilder: (country) => country.name ?? '',
            valueBuilder: (country) => country.id ?? '',
          ),
        ),
        SizedBox(width: ResponsiveUI.spacing(context, 12)),
        Expanded(
          child: _buildFilterDropdown<dynamic>(
            context: context,
            hint: 'City',
            value: selectedCity,
            items: selectedCountry != null
                ? (cubit.cities ?? [])
                .where((city) => city.country == selectedCountry)
                .toList()
                : cubit.cities ?? [],
            onChanged: onCityChanged,
            itemBuilder: (city) => city.name ?? '',
            valueBuilder: (city) => city.id ?? '',
          ),
        ),
      ],
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
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUI.padding(context, 12),
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveUI.borderRadius(context, 12),
        ),
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

  Widget _buildFilterChips(BuildContext context) {
    return Wrap(
      spacing: ResponsiveUI.spacing(context, 8),
      children: [
        if (selectedCountry != null)
          _buildFilterChip(
            context,
            label: cubit.countries
                ?.firstWhere((c) => c.id == selectedCountry)
                .name ??
                '',
            onDeleted: onCountryRemoved,
          ),
        if (selectedCity != null)
          _buildFilterChip(
            context,
            label:
            cubit.cities?.firstWhere((c) => c.id == selectedCity).name ??
                '',
            onDeleted: onCityRemoved,
          ),
      ],
    );
  }

  Widget _buildFilterChip(
      BuildContext context, {
        required String label,
        required VoidCallback onDeleted,
      }) {
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
}