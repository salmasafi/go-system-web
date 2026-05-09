import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:GoSystem/core/widgets/app_bar_widgets.dart';
import 'package:GoSystem/core/widgets/custom_snack_bar/custom_snackbar.dart';
import 'package:GoSystem/core/widgets/custom_textfield/build_text_field.dart';
import 'package:GoSystem/core/widgets/custom_drop_down_menu.dart';
import 'package:GoSystem/features/admin/bank_account/cubit/bank_account_cubit.dart';
import 'package:GoSystem/features/admin/product/cubit/get_products_cubit/product_cubit.dart';
import 'package:GoSystem/features/admin/product/cubit/get_products_cubit/product_state.dart';
import 'package:GoSystem/features/admin/product/models/product_model.dart' as pm;
import 'package:GoSystem/features/admin/purchase/cubit/purchase_cubit.dart';
import 'package:GoSystem/features/admin/purchase/model/purchase_model.dart';
import 'package:GoSystem/features/admin/suppliers/cubit/supplier_cubit.dart';
import 'package:GoSystem/features/admin/suppliers/cubit/supplier_state.dart';
import 'package:GoSystem/features/admin/warehouses/cubit/warehouse_cubit.dart';
import 'package:GoSystem/features/admin/warehouses/cubit/warehouse_state.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';

class CreatePurchaseScreen extends StatefulWidget {
  const CreatePurchaseScreen({super.key});

  @override
  State<CreatePurchaseScreen> createState() => _CreatePurchaseScreenState();
}

class _CreatePurchaseScreenState extends State<CreatePurchaseScreen> {
  final _noteController = TextEditingController();
  final _shippingController = TextEditingController(text: '0');
  final _discountController = TextEditingController(text: '0');

  String? _selectedWarehouseId;
  String? _selectedSupplierId;
  String? _paymentType = 'later'; // 'full', 'partial', 'later'
  String? _selectedFinancialAccountId;
  final _partialAmountController = TextEditingController();
  File? _receiptImage;
  final _picker = ImagePicker();

  // Items list
  final List<_PurchaseItemEntry> _items = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WareHouseCubit>().getWarehouses();
      context.read<SupplierCubit>().getSuppliers();
      context.read<BankAccountCubit>().getBankAccounts();
      context.read<ProductsCubit>().getProducts();
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    _shippingController.dispose();
    _discountController.dispose();
    _partialAmountController.dispose();
    for (final item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  double get _subtotal =>
      _items.fold(0, (sum, i) => sum + (i.quantity * i.unitCost));

  double get _discount =>
      double.tryParse(_discountController.text.replaceAll(',', '.')) ?? 0;

  double get _shipping =>
      double.tryParse(_shippingController.text.replaceAll(',', '.')) ?? 0;

  double get _grandTotal => (_subtotal - _discount + _shipping).clamp(0, double.infinity);

  Future<void> _pickImage() async {
    final f = await _picker.pickImage(source: ImageSource.gallery);
    if (f != null && mounted) setState(() => _receiptImage = File(f.path));
  }

  void _addProduct(pm.Product p) {
    setState(() {
      final exists = _items.any((i) => i.productId == p.id);
      if (!exists) _items.add(_PurchaseItemEntry(p));
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items[index].dispose();
      _items.removeAt(index);
    });
  }

  void _openProductPicker() {
    final productsState = context.read<ProductsCubit>().state;
    if (productsState is! ProductsSuccess) {
      CustomSnackbar.showWarning(context, LocaleKeys.loading.tr());
      return;
    }
    final products = productsState.products;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ResponsiveUI.borderRadius(context, 20)),
        ),
      ),
      builder: (ctx) {
        String query = '';
        return StatefulBuilder(builder: (ctx, setSheet) {
          final filtered = query.isEmpty
              ? products
              : products
                  .where((p) =>
                      p.name.toLowerCase().contains(query.toLowerCase()))
                  .toList();
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.7,
            maxChildSize: 0.95,
            builder: (_, scroll) => Column(
              children: [
                SizedBox(height: ResponsiveUI.spacing(context, 12)),
                Container(
                  width: ResponsiveUI.value(context, 40),
                  height: ResponsiveUI.value(context, 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: ResponsiveUI.spacing(context, 12)),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUI.padding(context, 16),
                  ),
                  child: TextField(
                    onChanged: (v) => setSheet(() => query = v),
                    decoration: InputDecoration(
                      hintText: LocaleKeys.product_name.tr(),
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveUI.borderRadius(context, 12),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: ResponsiveUI.spacing(context, 8)),
                Expanded(
                  child: ListView.builder(
                    controller: scroll,
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final p = filtered[i];
                      final added = _items.any((e) => e.productId == p.id);
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
                          child: Text(
                            p.name.isNotEmpty ? p.name[0].toUpperCase() : 'P',
                            style: TextStyle(color: AppColors.primaryBlue),
                          ),
                        ),
                        title: Text(p.name),
                        subtitle: Text('${p.price} EGP'),
                        trailing: added
                            ? Icon(Icons.check_circle, color: AppColors.successGreen)
                            : Icon(Icons.add_circle_outline, color: AppColors.primaryBlue),
                        onTap: () {
                          _addProduct(p);
                          Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  void _submit() {
    if (_selectedWarehouseId == null) {
      CustomSnackbar.showWarning(context, LocaleKeys.please_select_warehouse.tr());
      return;
    }
    if (_selectedSupplierId == null) {
      CustomSnackbar.showWarning(context, LocaleKeys.validation_required.tr(
        namedArgs: {'field': LocaleKeys.suppliers_title.tr()},
      ));
      return;
    }
    if (_items.isEmpty) {
      CustomSnackbar.showWarning(context, LocaleKeys.at_least_one_product.tr());
      return;
    }

    // Build items payload directly as maps (avoids Product type conflict)
    final items = _items.map((i) => {
      'product_id': i.productId,
      'product_code': '',
      'quantity': i.quantity,
      'unit_cost': i.unitCost,
      'discount': 0.0,
      'tax': 0.0,
      'subtotal': i.quantity * i.unitCost,
    }).toList();

    // Build payments
    List<Map<String, dynamic>>? payments;
    if (_paymentType == 'full' && _selectedFinancialAccountId != null) {
      payments = [
        PaymentModel(
          financialId: _selectedFinancialAccountId!,
          paymentAmount: _grandTotal,
        ).toJson(),
      ];
    } else if (_paymentType == 'partial' && _selectedFinancialAccountId != null) {
      final partial = double.tryParse(
              _partialAmountController.text.replaceAll(',', '.')) ??
          0;
      if (partial > 0) {
        payments = [
          PaymentModel(
            financialId: _selectedFinancialAccountId!,
            paymentAmount: partial,
          ).toJson(),
        ];
      }
    }

    context.read<PurchaseCubit>().createPurchase(
          warehouseId: _selectedWarehouseId!,
          supplierId: _selectedSupplierId!,
          items: items,
          grandTotal: _grandTotal,
          discount: _discount,
          shippingCost: _shipping,
          note: _noteController.text.trim(),
          receiptImageFile: _receiptImage,
          payments: payments,
        );
  }

  @override
  Widget build(BuildContext context) {
    Widget screenContent = BlocConsumer<PurchaseCubit, PurchaseState>(
      listener: (context, state) {
        if (state is CreatePurchaseSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          Navigator.pop(context, true);
        } else if (state is CreatePurchaseError) {
          CustomSnackbar.showError(context, state.error);
        }
      },
      builder: (context, state) {
        final isLoading = state is CreatePurchaseLoading;
        return Scaffold(
          backgroundColor: AppColors.lightBlueBackground,
          appBar: appBarWithActions(
            context,
            title: LocaleKeys.purchase_title.tr(),
          ),
          body: Stack(
            children: [
              SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionCard(
                        context,
                        title: LocaleKeys.warehouse.tr(),
                        icon: Icons.warehouse_outlined,
                        child: BlocBuilder<WareHouseCubit, WarehousesState>(
                          builder: (context, state) {
                            if (state is WarehousesLoaded) {
                              return buildDropdownField<String>(
                                context,
                                value: _selectedWarehouseId,
                                items: state.warehouses.map((w) => w.id).toList(),
                                label: LocaleKeys.select_warehouse.tr(),
                                icon: Icons.warehouse_outlined,
                                hint: LocaleKeys.select_warehouse.tr(),
                                onChanged: (v) =>
                                    setState(() => _selectedWarehouseId = v),
                                itemLabel: (id) {
                                  final w = state.warehouses
                                      .firstWhere((w) => w.id == id,
                                          orElse: () => state.warehouses.first);
                                  return w.name;
                                },
                              );
                            }
                            return const LinearProgressIndicator();
                          },
                        ),
                      ),
                      SizedBox(height: ResponsiveUI.spacing(context, 12)),
                      _buildSectionCard(
                        context,
                        title: LocaleKeys.suppliers_title.tr(),
                        icon: Icons.person_outline,
                        child: BlocBuilder<SupplierCubit, SupplierStates>(
                          builder: (context, state) {
                            final suppliers =
                                context.read<SupplierCubit>().suppliers ?? [];
                            if (state is SupplierSuccess && suppliers.isNotEmpty) {
                              return buildDropdownField<String>(
                                context,
                                value: _selectedSupplierId,
                                items: suppliers.map((s) => s.id ?? '').where((id) => id.isNotEmpty).toList(),
                                label: LocaleKeys.supplier_name.tr(),
                                icon: Icons.person_outline,
                                hint: LocaleKeys.supplier_name.tr(),
                                onChanged: (v) =>
                                    setState(() => _selectedSupplierId = v),
                                itemLabel: (id) {
                                  final s = suppliers.firstWhere(
                                    (s) => s.id == id,
                                    orElse: () => suppliers.first,
                                  );
                                  return s.username ?? s.companyName ?? id;
                                },
                              );
                            }
                            return const LinearProgressIndicator();
                          },
                        ),
                      ),
                      SizedBox(height: ResponsiveUI.spacing(context, 12)),
                      // Products section
                      _buildSectionCard(
                        context,
                        title: LocaleKeys.products.tr(),
                        icon: Icons.inventory_2_outlined,
                        trailing: TextButton.icon(
                          icon: const Icon(Icons.add),
                          label: Text(LocaleKeys.add_product.tr()),
                          onPressed: _openProductPicker,
                        ),
                        child: _items.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: EdgeInsets.all(
                                    ResponsiveUI.padding(context, 16),
                                  ),
                                  child: Text(
                                    LocaleKeys.at_least_one_product.tr(),
                                    style: TextStyle(
                                      color: AppColors.shadowGray,
                                    ),
                                  ),
                                ),
                              )
                            : Column(
                                children: _items.asMap().entries.map((e) {
                                  final idx = e.key;
                                  final item = e.value;
                                  return _buildItemRow(context, idx, item);
                                }).toList(),
                              ),
                      ),
                      SizedBox(height: ResponsiveUI.spacing(context, 12)),
                      // Totals section
                      _buildSectionCard(
                        context,
                        title: LocaleKeys.amount.tr(),
                        icon: Icons.calculate_outlined,
                        child: Column(
                          children: [
                            _buildSmallFieldWrap(
                              context,
                              controller: _discountController,
                              label: LocaleKeys.discount_amount.tr(),
                              icon: Icons.discount_outlined,
                              onChanged: (_) => setState(() {}),
                            ),
                            SizedBox(height: ResponsiveUI.spacing(context, 12)),
                            _buildSmallFieldWrap(
                              context,
                              controller: _shippingController,
                              label: LocaleKeys.shipping_cost.tr(),
                              icon: Icons.local_shipping_outlined,
                              onChanged: (_) => setState(() {}),
                            ),
                            SizedBox(height: ResponsiveUI.spacing(context, 12)),
                            _buildTotalsRow(context),
                          ],
                        ),
                      ),
                      SizedBox(height: ResponsiveUI.spacing(context, 12)),
                      // Payment section
                      _buildSectionCard(
                        context,
                        title: LocaleKeys.payments_title.tr(),
                        icon: Icons.payment_outlined,
                        child: Column(
                          children: [
                            Wrap(
                              spacing: ResponsiveUI.spacing(context, 8),
                              runSpacing: ResponsiveUI.spacing(context, 8),
                              children: [
                                _buildPaymentChip(context, 'later', 'لاحقاً'),
                                _buildPaymentChip(context, 'full', 'كامل'),
                                _buildPaymentChip(context, 'partial', 'جزئي'),
                              ],
                            ),
                            if (_paymentType != 'later') ...[
                              SizedBox(height: ResponsiveUI.spacing(context, 12)),
                              BlocBuilder<BankAccountCubit, BankAccountState>(
                                builder: (context, state) {
                                  if (state is GetBankAccountsSuccess) {
                                    return buildDropdownField<String>(
                                      context,
                                      value: _selectedFinancialAccountId,
                                      items: state.accounts.map((a) => a.id).toList(),
                                      label: LocaleKeys.financial_account.tr(),
                                      icon: Icons.account_balance_outlined,
                                      hint: LocaleKeys.select_financial_account.tr(),
                                      onChanged: (v) => setState(
                                          () => _selectedFinancialAccountId = v),
                                      itemLabel: (id) {
                                        final a = state.accounts.firstWhere(
                                          (a) => a.id == id,
                                          orElse: () => state.accounts.first,
                                        );
                                        return a.name;
                                      },
                                    );
                                  }
                                  return const LinearProgressIndicator();
                                },
                              ),
                            ],
                            if (_paymentType == 'partial') ...[
                              SizedBox(height: ResponsiveUI.spacing(context, 12)),
                              buildTextField(
                                context,
                                controller: _partialAmountController,
                                label: LocaleKeys.amount.tr(),
                                icon: Icons.money_outlined,
                                hint: '0',
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              ),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(height: ResponsiveUI.spacing(context, 12)),
                      // Note & Receipt
                      _buildSectionCard(
                        context,
                        title: LocaleKeys.note.tr(),
                        icon: Icons.notes_outlined,
                        child: Column(
                          children: [
                            buildTextField(
                              context,
                              controller: _noteController,
                              label: LocaleKeys.note.tr(),
                              icon: Icons.notes_outlined,
                              hint: LocaleKeys.hint_note.tr(),
                              maxLines: 3,
                            ),
                            SizedBox(height: ResponsiveUI.spacing(context, 12)),
                            GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                width: double.infinity,
                                height: ResponsiveUI.value(context, 100),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.lightGray),
                                  borderRadius: BorderRadius.circular(
                                    ResponsiveUI.borderRadius(context, 12),
                                  ),
                                  image: _receiptImage != null
                                      ? DecorationImage(
                                          image: FileImage(_receiptImage!),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: _receiptImage == null
                                    ? Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.receipt_outlined,
                                              color: AppColors.shadowGray),
                                          Text(LocaleKeys.attach_document.tr(),
                                              style: TextStyle(
                                                  color: AppColors.shadowGray)),
                                        ],
                                      )
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: ResponsiveUI.spacing(context, 24)),
                      SizedBox(
                        width: double.infinity,
                        height: ResponsiveUI.value(context, 52),
                        child: ElevatedButton.icon(
                          onPressed: isLoading ? null : _submit,
                          icon: isLoading
                              ? SizedBox(
                                  width: ResponsiveUI.value(context, 18),
                                  height: ResponsiveUI.value(context, 18),
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.save_outlined),
                          label: Text(
                            LocaleKeys.submit.tr(),
                            style: TextStyle(
                              fontSize: ResponsiveUI.fontSize(context, 16),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                ResponsiveUI.borderRadius(context, 14),
                              ),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                      SizedBox(height: ResponsiveUI.spacing(context, 32)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
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

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius:
            BorderRadius.circular(ResponsiveUI.borderRadius(context, 16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUI.padding(context, 16),
              vertical: ResponsiveUI.padding(context, 12),
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.05),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(ResponsiveUI.borderRadius(context, 16)),
                topRight:
                    Radius.circular(ResponsiveUI.borderRadius(context, 16)),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: ResponsiveUI.iconSize(context, 18),
                    color: AppColors.primaryBlue),
                SizedBox(width: ResponsiveUI.spacing(context, 8)),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 14),
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue,
                  ),
                ),
                if (trailing != null) ...[
                  const Spacer(),
                  trailing,
                ],
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(BuildContext context, int idx, _PurchaseItemEntry item) {
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveUI.spacing(context, 8)),
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
      decoration: BoxDecoration(
        color: AppColors.lightBlueBackground,
        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.productName,
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 14),
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkGray,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                iconSize: ResponsiveUI.iconSize(context, 20),
                onPressed: () => _removeItem(idx),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUI.spacing(context, 8)),
          Row(
            children: [
              Expanded(
                child: _buildSmallField(
                  context,
                  controller: item.quantityController,
                  label: LocaleKeys.quantity.tr(),
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              SizedBox(width: ResponsiveUI.spacing(context, 8)),
              Expanded(
                child: _buildSmallField(
                  context,
                  controller: item.unitCostController,
                  label: LocaleKeys.amount.tr(),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              SizedBox(width: ResponsiveUI.spacing(context, 8)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocaleKeys.price.tr(),
                      style: TextStyle(
                        fontSize: ResponsiveUI.fontSize(context, 11),
                        color: AppColors.shadowGray,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveUI.padding(context, 8),
                        vertical: ResponsiveUI.padding(context, 10),
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(
                          ResponsiveUI.borderRadius(context, 8),
                        ),
                        border: Border.all(
                            color: AppColors.primaryBlue.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        '${(item.quantity * item.unitCost).toStringAsFixed(2)} EGP',
                        style: TextStyle(
                          fontSize: ResponsiveUI.fontSize(context, 13),
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Full-width field with icon (for discount/shipping cards)
  Widget _buildSmallFieldWrap(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    IconData? icon,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: ResponsiveUI.iconSize(context, 16), color: AppColors.shadowGray),
              SizedBox(width: ResponsiveUI.spacing(context, 6)),
            ],
            Text(label,
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 13),
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkGray,
                )),
          ],
        ),
        SizedBox(height: ResponsiveUI.spacing(context, 6)),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: onChanged,
          style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 14)),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(
              horizontal: ResponsiveUI.padding(context, 12),
              vertical: ResponsiveUI.padding(context, 12),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 10)),
              borderSide: BorderSide(color: AppColors.lightGray),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 10)),
              borderSide: BorderSide(color: AppColors.lightGray),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 10)),
              borderSide: BorderSide(color: AppColors.primaryBlue, width: 1.5),
            ),
            suffixText: 'EGP',
            suffixStyle: TextStyle(color: AppColors.shadowGray, fontSize: ResponsiveUI.fontSize(context, 12)),
          ),
        ),
      ],
    );
  }

  Widget _buildSmallField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 11),
              color: AppColors.shadowGray,
            )),
        SizedBox(height: ResponsiveUI.spacing(context, 4)),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 13)),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(
              horizontal: ResponsiveUI.padding(context, 8),
              vertical: ResponsiveUI.padding(context, 10),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                ResponsiveUI.borderRadius(context, 8),
              ),
              borderSide:
                  BorderSide(color: AppColors.lightGray),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                ResponsiveUI.borderRadius(context, 8),
              ),
              borderSide: BorderSide(color: AppColors.lightGray),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                ResponsiveUI.borderRadius(context, 8),
              ),
              borderSide: BorderSide(color: AppColors.primaryBlue),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalsRow(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryBlue, AppColors.darkBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
      ),
      child: Column(
        children: [
          _totalsLine(context, LocaleKeys.balance.tr(), _subtotal),
          _totalsLine(context, LocaleKeys.discount_amount.tr(), -_discount),
          _totalsLine(context, LocaleKeys.shipping_cost.tr(), _shipping),
          Divider(color: Colors.white.withValues(alpha: 0.3), height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                LocaleKeys.amount.tr(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ResponsiveUI.fontSize(context, 16),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${_grandTotal.toStringAsFixed(2)} EGP',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ResponsiveUI.fontSize(context, 18),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _totalsLine(BuildContext context, String label, double amount) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: ResponsiveUI.padding(context, 2)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: ResponsiveUI.fontSize(context, 13))),
          Text(
            '${amount >= 0 ? '' : '-'}${amount.abs().toStringAsFixed(2)} EGP',
            style: TextStyle(
                color: Colors.white,
                fontSize: ResponsiveUI.fontSize(context, 13),
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentChip(BuildContext context, String type, String label) {
    final isSelected = _paymentType == type;
    return GestureDetector(
      onTap: () => setState(() => _paymentType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUI.padding(context, 16),
          vertical: ResponsiveUI.padding(context, 8),
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : AppColors.lightBlueBackground,
          borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 20)),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryBlue
                : AppColors.lightGray,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.darkGray,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: ResponsiveUI.fontSize(context, 13),
          ),
        ),
      ),
    );
  }
}

/// Helper class for purchase item entries in the form
class _PurchaseItemEntry {
  final pm.Product product;
  final TextEditingController quantityController;
  final TextEditingController unitCostController;

  _PurchaseItemEntry(this.product)
      : quantityController = TextEditingController(text: '1'),
        unitCostController =
            TextEditingController(text: product.price.toStringAsFixed(2));

  String get productId => product.id;
  String get productName => product.name;

  int get quantity => int.tryParse(quantityController.text.trim()) ?? 1;

  double get unitCost =>
      double.tryParse(unitCostController.text.trim().replaceAll(',', '.')) ??
      product.price;

  void dispose() {
    quantityController.dispose();
    unitCostController.dispose();
  }
}
