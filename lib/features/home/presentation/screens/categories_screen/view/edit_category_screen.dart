import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/custom_text_field_widget.dart';
import 'package:systego/features/home/presentation/screens/categories_screen/view/widgets/build_image_placeholder_widget.dart';
import '../../../../../../core/widgets/custom_loading/custom_loading_state.dart';
import '../logic/cubit/categories_cubit.dart';
import '../logic/cubit/categories_states.dart';
import '../logic/model/get_categories_model.dart';

class EditCategoryBottomSheet extends StatefulWidget {
  final CategoryItem category;

  const EditCategoryBottomSheet({super.key, required this.category});

  @override
  State<EditCategoryBottomSheet> createState() => _EditCategoryBottomSheetState();
}

class _EditCategoryBottomSheetState extends State<EditCategoryBottomSheet> {
  late TextEditingController _nameController;
  String? _selectedParentId;
  File? _selectedImage;
  final _picker = ImagePicker();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category.name);
    _selectedParentId = widget.category.parentId?.id;
    CategoriesCubit.get(context).getCategories(); // Ensure parentCategories is populated
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
          content: Text(
            'Please enter category name',
            style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 14)),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 8)),
          ),
          margin: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
        ),
      );
      return;
    }

    // Only send parentId if it's not null (i.e., user selected a parent category)
    if (_selectedParentId != null) {
      CategoriesCubit.get(context).updateCategory(
        categoryId: widget.category.id,
        name: _nameController.text.trim(),
        imageFile: _selectedImage,
        parentId: _selectedParentId,
      );
    } else {
      // Don't send parentId at all if none selected
      CategoriesCubit.get(context).updateCategory(
        categoryId: widget.category.id,
        name: _nameController.text.trim(),
        imageFile: _selectedImage,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = CategoriesCubit.get(context);
    final maxWidth = ResponsiveUI.contentMaxWidth(context);
    final isDesktop = maxWidth > 600;
    final image = _selectedImage != null
        ? Image.file(_selectedImage!, fit: BoxFit.cover)
        : widget.category.image.isNotEmpty
        ? Image.network(widget.category.image, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const CustomImagePlaceholder())
        : const CustomImagePlaceholder();

    return BlocListener<CategoriesCubit, CategoriesState>(
      listener: (context, state) {
        if (state is GetCategoriesLoading || state is UpdateCategoryLoading) {
          setState(() => _isLoading = true);
        } else if (state is GetCategoriesSuccess || state is GetCategoriesError) {
          setState(() => _isLoading = false);
        } else if (state is UpdateCategorySuccess) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 14)),
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 8)),
              ),
              margin: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
            ),
          );
          Navigator.pop(context, true);
        } else if (state is UpdateCategoryError) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.error,
                style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 14)),
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 8)),
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
          child: _isLoading
              ? Container(
            height: ResponsiveUI.value(context, 300),
            padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
            child: Center(
              child: CustomLoadingState(
                size: ResponsiveUI.iconSize(context, 60),
              ),
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
                  'Edit Category',
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 20),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: ResponsiveUI.spacing(context, 16)),
                CustomTextField(
                  controller: _nameController,
                  labelText: 'Category Name',
                  hintText: 'Enter category name',
                  prefixIcon: Icons.category,
                  hasBoxDecoration: false,
                  hasBorder: true,
                  prefixIconColor: AppColors.darkGray.withOpacity(0.7),
                ),
                SizedBox(height: ResponsiveUI.spacing(context, 25)),
                SizedBox(
                  height: ResponsiveUI.value(context, 60),
                  child: DropdownButtonFormField<String>(
                    value: _selectedParentId,
                    decoration: InputDecoration(
                      labelText: 'Parent Category (Optional)',
                      prefixIcon: Icon(
                        Icons.folder,
                        color: AppColors.darkGray,
                        size: ResponsiveUI.iconSize(context, 24),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 8)),
                        borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 8)),
                        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: ResponsiveUI.padding(context, 12),
                        vertical: ResponsiveUI.padding(context, 8),
                      ),
                    ),
                    dropdownColor: Colors.white,
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: AppColors.primaryBlue,
                      size: ResponsiveUI.iconSize(context, 24),
                    ),
                    style: TextStyle(
                      color: AppColors.darkGray,
                      fontSize: ResponsiveUI.fontSize(context, 14),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text(
                          'None',
                          style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 14)),
                        ),
                      ),
                      ...cubit.parentCategories
                          .where((parent) => parent.id != widget.category.id) // Exclude current category
                          .map(
                            (parent) => DropdownMenuItem(
                          value: parent.id,
                          child: Row(
                            children: [
                              Container(
                                width: ResponsiveUI.value(context, 24),
                                height: ResponsiveUI.value(context, 24),
                                margin: EdgeInsets.only(right: ResponsiveUI.spacing(context, 8)),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 4)),
                                  color: Colors.grey[200],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 4)),
                                  child: Image.network(
                                    parent.image,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Icon(
                                      Icons.category,
                                      color: Colors.grey[400],
                                      size: ResponsiveUI.iconSize(context, 16),
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                parent.name,
                                style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 14)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    onChanged: _isLoading ? null : (val) => setState(() => _selectedParentId = val),
                  ),
                ),
                SizedBox(height: ResponsiveUI.spacing(context, 12)),
                Text(
                  'Category Image',
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
                        if (_selectedImage != null || widget.category.image.isNotEmpty)
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
                _selectedImage == null && widget.category.image.isEmpty
                    ? Text(
                  'Tap to select an image',
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 12),
                    color: Colors.orange[700],
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                )
                    : _selectedImage != null
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: ResponsiveUI.iconSize(context, 16),
                    ),
                    SizedBox(width: ResponsiveUI.spacing(context, 4)),
                    Text(
                      'New image selected',
                      style: TextStyle(
                        fontSize: ResponsiveUI.fontSize(context, 12),
                        color: Colors.green[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                )
                    : const SizedBox.shrink(),
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
                    'Update Category',
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