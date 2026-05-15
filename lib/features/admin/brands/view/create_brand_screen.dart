import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
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

  @override
  Widget build(BuildContext context) {
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
                if (_nameController.text.trim().isEmpty) {
                  return;
                }
                BrandsCubit.get(context).createBrand(
                  name: _nameController.text.trim(),
                  logoFile: null,
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
                  CustomTextField(
                    controller: _nameController,
                    labelText: LocaleKeys.brand_name.tr(),
                    hintText: LocaleKeys.enter_brand_name.tr(),
                    hasBoxDecoration: false,
                    hasBorder: true,
                    prefixIcon: Icons.branding_watermark,
                    prefixIconColor: AppColors.darkGray.withValues(alpha: 0.7),
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
                              }
                              BrandsCubit.get(context).createBrand(
                                name: _nameController.text.trim(),
                                logoFile: null,
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
    super.dispose();
  }
}

