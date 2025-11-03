import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/custom_textfield/custom_text_field_widget.dart';
import '../../../../core/widgets/custom_loading/custom_loading_state.dart';
import '../../categories/view/widgets/build_image_placeholder_widget.dart';
import '../cubit/brand_cubit.dart';
import '../cubit/brand_states.dart';
import '../model/get_brand_by_id_model.dart';

class EditBrandBottomSheet extends StatefulWidget {
  final String brandId;

  const EditBrandBottomSheet({super.key, required this.brandId});

  @override
  State<EditBrandBottomSheet> createState() => _EditBrandBottomSheetState();
}

class _EditBrandBottomSheetState extends State<EditBrandBottomSheet> {
  late TextEditingController _nameController;
  File? _selectedImage;
  final _picker = ImagePicker();
  bool _isLoading = true; // Start with loading true to show loading state immediately
  BrandById? _brand;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    BrandsCubit.get(context).getBrandById(widget.brandId);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null && mounted) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  void _submitUpdate() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter brand name'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
        ),
      );
      return;
    }
    BrandsCubit.get(context).updateBrand(
      brandId: widget.brandId,
      name: _nameController.text.trim(),
      logoFile: _selectedImage,
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = ResponsiveUI.contentMaxWidth(context);
    final isDesktop = maxWidth > 600;
    final image = _selectedImage != null
        ? Image.file(_selectedImage!, fit: BoxFit.cover)
        : _brand?.logo?.isNotEmpty ?? false
        ? Image.network(_brand!.logo!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const CustomImagePlaceholder())
        : const CustomImagePlaceholder();

    return BlocListener<BrandsCubit, BrandsState>(
      listener: (context, state) {
        if (state is GetBrandByIdLoading) {
          setState(() => _isLoading = true);
        } else if (state is GetBrandByIdSuccess) {
          setState(() {
            _brand = state.brand;
            _nameController.text = _brand?.name ?? '';
            _isLoading = false;
          });
        } else if (state is GetBrandByIdError) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
            ),
          );
          Navigator.pop(context);
        } else if (state is UpdateBrandLoading) {
          setState(() => _isLoading = true);
        } else if (state is UpdateBrandSuccess) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
            ),
          );
          Navigator.pop(context, true);
        } else if (state is UpdateBrandError) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
            ),
          );
        }
      },
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        margin: EdgeInsets.symmetric(horizontal: isDesktop ? ResponsiveUI.padding(context, 20) : 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(ResponsiveUI.borderRadius(context, 24))),
        ),
        child: SafeArea(
          child: _isLoading || _brand == null // Show loading if _isLoading or _brand is null
              ? Container(
            height: ResponsiveUI.value(context, 300),
            padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
            child: const Center(
              child: CustomLoadingState(size: 60),
            ),
          )
              : SingleChildScrollView(
            padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: ResponsiveUI.value(context, 40),
                    height: ResponsiveUI.value(context, 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.all(Radius.circular(ResponsiveUI.borderRadius(context, 2))),
                    ),
                  ),
                ),
                SizedBox(height: ResponsiveUI.spacing(context, 12)),
                Text(
                  'Edit Brand',
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 20),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: ResponsiveUI.spacing(context, 16)),
                CustomTextField(
                  controller: _nameController,
                  labelText: 'Brand Name',
                  hintText: 'Enter brand name',
                  prefixIcon: Icons.branding_watermark,
                  hasBoxDecoration: false,
                  hasBorder: true,
                  prefixIconColor: AppColors.darkGray.withOpacity(0.7),
                ),
                SizedBox(height: ResponsiveUI.spacing(context, 12)),
                Text(
                  'Brand Logo',
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 14),
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: ResponsiveUI.spacing(context, 8)),
                GestureDetector(
                  onTap: _isLoading ? null : _pickImage,
                  child: Container(
                    height: ResponsiveUI.value(context, 300),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!, width: 1),
                      borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
                      color: Colors.grey[50],
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
                          child: image,
                        ),
                        if (_selectedImage != null || (_brand?.logo?.isNotEmpty ?? false))
                          Positioned(
                            top: ResponsiveUI.padding(context, 8),
                            right: ResponsiveUI.padding(context, 8),
                            child: Container(
                              padding: EdgeInsets.all(ResponsiveUI.padding(context, 6)),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 6)),
                              ),
                              child: Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: ResponsiveUI.iconSize(context, 18),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: ResponsiveUI.spacing(context, 8)),
                if (_selectedImage == null && (_brand?.logo?.isEmpty ?? true))
                  Text(
                    'Tap to select a logo',
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 12),
                      color: Colors.orange[700],
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                if (_selectedImage != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: ResponsiveUI.iconSize(context, 16),
                      ),
                      SizedBox(width: ResponsiveUI.spacing(context, 4)),
                      Text(
                        'New logo selected',
                        style: TextStyle(
                          fontSize: ResponsiveUI.fontSize(context, 12),
                          color: Colors.green[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                SizedBox(height: ResponsiveUI.spacing(context, 16)),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitUpdate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    padding: EdgeInsets.symmetric(vertical: ResponsiveUI.padding(context, 14)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                    height: ResponsiveUI.iconSize(context, 20),
                    width: ResponsiveUI.iconSize(context, 20),
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : Text(
                    'Update Brand',
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 16),
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}