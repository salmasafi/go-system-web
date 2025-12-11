import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/custom_button_widget.dart';
import 'package:systego/core/widgets/custom_snack_bar/custom_snackbar.dart';
import 'package:systego/core/widgets/custom_textfield/custom_text_field_widget.dart';
import 'package:systego/features/admin/popup/cubit/popup_cubit.dart';
import 'package:systego/features/admin/popup/model/popup_model.dart';
import 'package:systego/features/admin/categories/view/widgets/build_image_placeholder_widget.dart';
import 'package:systego/generated/locale_keys.g.dart';

class EditPopupBottomSheet extends StatefulWidget {
  final PopupModel popup;

  const EditPopupBottomSheet({super.key, required this.popup});

  @override
  State<EditPopupBottomSheet> createState() => _EditPopupBottomSheetState();
}

class _EditPopupBottomSheetState extends State<EditPopupBottomSheet> {
  late final TextEditingController _titleEnController;
  late final TextEditingController _descriptionEnController;
  File? _selectedEnImage;

  late final TextEditingController _titleArController;
  late final TextEditingController _descriptionArController;
  File? _selectedArImage;

  late final TextEditingController _linkController;

  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titleEnController = TextEditingController(text: widget.popup.titleEn);
    _titleArController = TextEditingController(text: widget.popup.titleAr);
    _descriptionEnController = TextEditingController(
      text: widget.popup.descriptionEn,
    );
    _descriptionArController = TextEditingController(
      text: widget.popup.descriptionAr,
    );
    _linkController = TextEditingController(text: widget.popup.link);

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


  Future<void> _pickImage(bool isEnglishImage) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null && mounted) {
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
        // widget.popup.imageEn = ''; // Clear network URL to show placeholder
      } else {
        _selectedArImage = null;
        // widget.popup.imageAr = ''; // Clear network URL to show placeholder
      }
    });
  }


  void _submitUpdate() {
    if (_titleEnController.text.trim().isEmpty) {
      CustomSnackbar.showWarning(
        context,
        LocaleKeys.warning_title_en.tr(),
      );
      return;
    }
    if (_titleArController.text.trim().isEmpty) {
      CustomSnackbar.showWarning(context, LocaleKeys.warning_title_ar.tr());
      return;
    }

    context.read<PopupCubit>().updatePopup(
      popupId: widget.popup.id,
      titleEn: _titleEnController.text.trim(),
      titleAr: _titleArController.text.trim(),
      descriptionEn: _descriptionEnController.text.trim(),
      descriptionAr: _descriptionArController.text.trim(),
      link: _linkController.text.trim(),
      imageEn: _selectedEnImage,
      imageAr: _selectedArImage,
    );
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
    required File? selectedLocalImage,
    required String existingImageUrl,
    required String title,
    required void Function() onPick,
    required void Function() onRemove,
  }) {
    final width = ResponsiveUI.screenWidth(context);
    final displayImage = selectedLocalImage != null
        ? Image.file(selectedLocalImage, fit: BoxFit.cover)
        : (existingImageUrl.isNotEmpty
              ? Image.network(
                  existingImageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const CustomImagePlaceholder(),
                )
              : const CustomImagePlaceholder());

    final isImagePresent =
        selectedLocalImage != null || existingImageUrl.isNotEmpty;

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
            if (selectedLocalImage != null)
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
              border: Border.all(color: AppColors.lightGray, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                ResponsiveUI.borderRadius(context, 12),
              ),
              child: isImagePresent
                  ? Stack(
                      children: [
                        displayImage,
                        Positioned.fill(
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(
                                selectedLocalImage != null ? 0.3 : 0.0,
                              ),
                            ),
                            child: Icon(
                              selectedLocalImage != null
                                  ? Icons.check_circle
                                  : Icons.edit,
                              color: selectedLocalImage != null
                                  ? Colors.white
                                  : Colors.black54,
                              size: ResponsiveUI.iconSize(context, 30),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: ResponsiveUI.iconSize(context, 45),
                          color: AppColors.primaryBlue,
                        ),
                        SizedBox(height: ResponsiveUI.spacing(context, 8)),
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
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    final maxWidth = ResponsiveUI.contentMaxWidth(context);
    final isDesktop = maxWidth > 600;

    return BlocConsumer<PopupCubit, PopupState>(
      listener: (context, state) {
        if (state is UpdatePopupSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          Navigator.pop(context, true);
        } else if (state is UpdatePopupError) {
          CustomSnackbar.showError(context, state.error);
        }
      },
      builder: (context, state) {
        final isLoading = state is UpdatePopupLoading;

        return Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          margin: EdgeInsets.symmetric(
            horizontal: isDesktop ? ResponsiveUI.padding(context, 20) : 0,
          ),
          decoration: BoxDecoration(
            color: const Color.fromARGB(
              255,
              243,
              249,
              254,
            ),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(ResponsiveUI.borderRadius(context, 24)),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(ResponsiveUI.borderRadius(context, 24)),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
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
                      LocaleKeys.edit_popup.tr(),
                      style: TextStyle(
                        fontSize: ResponsiveUI.fontSize(context, 20),
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),

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
                      selectedLocalImage: _selectedEnImage,
                      existingImageUrl: widget.popup.imageEn,
                      title: LocaleKeys.popup_english_image.tr(),
                      onPick: () => _pickImage(true),
                      onRemove: () => _removeImage(true),
                    ),

                    _buildImagePicker(
                      selectedLocalImage: _selectedArImage,
                      existingImageUrl: widget.popup.imageAr,
                      title: LocaleKeys.popup_arabic_image.tr(),
                      onPick: () => _pickImage(false),
                      onRemove: () => _removeImage(false),
                    ),

                    SizedBox(height: ResponsiveUI.spacing(context, 24)),
                    SizedBox(
                      width: double.infinity,
                      height: ResponsiveUI.value(context, 48),
                      child: CustomElevatedButton(
                        onPressed: isLoading ? null : _submitUpdate,
                        text: isLoading ? LocaleKeys.updating_popup.tr() : LocaleKeys.update_popup.tr(),
                        isLoading: isLoading
                      ),
                    ),
                    SizedBox(height: ResponsiveUI.spacing(context, 16)),
                    
                  ],
                  
                ),
                
              ),
            ),
          ),
        );
      },
    );
  }
}