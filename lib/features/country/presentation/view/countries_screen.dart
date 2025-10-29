import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/animation/animated_element.dart';
import 'package:systego/core/widgets/app_bar_widgets.dart';
import 'package:systego/core/widgets/custom_error/custom_empty_state.dart';
import 'package:systego/core/widgets/custom_loading/custom_loading_state_with_shimmer.dart';
import 'package:systego/features/country/cubit/country_cubit.dart';
import '../../../../core/widgets/custom_snck_bar/custom_snackbar.dart';
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
                ? 'No countries'
                : 'No Matching countries';
            String message = countries.isEmpty
                ? 'You\'re all caught up!'
                : 'Try adjusting your filters';
            return CustomEmptyState(
              icon: Icons.monetization_on_rounded,
              title: title,
              message: message,
              onRefresh: _refresh,
              actionLabel: 'Retry',
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
            title: 'No countries',
            message: 'Pull to refresh or check your connection',
            onRefresh: _refresh,
            actionLabel: 'Retry',
            onAction: _refresh,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWithActions(
        context,
        title: 'Countries',
        showActions: true,
        onPressed: () => showDialog(
          context: context,
          builder: (context) => CountryFormDialog(),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: ResponsiveUI.contentMaxWidth(context),
          ),
          child: AnimatedElement(
            delay: const Duration(milliseconds: 200),
            child: _buildListContent(),
          ),
        ),
      ),
    );
  }
}
