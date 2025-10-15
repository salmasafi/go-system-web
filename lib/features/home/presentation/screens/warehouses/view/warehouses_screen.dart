import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/features/home/presentation/screens/warehouses/view/warehouse_form_dialog.dart';
import 'package:systego/features/home/presentation/screens/warehouses/view/widgets/animated_warehouse_card.dart';
import 'package:systego/features/home/presentation/screens/warehouses/view/widgets/custom_delete_dialog.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/widgets/app_bar_widgets.dart';
import '../../../../../../core/widgets/custom_error/custom_empty_state.dart';
import '../../../../../../core/widgets/custom_loading/custom_loading_state_with_shimmer.dart';
import '../../../../../../core/widgets/custom_warehouse_details_sheet.dart';
import '../../../../../product/presentation/widgets/search_bar_widget.dart';
import '../cubit/warehouse_cubit.dart';
import '../cubit/warehouse_state.dart';
import '../data/model/ware_house_model.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

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
      backgroundColor: AppColors.lightBlueBackground,
      appBar: appBarWithActions(context, 'Warehouses', () {
        Navigator.pop(context);
      }),
      body: Stack(
        children: [
          BlocConsumer<WareHouseCubit, WarehousesState>(
            listener: (context, state) {
              if (state is WarehousesError) {
                _showErrorSnackbar(context, state.message);
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
                _showSuccessSnackbar(context, 'Warehouse deleted successfully!');
                setState(() => _isDeleting = false);
              }

              if (state is WarehouseCreated) {
                _showSuccessSnackbar(context, 'Warehouse created successfully!');
              }

              if (state is WarehouseUpdated) {
                _showSuccessSnackbar(context, 'Warehouse updated successfully!');
              }
            },
            builder: (context, state) {
              if (state is WarehousesLoading && !_isDeleting) {
                return const CustomLoadingShimmer();
              }

              final warehouses = context.read<WareHouseCubit>().warehouses;

              // Initialize filtered list if empty
              if (_filteredWarehouses.isEmpty && _searchController.text.isEmpty) {
                _filteredWarehouses = warehouses;
              }

              if (warehouses.isEmpty) {
                return CustomEmptyState(
                  icon: Icons.warehouse_outlined,
                  title: 'No Warehouses Found',
                  message: 'Add your first warehouse to get started',
                  onRefresh: () async =>
                  await context.read<WareHouseCubit>().getWarehouses(),
                );
              }

              return Column(
                children: [
                  SearchBarWidget(
                    controller: _searchController,
                    onChanged: (value) => _filterWarehouses(value, warehouses),
                  ),
                  Expanded(
                    child: _filteredWarehouses.isEmpty
                        ? CustomEmptyState(
                      icon: Icons.search_off,
                      title: 'No Results Found',
                      message: 'Try searching with different keywords',
                      onRefresh: () async {
                        _searchController.clear();
                        await context.read<WareHouseCubit>().getWarehouses();
                      },
                    )
                        : RefreshIndicator(
                      onRefresh: () async {
                        await context.read<WareHouseCubit>().getWarehouses();
                      },
                      color: AppColors.primaryBlue,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredWarehouses.length,
                        itemBuilder: (context, index) {
                          return AnimatedWarehouseCard(
                            warehouse: _filteredWarehouses[index],
                            index: index,
                            onTap: () => _showWarehouseDetails(
                                context, _filteredWarehouses[index]),
                            onEdit: () => _navigateToEdit(_filteredWarehouses[index]),
                            onDelete: () => _showDeleteDialog(
                                context, _filteredWarehouses[index]),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // Loading overlay when deleting
          if (_isDeleting)
            Container(
              color: Colors.black38,
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Deleting warehouse...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const WarehouseFormDialog(),
          );
        },
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _navigateToEdit(Warehouses warehouse) {
    showDialog(
      context: context,
      builder: (context) => WarehouseFormDialog(warehouse: warehouse),
    );
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: 'Error!',
        message: message,
        contentType: ContentType.failure,
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
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
      _showErrorSnackbar(context, 'Invalid warehouse ID');
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => CustomDeleteDialog(
        title: 'Delete Warehouse',
        message: 'Are you sure you want to delete "${warehouse.name}"? This action cannot be undone.',
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

  void _showSuccessSnackbar(BuildContext context, String message) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: 'Success!',
        message: message,
        contentType: ContentType.success,
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}