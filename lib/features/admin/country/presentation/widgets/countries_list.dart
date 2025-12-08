import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/generated/locale_keys.g.dart';
import '../../../../../core/widgets/custom_snack_bar/custom_snackbar.dart';
import '../../../warehouses/view/widgets/custom_delete_dialog.dart';
import '../../cubit/country_cubit.dart';
import '../../model/country_model.dart';
import 'animated_country_card.dart';
import 'country_form_dialog.dart';

class CountriesList extends StatelessWidget {
  final List<CountryModel> countries;
  const CountriesList({super.key, required this.countries});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.only(
        right: ResponsiveUI.padding(context, 16),
        left: ResponsiveUI.padding(context, 16),
        top: ResponsiveUI.padding(context, 16),
      ),
      itemCount: countries.length,
      itemBuilder: (context, index) {
        return AnimatedCountryCard(
          country: countries[index],
          index: index,
          onDelete: () => _showDeleteDialog(context, countries[index]),
          onEdit: () => _showEditDialog(context, countries[index]),
          onTap: () => _showSelectDialog(context, countries[index]),
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, CountryModel country) {
    showDialog(
      context: context,
      builder: (context) => CountryFormDialog(country: country),
    );
  }

  void _showDeleteDialog(BuildContext context, CountryModel country) {
    if (country.id.isEmpty) {
      CustomSnackbar.showError(context, LocaleKeys.invalid_country_id.tr());
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => CustomDeleteDialog(
        title: LocaleKeys.delete_country.tr(),
        message:
            '${LocaleKeys.delete_country_message.tr()} \n"${country.name}"',
        onDelete: () {
          Navigator.pop(dialogContext);
          context.read<CountryCubit>().deleteCountry(country.id);
        },
      ),
    );
  }

  void _showSelectDialog(BuildContext context, CountryModel country) {
    if (country.id.isEmpty) {
      CustomSnackbar.showError(context, LocaleKeys.invalid_country_id.tr());
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => CustomDeleteDialog(
        title: LocaleKeys.select_country.tr(),
        message:
            '${LocaleKeys.select_country_message.tr()} \n"${country.name}"',
        icon: Icons.check_circle_rounded,
        iconColor: AppColors.primaryBlue,
        deleteText: LocaleKeys.select.tr(),
        onDelete: () {
          Navigator.pop(dialogContext);
          context.read<CountryCubit>().selectCountry(country.id, country.name);
        },
      ),
    );
  }
}
