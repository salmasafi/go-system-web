import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/animation/animated_element.dart';
import 'package:systego/core/widgets/app_bar_widgets.dart';
import 'package:systego/core/widgets/custom_error/custom_empty_state.dart';
import 'package:systego/core/widgets/custom_loading/custom_loading_state_with_shimmer.dart';
import 'package:systego/features/currency/cubit/currency_cubit.dart';
import 'package:systego/features/currency/presentation/widgets/currrency_form_dialog.dart';
import '../../../../core/widgets/custom_snck_bar/custom_snackbar.dart';
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
                ? 'No Currencies'
                : 'No Matching Currencies';
            String message = currencies.isEmpty
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
              child: CurrenciesList(currencies: currencies),
            );
          }
        } else {
          return CustomEmptyState(
            icon: Icons.monetization_on_rounded,
            title: 'No Currencies',
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
        title: 'Currencies',
        showActions: true,
        onPressed: () => showDialog(
          context: context,
          builder: (context) => CurrencyFormDialog(),
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
