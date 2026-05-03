import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:GoSystem/core/widgets/animation/animated_element.dart';
import 'package:GoSystem/core/widgets/app_bar_widgets.dart';
import 'package:GoSystem/core/widgets/custom_error/custom_empty_state.dart';
import 'package:GoSystem/core/widgets/custom_loading/custom_loading_state_with_shimmer.dart';
import 'package:GoSystem/features/admin/country/cubit/country_cubit.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';
import '../../../../../core/widgets/custom_snack_bar/custom_snackbar.dart';
import '../../cubit/Country_state.dart';
import '../widgets/countries_list.dart';
import '../widgets/country_form_dialog.dart';

class CountriessScreen extends StatefulWidget {
  const CountriessScreen({super.key});

  @override
  State<CountriessScreen> createState() => _CountriessScreenState();
}

class _CountriessScreenState extends State<CountriessScreen> {
  void countriesInit() async {
    context.read<CountryCubit>().getCountries();
  }

  @override
  void initState() {
    super.initState();
    countriesInit();
  }

  Future<void> _refresh() async {
    countriesInit();
  }

  Widget _buildListContent() {
    return BlocConsumer<CountryCubit, CountryState>(
      listener: (context, state) {
        if (state is GetCountriesError) {
          CustomSnackbar.showError(context, state.error);
        } else if (state is DeleteCountryError) {
          CustomSnackbar.showError(context, state.error);
          countriesInit();
        } else if (state is DeleteCountrySuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          countriesInit();
        } else if (state is SelectCountryError) {
          CustomSnackbar.showError(context, state.error);
          countriesInit();
        } else if (state is SelectCountrySuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          countriesInit();
        } else if (state is CreateCountrySuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          countriesInit();
        } else if (state is UpdateCountrySuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          countriesInit();
        }
      },
      builder: (context, state) {
        if (state is GetCountriesLoading ||
            state is DeleteCountryLoading ||
            state is SelectCountryLoading) {
          return RefreshIndicator(
            onRefresh: _refresh,
            color: AppColors.primaryBlue,
            child: CustomLoadingShimmer(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
            ),
          );
        } else if (state is GetCountriesSuccess) {
          final countries = state.countries;

          if (countries.isEmpty) {
            String title = countries.isEmpty
                ? LocaleKeys.no_countries.tr()
                : LocaleKeys.no_matching_countries.tr();
            String message = countries.isEmpty
                ? LocaleKeys.cities_all_caught_up.tr()
                : LocaleKeys.try_adjusting_search.tr();
            return CustomEmptyState(
              icon: Icons.monetization_on_rounded,
              title: title,
              message: message,
              onRefresh: _refresh,
              actionLabel: LocaleKeys.retry.tr(),
              onAction: _refresh,
            );
          } else {
            return RefreshIndicator(
              onRefresh: _refresh,
              color: AppColors.primaryBlue,
              child: CountriesList(countries: countries),
            );
          }
        } else {
          return CustomEmptyState(
            icon: Icons.monetization_on_rounded,
            title: LocaleKeys.no_countries.tr(),
            message: LocaleKeys.empty_connection.tr(),
            onRefresh: _refresh,
            actionLabel: LocaleKeys.retry.tr(),
            onAction: _refresh,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Scale down for web
    Widget screenContent = Scaffold(
      backgroundColor: AppColors.lightBlueBackground,
      appBar: appBarWithActions(
        context,
        title: LocaleKeys.countries_title.tr(),
        showActions: true,
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const CountryFormDialog(),
          );
        },
      ),
      body: SafeArea(
        child: _buildListContent(),
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
  }
}
