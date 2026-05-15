import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:GoSystem/core/widgets/custom_textfield/custom_text_field_widget.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';
import '../../../../core/widgets/custom_loading/custom_loading_state.dart';
import '../../../../core/widgets/custom_snack_bar/custom_snackbar.dart';
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

  bool _isLoading =
      true; // Start with loading true to show loading state immediately
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

  void _submitUpdate() {
    if (_nameController.text.trim().isEmpty) {
      CustomSnackbar.showWarning(context, LocaleKeys.please_enter_brand_name.tr());
      return;
    }
    BrandsCubit.get(context).updateBrand(
      brandId: widget.brandId,
      name: _nameController.text.trim(),
      logoFile: null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = ResponsiveUI.contentMaxWidth(context);
    final isDesktop = maxWidth > 600;
    // Scale down for web
    return BlocConsumer<BrandsCubit, BrandsState>(
      listener: (context, state) {
        if (state is GetBrandByIdSuccess) {
          setState(() {
            _brand = state.brand;
            _nameController.text = _brand?.name ?? '';
            _isLoading = false;
          });
        } else if (state is GetBrandByIdError) {
          setState(() => _isLoading = false);
          CustomSnackbar.showError(context, state.error);
          Navigator.pop(context);
        } else if (state is UpdateBrandLoading) {
          setState(() => _isLoading = true);
        } else if (state is UpdateBrandSuccess) {
          setState(() => _isLoading = false);
          CustomSnackbar.showSuccess(context, state.message);
          Navigator.pop(context, true);
        } else if (state is UpdateBrandError) {
          setState(() => _isLoading = false);
          CustomSnackbar.showError(context, state.error);
        }
      },
      builder: (context, state) {
        Widget screenContent = Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          margin: EdgeInsets.symmetric(
            horizontal: isDesktop ? ResponsiveUI.padding(context, 20) : 0,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(ResponsiveUI.borderRadius(context, 24)),
            ),
          ),
          child: SafeArea(
            child:
                _isLoading ||
                    _brand ==
                        null // Show loading if _isLoading or _brand is null
                ? Container(
                    height: ResponsiveUI.value(context, 300),
                    padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
                    child: Center(child: CustomLoadingState(size: ResponsiveUI.iconSize(context, 60))),
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
                        LocaleKeys.edit_brand.tr(),
                        style: TextStyle(
                          fontSize: ResponsiveUI.fontSize(context, 20),
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: ResponsiveUI.spacing(context, 16)),
                      CustomTextField(
                        controller: _nameController,
                        labelText: LocaleKeys.brand_name.tr(),
                        hintText: LocaleKeys.enter_brand_name.tr(),
                        prefixIcon: Icons.branding_watermark,
                        hasBoxDecoration: false,
                        hasBorder: true,
                        prefixIconColor: AppColors.darkGray.withValues(alpha: 0.7),
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
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                LocaleKeys.update_brand.tr(),
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
      },
    );
  }
}

