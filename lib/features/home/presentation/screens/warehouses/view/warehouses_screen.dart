import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/app_bar_widgets.dart';
import 'package:systego/core/widgets/custom_error/custom_empty_state.dart';
import 'package:systego/core/widgets/custom_loading/custom_loading_state_with_shimmer.dart';
import 'package:systego/core/widgets/custom_warehouse_details_sheet.dart';
import 'package:systego/features/home/presentation/screens/warehouses/view/widgets/animated_warehouse_card.dart';
import 'package:systego/features/home/presentation/screens/warehouses/view/widgets/custom_delete_dialog.dart';
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
  @override
  void initState() {
    super.initState();
    context.read<WareHouseCubit>().getWarehouses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBlueBackground,
      appBar: appBarWithActions(
        context,
        'Warehouses',
            () => Navigator.pushNamed(context, '/add-warehouse-screen'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: ResponsiveUI.contentMaxWidth(context)),
          child: BlocConsumer<WareHouseCubit, WarehousesState>(
            listener: (context, state) {
              if (state is WarehousesError) {
                _showErrorSnackbar(context, state.message);
              }
            },
            builder: (context, state) {
              if (state is WarehousesLoading) {
                return CustomLoadingShimmer(
                );
              }

              final warehouses = context.read<WareHouseCubit>().warehouses;

              if (warehouses.isEmpty) {
                return CustomEmptyState(
                  icon: Icons.warehouse_outlined,
                  title: 'No Warehouses Found',
                  message: 'Add your first warehouse to get started',
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  await context.read<WareHouseCubit>().getWarehouses();
                },
                color: AppColors.primaryBlue,
                child: ListView.builder(
                  padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
                  itemCount: warehouses.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: ResponsiveUI.spacing(context, 8)),
                      child: AnimatedWarehouseCard(
                        warehouse: warehouses[index],
                        index: index,
                        onTap: () => _showWarehouseDetails(context, warehouses[index]),
                        onEdit: () {},
                        onDelete: () => _showDeleteDialog(context, warehouses[index].id ?? ''),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
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
      margin: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 8)),
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
      builder: (context) => CustomWarehouseDetailsSheet(
        warehouse: warehouse,
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String id) {
    if (id.isEmpty) return;

    showDialog(
      context: context,
      builder: (dialogContext) => CustomDeleteDialog(
        title: 'Delete Warehouse',
        message: 'Are you sure you want to delete this warehouse? This action cannot be undone.',
        onDelete: () {
          Navigator.pop(dialogContext);
          _showSuccessSnackbar(context, 'Warehouse deleted successfully!');
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
      margin: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 8)),
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}