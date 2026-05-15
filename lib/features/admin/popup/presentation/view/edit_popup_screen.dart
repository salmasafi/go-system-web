import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:GoSystem/core/widgets/app_bar_widgets.dart';
import 'package:GoSystem/core/widgets/custom_button_widget.dart';
import 'package:GoSystem/core/widgets/custom_snack_bar/custom_snackbar.dart';
import 'package:GoSystem/core/widgets/custom_textfield/custom_text_field_widget.dart';
import 'package:GoSystem/features/admin/popup/cubit/popup_cubit.dart';
import 'package:GoSystem/features/admin/popup/model/popup_model.dart';
import 'package:GoSystem/features/admin/categories/view/widgets/build_image_placeholder_widget.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';

class EditPopupBottomSheet extends StatefulWidget {
  final PopupModel popup;

  const EditPopupBottomSheet({super.key, required this.popup});

  @override
  State<EditPopupBottomSheet> createState() => _EditPopupBottomSheetState();
}

class _EditPopupBottomSheetState extends State<EditPopupBottomSheet> {
  late final TextEditingController _titleEnController;
  late final TextEditingController _descriptionEnController;
  late final TextEditingController _titleArController;
  late final TextEditingController _descriptionArController;
  late final TextEditingController _linkController;

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
      image: null,
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
          prefixIconColor: AppColors.darkGray.withValues(alpha: 0.7),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = ResponsiveUI.contentMaxWidth(context);
    final isDesktop = maxWidth > 600;
    // Scale down for web
    Widget screenContent = BlocConsumer<PopupCubit, PopupState>(
      listener: (context, state) {
        if (state is UpdatePopupSuccess) {
          Navigator.pop(context, true);
        } else if (state is UpdatePopupError) {
          CustomSnackbar.showError(context, state.error);
        }
      },
      builder: (context, state) {
        final isLoading = state is UpdatePopupLoading;
        return Scaffold(
          backgroundColor: const Color.fromARGB(255, 243, 249, 254),
          appBar: appBarWithActions(context, title: LocaleKeys.edit_popup.tr()),
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
                      onPressed: isLoading ? null : _submitUpdate,
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
                              LocaleKeys.update_popup.tr(),
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
}
