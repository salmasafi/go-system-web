import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:GoSystem/core/widgets/custom_loading/custom_loading_state.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';
import '../../cubit/online_orders_cubit.dart';
import '../../model/online_order_model.dart';
import '../widgets/online_order_card.dart';

class OnlineOrdersScreen extends StatefulWidget {
  const OnlineOrdersScreen({super.key});

  @override
  State<OnlineOrdersScreen> createState() => _OnlineOrdersScreenState();
}

class _OnlineOrdersScreenState extends State<OnlineOrdersScreen> {
  final _searchCtrl = TextEditingController();
  String _selectedStatus = '';

  @override
  void initState() {
    super.initState();
    context.read<OnlineOrdersCubit>().fetchOrders();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBlueBackground,
      appBar: AppBar(
        title: Text(
          LocaleKeys.online_orders_title.tr(),
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: ResponsiveUI.fontSize(context, 18)),
        ),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.darkGray,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: ResponsiveUI.value(context, 1), color: AppColors.lightGray),
        ),
      ),
      body: BlocBuilder<OnlineOrdersCubit, OnlineOrdersState>(
        builder: (context, state) {
          final isLoading = state is OnlineOrdersLoading;
          final orders =
              state is OnlineOrdersLoaded ? state.orders : <OnlineOrderModel>[];
          final total =
              state is OnlineOrdersLoaded ? state.totalCount : 0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Total count ──
              Padding(
                padding: EdgeInsets.fromLTRB(
                  ResponsiveUI.padding(context, 16),
                  ResponsiveUI.padding(context, 12),
                  ResponsiveUI.padding(context, 16),
                  0,
                ),
                child: RichText(
                  text: TextSpan(
                    text: LocaleKeys.total_orders.tr() + ': ',
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 13),
                      color: AppColors.shadowGray,
                      fontFamily: 'Rubik',
                    ),
                    children: [
                      TextSpan(
                        text: '$total',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkGray,
                          fontSize: ResponsiveUI.fontSize(context, 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: ResponsiveUI.spacing(context, 10)),

              // ── Search + Filter row ──
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUI.padding(context, 16),
                ),
                child: Row(
                  children: [
                    // Search
                    Expanded(
                      flex: 3,
                      child: _SearchField(
                        controller: _searchCtrl,
                        onChanged: (v) {
                          context.read<OnlineOrdersCubit>().search(v);
                        },
                        onClear: () {
                          _searchCtrl.clear();
                          context.read<OnlineOrdersCubit>().search('');
                        },
                      ),
                    ),
                    SizedBox(width: ResponsiveUI.spacing(context, 10)),
                    // Status filter
                    Expanded(
                      flex: 2,
                      child: _StatusFilter(
                        selected: _selectedStatus,
                        onChanged: (v) {
                          setState(() => _selectedStatus = v ?? '');
                          context
                              .read<OnlineOrdersCubit>()
                              .filterByStatus(_selectedStatus);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: ResponsiveUI.spacing(context, 10)),

              // ── List ──
              Expanded(
                child: isLoading
                    ? Center(child: CustomLoadingState())
                    : orders.isEmpty
                        ? _EmptyView(
                            onRefresh: () =>
                                context.read<OnlineOrdersCubit>().fetchOrders(),
                          )
                        : RefreshIndicator(
                            color: AppColors.primaryBlue,
                            onRefresh: () =>
                                context.read<OnlineOrdersCubit>().fetchOrders(),
                            child: ListView.builder(
                              padding: EdgeInsets.symmetric(
                                horizontal: ResponsiveUI.padding(context, 16),
                                vertical: ResponsiveUI.padding(context, 4),
                              ),
                              itemCount: orders.length,
                              itemBuilder: (context, index) => OnlineOrderCard(
                                order: orders[index],
                                index: index,
                              ),
                            ),
                          ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Search Field ─────────────────────────────────────────────────────────────

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: TextStyle(
        fontSize: ResponsiveUI.fontSize(context, 13),
        color: AppColors.darkGray,
      ),
      decoration: InputDecoration(
        hintText: LocaleKeys.search_orders_hint.tr(),
        hintStyle: TextStyle(
          fontSize: ResponsiveUI.fontSize(context, 12),
          color: AppColors.shadowGray,
        ),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: AppColors.shadowGray,
          size: ResponsiveUI.iconSize(context, 18),
        ),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.close_rounded,
                    color: AppColors.shadowGray, size: ResponsiveUI.iconSize(context, 16)),
                onPressed: onClear,
              )
            : null,
        filled: true,
        fillColor: AppColors.white,
        contentPadding: EdgeInsets.symmetric(
          horizontal: ResponsiveUI.padding(context, 12),
          vertical: ResponsiveUI.padding(context, 10),
        ),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
          borderSide: BorderSide(
              color: AppColors.lightGray.withValues(alpha: 0.6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
          borderSide:
              BorderSide(color: AppColors.primaryBlue, width: ResponsiveUI.value(context, 1.5)),
        ),
      ),
    );
  }
}

// ─── Status Filter ────────────────────────────────────────────────────────────

class _StatusFilter extends StatelessWidget {
  final String selected;
  final ValueChanged<String?> onChanged;

  const _StatusFilter({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: selected.isEmpty ? null : selected,
      isExpanded: true,
      hint: Row(
        children: [
          Icon(Icons.filter_alt_outlined,
              size: ResponsiveUI.iconSize(context, 16),
              color: AppColors.shadowGray),
          SizedBox(width: ResponsiveUI.spacing(context, 6)),
          Text(
            LocaleKeys.all_statuses.tr(),
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 12),
              color: AppColors.shadowGray,
            ),
          ),
        ],
      ),
      icon: Icon(Icons.keyboard_arrow_down_rounded,
          color: AppColors.shadowGray, size: ResponsiveUI.iconSize(context, 18)),
      style: TextStyle(
        fontSize: ResponsiveUI.fontSize(context, 12),
        color: AppColors.darkGray,
        fontFamily: 'Rubik',
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: EdgeInsets.symmetric(
          horizontal: ResponsiveUI.padding(context, 12),
          vertical: ResponsiveUI.padding(context, 10),
        ),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
          borderSide: BorderSide(
              color: AppColors.lightGray.withValues(alpha: 0.6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
          borderSide:
              BorderSide(color: AppColors.primaryBlue, width: ResponsiveUI.value(context, 1.5)),
        ),
      ),
      items: [
        const DropdownMenuItem(
          value: '',
          child: Text('All Statuses'),
        ),
        ...OnlineOrdersCubit.statuses.map(
          (s) => DropdownMenuItem(
            value: s,
            child: Text(s.replaceAll('_', ' ')),
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }
}

// ─── Empty View ───────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  final VoidCallback onRefresh;
  const _EmptyView({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: AppColors.primaryBlue,
      child: ListView(
        children: [
          SizedBox(height: ResponsiveUI.value(context, 120)),
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: ResponsiveUI.iconSize(context, 64),
                  color: AppColors.shadowGray.withValues(alpha: 0.4),
                ),
                SizedBox(height: ResponsiveUI.spacing(context, 16)),
                Text(
                  LocaleKeys.no_orders_found.tr(),
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 16),
                    fontWeight: FontWeight.w600,
                    color: AppColors.shadowGray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
