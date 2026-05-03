import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:GoSystem/core/widgets/app_bar_widgets.dart';
import 'package:GoSystem/core/widgets/custom_snack_bar/custom_snackbar.dart';
import 'package:GoSystem/core/widgets/custom_textfield/custom_text_field_widget.dart';
import 'package:GoSystem/features/admin/popup/cubit/popup_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';

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
          prefixIconColor: AppColors.darkGray.withValues(alpha: 0.7),
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
                          color: AppColors.darkGray.withValues(alpha: 0.7),
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
    // Images are now optional - removed validation
    
    context.read<PopupCubit>().addPopup(
          titleEn: _titleEnController.text.trim(),
          titleAr: _titleArController.text.trim(),
          descriptionEn: _descriptionEnController.text.trim(),
          descriptionAr: _descriptionArController.text.trim(),
          link: _linkController.text.trim(),
          image: _selectedEnImage,
          // imageAr: _selectedArImage,
        );
  }

  @override
  Widget build(BuildContext context) {
    // Scale down for web
    Widget screenContent = BlocConsumer<PopupCubit, PopupState>(
      listener: (context, state) {
        if (state is CreatePopupSuccess) {
          Navigator.pop(context, true);
        } else if (state is CreatePopupError) {
          CustomSnackbar.showError(context, state.error);
        }
      },
      builder: (context, state) {
        final isLoading = state is CreatePopupLoading;
        return Scaffold(
          backgroundColor: const Color.fromARGB(255, 243, 249, 254),
          appBar: appBarWithActions(context, title: LocaleKeys.new_popup.tr()),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: ResponsiveUI.padding(context, 16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(
                    controller: _titleEnController,
                    title: LocaleKeys.popup_title_en.tr(),
                    hint: LocaleKeys.enter_popup_title_en.tr(),
                  ),
                  SizedBox(height: ResponsiveUI.spacing(context, 32)),
                  SizedBox(
                    width: double.infinity,
                    height: ResponsiveUI.value(context, 48),
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _validateAndSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
                        ),
                      ),
                      child: isLoading
                          ? SizedBox(
                              height: ResponsiveUI.iconSize(context, 20),
                              width: ResponsiveUI.iconSize(context, 20),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                              ),
                            )
                          : Text(
                              LocaleKeys.save_popup.tr(),
                              style: TextStyle(
                                fontSize: ResponsiveUI.fontSize(context, 16),
                                fontWeight: FontWeight.w600,
                                color: AppColors.white,
                              ),
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
    _titleEnController.dispose();
    _titleArController.dispose();
    _descriptionEnController.dispose();
    _descriptionArController.dispose();
    _linkController.dispose();
    super.dispose();
  }
}
