import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:GoSystem/core/widgets/app_bar_widgets.dart';
import 'package:GoSystem/core/widgets/custom_button_widget.dart';
import 'package:GoSystem/core/widgets/custom_loading/custom_loading_state.dart';
import 'package:GoSystem/core/widgets/custom_textfield/custom_text_field_widget.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';
import '../cubit/categories_cubit.dart';
import '../cubit/categories_states.dart';
import '../model/get_categories_model.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _nameController = TextEditingController();
  final _arNameController = TextEditingController();
  File? _selectedImage;
  CategoryItem? _selectedParentCategory;
  bool _makeParentCategory = true;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  @override
  void initState() {
    super.initState();
    CategoriesCubit.get(context).getCategories();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CategoriesCubit, CategoriesState>(
      listener: (context, state) {
        if (state is CreateCategorySuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 14)),
              ),
              backgroundColor: AppColors.successGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  ResponsiveUI.borderRadius(context, 8),
                ),
              ),
              margin: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
            ),
          );
          Navigator.pop(context, true);
        } else if (state is CreateCategoryError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.error,
                style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 14)),
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  ResponsiveUI.borderRadius(context, 8),
                ),
              ),
              margin: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = CategoriesCubit.get(context);

        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: appBarWithActions(context, title: LocaleKeys.new_category.tr()),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUI.horizontalPadding(context),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: ResponsiveUI.spacing(context, 8)),

                  CustomTextField(
                    controller: _nameController,
                    labelText: LocaleKeys.enter_category_name_en.tr(),
                    hasBoxDecoration: false,
                    hasBorder: true,
                    prefixIcon: Icons.category,
                  ),
                  SizedBox(height: ResponsiveUI.spacing(context, 16)),
                  CustomTextField(
                    controller: _arNameController,
                    labelText: LocaleKeys.enter_category_name_ar.tr(),
                    hasBoxDecoration: false,
                    hasBorder: true,
                    prefixIcon: Icons.category,
                  ),
                  SizedBox(height: ResponsiveUI.spacing(context, 16)),
                  CheckboxListTile(
                    value: _makeParentCategory,
                    onChanged: (value) {
                      setState(() {
                        _makeParentCategory = value ?? true;
                        if (_makeParentCategory) _selectedParentCategory = null;
                      });
                    },
                    title: Text(
                      LocaleKeys.set_as_parent_category.tr(),
                      style: TextStyle(
                        fontSize: ResponsiveUI.fontSize(context, 14),
                      ),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.primaryBlue,
                  ),
                  if (!_makeParentCategory) ...[
                    SizedBox(height: ResponsiveUI.spacing(context, 16)),
                    Text(
                      LocaleKeys.parent_category.tr(),
                      style: TextStyle(
                        fontSize: ResponsiveUI.fontSize(context, 14),
                        color: AppColors.darkGray,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: ResponsiveUI.spacing(context, 8)),
                    if (state is GetCategoriesLoading)
                      Padding(
                        padding: EdgeInsets.all(
                          ResponsiveUI.padding(context, 20),
                        ),
                        child: CustomLoadingState(
                          message: LocaleKeys.loading_parent_categories.tr(),
                          color: AppColors.primaryBlue,
                          size: ResponsiveUI.iconSize(context, 60),
                        ),
                      )
                    else if (cubit.parentCategories.isEmpty)
                      Container(
                        padding: EdgeInsets.all(
                          ResponsiveUI.padding(context, 16),
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warningOrange,
                          borderRadius: BorderRadius.circular(
                            ResponsiveUI.borderRadius(context, 12),
                          ),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppColors.warningOrange,
                              size: ResponsiveUI.iconSize(context, 20),
                            ),
                            SizedBox(width: ResponsiveUI.spacing(context, 8)),
                            Expanded(
                              child: Text(
                                LocaleKeys.no_parent_categories.tr(),
                                style: TextStyle(
                                  fontSize: ResponsiveUI.fontSize(context, 12),
                                  color: Colors.orange[900],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          border: Border.all(
                            color: AppColors.lightGray,
                            width: ResponsiveUI.value(context, 1.5),
                          ),
                          borderRadius: BorderRadius.circular(
                            ResponsiveUI.borderRadius(context, 12),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: ResponsiveUI.borderRadius(context, 6),
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: DropdownSearch<CategoryItem>(
                          popupProps: PopupProps.menu(
                            showSearchBox: true,
                            searchFieldProps: TextFieldProps(
                              decoration: InputDecoration(
                                hintText: LocaleKeys.search_categories.tr(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: ResponsiveUI.padding(context, 12),
                                  vertical: ResponsiveUI.padding(context, 8),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    ResponsiveUI.borderRadius(context, 8),
                                  ),
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: AppColors.darkGray,
                                ),
                              ),
                            ),
                            fit: FlexFit.loose,
                            constraints: BoxConstraints(
                              maxHeight: ResponsiveUI.imageHeight(context),
                            ),
                            itemBuilder: (context, item, isSelected) =>
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: ResponsiveUI.padding(
                                      context,
                                      12,
                                    ),
                                    vertical: ResponsiveUI.padding(context, 8),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: ResponsiveUI.iconSize(
                                          context,
                                          50,
                                        ),
                                        height: ResponsiveUI.iconSize(
                                          context,
                                          30,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            ResponsiveUI.borderRadius(
                                              context,
                                              6,
                                            ),
                                          ),
                                          color: Colors.grey[200],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            ResponsiveUI.borderRadius(
                                              context,
                                              6,
                                            ),
                                          ),
                                          child: Image.network(
                                            item.image,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Icon(
                                              Icons.category,
                                              size: ResponsiveUI.iconSize(
                                                context,
                                                16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: ResponsiveUI.spacing(context, 8),
                                      ),
                                      Expanded(
                                        child: Text(
                                          item.name,
                                          style: TextStyle(
                                            fontSize: ResponsiveUI.fontSize(
                                              context,
                                              14,
                                            ),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                          ),
                          items: cubit.parentCategories,
                          itemAsString: (CategoryItem item) => item.name,
                          dropdownDecoratorProps: DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: ResponsiveUI.padding(context, 12),
                                vertical: ResponsiveUI.padding(context, 10),
                              ),
                              border: InputBorder.none,
                              suffixIcon: Icon(
                                Icons.arrow_drop_down,
                                color: AppColors.darkGray,
                              ),
                            ),
                          ),
                          selectedItem: _selectedParentCategory,
                          onChanged: (CategoryItem? value) =>
                              setState(() => _selectedParentCategory = value),
                          dropdownBuilder: (context, CategoryItem? item) =>
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: ResponsiveUI.padding(context, 12),
                                  vertical: ResponsiveUI.padding(context, 4),
                                ),
                                child: item == null
                                    ? Text(
                                        LocaleKeys.select_parent_category.tr(),
                                        style: TextStyle(
                                          color: AppColors.darkGray,
                                          fontSize: ResponsiveUI.fontSize(
                                            context,
                                            14,
                                          ),
                                        ),
                                      )
                                    : Row(
                                        children: [
                                          Container(
                                            width: ResponsiveUI.iconSize(
                                              context,
                                              50,
                                            ),
                                            height: ResponsiveUI.iconSize(
                                              context,
                                              30,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    ResponsiveUI.borderRadius(
                                                      context,
                                                      6,
                                                    ),
                                                  ),
                                              color: Colors.grey[200],
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    ResponsiveUI.borderRadius(
                                                      context,
                                                      6,
                                                    ),
                                                  ),
                                              child: Image.network(
                                                item.image,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    Icon(
                                                      Icons.category,
                                                      size:
                                                          ResponsiveUI.iconSize(
                                                            context,
                                                            16,
                                                          ),
                                                    ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: ResponsiveUI.spacing(
                                              context,
                                              8,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              item.name,
                                              style: TextStyle(
                                                fontSize: ResponsiveUI.fontSize(
                                                  context,
                                                  14,
                                                ),
                                                fontWeight: FontWeight.w500,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                        ),
                      ),
                  ],
                  SizedBox(height: ResponsiveUI.spacing(context, 24)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        LocaleKeys.category_image.tr(),
                        style: TextStyle(
                          fontSize: ResponsiveUI.fontSize(context, 14),
                          color: AppColors.darkGray,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (_selectedImage != null)
                        TextButton.icon(
                          icon: Icon(
                            Icons.delete,
                            color: AppColors.red,
                            size: ResponsiveUI.iconSize(context, 18),
                          ),
                          label: Text(
                            LocaleKeys.remove.tr(),
                            style: TextStyle(
                              color: AppColors.red,
                              fontSize: ResponsiveUI.fontSize(context, 12),
                            ),
                          ),
                          onPressed: () =>
                              setState(() => _selectedImage = null),
                        ),
                    ],
                  ),
                  SizedBox(height: ResponsiveUI.spacing(context, 10)),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: ResponsiveUI.value(context, 140),
                      height: ResponsiveUI.value(context, 140),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(
                          ResponsiveUI.borderRadius(context, 12),
                        ),
                        border: Border.all(
                          color: AppColors.lightGray,
                          width: ResponsiveUI.value(context, 2),
                        ),
                      ),
                      child: _selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(
                                ResponsiveUI.borderRadius(context, 12),
                              ),
                              child: Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                                key: ValueKey(_selectedImage!.path),
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate_outlined,
                                  size: ResponsiveUI.iconSize(context, 45),
                                  color: AppColors.primaryBlue,
                                ),
                                SizedBox(
                                  height: ResponsiveUI.spacing(context, 8),
                                ),
                                Text(
                                  LocaleKeys.tap_to_upload.tr(),
                                  style: TextStyle(
                                    color: AppColors.darkGray,
                                    fontSize: ResponsiveUI.fontSize(
                                      context,
                                      13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  SizedBox(height: ResponsiveUI.spacing(context, 30)),
                  SizedBox(
                    width: double.infinity,
                    height: ResponsiveUI.value(context, 56),
                    child: CustomElevatedButton(
                      onPressed: state is CreateCategoryLoading
                          ? null
                          : () {
                              if (_nameController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      LocaleKeys.please_enter_category_name.tr(),
                                      style: TextStyle(
                                        fontSize: ResponsiveUI.fontSize(
                                          context,
                                          14,
                                        ),
                                      ),
                                    ),
                                    backgroundColor: AppColors.red,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        ResponsiveUI.borderRadius(context, 8),
                                      ),
                                    ),
                                    margin: EdgeInsets.all(
                                      ResponsiveUI.padding(context, 12),
                                    ),
                                  ),
                                );
                                return;
                              }
                              // Image is now optional - removed validation
                              
                              if (!_makeParentCategory &&
                                  _selectedParentCategory == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      LocaleKeys.please_select_parent_category.tr(),
                                      style: TextStyle(
                                        fontSize: ResponsiveUI.fontSize(
                                          context,
                                          14,
                                        ),
                                      ),
                                    ),
                                    backgroundColor: AppColors.red,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        ResponsiveUI.borderRadius(context, 8),
                                      ),
                                    ),
                                    margin: EdgeInsets.all(
                                      ResponsiveUI.padding(context, 12),
                                    ),
                                  ),
                                );
                                return;
                              }
                              cubit.createCategory(
                                name: _nameController.text.trim(),
                                arName: _arNameController.text.trim(),
                                imageFile: _selectedImage, // Made optional
                                parentId: _makeParentCategory
                                    ? null
                                    : _selectedParentCategory?.id,
                              );
                            },
                      // style: ElevatedButton.styleFrom(
                      //   backgroundColor: AppColors.primaryBlue,
                      //   shape: RoundedRectangleBorder(
                      //     borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
                      //   ),
                      //   elevation: ResponsiveUI.value(context, 2),
                      // ),
                      text: state is CreateCategoryLoading
                          ? LocaleKeys.saving_category.tr()
                          : LocaleKeys.save_category.tr(),
                    ),
                    // child: state is CreateCategoryLoading
                    //     ? SizedBox(
                    //   height: ResponsiveUI.iconSize(context, 24),
                    //   width: ResponsiveUI.iconSize(context, 24),
                    //   child: CircularProgressIndicator(
                    //     color: AppColors.white,
                    //     strokeWidth: 2.5,
                    //   ),
                    // )
                    //     : Text(
                    //   'Save Category',
                    //   style: TextStyle(
                    //     fontSize: ResponsiveUI.fontSize(context, 16),
                    //     fontWeight: FontWeight.w600,
                    //     color: AppColors.white,
                    //   ),
                    // ),
                    // ),
                  ),

                  SizedBox(height: ResponsiveUI.spacing(context, 20)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}

