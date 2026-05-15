import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:GoSystem/core/widgets/custom_textfield/custom_text_field_widget.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';
import '../../../../core/widgets/custom_loading/custom_loading_state.dart';
import '../../../../core/widgets/custom_snack_bar/custom_snackbar.dart';
import '../cubit/categories_cubit.dart';
import '../cubit/categories_states.dart';
import '../model/get_categories_model.dart';

class EditCategoryBottomSheet extends StatefulWidget {
  final CategoryItem category;

  const EditCategoryBottomSheet({super.key, required this.category});

  @override
  State<EditCategoryBottomSheet> createState() =>
      _EditCategoryBottomSheetState();
}

class _EditCategoryBottomSheetState extends State<EditCategoryBottomSheet> {
  late TextEditingController _nameController;
  String? _selectedParentId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category.name);
    _selectedParentId = widget.category.parentId?.id;
    CategoriesCubit.get(
      context,
    ).getCategories(); // Ensure parentCategories is populated
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submitUpdate() {
    if (_nameController.text.trim().isEmpty) {
      CustomSnackbar.showWarning(context, LocaleKeys.please_enter_category_name_en_ar.tr());
      return;
    }

    if (_selectedParentId != null) {
      CategoriesCubit.get(context).updateCategory(
        categoryId: widget.category.id,
        name: _nameController.text.trim(),
        imageFile: null,
        parentId: _selectedParentId,
      );
    } else {
      CategoriesCubit.get(context).updateCategory(
        categoryId: widget.category.id,
        name: _nameController.text.trim(),
        imageFile: null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = CategoriesCubit.get(context);
    final maxWidth = ResponsiveUI.contentMaxWidth(context);
    final isDesktop = maxWidth > 600;
    // Scale down for web
    return BlocConsumer<CategoriesCubit, CategoriesState>(
      listener: (context, state) {
        if (state is GetCategoriesSuccess ||
            state is GetCategoriesError) {
          setState(() => _isLoading = false);
        } else if (state is UpdateCategorySuccess) {
          setState(() => _isLoading = false);
          CustomSnackbar.showSuccess(context, state.message);
          Navigator.pop(context, true);
        } else if (state is UpdateCategoryError) {
          setState(() => _isLoading = false);
          CustomSnackbar.showError(context, state.error);
        }
      },
      builder: (context, state) {
        return Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        margin: EdgeInsets.symmetric(
          horizontal: isDesktop ? ResponsiveUI.padding(context, 20) : 0,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(ResponsiveUI.borderRadius(context, 24)),
          ),
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
                            color: AppColors.shadowGray[300],
                            borderRadius: BorderRadius.all(
                              Radius.circular(
                                ResponsiveUI.borderRadius(context, 2),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: ResponsiveUI.spacing(context, 12)),
                      Text(
                       LocaleKeys.edit_category.tr(),
                        style: TextStyle(
                          fontSize: ResponsiveUI.fontSize(context, 20),
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: ResponsiveUI.spacing(context, 25)),
                      CustomTextField(
                        controller: _nameController,
                        labelText: LocaleKeys.category_name_en.tr(),
                        hintText: LocaleKeys.enter_category_name_en.tr(),
                        prefixIcon: Icons.category,
                        hasBoxDecoration: false,
                        hasBorder: true,
                        prefixIconColor: AppColors.darkGray.withValues(alpha: 0.7),
                      ),
                      SizedBox(height: ResponsiveUI.spacing(context, 25)),

                      SizedBox(
                        height: ResponsiveUI.value(context, 60),
                        child: DropdownButtonFormField<String>(
                          value: _selectedParentId,
                          decoration: InputDecoration(
                            labelText: LocaleKeys.parent_category_optional.tr(),
                            prefixIcon: Icon(
                              Icons.folder,
                              color: AppColors.darkGray,
                              size: ResponsiveUI.iconSize(context, 24),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                ResponsiveUI.borderRadius(context, 8),
                              ),
                              borderSide: BorderSide(
                                color: AppColors.shadowGray[300]!,
                                width: ResponsiveUI.value(context, 1),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                ResponsiveUI.borderRadius(context, 8),
                              ),
                              borderSide: BorderSide(
                                color: AppColors.primaryBlue,
                                width: ResponsiveUI.value(context, 2),
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: ResponsiveUI.padding(context, 12),
                              vertical: ResponsiveUI.padding(context, 8),
                            ),
                          ),
                          dropdownColor: AppColors.white,
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
                                LocaleKeys.note.tr(),
                                style: TextStyle(
                                  fontSize: ResponsiveUI.fontSize(context, 14),
                                ),
                              ),
                            ),
                            ...cubit.parentCategories
                                .where(
                                  (parent) => parent.id != widget.category.id,
                                ) // Exclude current category
                                .map(
                                  (parent) => DropdownMenuItem(
                                    value: parent.id,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: ResponsiveUI.value(
                                            context,
                                            24,
                                          ),
                                          height: ResponsiveUI.value(
                                            context,
                                            24,
                                          ),
                                          margin: EdgeInsets.only(
                                            right: ResponsiveUI.spacing(
                                              context,
                                              8,
                                            ),
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              ResponsiveUI.borderRadius(
                                                context,
                                                4,
                                              ),
                                            ),
                                            color: AppColors.shadowGray[200],
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              ResponsiveUI.borderRadius(
                                                context,
                                                4,
                                              ),
                                            ),
                                            child: Image.network(
                                              parent.image,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  Icon(
                                                    Icons.category,
                                                    color: AppColors
                                                        .shadowGray[400],
                                                    size: ResponsiveUI.iconSize(
                                                      context,
                                                      16,
                                                    ),
                                                  ),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          parent.name,
                                          style: TextStyle(
                                            fontSize: ResponsiveUI.fontSize(
                                              context,
                                              14,
                                            ),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                          ],
                          onChanged: _isLoading
                              ? null
                              : (val) =>
                                    setState(() => _selectedParentId = val),
                        ),
                      ),
                      SizedBox(height: ResponsiveUI.spacing(context, 16)),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _submitUpdate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          padding: EdgeInsets.symmetric(
                            vertical: ResponsiveUI.padding(context, 14),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              ResponsiveUI.borderRadius(context, 12),
                            ),
                          ),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                height: ResponsiveUI.iconSize(context, 20),
                                width: ResponsiveUI.iconSize(context, 20),
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.white,
                                  ),
                                ),
                              )
                            : Text(
                                LocaleKeys.update_category.tr(),
                                style: TextStyle(
                                  fontSize: ResponsiveUI.fontSize(context, 16),
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.white,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
          );
        },
      );
  }
}
