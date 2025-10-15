import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/features/home/presentation/screens/warehouses/view/widgets/wisgets_add_edit/warehouse_dialog_buttons.dart';
import 'package:systego/features/home/presentation/screens/warehouses/view/widgets/wisgets_add_edit/warehouse_dialog_form.dart';
import 'package:systego/features/home/presentation/screens/warehouses/view/widgets/wisgets_add_edit/warehouse_dialog_header.dart';
import '../cubit/warehouse_cubit.dart';
import '../cubit/warehouse_state.dart';
import '../data/model/ware_house_model.dart';


class WarehouseFormDialog extends StatefulWidget {
  final Warehouses? warehouse;

  const WarehouseFormDialog({super.key, this.warehouse});

  @override
  State<WarehouseFormDialog> createState() => _WarehouseFormDialogState();
}

class _WarehouseFormDialogState extends State<WarehouseFormDialog>
    with SingleTickerProviderStateMixin {

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  bool get isEditMode => widget.warehouse != null;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupAnimation();
  }

  void _initializeControllers() {
    if (isEditMode) {
      _nameController.text = widget.warehouse!.name ?? '';
      _addressController.text = widget.warehouse!.address ?? '';
      _phoneController.text = widget.warehouse!.phone ?? '';
      _emailController.text = widget.warehouse!.email ?? '';
    }
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: BlocConsumer<WareHouseCubit, WarehousesState>(
          listener: _handleStateChanges,
          builder: (context, state) {
            final isLoading = state is WarehouseCreating ||
                state is WarehouseUpdating;

            return Container(
              constraints: const BoxConstraints(maxWidth: 500, maxHeight: 650),
              decoration: _buildDialogDecoration(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  WarehouseDialogHeader(
                    isEditMode: isEditMode,
                    onClose: () => Navigator.of(context).pop(),
                  ),

                  WarehouseDialogForm(
                    formKey: _formKey,
                    nameController: _nameController,
                    addressController: _addressController,
                    phoneController: _phoneController,
                    emailController: _emailController,
                    isLoading: isLoading,
                  ),

                  WarehouseDialogButtons(
                    isEditMode: isEditMode,
                    isLoading: isLoading,
                    onCancel: () => Navigator.of(context).pop(),
                    onSubmit: _handleSubmit,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  BoxDecoration _buildDialogDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 30,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  void _handleStateChanges(BuildContext context, WarehousesState state) {
    if (state is WarehouseCreated || state is WarehouseUpdated) {
      Navigator.of(context).pop();
    }

    if (state is WarehousesError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(state.message)),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final cubit = context.read<WareHouseCubit>();

      if (isEditMode) {
        cubit.updateWarehouse(
          warehouseId: widget.warehouse!.id!,
          name: _nameController.text.trim(),
          address: _addressController.text.trim(),
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim(),
        );
      } else {
        cubit.createWarehouse(
          name: _nameController.text.trim(),
          address: _addressController.text.trim(),
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim(),
        );
      }
    }
  }
}