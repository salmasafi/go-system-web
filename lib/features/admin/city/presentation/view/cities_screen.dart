import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:GoSystem/core/widgets/animation/animated_element.dart';
import 'package:GoSystem/core/widgets/app_bar_widgets.dart';
import 'package:GoSystem/core/widgets/custom_error/custom_empty_state.dart';
import 'package:GoSystem/core/widgets/custom_loading/custom_loading_state_with_shimmer.dart';
import 'package:GoSystem/features/admin/city/presentation/widgets/cities_list.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';
import '../../../../../core/widgets/custom_snack_bar/custom_snackbar.dart';
import '../../cubit/city_cubit.dart';
import '../../cubit/city_state.dart';
import '../widgets/city_form_dialog.dart';

class CitiesScreen extends StatefulWidget {
  const CitiesScreen({super.key});

  @override
  State<CitiesScreen> createState() => _CitiesScreenState();
}

class _CitiesScreenState extends State<CitiesScreen> {
  void citiesInit() async {
    context.read<CityCubit>().getCities();
  }

  @override
  void initState() {
    super.initState();
    citiesInit();
  }

  Future<void> _refresh() async {
    citiesInit();
  }

  Widget _buildListContent() {
    return BlocConsumer<CityCubit, CityState>(
      listener: (context, state) {
        if (state is GetCitiesError) {
          CustomSnackbar.showError(context, state.error);
        } else if (state is DeleteCityError) {
          CustomSnackbar.showError(context, state.error);
          citiesInit();
        } else if (state is DeleteCitySuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          citiesInit();
        } else if (state is SelectCityError) {
          CustomSnackbar.showError(context, state.error);
          citiesInit();
        } else if (state is SelectCitySuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          citiesInit();
        } else if (state is CreateCitySuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          citiesInit();
        } else if (state is UpdateCitySuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          citiesInit();
        }
      },
      builder: (context, state) {
        if (state is GetCitiesLoading ||
            state is DeleteCityLoading ||
            state is SelectCityLoading) {
          return RefreshIndicator(
            onRefresh: _refresh,
            color: AppColors.primaryBlue,
            child: CustomLoadingShimmer(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
            ),
          );
        } else if (state is GetCitiesSuccess) {
          final cities = state.cityData.cities;

          if (cities.isEmpty) {
            String title = cities.isEmpty ? LocaleKeys.no_cities.tr() : LocaleKeys.no_matching_cities.tr();
            String message = cities.isEmpty
                ?  LocaleKeys.cities_all_caught_up.tr()
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
              child: CitiesList(cities: cities),
            );
          }
        } else {
          return CustomEmptyState(
            icon: Icons.monetization_on_rounded,
            title: LocaleKeys.no_cities.tr(),
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
    return Scaffold(
      appBar: appBarWithActions(
        context,
        title: LocaleKeys.cities.tr(),
        showActions: true,
        onPressed: () => showDialog(
          context: context,
          builder: (context) => CityFormDialog(),
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
