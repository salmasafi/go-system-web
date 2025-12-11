import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/app_bar_widgets.dart';
import 'package:systego/core/widgets/custom_button_widget.dart';
import 'package:systego/core/widgets/custom_error/custom_error_state.dart';
import 'package:systego/core/widgets/custom_snack_bar/custom_snackbar.dart';
import 'package:systego/core/widgets/custom_textfield/custom_text_field_widget.dart';
import 'package:systego/features/admin/popup/cubit/popup_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:systego/generated/locale_keys.g.dart';

class CreatePopupScreen extends StatefulWidget {
  const CreatePopupScreen({super.key});

  @override
  State<CreatePopupScreen> createState() => _CreatePopupScreenState();
}

class _CreatePopupScreenState extends State<CreatePopupScreen> {
  final _titleEnController = TextEditingController();
  final _titleArController = TextEditingController();
  final _descriptionEnController = TextEditingController();
  final _descriptionArController = TextEditingController();
  final _linkController = TextEditingController();

  File? _selectedEnImage;
  File? _selectedArImage;

  final _picker = ImagePicker();

  Future<void> _pickImage(bool isEnglishImage) async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        final pickedFileAsFile = File(pickedFile.path);
        if (isEnglishImage) {
          _selectedEnImage = pickedFileAsFile;
        } else {
          _selectedArImage = pickedFileAsFile;
        }
      });
    }
  }

  void _removeImage(bool isEnglishImage) {
    setState(() {
      if (isEnglishImage) {
        _selectedEnImage = null;
      } else {
        _selectedArImage = null;
      }
    });
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String title,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: ResponsiveUI.spacing(context, 16)),
        Text(
          title,
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 14),
            color: AppColors.darkGray,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: ResponsiveUI.spacing(context, 8)),
        CustomTextField(
          controller: controller,
          labelText: '',
          hintText: hint,
          hasBoxDecoration: false,
          hasBorder: true,
          prefixIconColor: AppColors.darkGray.withOpacity(0.7),
        ),
      ],
    );
  }

  Widget _buildImagePicker({
    required File? selectedImage,
    required String title,
    required void Function() onPick,
    required void Function() onRemove,
  }) {
    final width = ResponsiveUI.screenWidth(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: ResponsiveUI.spacing(context, 16)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 14),
                color: AppColors.darkGray,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (selectedImage != null)
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
                onPressed: onRemove,
              ),
          ],
        ),
        SizedBox(height: ResponsiveUI.spacing(context, 8)),
        GestureDetector(
          onTap: onPick,
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
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: selectedImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(
                      ResponsiveUI.borderRadius(context, 12),
                    ),
                    child: Image.file(
                      selectedImage,
                      fit: BoxFit.cover,
                      key: ValueKey(selectedImage.path),
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
                          color: AppColors.darkGray.withOpacity(0.7),
                          fontSize: ResponsiveUI.fontSize(context, 13),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  void _validateAndSubmit() {
    if (_titleEnController.text.trim().isEmpty) {
      CustomSnackbar.showWarning(
          context, LocaleKeys.warning_enter_title_en.tr());
      return;
    }
    if (_titleArController.text.trim().isEmpty) {
      CustomSnackbar.showWarning(
          context, LocaleKeys.warning_enter_title_ar.tr());
      return;
    }
    if (_descriptionEnController.text.trim().isEmpty) {
      CustomSnackbar.showWarning(
          context, LocaleKeys.warning_enter_description_en.tr());
      return;
    }
    if (_descriptionArController.text.trim().isEmpty) {
      CustomSnackbar.showWarning(
          context, LocaleKeys.warning_enter_description_ar.tr());
      return;
    }
    if (_selectedEnImage == null) {
      CustomSnackbar.showWarning(
          context, LocaleKeys.warning_select_en_image.tr());
      return;
    }
    if (_selectedArImage == null) {
      CustomSnackbar.showWarning(
          context, LocaleKeys.warning_select_ar_image.tr());
      return;
    }

    context.read<PopupCubit>().addPopup(
          titleEn: _titleEnController.text.trim(),
          titleAr: _titleArController.text.trim(),
          descriptionEn: _descriptionEnController.text.trim(),
          descriptionAr: _descriptionArController.text.trim(),
          link: _linkController.text.trim(),
          imageEn: _selectedEnImage,
          imageAr: _selectedArImage,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PopupCubit, PopupState>(
      listener: (context, state) {
        if (state is CreatePopupSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          Navigator.pop(context, true);
        } else if (state is CreatePopupError) {
          CustomSnackbar.showError(context, state.error);
        }
      },
      builder: (context, state) {
        if (state is CreatePopupSuccess) {
          return Scaffold(
            backgroundColor: AppColors.lightBlueBackground,
            appBar:
                appBarWithActions(context, title: LocaleKeys.new_popup.tr()),
            body: CustomErrorState(
              message: state.message,
              onRetry: _validateAndSubmit,
            ),
          );
        }

        final isLoading = state is CreatePopupLoading;

        return Scaffold(
          backgroundColor: const Color.fromARGB(255, 243, 249, 254),
          appBar:
              appBarWithActions(context, title: LocaleKeys.new_popup.tr()),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUI.padding(context, 16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(
                    controller: _titleEnController,
                    title: LocaleKeys.popup_title_en.tr(),
                    hint: LocaleKeys.enter_popup_title_en.tr(),
                  ),
                  _buildTextField(
                    controller: _titleArController,
                    title: LocaleKeys.popup_title_ar.tr(),
                    hint: LocaleKeys.enter_popup_title_ar.tr(),
                  ),
                  _buildTextField(
                    controller: _descriptionEnController,
                    title: LocaleKeys.popup_description_en.tr(),
                    hint: LocaleKeys.enter_popup_description_en.tr(),
                  ),
                  _buildTextField(
                    controller: _descriptionArController,
                    title: LocaleKeys.popup_description_ar.tr(),
                    hint: LocaleKeys.enter_popup_description_ar.tr(),
                  ),
                  _buildTextField(
                    controller: _linkController,
                    title: LocaleKeys.popup_link.tr(),
                    hint: LocaleKeys.enter_popup_link.tr(),
                  ),

                  _buildImagePicker(
                    selectedImage: _selectedEnImage,
                    title: LocaleKeys.popup_english_image.tr(),
                    onPick: () => _pickImage(true),
                    onRemove: () => _removeImage(true),
                  ),

                  _buildImagePicker(
                    selectedImage: _selectedArImage,
                    title: LocaleKeys.popup_arabic_image.tr(),
                    onPick: () => _pickImage(false),
                    onRemove: () => _removeImage(false),
                  ),

                  SizedBox(height: ResponsiveUI.spacing(context, 24)),
                  SizedBox(
                    width: double.infinity,
                    height: ResponsiveUI.value(context, 48),
                    child: CustomElevatedButton(
                      onPressed: isLoading ? null : _validateAndSubmit,
                      text: isLoading
                          ? LocaleKeys.saving_popup.tr()
                          : LocaleKeys.save_popup.tr(),
                      isLoading: isLoading,
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
  }

  @override
  void dispose() {
    _titleEnController.dispose();
    _titleArController.dispose();
    _descriptionEnController.dispose();
    _descriptionArController.dispose();
    _linkController.dispose();
    super.dispose();
  }
}
