import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/features/admin/city/cubit/city_cubit.dart';
import 'package:systego/features/admin/country/model/country_model.dart';
import 'package:systego/generated/locale_keys.g.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/responsive_ui.dart';
import '../../../../../core/utils/validators.dart';
import '../../../../../core/widgets/custom_loading/build_overlay_loading.dart';
import '../../../../../core/widgets/custom_snack_bar/custom_snackbar.dart';
import '../../../../../core/widgets/custom_textfield/build_text_field.dart';
import '../../../../../core/widgets/custom_drop_down_menu.dart';
import '../../../city/model/city_model.dart';
import '../../cubit/zone_cubit.dart';
import '../../cubit/zone_state.dart';
import '../../model/zone_model.dart';

class ZoneFormDialog extends StatefulWidget {
  final ZoneModel? zone;

  const ZoneFormDialog({super.key, this.zone});

  @override
  State<ZoneFormDialog> createState() => _ZoneFormDialogState();
}

class _ZoneFormDialogState extends State<ZoneFormDialog>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _arNameController = TextEditingController();
  final _costController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  // Dropdown states
  CountryModel? selectedCountry;
  CityModel? selectedCity;
  List<CityModel> filteredCities = []; // Cities filtered by selected country

  bool get isEditMode => widget.zone != null;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupAnimation();
  }

  void _initializeControllers() {
    // Common setup for both modes
    if (isEditMode) {
      _nameController.text = widget.zone!.name;
      _arNameController.text = widget.zone!.arName;
      _costController.text = widget.zone!.cost.toString();
    } else {
      _costController.text = '';
    }

    // Ensure cities and countries are loaded (static from cubit)
    final countries = CityCubit.countries;

    // Set selectedCountry: Match by ID from zone.country (for edit) or default
    if (isEditMode &&
        widget.zone!.country.id.isNotEmpty &&
        countries.isNotEmpty) {
      final matchingCountries = countries.where(
        (country) => country.id == widget.zone!.country.id,
      );
      if (matchingCountries.isNotEmpty) {
        final matchingCountry = matchingCountries.first;
        selectedCountry = matchingCountry;
        _filterCitiesByCountry(matchingCountry);
        // Set selectedCity: Match by ID from zone.city
        if (widget.zone!.city.id.isNotEmpty && filteredCities.isNotEmpty) {
          final matchingCities = filteredCities.where(
            (city) => city.id == widget.zone!.city.id,
          );
          if (matchingCities.isNotEmpty) {
            selectedCity = matchingCities.first;
          }
        }
      } else {
        // Fallback to default if no match
        final defaultCountries = countries.where((c) => c.isDefault);
        if (defaultCountries.isNotEmpty) {
          final defaultCountry = defaultCountries.first;
          selectedCountry = defaultCountry;
          _filterCitiesByCountry(defaultCountry);
        }
      }
    } else if (countries.isNotEmpty) {
      // Create mode: Default to first default country
      final defaultCountries = countries.where((country) => country.isDefault);
      if (defaultCountries.isNotEmpty) {
        final defaultCountry = defaultCountries.first;
        selectedCountry = defaultCountry;
        _filterCitiesByCountry(defaultCountry);
      } else {
        // Fallback to first country if no default
        selectedCountry = countries.first;
        _filterCitiesByCountry(selectedCountry!);
      }
    }
  }

  void _filterCitiesByCountry(CountryModel country) {
    filteredCities = CityCubit.cities
        .where((city) => city.country?.id == country.id)
        .toList();
    if (filteredCities.isNotEmpty && selectedCity != null) {
      // Re-validate selectedCity if needed
      selectedCity = filteredCities.firstWhere(
        (city) => city.id == selectedCity!.id,
        orElse: () => filteredCities.first,
      );
    } else {
      selectedCity = null; // Reset if no cities
    }
    setState(() {}); // Trigger rebuild for city dropdown
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
    _costController.dispose();
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
        child: BlocConsumer<ZoneCubit, ZoneState>(
          listener: _handleStateChanges,
          builder: (context, state) {
            final isLoading =
                state is CreateZoneLoading || state is UpdateZoneLoading;

            return Container(
              constraints: BoxConstraints(
                maxWidth: maxWidth,
                maxHeight: maxHeight,
              ),
              decoration: _buildDialogDecoration(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ZoneDialogHeader(
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
                                  label: LocaleKeys.zone_name_en.tr(),
                                  icon: Icons.gps_fixed,
                                  hint: LocaleKeys.enter_zone_name_en.tr(),
                                  validator: (v) =>
                                      LoginValidator.validateRequired(
                                        v,
                                        LocaleKeys.zone_name_en.tr(),
                                      ),
                                ),
                                SizedBox(
                                  height: ResponsiveUI.spacing(context, 12),
                                ),
                                buildTextField(
                                  context,
                                  controller: _arNameController,
                                  label: LocaleKeys.zone_name_ar.tr(),
                                  icon: Icons.gps_fixed,
                                  hint:  LocaleKeys.enter_zone_name_ar.tr(),
                                  validator: (v) =>
                                      LoginValidator.validateRequired(
                                        v,
                                        LocaleKeys.zone_name_ar.tr(),
                                      ),
                                ),
                                SizedBox(
                                  height: ResponsiveUI.spacing(context, 12),
                                ),
                                // Country Dropdown
                                buildDropdownField<CountryModel>(
                                  context,
                                  value: selectedCountry,
                                  items: CityCubit.countries,
                                  label: LocaleKeys.country.tr(),
                                  icon: Icons.public_rounded,
                                  hint: LocaleKeys.select_country.tr(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedCountry = value;
                                      selectedCity =
                                          null; // Reset city on country change
                                    });
                                    if (value != null) {
                                      _filterCitiesByCountry(value);
                                    }
                                  },
                                  itemLabel: (country) => country.name,
                                  validator: (value) {
                                    if (value == null) {
                                      return LocaleKeys.please_select_country_city.tr();
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(
                                  height: ResponsiveUI.spacing(context, 12),
                                ),
                                // City Dropdown (cascading)
                                buildDropdownField<CityModel>(
                                  context,
                                  value: selectedCity,
                                  items: filteredCities,
                                  label: LocaleKeys.city.tr(),
                                  icon: Icons.location_city_rounded,
                                  hint: LocaleKeys.select_city.tr(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedCity = value;
                                    });
                                  },
                                  itemLabel: (city) => city.name,
                                  validator: (value) {
                                    if (value == null) {
                                      return LocaleKeys.please_select_country_city.tr();
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(
                                  height: ResponsiveUI.spacing(context, 12),
                                ),
                                buildTextField(
                                  context,
                                  controller: _costController,
                                  keyboardType: TextInputType.number,
                                  label:  LocaleKeys.cost.tr(),
                                  icon: Icons.local_shipping,
                                  hint: LocaleKeys.enter_cost.tr(),
                                  validator: (v) =>
                                      LoginValidator.validateRequired(
                                        v,
                                        LocaleKeys.cost.tr(),
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
                  ZoneDialogButtons(
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

  void _handleStateChanges(BuildContext context, ZoneState state) {
    if (state is CreateZoneSuccess || state is UpdateZoneSuccess) {
      Navigator.of(context).pop();
    }

    if (state is CreateZoneError) {
      CustomSnackbar.showError(context, state.error);
    } else if (state is UpdateZoneError) {
      CustomSnackbar.showError(context, state.error);
    }
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate() &&
        selectedCountry != null &&
        selectedCity != null) {
      final cubit = context.read<ZoneCubit>();

      final cost = num.tryParse(_costController.text.trim()) ?? 0.0;

      if (isEditMode) {
        cubit.updateZone(
          zoneId: widget.zone!.id,
          name: _nameController.text.trim(),
          arName: _arNameController.text.trim(),
          countryId: selectedCountry!.id,
          cityId: selectedCity!.id,
          cost: cost.toString(),
        );
      } else {
        cubit.createZone(
          name: _nameController.text.trim(),
          arName: _arNameController.text.trim(),
          countryId: selectedCountry!.id,
          cityId: selectedCity!.id,
          cost: cost,
        );
      }
    } else if (selectedCountry == null || selectedCity == null) {
      CustomSnackbar.showError(context, LocaleKeys.please_select_country_city.tr());
    }
  }
}

// ZoneDialogHeader and ZoneDialogButtons remain unchanged
class ZoneDialogHeader extends StatelessWidget {
  final bool isEditMode;
  final VoidCallback onClose;

  const ZoneDialogHeader({
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
                  isEditMode  ? LocaleKeys.edit_zone.tr()
                      : LocaleKeys.new_zone.tr(),
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: fontSize22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  isEditMode  ? LocaleKeys.update_zone_details.tr()
                      : LocaleKeys.add_new_zone.tr(),
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

class ZoneDialogButtons extends StatelessWidget {
  final bool isEditMode;
  final bool isLoading;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  const ZoneDialogButtons({
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
                      isEditMode ? LocaleKeys.update_zone.tr()
                          : LocaleKeys.create_zone.tr(),
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


