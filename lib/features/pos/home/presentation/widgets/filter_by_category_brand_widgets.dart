// lib/features/pos/home/presentation/widgets/tab_bar.dart
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
  final int count;

  FilterItem({
    required this.id,
    required this.name,
    required this.image,
    required this.count,
  });
}

class POSFilterBar extends StatelessWidget {
  const POSFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PosCubit, PosState>(
      builder: (context, state) {
        final cubit = context.read<PosCubit>();
        if (state is! PosDataLoaded && state is! PosLoading) {
          return const SizedBox.shrink();
        }

        return AnimatedElement(
          delay: const Duration(milliseconds: 200),
          child: Column(
            children: [
              SizedBox(height: ResponsiveUI.spacing(context, 12)),
              // Panels
              if (cubit.selectedTab == 'category')
                AnimatedElement(
                  delay: Duration.zero,
                  child: GenericFilterPanel(
                    filterType: FilterType.categories,
                    selectedId: cubit.currentCategoryId,
                    onSelected: (id) {
                      if (id != null) {
                        cubit.getProductsByCategory(id);
                      }
                    },
                    onClose: () {
                      cubit.clearFilter();
                    },
                  ),
                ),

              if (cubit.selectedTab == 'brand')
                AnimatedElement(
                  delay: Duration.zero,
                  child: GenericFilterPanel(
                    filterType: FilterType.brands,
                    selectedId: cubit.currentBrandId,
                    onSelected: (id) {
                      if (id != null) {
                        cubit.getProductsByBrand(id);
                      }
                    },
                    onClose: () {
                      cubit.clearFilter();
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

// Generic Panel
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

  String _title() =>
      filterType == FilterType.categories ? 'Categories' : 'Brands';
  IconData _icon() =>
      filterType == FilterType.categories ? Icons.category : Icons.business;

  List<FilterItem> _items(List<dynamic> list) {
    return list.map((e) {
      final item = e as dynamic;
      final count = list.length; // fallback; update if API gives count
      return FilterItem(
        id: filterType == FilterType.categories
            ? (item as Category).id
            : (item as Brand).id,
        name: filterType == FilterType.categories ? item.name : item.name,
        image: '',
        count: count,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PosCubit>();
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
              onRetry: () => cubit.loadPosData(),
            ),
          );
        }

        if (state is PosDataLoaded || state is PosInitial) {
          final cubit = context.read<PosCubit>();
          final List<dynamic> source = filterType == FilterType.categories
              ? cubit.categories
              : cubit.brands;

          if (source.isEmpty) return const SizedBox.shrink();

          final items = _items(source);

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
                FilterPanelHeader(title: _title(), onClose: onClose),
                SizedBox(height: ResponsiveUI.spacing(context, 16)),
                SizedBox(
                  height: ResponsiveUI.value(context, 200),
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (_, i) {
                      final it = items[i];
                      final selected = selectedId == it.id;
                      return ListTile(
                        leading: Icon(_icon()),
                        title: Text(it.name),
                        subtitle: Text('${it.count} items'),
                        trailing: selected
                            ? const Icon(
                                Icons.check,
                                color: AppColors.primaryBlue,
                              )
                            : null,
                        selected: selected,
                        onTap: () => onSelected(selected ? null : it.id),
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
