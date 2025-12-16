import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/custom_snack_bar/custom_snackbar.dart';
import 'package:systego/features/admin/suppliers/view/suppplier_add_edit/supplier_dialog_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:systego/generated/locale_keys.g.dart';
import '../../cubit/supplier_cubit.dart';
import '../../model/supplier_model.dart';
import 'supplier_dialog_form.dart';
import 'supplier_dialog_header.dart';

class SupplierDialog {
  static void show(
    BuildContext context, {
    Suppliers? supplier,
  }) {
    final cubit = context.read<SupplierCubit>();

    if ((cubit.countries?.isEmpty ?? true) ||
        (cubit.cities?.isEmpty ?? true)) {
      cubit.getSuppliers().then((_) {
        _showDialogContent(context, supplier, cubit);
      }).catchError((_) {
        _showDialogContent(context, supplier, cubit);
      });
    } else {
      _showDialogContent(context, supplier, cubit);
    }
  }

  static void _showDialogContent(
    BuildContext context,
    Suppliers? supplier,
    SupplierCubit cubit,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _SupplierDialogContent(
        supplier: supplier,
        cubit: cubit,
      ),
    );
  }
}

class _SupplierDialogContent extends StatefulWidget {
  final Suppliers? supplier;
  final SupplierCubit cubit;

  const _SupplierDialogContent({
    this.supplier,
    required this.cubit,
  });

  @override
  State<_SupplierDialogContent> createState() => _SupplierDialogContentState();
}

class _SupplierDialogContentState extends State<_SupplierDialogContent> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _companyNameController;

  String? _selectedCountryId;
  String? _selectedCityId;
  bool _isLoading = false;
  XFile? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();

  bool get isEditMode => widget.supplier != null;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.supplier?.username);
    _emailController = TextEditingController(text: widget.supplier?.email);
    _phoneController = TextEditingController(text: widget.supplier?.phoneNumber);
    _addressController = TextEditingController(text: widget.supplier?.address);
    _companyNameController = TextEditingController(text: widget.supplier?.companyName);
    _selectedCountryId = widget.supplier?.countryId?.id;
    _selectedCityId = widget.supplier?.cityId?.id;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _companyNameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showError(context, LocaleKeys.failed_to_pick_image.tr());
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCountryId == null) {
      CustomSnackbar.showError(context, LocaleKeys.please_select_country.tr());
      return;
    }

    if (_selectedCityId == null) {
      CustomSnackbar.showError(context, LocaleKeys.please_select_city.tr());
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (isEditMode) {
        await widget.cubit.updateSupplier(
          id: widget.supplier!.id!,
          username: _usernameController.text.trim(),
          email: _emailController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          address: _addressController.text.trim(),
          companyName: _companyNameController.text.trim(),
          countryId: _selectedCountryId,
          cityId: _selectedCityId,
          imageFile: _selectedImage,
        );
      } else {
        await widget.cubit.createSupplier(
          username: _usernameController.text.trim(),
          email: _emailController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          address: _addressController.text.trim(),
          companyName: _companyNameController.text.trim(),
          countryId: _selectedCountryId!,
          cityId: _selectedCityId!,
          imageFile: _selectedImage,
        );
      }

      if (mounted) {
        Navigator.of(context).pop();
        CustomSnackbar.showSuccess(
          context,
          isEditMode
              ? LocaleKeys.supplier_updated_successfully.tr()
              : LocaleKeys.supplier_created_successfully.tr(),
        );
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showError(context, e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dialogWidth = ResponsiveUI.value(context, 520);
    final maxHeight = MediaQuery.of(context).size.height * 0.85;
    final borderRadius24 = ResponsiveUI.borderRadius(context, 24);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: ResponsiveUI.padding(context, 20),
        vertical: ResponsiveUI.padding(context, 30),
      ),
      child: Container(
        width: dialogWidth,
        constraints: BoxConstraints(maxHeight: maxHeight),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SupplierDialogHeader(
              isEditMode: isEditMode,
              onClose: () => Navigator.of(context).pop(),
            ),
            SupplierDialogForm(
              formKey: _formKey,
              usernameController: _usernameController,
              emailController: _emailController,
              phoneController: _phoneController,
              addressController: _addressController,
              companyNameController: _companyNameController,
              selectedCountryId: _selectedCountryId,
              selectedCityId: _selectedCityId,
              countries: widget.cubit.countries,
              cities: widget.cubit.cities,
              onCountryChanged: (value) {
                setState(() {
                  _selectedCountryId = value;
                  _selectedCityId = null;
                });
              },
              onCityChanged: (value) {
                setState(() {
                  _selectedCityId = value;
                });
              },
              isLoading: _isLoading,
              selectedImage: _selectedImage,
              onPickImage: _pickImage,
              onClearImage: () {
                setState(() {
                  _selectedImage = null;
                });
              },
              existingImageUrl: widget.supplier?.image,
            ),
            SupplierDialogButtons(
              isEditMode: isEditMode,
              isLoading: _isLoading,
              onCancel: () => Navigator.of(context).pop(),
              onSubmit: _handleSubmit,
            ),
          ],
        ),
      ),
    );
  }
}
