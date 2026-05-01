import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/features/admin/country/model/country_model.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/responsive_ui.dart';
import '../../../../../core/utils/validators.dart';
import '../../../../../core/widgets/custom_loading/build_overlay_loading.dart';
import '../../../../../core/widgets/custom_snack_bar/custom_snackbar.dart';
import '../../../../../core/widgets/custom_textfield/build_text_field.dart';
import '../../../../../core/widgets/custom_drop_down_menu.dart';
import '../../cubit/city_state.dart';
import '../../cubit/city_cubit.dart';
import '../../model/city_model.dart';

class CityFormDialog extends StatefulWidget {
  final CityModel? city;

  const CityFormDialog({super.key, this.city});

  @override
  State<CityFormDialog> createState() => _CityFormDialogState();
}

class _CityFormDialogState extends State<CityFormDialog>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _arNameController = TextEditingController();
  final _shipingCostController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  // Dropdown state
  CountryModel? selectedCountry;
  final countries = CityCubit.countries;

  bool get isEditMode => widget.city != null;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupAnimation();
  }

  void _initializeControllers() {
    if (isEditMode) {
      _nameController.text = widget.city!.name;
      _arNameController.text = widget.city!.arName;
      _shipingCostController.text = widget.city!.shipingCost.toString();
      // Start with null
      selectedCountry = null;
      // Set to city's country if available AND it exists in countries
      if (widget.city?.country != null && countries.isNotEmpty) {
        final matching = countries.where(
          (country) =>
              country.id ==
              widget.city!.country?.id, // Match by ID for uniqueness
        );
        if (matching.isNotEmpty) {
          selectedCountry = matching.first;
        }
      }

      // Fallback: If still null, find default from countries
      if (selectedCountry == null && countries.isNotEmpty) {
        final defaults = countries.where((country) => country.isDefault);
        if (defaults.isNotEmpty) {
          selectedCountry = null;
        }
      }
    } else {
      _shipingCostController.text = '';

      // Start with null
      selectedCountry = null;
      // Set to city's country if available AND it exists in countries
      if (widget.city?.country != null && countries.isNotEmpty) {
        final matching = countries.where(
          (country) =>
              country.id ==
              widget.city!.country?.id, // Match by ID for uniqueness
        );
        if (matching.isNotEmpty) {
          selectedCountry = matching.first;
        }
      }

      // Fallback: If still null, find default from countries
      if (selectedCountry == null && countries.isNotEmpty) {
        final defaults = countries.where((country) => country.isDefault);
        if (defaults.isNotEmpty) {
          selectedCountry = defaults.first;
        }
      }
    }
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _arNameController.dispose();
    _shipingCostController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = ResponsiveUI.isMobile(context)
        ? ResponsiveUI.screenWidth(context) * 0.95
        : ResponsiveUI.contentMaxWidth(context);
    final maxHeight = ResponsiveUI.screenHeight(context) * 0.85;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: BlocConsumer<CityCubit, CityState>(
          listener: _handleStateChanges,
          builder: (context, state) {
            final isLoading =
                state is CreateCityLoading || state is UpdateCityLoading;

            return Container(
              constraints: BoxConstraints(
                maxWidth: maxWidth,
                maxHeight: maxHeight,
              ),
              decoration: _buildDialogDecoration(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CityDialogHeader(
                    isEditMode: isEditMode,
                    onClose: () => Navigator.of(context).pop(),
                  ),
                  Flexible(
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          padding: EdgeInsets.all(
                            ResponsiveUI.padding(context, 24),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                buildTextField(
                                  context,
                                  controller: _nameController,
                                  label: LocaleKeys.city_name_en.tr(),
                                  icon: Icons.location_city_rounded,
                                  hint: LocaleKeys.hint_city_name_en.tr(),
                                  validator: (v) =>
                                      LoginValidator.validateRequired(
                                        v,
                                        LocaleKeys.city_name_en.tr(),
                                      ),
                                ),
                                SizedBox(
                                  height: ResponsiveUI.spacing(context, 12),
                                ),
                                buildTextField(
                                  context,
                                  controller: _arNameController,
                                  label: LocaleKeys.city_name_ar.tr(),
                                  icon: Icons.location_city_rounded,
                                  hint: LocaleKeys.hint_city_name_ar.tr(),
                                  validator: (v) =>
                                      LoginValidator.validateRequired(
                                        v,
                                        LocaleKeys.city_name_ar.tr(),
                                      ),
                                ),
                                SizedBox(
                                  height: ResponsiveUI.spacing(context, 12),
                                ),
                                // Custom Dropdown Menu for Country
                                buildDropdownField<CountryModel>(
                                  context,
                                  value: selectedCountry,
                                  items: countries,
                                  label: LocaleKeys.country.tr(),
                                  icon: Icons.public_rounded,
                                  hint: LocaleKeys.hint_select_country.tr(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedCountry = value;
                                    });
                                  },
                                  itemLabel: (country) => country.name,
                                  validator: (value) {
                                    if (value == null) {
                                      return LocaleKeys.validation_select_country.tr();
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(
                                  height: ResponsiveUI.spacing(context, 12),
                                ),
                                buildTextField(
                                  context,
                                  controller: _shipingCostController,
                                  keyboardType: TextInputType.number,
                                  label: LocaleKeys.shipping_cost.tr(),
                                  icon: Icons.local_shipping,
                                  hint: LocaleKeys.hint_shipping_cost.tr(),
                                  validator: (v) =>
                                      LoginValidator.validateRequired(
                                        v,
                                        LocaleKeys.shipping_cost.tr(),
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isLoading) buildLoadingOverlay(context, 45),
                      ],
                    ),
                  ),
                  CityDialogButtons(
                    isEditMode: isEditMode,
                    isLoading: isLoading,
                    onCancel: () => Navigator.of(context).pop(),
                    onSubmit: _handleSubmit,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  BoxDecoration _buildDialogDecoration() {
    return BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(
        ResponsiveUI.borderRadius(context, 24),
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.black.withValues(alpha: 0.2),
          blurRadius: ResponsiveUI.value(context, 30),
          offset: Offset(0, ResponsiveUI.value(context, 10)),
        ),
      ],
    );
  }

  void _handleStateChanges(BuildContext context, CityState state) {
    if (state is CreateCitySuccess || state is UpdateCitySuccess) {
      Navigator.of(context).pop();
    }

    if (state is CreateCityError) {
      CustomSnackbar.showError(context, state.error);
    } else if (state is UpdateCityError) {
      CustomSnackbar.showError(context, state.error);
    }
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final cubit = context.read<CityCubit>();

      if (isEditMode) {
        cubit.updateCity(
          cityId: widget.city!.id,
          name: _nameController.text.trim(),
          arName: _arNameController.text.trim(),
          countryId: selectedCountry!.id,
          shipingCost: _shipingCostController.text.trim(),
        );
      } else {
        cubit.createCity(
          name: _nameController.text.trim(),
          arName: _arNameController.text.trim(),
          countryId: selectedCountry!.id,
          shipingCost: _shipingCostController.text.trim(),
        );
      }
    }
  }
}

class CityDialogHeader extends StatelessWidget {
  final bool isEditMode;
  final VoidCallback onClose;

  const CityDialogHeader({
    super.key,
    required this.isEditMode,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final paddingHorizontal = ResponsiveUI.padding(context, 24);
    final paddingVertical = ResponsiveUI.padding(context, 20);
    final iconSize28 = ResponsiveUI.iconSize(context, 28);
    final fontSize22 = ResponsiveUI.fontSize(context, 22);
    final fontSize13 = ResponsiveUI.fontSize(context, 13);
    final spacing16 = ResponsiveUI.spacing(context, 16);
    final padding10 = ResponsiveUI.padding(context, 10);
    final borderRadius12 = ResponsiveUI.borderRadius(context, 12);
    final borderRadius24 = ResponsiveUI.borderRadius(context, 24);
    final iconSize24 = ResponsiveUI.iconSize(context, 24);
    final padding8 = ResponsiveUI.padding(context, 8);
    final borderRadius20 = ResponsiveUI.borderRadius(context, 20);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: paddingHorizontal,
        vertical: paddingVertical,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryBlue,
            AppColors.darkBlue,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(borderRadius24),
          topRight: Radius.circular(borderRadius24),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(padding10),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(borderRadius12),
            ),
            child: Icon(
              isEditMode ? Icons.edit : Icons.add,
              color: AppColors.white,
              size: iconSize28,
            ),
          ),
          SizedBox(width: spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditMode ? LocaleKeys.edit_city.tr() : LocaleKeys.new_city.tr(),
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: fontSize22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  isEditMode ? LocaleKeys.city_dialog_update_city_details.tr() : LocaleKeys.city_dialog_add_new_city.tr(),
                  style: TextStyle(
                    color: AppColors.white.withValues(alpha: 0.9),
                    fontSize: fontSize13,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(borderRadius20),
              onTap: onClose,
              child: Container(
                padding: EdgeInsets.all(padding8),
                child: Icon(
                  Icons.close,
                  color: AppColors.white,
                  size: iconSize24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CityDialogButtons extends StatelessWidget {
  final bool isEditMode;
  final bool isLoading;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  const CityDialogButtons({
    super.key,
    required this.isEditMode,
    required this.isLoading,
    required this.onCancel,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final padding24 = ResponsiveUI.padding(context, 24);
    final borderRadius24 = ResponsiveUI.borderRadius(context, 24);
    final borderRadius12 = ResponsiveUI.borderRadius(context, 12);
    final padding16 = ResponsiveUI.padding(context, 16);
    final value1_5 = ResponsiveUI.value(context, 1.5);
    final fontSize16 = ResponsiveUI.fontSize(context, 16);
    final padding12 = ResponsiveUI.padding(context, 12);
    final value14 = ResponsiveUI.fontSize(context, 14);
    final iconSize20 = ResponsiveUI.iconSize(context, 20);
    final spacing8 = ResponsiveUI.spacing(context, 8);
    final spacing16 = ResponsiveUI.spacing(context, 16);

    return Container(
      padding: EdgeInsets.all(padding24),
      decoration: BoxDecoration(
        color: AppColors.shadowGray[50],
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(borderRadius24),
          bottomRight: Radius.circular(borderRadius24),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: isLoading ? null : onCancel,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: padding16),
                side: BorderSide(
                  color: AppColors.shadowGray[300]!,
                  width: value1_5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius12),
                ),
              ),
              child: Text(
                LocaleKeys.cancel.tr(),
                style: TextStyle(
                  fontSize: fontSize16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.shadowGray[700],
                ),
              ),
            ),
          ),
          SizedBox(width: spacing16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: isLoading ? null : onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: AppColors.white,
                padding: EdgeInsets.symmetric(
                  vertical: padding16,
                  horizontal: padding12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius12),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isEditMode
                        ? Icons.check_circle_outline
                        : Icons.add_circle_outline,
                    size: iconSize20,
                  ),
                  SizedBox(width: spacing8),
                  Flexible(
                    child: Text(
                      isEditMode ? LocaleKeys.update_city.tr() : LocaleKeys.create_city.tr(),
                      style: TextStyle(
                        fontSize: value14,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


