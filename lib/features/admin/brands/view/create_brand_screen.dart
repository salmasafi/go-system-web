import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:GoSystem/core/widgets/app_bar_widgets.dart';
import 'package:GoSystem/core/widgets/custom_button_widget.dart';
import 'package:GoSystem/core/widgets/custom_textfield/custom_text_field_widget.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';
import '../../../../core/widgets/custom_error/custom_error_state.dart';
import '../../../../core/widgets/custom_snack_bar/custom_snackbar.dart';
import '../cubit/brand_cubit.dart';
import '../cubit/brand_states.dart';

class AddBrandScreen extends StatefulWidget {
  const AddBrandScreen({super.key});

  @override
  State<AddBrandScreen> createState() => _AddBrandScreenState();
}

class _AddBrandScreenState extends State<AddBrandScreen> {
  final _nameController = TextEditingController();
  final _arNameController = TextEditingController();
  File? _selectedImage;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = ResponsiveUI.screenWidth(context);
    //final height = ResponsiveUI.screenHeight(context);
    // Scale down for web
    Widget screenContent = BlocConsumer<BrandsCubit, BrandsState>(
      listener: (context, state) {
        if (state is CreateBrandSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          Navigator.pop(context, true);
        } else if (state is CreateBrandError) {
          CustomSnackbar.showError(context, state.error);
        }
      },
      builder: (context, state) {
        if (state is CreateBrandError) {
          return Scaffold(
            appBar: appBarWithActions(
              context,
              title: LocaleKeys.new_brand.tr(),
            ),
            body: CustomErrorState(
              message: state.error,
              onRetry: () {
                if (_nameController.text.trim().isEmpty ||
                    _arNameController.text.trim().isEmpty ||
                    _selectedImage == null) {
                  return;
                }
                BrandsCubit.get(context).createBrand(
                  name: _nameController.text.trim(),
                  arName: _arNameController.text.trim(),
                  logoFile: _selectedImage!,
                );
              },
            ),
          );
        }

        return Scaffold(
          appBar: appBarWithActions(context, title: LocaleKeys.new_brand.tr()),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUI.padding(context, 16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: ResponsiveUI.spacing(context, 16)),
                  // Text(
                  //   LocaleKeys.brand_name.tr(),
                  //   style: TextStyle(
                  //     fontSize: ResponsiveUI.fontSize(context, 14),
                  //     color: AppColors.darkGray,
                  //     fontWeight: FontWeight.w500,
                  //   ),
                  // ),
                  //SizedBox(height: ResponsiveUI.spacing(context, 8)),
                  CustomTextField(
                    controller: _nameController,
                    labelText: LocaleKeys.brand_name.tr(),
                    hintText: LocaleKeys.enter_brand_name.tr(),
                    hasBoxDecoration: false,
                    hasBorder: true,
                    prefixIcon: Icons.branding_watermark,
                    prefixIconColor: AppColors.darkGray.withValues(alpha: 0.7),
                  ),
                  SizedBox(height: ResponsiveUI.spacing(context, 16)),
                  CustomTextField(
                    controller: _arNameController,
                    labelText: LocaleKeys.brand_ar_name.tr(),
                    hintText: LocaleKeys.enter_brand_ar_name.tr(),
                    hasBoxDecoration: false,
                    hasBorder: true,
                    prefixIcon: Icons.branding_watermark,
                    prefixIconColor: AppColors.darkGray.withValues(alpha: 0.7),
                  ),
                  SizedBox(height: ResponsiveUI.spacing(context, 16)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        LocaleKeys.brand_logo.tr(),
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
                  SizedBox(height: ResponsiveUI.spacing(context, 8)),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: width * 0.35,
                      height: width * 0.35,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(
                          ResponsiveUI.borderRadius(context, 12),
                        ),
                        border: Border.all(
                          color: AppColors.lightGray,
                          width: ResponsiveUI.value(context, 1),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
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
                                    color: AppColors.darkGray.withValues(alpha: 0.7),
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
                  SizedBox(height: ResponsiveUI.spacing(context, 24)),
                  SizedBox(
                    width: double.infinity,
                    height: ResponsiveUI.value(context, 48),
                    child: CustomElevatedButton(
                      onPressed: state is CreateBrandLoading
                          ? null
                          : () {
                              if (_nameController.text.trim().isEmpty) {
                                CustomSnackbar.showWarning(
                                  context,
                                  LocaleKeys.please_enter_brand_name.tr(),
                                );
                                return;
                              } else if (_arNameController.text
                                  .trim()
                                  .isEmpty) {
                                CustomSnackbar.showWarning(
                                  context,
                                  LocaleKeys.please_enter_brand_ar_name.tr(),
                                );
                                return;
                              }
                              // Logo is now optional - removed validation
                              BrandsCubit.get(context).createBrand(
                                name: _nameController.text.trim(),
                                arName: _arNameController.text.trim(),
                                logoFile: _selectedImage,
                              );
                            },
                      // style: ElevatedButton.styleFrom(
                      //   backgroundColor: AppColors.primaryBlue,
                      //   shape: RoundedRectangleBorder(
                      //     borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
                      //   ),
                      //   elevation: ResponsiveUI.value(context, 2),
                      // ),
                      text: state is CreateBrandLoading
                          ? LocaleKeys.saving_brand.tr()
                          : LocaleKeys.save_brand.tr(),
                      // child: state is CreateBrandLoading
                      //     ? SizedBox(
                      //   height: ResponsiveUI.iconSize(context, 24),
                      //   width: ResponsiveUI.iconSize(context, 24),
                      //   child: CircularProgressIndicator(
                      //     color: AppColors.white,
                      //     strokeWidth: 2.5,
                      //   ),
                      // )
                      //     : Text(
                      //   'Save Brand',
                      //   style: TextStyle(
                      //     fontSize: ResponsiveUI.fontSize(context, 16),
                      //     fontWeight: FontWeight.w600,
                      //     color: AppColors.white,
                      //   ),
                      // ),
                    ),
                  ),
                  SizedBox(height: ResponsiveUI.spacing(context, 16)),
                ],
              ),
            ),
          ),
        );
      },
    );
    if (kIsWeb) {
      screenContent = MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: const TextScaler.linear(0.55),
        ),
        child: screenContent,
      );
    }
    return screenContent;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _arNameController.dispose();
    super.dispose();
  }
}

