import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/app_bar_widgets.dart';
import 'package:systego/features/admin/suppliers/cubit/supplier_cubit.dart';
import 'package:systego/features/admin/suppliers/cubit/supplier_state.dart';
import 'package:systego/features/admin/suppliers/view/widgets_supplier_screen/supplier_list.dart';
import 'package:systego/features/admin/suppliers/view/widgets_supplier_screen/supplier_search_filter_section.dart';
import 'suppplier_add_edit/supplier_dialog.dart';
import '../../../../core/widgets/custom_error/custom_empty_state.dart';
import '../../../../core/widgets/custom_error/custom_error_state.dart';
import '../../../../core/widgets/custom_loading/custom_loading_state_with_shimmer.dart';
import '../../../../core/widgets/custom_snack_bar/custom_snackbar.dart';
import '../model/supplier_model.dart';
import '../../../../generated/locale_keys.g.dart';
import '../data/repositories/supplier_repository.dart';

class SupplierScreen extends StatefulWidget {
  const SupplierScreen({super.key});

  @override
  State<SupplierScreen> createState() => _SupplierScreenState();
}

class _SupplierScreenState extends State<SupplierScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCountry;
  String? _selectedCity;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SupplierCubit(SupplierRepository())..getSuppliers(),
      child: Scaffold(
        appBar: appBarWithActions(
          context,
          title: LocaleKeys.suppliers_title.tr(),
          onPressed: () {
            SupplierDialog.show(context);
          },
          showActions: true,
        ),
        body: BlocConsumer<SupplierCubit, SupplierStates>(
          listener: (context, state) {
            if (state is SupplierError) {
              CustomSnackbar.showError(context, state.message);
            }
          },
          builder: (context, state) {
            if (state is SupplierLoading) {
              return CustomLoadingShimmer(
                itemCount: 6,
                padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
              );
            }

            if (state is SupplierError) {
              return CustomErrorState(
                message: state.message,
                onRetry: () {
                  context.read<SupplierCubit>().getSuppliers();
                },
              );
            }

            if (state is SupplierSuccess) {
              final cubit = context.read<SupplierCubit>();
              final suppliers = _getFilteredSuppliers(cubit);

              if (suppliers.isEmpty &&
                  _searchQuery.isEmpty &&
                  _selectedCountry == null &&
                  _selectedCity == null) {
                return CustomEmptyState(
                  icon: Icons.store_outlined,
                  title: LocaleKeys.no_suppliers_title.tr(),
                  message: LocaleKeys.no_suppliers_message.tr(),
                  onRefresh: () async {
                    await cubit.getSuppliers();
                  },
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  await cubit.getSuppliers();
                },
                color: AppColors.primaryBlue,
                child: Column(
                  children: [
                    SupplierSearchFilterSection(
                      searchController: _searchController,
                      searchQuery: _searchQuery,
                      selectedCountry: _selectedCountry,
                      selectedCity: _selectedCity,
                      cubit: cubit,
                      onSearchChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      onSearchCleared: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        });
                      },
                      onCountryChanged: (value) {
                        setState(() {
                          _selectedCountry = value;
                          _selectedCity = null;
                        });
                      },
                      onCityChanged: (value) {
                        setState(() {
                          _selectedCity = value;
                        });
                      },
                      onCountryRemoved: () {
                        setState(() {
                          _selectedCountry = null;
                          _selectedCity = null;
                        });
                      },
                      onCityRemoved: () {
                        setState(() {
                          _selectedCity = null;
                        });
                      },
                    ),
                    if (suppliers.isEmpty &&
                        (_searchQuery.isNotEmpty ||
                            _selectedCountry != null ||
                            _selectedCity != null))
                      Expanded(
                        child: CustomEmptyState(
                          icon: Icons.search_off,
                          title: LocaleKeys.no_results_title.tr(),
                          message: LocaleKeys.no_results_message.tr(),
                          actionLabel: LocaleKeys.clear_filters.tr(),
                          onAction: () {
                            setState(() {
                              _searchQuery = '';
                              _searchController.clear();
                              _selectedCountry = null;
                              _selectedCity = null;
                            });
                          },
                        ),
                      )
                    else
                      Expanded(child: SupplierList(suppliers: suppliers)),
                  ],
                ),
              );
            }

            return SizedBox();
          },
        ),
      ),
    );
  }

  List<Suppliers> _getFilteredSuppliers(SupplierCubit cubit) {
    List<Suppliers> suppliers = cubit.suppliers ?? [];

    if (_searchQuery.isNotEmpty) {
      suppliers = cubit.searchSuppliers(_searchQuery);
    }

    if (_selectedCountry != null) {
      suppliers = suppliers
          .where((s) => s.countryId?.id == _selectedCountry)
          .toList();
    }

    if (_selectedCity != null) {
      suppliers = suppliers
          .where((s) => s.cityId?.id == _selectedCity)
          .toList();
    }

    return suppliers;
  }
}
