// File 1: lib/features/product/presentation/widgets/filter_by_category_brand_widgets.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/animation/animated_element.dart';
import 'package:systego/core/widgets/custom_loading/custom_loading_state.dart';
import 'package:systego/features/admin/product/cubit/product_filter_cubit.dart';
import 'package:systego/features/admin/product/cubit/product_filter_state.dart';
import 'package:systego/features/admin/product/models/filter_models.dart';

enum FilterType { categories, brands, variations, warehouses }

class FilterItem {
  final String id;
  final String name;
  final String image;
  final int count;

  FilterItem({
    required this.id,
    required this.name,
    required this.image,
    required this.count,
  });
}

class FilterButtons extends StatefulWidget {
  final Function(String?) onCategorySelected;
  final Function(String?) onBrandSelected;
  final Function(String?) onVariationSelected;
  final Function(String?) onWarehouseSelected;

  const FilterButtons({
    super.key,
    required this.onCategorySelected,
    required this.onBrandSelected,
    required this.onVariationSelected,
    required this.onWarehouseSelected,
  });

  @override
  State<FilterButtons> createState() => _FilterButtonsState();
}

class _FilterButtonsState extends State<FilterButtons> {
  bool _showCategoriesFilter = false;
  bool _showBrandsFilter = false;
  bool _showWarhousesFilter = false;
  bool _showVariationsFilter = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductFiltersCubit, ProductFiltersState>(
      builder: (context, state) {
        if (state is ProductFiltersSuccess) {
          return AnimatedElement(
            delay: const Duration(milliseconds: 200),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUI.padding(context, 16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: FilterButton(
                              label: 'Categories',
                              isActive: _showCategoriesFilter,
                              onTap: () {
                                setState(() {
                                  _showCategoriesFilter =
                                      !_showCategoriesFilter;
                                  if (_showCategoriesFilter) {
                                    _showBrandsFilter = false;
                                    _showWarhousesFilter = false;
                                    _showVariationsFilter = false;
                                  }
                                });
                              },
                            ),
                          ),
                          SizedBox(width: ResponsiveUI.spacing(context, 12)),
                          Expanded(
                            child: FilterButton(
                              label: 'Brands',
                              isActive: _showBrandsFilter,
                              onTap: () {
                                setState(() {
                                  _showBrandsFilter = !_showBrandsFilter;
                                  if (_showBrandsFilter) {
                                    _showCategoriesFilter = false;
                                    _showWarhousesFilter = false;
                                    _showVariationsFilter = false;
                                  }
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: ResponsiveUI.spacing(context, 12)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: FilterButton(
                              label: 'Warehouses',
                              isActive: _showWarhousesFilter,
                              onTap: () {
                                setState(() {
                                  _showWarhousesFilter = !_showWarhousesFilter;
                                  if (_showWarhousesFilter) {
                                    _showCategoriesFilter = false;
                                    _showBrandsFilter = false;
                                    _showVariationsFilter = false;
                                  }
                                });
                              },
                            ),
                          ),
                          SizedBox(width: ResponsiveUI.spacing(context, 12)),
                          Expanded(
                            child: FilterButton(
                              label: 'Variations',
                              isActive: _showVariationsFilter,
                              onTap: () {
                                setState(() {
                                  _showVariationsFilter =
                                      !_showVariationsFilter;
                                  if (_showVariationsFilter) {
                                    _showCategoriesFilter = false;
                                    _showWarhousesFilter = false;
                                    _showBrandsFilter = false;
                                  }
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: ResponsiveUI.spacing(context, 12)),
                if (_showCategoriesFilter)
                  AnimatedElement(
                    delay: Duration.zero,
                    child: GenericFilterPanel(
                      filterType: FilterType.categories,
                      selectedId: null, // Local or pass from parent if needed
                      onSelected: widget.onCategorySelected,
                      onClose: () {
                        setState(() {
                          _showCategoriesFilter = false;
                        });
                      },
                    ),
                  ),
                if (_showBrandsFilter)
                  AnimatedElement(
                    delay: Duration.zero,
                    child: GenericFilterPanel(
                      filterType: FilterType.brands,
                      selectedId: null,
                      onSelected: widget.onBrandSelected,
                      onClose: () {
                        setState(() {
                          _showBrandsFilter = false;
                        });
                      },
                    ),
                  ),
                if (_showVariationsFilter)
                  AnimatedElement(
                    delay: Duration.zero,
                    child: GenericFilterPanel(
                      filterType: FilterType.variations,
                      selectedId: null,
                      onSelected: widget.onVariationSelected,
                      onClose: () {
                        setState(() {
                          _showVariationsFilter = false;
                        });
                      },
                    ),
                  ),
                if (_showWarhousesFilter)
                  AnimatedElement(
                    delay: Duration.zero,
                    child: GenericFilterPanel(
                      filterType: FilterType.warehouses,
                      selectedId: null,
                      onSelected: widget.onWarehouseSelected,
                      onClose: () {
                        setState(() {
                          _showWarhousesFilter = false;
                        });
                      },
                    ),
                  ),
              ],
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}

class FilterButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const FilterButton({
    super.key,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: ResponsiveUI.padding(context, 12),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            ResponsiveUI.borderRadius(context, 8),
          ),
          border: Border.all(
            color: isActive ? AppColors.primaryBlue : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppColors.primaryBlue : Colors.grey[700],
                fontSize: ResponsiveUI.fontSize(context, 14),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: ResponsiveUI.spacing(context, 6)),
            Icon(
              isActive ? Icons.arrow_drop_up : Icons.arrow_drop_down,
              color: isActive ? AppColors.primaryBlue : Colors.grey[600],
              size: ResponsiveUI.iconSize(context, 20),
            ),
          ],
        ),
      ),
    );
  }
}

// Generic Filter Panel using BlocBuilder
class GenericFilterPanel extends StatelessWidget {
  final FilterType filterType;
  final String? selectedId;
  final Function(String?) onSelected;
  final VoidCallback onClose;

  const GenericFilterPanel({
    super.key,
    required this.filterType,
    required this.selectedId,
    required this.onSelected,
    required this.onClose,
  });

  String _getTitle() {
    switch (filterType) {
      case FilterType.categories:
        return 'Categories';
      case FilterType.brands:
        return 'Brands';
      case FilterType.variations:
        return 'Variations';
      case FilterType.warehouses:
        return 'Warehouses';
    }
  }

  List<FilterItem> _getItems(List<dynamic> list) {
    return list.map((item) {
      int count = 0;
      switch (filterType) {
        case FilterType.categories:
          count = (item as CategoryFilter).productQuantity;
          return FilterItem(
            id: item.id,
            name: item.name,
            image: item.image,
            count: count,
          );
        case FilterType.brands:
          return FilterItem(
            id: (item as BrandFilter).id,
            name: item.name,
            image: item.logo,
            count: 0, // Add count from API if available
          );
        case FilterType.variations:
          final varn = item as VariationFilter;
          return FilterItem(
            id: varn.id,
            name: varn.name,
            image: '',
            count: varn.options.length,
          );
        case FilterType.warehouses:
          final wh = item as WarehouseFilter;
          return FilterItem(
            id: wh.id,
            name: wh.name,
            image: '',
            count: wh.numberOfProducts,
          );
      }
    }).toList();
  }

  Widget _buildItem(FilterItem item, bool isSelected) {
    return ListTile(
      leading: item.image.isNotEmpty
          ? CircleAvatar(
              backgroundImage: NetworkImage(item.image),
              onBackgroundImageError: (_, __) => Icon(Icons.error),
            )
          : Icon(_getIconForType()),
      title: Text(item.name),
      subtitle: Text('${item.count} products'),
      trailing: isSelected
          ? Icon(Icons.check, color: AppColors.primaryBlue)
          : null,
      selected: isSelected,
      onTap: () => onSelected(isSelected ? null : item.id),
    );
  }

  IconData _getIconForType() {
    switch (filterType) {
      case FilterType.categories:
        return Icons.category;
      case FilterType.brands:
        return Icons.business;
      case FilterType.variations:
        return Icons.tune;
      case FilterType.warehouses:
        return Icons.warehouse;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductFiltersCubit, ProductFiltersState>(
      builder: (context, state) {
        if (state is ProductFiltersLoading) {
          return Container(
            padding: EdgeInsets.all(16),
            child: Center(
              child: CustomLoadingState(),
              //  child: CircularProgressIndicator(color: AppColors.primaryBlue),
            ),
          );
        }

        if (state is ProductFiltersError) {
          return Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text('Error: ${state.message}'),
                ElevatedButton(
                  onPressed: () =>
                      context.read<ProductFiltersCubit>().getFilters(),
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is ProductFiltersSuccess) {
          List<dynamic> list;
          switch (filterType) {
            case FilterType.categories:
              list = state.filters.data?.categories ?? [];
              break;
            case FilterType.brands:
              list = state.filters.data?.brands ?? [];
              break;
            case FilterType.variations:
              list = state.filters.data?.variations ?? [];
              break;
            case FilterType.warehouses:
              list = state.filters.data?.warehouses ?? [];
          }

          final items = _getItems(list);

          return Container(
            margin: EdgeInsets.symmetric(
              horizontal: ResponsiveUI.padding(context, 16),
            ),
            padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                ResponsiveUI.borderRadius(context, 12),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FilterPanelHeader(title: _getTitle(), onClose: onClose),
                SizedBox(height: ResponsiveUI.spacing(context, 16)),
                SizedBox(
                  height: ResponsiveUI.value(context, 200),
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isSelected = selectedId == item.id;
                      return _buildItem(item, isSelected);
                    },
                  ),
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class FilterPanelHeader extends StatelessWidget {
  final String title;
  final VoidCallback onClose;

  const FilterPanelHeader({
    super.key,
    required this.title,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 18),
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        IconButton(
          icon: Icon(Icons.close, size: ResponsiveUI.iconSize(context, 24)),
          onPressed: onClose,
        ),
      ],
    );
  }
}
