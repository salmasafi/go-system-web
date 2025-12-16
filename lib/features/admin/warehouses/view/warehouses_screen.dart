import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/features/admin/warehouses/view/warehouse_form_dialog.dart';
import 'package:systego/features/admin/warehouses/view/widgets/animated_warehouse_card.dart';
import 'package:systego/features/admin/warehouses/view/widgets/custom_delete_dialog.dart';
import 'package:systego/generated/locale_keys.g.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_ui.dart';
import '../../../../core/widgets/app_bar_widgets.dart';
import '../../../../core/widgets/custom_error/custom_empty_state.dart';
import '../../../../core/widgets/custom_loading/custom_loading_state_with_shimmer.dart';
import '../../../../core/widgets/custom_snack_bar/custom_snackbar.dart';
import '../../../../core/widgets/custom_warehouse_details_sheet.dart';
import '../../product/presentation/widgets/search_bar_widget.dart';
import '../cubit/warehouse_cubit.dart';
import '../cubit/warehouse_state.dart';
import '../model/ware_house_model.dart';

class WarehousesScreen extends StatefulWidget {
  const WarehousesScreen({super.key});

  @override
  State<WarehousesScreen> createState() => _WarehousesScreenState();
}

class _WarehousesScreenState extends State<WarehousesScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Warehouses> _filteredWarehouses = [];
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    context.read<WareHouseCubit>().getWarehouses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterWarehouses(String query, List<Warehouses> warehouses) {
    setState(() {
      if (query.isEmpty) {
        _filteredWarehouses = warehouses;
      } else {
        _filteredWarehouses = warehouses.where((warehouse) {
          final nameLower = (warehouse.name ?? '').toLowerCase();
          final locationLower = (warehouse.address ?? '').toLowerCase();
          final searchLower = query.toLowerCase();

          return nameLower.contains(searchLower) ||
              locationLower.contains(searchLower);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWithActions(
        context,
        title: LocaleKeys.warehouses.tr(),
        showActions: true,
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const WarehouseFormDialog(),
          );
        },
      ),
      body: Stack(
        children: [
          BlocConsumer<WareHouseCubit, WarehousesState>(
            listener: (context, state) {
              if (state is WarehousesError) {
                CustomSnackbar.showError(context, state.message);
                setState(() => _isDeleting = false);
              }

              if (state is WarehousesSuccess) {
                final warehouses = context.read<WareHouseCubit>().warehouses;
                _filterWarehouses(_searchController.text, warehouses);
                setState(() => _isDeleting = false);
              }

              if (state is WarehouseDeleting) {
                setState(() => _isDeleting = true);
              }

              if (state is WarehouseDeleted) {
                CustomSnackbar.showSuccess(
                  context,
                  LocaleKeys.warehouse_deleted_success.tr(),
                );
                setState(() => _isDeleting = false);
              }

              if (state is WarehouseCreated) {
                CustomSnackbar.showSuccess(
                  context,
                  LocaleKeys.warehouse_created_success.tr(),
                );
              }

              if (state is WarehouseUpdated) {
                CustomSnackbar.showSuccess(
                  context,
                  LocaleKeys.warehouse_updated_success.tr(),
                );
              }
            },
            builder: (context, state) {
              if (state is WarehousesLoading && !_isDeleting) {
                return CustomLoadingShimmer(
                  padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
                );
              }

              final warehouses = context.read<WareHouseCubit>().warehouses;

              // Initialize filtered list if empty
              if (_filteredWarehouses.isEmpty &&
                  _searchController.text.isEmpty) {
                _filteredWarehouses = warehouses;
              }

              if (warehouses.isEmpty) {
                return CustomEmptyState(
                  icon: Icons.warehouse_outlined,
                  title: LocaleKeys.no_warehouses_found.tr(),
                  message: LocaleKeys.add_first_warehouse_message.tr(),
                  onRefresh: () async =>
                      await context.read<WareHouseCubit>().getWarehouses(),
                );
              }

              return Column(
                children: [
                  SearchBarWidget(
                    text: LocaleKeys.warehouses.tr(),
                    controller: _searchController,
                    onChanged: (value) => _filterWarehouses(value, warehouses),
                  ),
                  Expanded(
                    child: _filteredWarehouses.isEmpty
                        ? CustomEmptyState(
                            icon: Icons.search_off,
                            title: LocaleKeys.no_results_found.tr(),
                            message:  LocaleKeys.try_different_keywords.tr(),
                            onRefresh: () async {
                              _searchController.clear();
                              await context
                                  .read<WareHouseCubit>()
                                  .getWarehouses();
                            },
                          )
                        : RefreshIndicator(
                            onRefresh: () async {
                              await context
                                  .read<WareHouseCubit>()
                                  .getWarehouses();
                            },
                            color: AppColors.primaryBlue,
                            child: ListView.builder(
                              padding: EdgeInsets.symmetric(
                                horizontal: ResponsiveUI.padding(context, 16),
                              ),
                              itemCount: _filteredWarehouses.length,
                              itemBuilder: (context, index) {
                                return AnimatedWarehouseCard(
                                  warehouse: _filteredWarehouses[index],
                                  index: index,
                                  onTap: () => _showWarehouseDetails(
                                    context,
                                    _filteredWarehouses[index],
                                  ),
                                  onEdit: () => _navigateToEdit(
                                    _filteredWarehouses[index],
                                  ),
                                  onDelete: () => _showDeleteDialog(
                                    context,
                                    _filteredWarehouses[index],
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      //   floatingActionButton: FloatingActionButton(
      //     onPressed: () {
      //       showDialog(
      //         context: context,
      //         builder: (context) => const WarehouseFormDialog(),
      //       );
      //     },
      //     backgroundColor: AppColors.primaryBlue,
      //     child: Icon(
      //       Icons.add,
      //       color: AppColors.white,
      //       size: ResponsiveUI.iconSize(context, 24),
      //     ),
      //   ),
      //   floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _navigateToEdit(Warehouses warehouse) {
    showDialog(
      context: context,
      builder: (context) => WarehouseFormDialog(warehouse: warehouse),
    );
  }

  void _showWarehouseDetails(BuildContext context, Warehouses warehouse) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      builder: (context) => CustomWarehouseDetailsSheet(warehouse: warehouse),
    );
  }

  void _showDeleteDialog(BuildContext context, Warehouses warehouse) {
    if (warehouse.id == null || warehouse.id!.isEmpty) {
      CustomSnackbar.showError(context, LocaleKeys.invalid_warehouse_id.tr());
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => CustomDeleteDialog(
        title: LocaleKeys.delete_warehouse.tr(),
        message:
            '${LocaleKeys.delete_warehouse_message} ${warehouse.name}',
        onDelete: () {
          Navigator.pop(dialogContext);

          // Call delete method from cubit
          context.read<WareHouseCubit>().deleteWarehouse(
            warehouseId: warehouse.id!,
          );
        },
      ),
    );
  }
}
