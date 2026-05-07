import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:GoSystem/features/pos/home/cubit/pos_home_cubit.dart';
import 'package:GoSystem/features/pos/home/cubit/pos_home_state.dart';
import 'package:GoSystem/features/pos/home/model/pos_models.dart';

enum FilterType { categories, brands }

class FilterItem {
  final String id;
  final String name;
  final String image;
  FilterItem({required this.id, required this.name, required this.image});
}

// ─── Filter Bar (horizontal chip strip) ──────────────────────────────────────

class POSFilterBar extends StatelessWidget {
  const POSFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PosCubit, PosState>(
      builder: (context, state) {
        final cubit = context.read<PosCubit>();
        final showCategory = cubit.showCategoryFilters;
        final showBrand = cubit.showBrandFilters;

        if (!showCategory && !showBrand) return const SizedBox.shrink();

        return Container(
          color: AppColors.white,
          padding: EdgeInsets.only(
            top: ResponsiveUI.padding(context, 6),
            bottom: ResponsiveUI.padding(context, 8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showCategory)
                _HorizontalFilterStrip(
                  filterType: FilterType.categories,
                  selectedId: cubit.currentCategoryId,
                  onSelected: (id) => cubit.getProductsByCategory(id),
                  onClear: () => cubit.clearFilter(),
                ),
              if (showBrand)
                _HorizontalFilterStrip(
                  filterType: FilterType.brands,
                  selectedId: cubit.currentBrandId,
                  onSelected: (id) => cubit.getProductsByBrand(id),
                  onClear: () => cubit.clearFilter(),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Horizontal scrollable chip strip ────────────────────────────────────────

class _HorizontalFilterStrip extends StatelessWidget {
  final FilterType filterType;
  final String? selectedId;
  final Function(String?) onSelected;
  final VoidCallback onClear;

  const _HorizontalFilterStrip({
    required this.filterType,
    required this.selectedId,
    required this.onSelected,
    required this.onClear,
  });

  List<FilterItem> _buildItems(PosCubit cubit) {
    final source =
        filterType == FilterType.categories ? cubit.categories : cubit.brands;
    return source.map((e) {
      if (filterType == FilterType.categories) {
        final cat = e as Category;
        return FilterItem(id: cat.id, name: cat.name, image: cat.image ?? '');
      } else {
        final brand = e as Brand;
        return FilterItem(
            id: brand.id, name: brand.name, image: brand.logo ?? '');
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PosCubit, PosState>(
      builder: (context, state) {
        final cubit = context.read<PosCubit>();
        final items = _buildItems(cubit);
        if (items.isEmpty) return const SizedBox.shrink();

        final icon = filterType == FilterType.categories
            ? Icons.category_rounded
            : Icons.business_rounded;

        return SizedBox(
          height: ResponsiveUI.value(context, 44),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUI.padding(context, 16),
            ),
            itemCount: items.length + 1,
            separatorBuilder: (_, __) =>
                SizedBox(width: ResponsiveUI.value(context, 8)),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _Chip(
                  label: 'All',
                  imageUrl: '',
                  icon: icon,
                  isSelected: selectedId == null,
                  onTap: selectedId != null ? onClear : null,
                );
              }
              final item = items[index - 1];
              final isSelected = selectedId == item.id;
              return _Chip(
                label: item.name,
                imageUrl: item.image,
                icon: icon,
                isSelected: isSelected,
                onTap: () => onSelected(isSelected ? null : item.id),
              );
            },
          ),
        );
      },
    );
  }
}

// ─── Single chip ──────────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final String label;
  final String imageUrl;
  final IconData icon;
  final bool isSelected;
  final VoidCallback? onTap;

  const _Chip({
    required this.label,
    required this.imageUrl,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUI.padding(context, 12),
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : AppColors.white,
          borderRadius: BorderRadius.circular(
            ResponsiveUI.borderRadius(context, 20),
          ),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryBlue
                : AppColors.shadowGray.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (imageUrl.isNotEmpty)
              Padding(
                padding: EdgeInsetsDirectional.only(
                    end: ResponsiveUI.padding(context, 6)),
                child: CircleAvatar(
                  radius: ResponsiveUI.value(context, 9),
                  backgroundImage: NetworkImage(imageUrl),
                  onBackgroundImageError: (_, __) {},
                  backgroundColor: isSelected
                      ? Colors.white.withValues(alpha: 0.3)
                      : AppColors.lightBlueBackground,
                ),
              )
            else
              Padding(
                padding: EdgeInsetsDirectional.only(
                    end: ResponsiveUI.padding(context, 5)),
                child: Icon(
                  icon,
                  size: ResponsiveUI.iconSize(context, 13),
                  color: isSelected ? Colors.white : AppColors.primaryBlue,
                ),
              ),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.darkGray,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: ResponsiveUI.fontSize(context, 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
