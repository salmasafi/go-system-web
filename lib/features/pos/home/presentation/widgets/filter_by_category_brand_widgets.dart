// lib/features/pos/home/presentation/widgets/pos_filter_widgets.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/animation/animated_element.dart';
import 'package:systego/core/widgets/custom_loading/custom_loading_state.dart';
import 'package:systego/core/widgets/custom_error/custom_error_state.dart';
import 'package:systego/features/pos/home/cubit/pos_home_cubit.dart';
import 'package:systego/features/pos/home/cubit/pos_home_state.dart';
import 'package:systego/features/pos/home/model/pos_models.dart';

enum FilterType { categories, brands }

class FilterItem {
  final String id;
  final String name;
  final String image;
  FilterItem({required this.id, required this.name, required this.image});
}

class POSFilterBar extends StatefulWidget {
  const POSFilterBar({super.key});
  @override
  State<POSFilterBar> createState() => _POSFilterBarState();
}

class _POSFilterBarState extends State<POSFilterBar> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PosCubit, PosState>(
      builder: (context, state) {
        final cubit = context.read<PosCubit>();

        final bool showCategoryFilters = cubit.showCategoryFilters;
        final bool showBrandFilters = cubit.showBrandFilters;

        return AnimatedElement(
          delay: const Duration(milliseconds: 200),
          child: Column(
            children: [
              SizedBox(height: ResponsiveUI.spacing(context, 12)),

              // CATEGORY PANEL
              if (showCategoryFilters)
                AnimatedElement(
                  delay: Duration.zero,
                  child: GenericFilterPanel(
                    filterType: FilterType.categories,
                    selectedId: cubit.currentCategoryId,
                    onSelected: (id) => cubit.getProductsByCategory(id),
                    onClose: () => cubit.hideFilterPanels(
                      isCategoryRefresh: true,
                    ), // Only hide
                    onFilterClear: () =>
                        cubit.clearFilter(), // Clear + back to featured
                  ),
                ),

              // BRAND PANEL
              if (showBrandFilters)
                AnimatedElement(
                  delay: Duration.zero,
                  child: GenericFilterPanel(
                    filterType: FilterType.brands,
                    selectedId: cubit.currentBrandId,
                    onSelected: (id) => cubit.getProductsByBrand(id),
                    onClose: () => cubit.hideFilterPanels(
                      isBrandRefresh: true,
                    ), // Only hide
                    onFilterClear: () =>
                        cubit.clearFilter(), // Clear + back to featured
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Generic Panel
class GenericFilterPanel extends StatelessWidget {
  final FilterType filterType;
  final String? selectedId;
  final Function(String?) onSelected;
  final VoidCallback onClose; // Hide panel only
  final VoidCallback onFilterClear; // Clear filter + go to featured

  const GenericFilterPanel({
    super.key,
    required this.filterType,
    required this.selectedId,
    required this.onSelected,
    required this.onClose,
    required this.onFilterClear,
  });

  String _title() =>
      filterType == FilterType.categories ? 'Categories' : 'Brands';
  IconData _icon() =>
      filterType == FilterType.categories ? Icons.category : Icons.business;

  List<FilterItem> _items(List<dynamic> list) {
    return list.map((e) {
      final item = e as dynamic;
      return FilterItem(
        id: filterType == FilterType.categories
            ? (item as Category).id
            : (item as Brand).id,
        name: filterType == FilterType.categories
            ? (item as Category).name
            : (item as Brand).name,
        image: filterType == FilterType.categories
            ? (item as Category).image ?? ''
            : (item as Brand).logo ?? '',
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PosCubit, PosState>(
      builder: (context, state) {
        if (state is PosLoading) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: CustomLoadingState(),
          );
        }

        if (state is PosError) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: CustomErrorState(
              message: state.message,
              onRetry: () => context.read<PosCubit>().loadPosData(),
            ),
          );
        }

        if (state is PosDataLoaded || state is PosInitial) {
          final cubit = context.read<PosCubit>();
          final source = filterType == FilterType.categories
              ? cubit.categories
              : cubit.brands;
          if (source.isEmpty) return const SizedBox.shrink();

          final items = _items(source);

          return Container(
            margin: EdgeInsets.symmetric(
              horizontal: ResponsiveUI.padding(context, 16),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUI.padding(context, 16),
              vertical: ResponsiveUI.padding(context, 10),
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(
                ResponsiveUI.borderRadius(context, 12),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FilterPanelHeader(
                  title: _title(),
                  onClose: onClose,
                  onFilterClear: onFilterClear,
                ),
                SizedBox(height: ResponsiveUI.spacing(context, 16)),
                SizedBox(
                  height: ResponsiveUI.value(context, 200),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                    ),
                    itemCount: items.length,
                    itemBuilder: (_, i) {
                      final it = items[i];
                      final selected = selectedId == it.id;
                      return GestureDetector(
                        onTap: () {
                          onSelected(selected ? null : it.id);
                          //Optional: auto-hide panel after selection?
                          onClose();
                        },
                        child: Container(
                          margin: EdgeInsets.all(
                            ResponsiveUI.padding(context, 5),
                          ),
                          padding: EdgeInsets.all(
                            ResponsiveUI.padding(context, 10),
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: selected
                                  ? AppColors.linkBlue
                                  : Colors.transparent,
                            ),
                            borderRadius: BorderRadius.circular(
                              ResponsiveUI.borderRadius(context, 16),
                            ),
                            color: selected
                                ? AppColors.lightBlueBackground.withOpacity(0.7)
                                : AppColors.white,
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                it.image.isNotEmpty
                                    ? CircleAvatar(
                                        backgroundImage: NetworkImage(it.image),
                                        onBackgroundImageError: (_, __) =>
                                            Icon(_icon()),
                                      )
                                    : Icon(_icon()),
                                SizedBox(
                                  height: ResponsiveUI.value(context, 10),
                                ),
                                Text(
                                  it.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
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

// ─────────────────────────────────────────────────────────────────────────────
class FilterPanelHeader extends StatelessWidget {
  final String title;
  final VoidCallback onClose;
  final VoidCallback onFilterClear;

  const FilterPanelHeader({
    super.key,
    required this.title,
    required this.onClose,
    required this.onFilterClear,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 18),
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const Spacer(),
        // Clear Filter Button
        IconButton(
          icon: Icon(
            Icons.filter_alt_off,
            size: ResponsiveUI.iconSize(context, 24),
          ),
          onPressed: onFilterClear,
          tooltip: 'Clear filter',
        ),
        // Close Panel Button
        IconButton(
          icon: Icon(Icons.close, size: ResponsiveUI.iconSize(context, 24)),
          onPressed: onClose,
          tooltip: 'Close panel',
        ),
      ],
    );
  }
}
