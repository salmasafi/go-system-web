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
import 'package:GoSystem/features/admin/currency/cubit/currency_cubit.dart';
import 'package:GoSystem/features/admin/currency/presentation/widgets/currrency_form_dialog.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';
import '../../../../../core/widgets/custom_snack_bar/custom_snackbar.dart';
import '../widgets/currencies_list.dart';

class CurrenciesScreen extends StatefulWidget {
  const CurrenciesScreen({super.key});

  @override
  State<CurrenciesScreen> createState() => _CurrenciesScreenState();
}

class _CurrenciesScreenState extends State<CurrenciesScreen> {
  void currenciesInit() async {
    context.read<CurrencyCubit>().getCurrencies();
  }

  @override
  void initState() {
    super.initState();
    currenciesInit();
  }

  Future<void> _refresh() async {
    currenciesInit();
  }

  Widget _buildListContent() {
    return BlocConsumer<CurrencyCubit, CurrencyState>(
      listener: (context, state) {
        if (state is GetCurrenciesError) {
          CustomSnackbar.showError(context, state.error);
        } else if (state is DeleteCurrencyError) {
          CustomSnackbar.showError(context, state.error);
          currenciesInit();
        } else if (state is DeleteCurrencySuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          currenciesInit();
        } else if (state is CreateCurrencySuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          currenciesInit();
        } else if (state is UpdateCurrencySuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          currenciesInit();
        }
      },
      builder: (context, state) {
        if (state is GetCurrenciesLoading || state is DeleteCurrencyLoading) {
          return RefreshIndicator(
            onRefresh: _refresh,
            color: AppColors.primaryBlue,
            child: CustomLoadingShimmer(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
            ),
          );
        } else if (state is GetCurrenciesSuccess) {
          final currencies = state.currencies;

          if (currencies.isEmpty) {
            String title = currencies.isEmpty
                ? LocaleKeys.no_currencies.tr()
                : LocaleKeys.no_matching_currencies.tr();
            String message = currencies.isEmpty
                ? LocaleKeys.cities_all_caught_up.tr()
                : LocaleKeys.cities_try_adjusting_filters.tr();
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
              child: CurrenciesList(currencies: currencies),
            );
          }
        } else {
          return CustomEmptyState(
            icon: Icons.monetization_on_rounded,
            title: LocaleKeys.no_currencies.tr(),
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
        title: LocaleKeys.currencies_title.tr(),
        showActions: true,
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const CurrencyFormDialog(),
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
