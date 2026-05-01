// lib/features/pos/home/presentation/widgets/bundle_attribute_selection_dialog.dart
// Task 15: BundleAttributeSelectionDialog for POS
// Shows per-product attribute selection for bundles, validates all products before adding.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:GoSystem/features/admin/product/cubit/attribute_value_cubit/attribute_value_cubit.dart';
import 'package:GoSystem/features/admin/product/cubit/attribute_value_cubit/attribute_value_state.dart';
import 'package:GoSystem/features/admin/product/models/attribute_type_model.dart';
import 'package:GoSystem/features/admin/product/models/attribute_value_model.dart';
import 'package:GoSystem/features/admin/product/models/product_attribute_model.dart';
import 'package:GoSystem/features/admin/product/models/selected_attribute_model.dart';
import 'package:GoSystem/features/pos/home/model/pos_models.dart';

/// Represents the attribute selection state for a single bundle product
class _BundleProductAttributeState {
  final String productId;
  final String productName;
  final List<ProductAttribute> productAttributes;
  // attributeTypeId → selected attributeValueId
  final Map<String, String> selectedValues;
  // attributeTypeId → list of available AttributeValue objects
  final Map<String, List<AttributeValue>> availableValues;
  // attributeTypeId → AttributeType
  final Map<String, AttributeType> attributeTypes;

  _BundleProductAttributeState({
    required this.productId,
    required this.productName,
    required this.productAttributes,
    Map<String, String>? selectedValues,
    Map<String, List<AttributeValue>>? availableValues,
    Map<String, AttributeType>? attributeTypes,
  })  : selectedValues = selectedValues ?? {},
        availableValues = availableValues ?? {},
        attributeTypes = attributeTypes ?? {};

  bool get isComplete =>
      attributeTypes.keys.every((id) => selectedValues.containsKey(id));

  List<SelectedAttribute> buildSelectedAttributes() {
    return selectedValues.entries.map((entry) {
      final typeId = entry.key;
      final valueId = entry.value;
      final type = attributeTypes[typeId]!;
      final value =
          availableValues[typeId]!.firstWhere((v) => v.id == valueId);
      return SelectedAttribute(
        attributeTypeId: typeId,
        attributeValueId: valueId,
        attributeTypeName: type.name,
        attributeTypeArName: type.arName,
        attributeValueName: value.name,
        attributeValueArName: value.arName,
      );
    }).toList();
  }
}

/// Dialog that lets the cashier select attributes for each product in a bundle.
/// Products without attributes are skipped (no selection needed).
/// Returns a map of productId → List<SelectedAttribute> via [onAttributesSelected].
class BundleAttributeSelectionDialog extends StatefulWidget {
  final BundleModel bundle;
  final ValueChanged<Map<String, List<SelectedAttribute>>> onAttributesSelected;

  const BundleAttributeSelectionDialog({
    required this.bundle,
    required this.onAttributesSelected,
    super.key,
  });

  @override
  State<BundleAttributeSelectionDialog> createState() =>
      _BundleAttributeSelectionDialogState();
}

class _BundleAttributeSelectionDialogState
    extends State<BundleAttributeSelectionDialog> {
  // productId → state
  final Map<String, _BundleProductAttributeState> _productStates = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAllAttributes();
  }

  Future<void> _loadAllAttributes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      for (final bundleProduct in widget.bundle.products) {
        // Only process products that have attributes assigned
        final attrs = bundleProduct.attributes;
        if (attrs.isEmpty) continue;

        final productState = _BundleProductAttributeState(
          productId: bundleProduct.productId,
          productName: bundleProduct.name,
          productAttributes: attrs,
        );

        for (final productAttr in attrs) {
          if (productAttr.attributeType != null) {
            productState.attributeTypes[productAttr.attributeTypeId] =
                productAttr.attributeType!;

            // Load values for this attribute type
            await AttributeValueCubit.get(context)
                .loadAttributeValues(productAttr.attributeTypeId);

            final valueState = AttributeValueCubit.get(context).state;
            if (valueState is AttributeValueLoaded) {
              productState.availableValues[productAttr.attributeTypeId] =
                  valueState.attributeValues
                      .where((v) =>
                          productAttr.attributeValueIds.contains(v.id))
                      .toList();
            }
          }
        }

        _productStates[bundleProduct.productId] = productState;
      }
    } catch (e) {
      _error = 'Failed to load attributes: $e';
      debugPrint('BundleAttributeSelectionDialog error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  bool get _allProductsComplete {
    if (_productStates.isEmpty) return true;
    return _productStates.values.every((s) => s.isComplete);
  }

  void _handleAddToCart() {
    if (!_allProductsComplete) return;

    final result = <String, List<SelectedAttribute>>{};
    for (final entry in _productStates.entries) {
      result[entry.key] = entry.value.buildSelectedAttributes();
    }

    widget.onAttributesSelected(result);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(ResponsiveUI.borderRadius(context, 20)),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 540, maxHeight: 720),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            if (_isLoading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              Expanded(child: _buildError())
            else if (_productStates.isEmpty)
              Expanded(child: _buildNoAttributes())
            else
              Expanded(child: _buildProductList()),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 20)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryBlue, AppColors.darkBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft:
              Radius.circular(ResponsiveUI.borderRadius(context, 20)),
          topRight:
              Radius.circular(ResponsiveUI.borderRadius(context, 20)),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.redeem,
              color: AppColors.white,
              size: ResponsiveUI.iconSize(context, 32)),
          SizedBox(width: ResponsiveUI.value(context, 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.bundle.name,
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 18),
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                SizedBox(height: ResponsiveUI.value(context, 4)),
                Text(
                  'Select attributes for bundle products',
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 13),
                    color: AppColors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: AppColors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUI.padding(context, 20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                color: AppColors.red,
                size: ResponsiveUI.iconSize(context, 48)),
            SizedBox(height: ResponsiveUI.value(context, 12)),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 14),
                color: AppColors.darkGray,
              ),
            ),
            SizedBox(height: ResponsiveUI.value(context, 16)),
            ElevatedButton(
              onPressed: _loadAllAttributes,
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue),
              child: Text('Retry',
                  style: TextStyle(color: AppColors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoAttributes() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUI.padding(context, 20)),
        child: Text(
          'No attribute selection required for this bundle.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 15),
            color: AppColors.darkGray,
          ),
        ),
      ),
    );
  }

  Widget _buildProductList() {
    return ListView.builder(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
      itemCount: _productStates.length,
      itemBuilder: (context, index) {
        final state = _productStates.values.elementAt(index);
        return _buildProductSection(state);
      },
    );
  }

  Widget _buildProductSection(_BundleProductAttributeState state) {
    final isComplete = state.isComplete;
    return Container(
      margin:
          EdgeInsets.only(bottom: ResponsiveUI.padding(context, 16)),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(
          color: isComplete
              ? AppColors.successGreen
              : AppColors.lightGray,
          width: isComplete ? 2 : 1,
        ),
        borderRadius:
            BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
        boxShadow: isComplete
            ? [
                BoxShadow(
                  color:
                      AppColors.successGreen.withValues(alpha: 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product header
          Container(
            padding: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
            decoration: BoxDecoration(
              color: isComplete
                  ? AppColors.successGreen.withValues(alpha: 0.06)
                  : AppColors.lightBlueBackground,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(
                    ResponsiveUI.borderRadius(context, 12)),
                topRight: Radius.circular(
                    ResponsiveUI.borderRadius(context, 12)),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: ResponsiveUI.iconSize(context, 18),
                  color: isComplete
                      ? AppColors.successGreen
                      : AppColors.primaryBlue,
                ),
                SizedBox(width: ResponsiveUI.value(context, 8)),
                Expanded(
                  child: Text(
                    state.productName,
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 14),
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkGray,
                    ),
                  ),
                ),
                if (isComplete)
                  Icon(
                    Icons.check_circle,
                    size: ResponsiveUI.iconSize(context, 20),
                    color: AppColors.successGreen,
                  ),
              ],
            ),
          ),

          // Attribute type selectors for this product
          Padding(
            padding:
                EdgeInsets.all(ResponsiveUI.padding(context, 12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: state.attributeTypes.keys.map((typeId) {
                return _buildAttributeTypeSection(state, typeId);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttributeTypeSection(
      _BundleProductAttributeState productState, String typeId) {
    final type = productState.attributeTypes[typeId]!;
    final values = productState.availableValues[typeId] ?? [];
    final selectedValueId = productState.selectedValues[typeId];

    return Padding(
      padding:
          EdgeInsets.only(bottom: ResponsiveUI.padding(context, 12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.tune,
                size: ResponsiveUI.iconSize(context, 14),
                color: AppColors.linkBlue,
              ),
              SizedBox(width: ResponsiveUI.value(context, 6)),
              Text(
                type.name,
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 13),
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkGray,
                ),
              ),
              if (type.arName.isNotEmpty) ...[
                SizedBox(width: ResponsiveUI.value(context, 6)),
                Text(
                  '(${type.arName})',
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 11),
                    color: AppColors.linkBlue,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: ResponsiveUI.value(context, 8)),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: values.map((value) {
              final isSelected = selectedValueId == value.id;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    productState.selectedValues[typeId] = value.id;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUI.padding(context, 14),
                    vertical: ResponsiveUI.padding(context, 8),
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryBlue
                        : AppColors.lightBlueBackground,
                    borderRadius: BorderRadius.circular(
                        ResponsiveUI.borderRadius(context, 8)),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryBlue
                          : AppColors.lightGray,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primaryBlue
                                  .withValues(alpha: 0.25),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected)
                        Padding(
                          padding: EdgeInsets.only(
                              right: ResponsiveUI.padding(context, 5)),
                          child: Icon(
                            Icons.check,
                            size: ResponsiveUI.iconSize(context, 14),
                            color: AppColors.white,
                          ),
                        ),
                      Text(
                        value.name,
                        style: TextStyle(
                          fontSize: ResponsiveUI.fontSize(context, 13),
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isSelected
                              ? AppColors.white
                              : AppColors.darkGray,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 20)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          bottomLeft:
              Radius.circular(ResponsiveUI.borderRadius(context, 20)),
          bottomRight:
              Radius.circular(ResponsiveUI.borderRadius(context, 20)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Validation message
          if (!_isLoading && !_allProductsComplete && _productStates.isNotEmpty)
            Container(
              margin: EdgeInsets.only(
                  bottom: ResponsiveUI.padding(context, 12)),
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
              decoration: BoxDecoration(
                color: AppColors.warningOrange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(
                    ResponsiveUI.borderRadius(context, 8)),
                border: Border.all(color: AppColors.warningOrange),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      size: ResponsiveUI.iconSize(context, 18),
                      color: AppColors.warningOrange),
                  SizedBox(width: ResponsiveUI.value(context, 8)),
                  Expanded(
                    child: Text(
                      'Please select all required attributes to continue',
                      style: TextStyle(
                        fontSize: ResponsiveUI.fontSize(context, 12),
                        color: AppColors.warningOrange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                        vertical: ResponsiveUI.padding(context, 14)),
                    side: BorderSide(
                        color: AppColors.lightGray,
                        width: ResponsiveUI.value(context, 1.5)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          ResponsiveUI.borderRadius(context, 12)),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 15),
                      color: AppColors.darkGray,
                    ),
                  ),
                ),
              ),
              SizedBox(width: ResponsiveUI.value(context, 12)),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _allProductsComplete ? _handleAddToCart : null,
                  icon: Icon(
                    Icons.shopping_cart,
                    size: ResponsiveUI.iconSize(context, 20),
                    color: _allProductsComplete
                        ? AppColors.white
                        : AppColors.darkGray,
                  ),
                  label: Text(
                    'Add Bundle to Cart',
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 15),
                      fontWeight: FontWeight.bold,
                      color: _allProductsComplete
                          ? AppColors.white
                          : AppColors.darkGray,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                        vertical: ResponsiveUI.padding(context, 14)),
                    backgroundColor: AppColors.primaryBlue,
                    disabledBackgroundColor: AppColors.lightGray,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          ResponsiveUI.borderRadius(context, 12)),
                    ),
                    elevation: _allProductsComplete ? 2 : 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
