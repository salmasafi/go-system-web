import 'package:flutter/material.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:GoSystem/features/admin/product/cubit/attribute_type_cubit/attribute_type_cubit.dart';
import 'package:GoSystem/features/admin/product/cubit/attribute_value_cubit/attribute_value_cubit.dart';
import 'package:GoSystem/features/admin/product/cubit/attribute_value_cubit/attribute_value_state.dart';
import 'package:GoSystem/features/admin/product/models/attribute_type_model.dart';
import 'package:GoSystem/features/admin/product/models/attribute_value_model.dart';
import 'package:GoSystem/features/admin/product/models/selected_attribute_model.dart';
import 'package:GoSystem/features/pos/home/model/pos_models.dart';

class AttributeSelectionDialog extends StatefulWidget {
  final Product product;
  final ValueChanged<List<SelectedAttribute>> onAttributesSelected;

  const AttributeSelectionDialog({
    required this.product,
    required this.onAttributesSelected,
    super.key,
  });

  @override
  State<AttributeSelectionDialog> createState() => _AttributeSelectionDialogState();
}

class _AttributeSelectionDialogState extends State<AttributeSelectionDialog> {
  final Map<String, String> _selectedValues = {}; // attributeTypeId -> attributeValueId
  final Map<String, AttributeType> _attributeTypes = {};
  final Map<String, List<AttributeValue>> _attributeValues = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAttributes();
  }

  Future<void> _loadAttributes() async {
    setState(() => _isLoading = true);

    try {
      // Load attribute types
      await AttributeTypeCubit.get(context).loadAttributeTypes();
      if (!mounted) return;

      // Get product attributes from the product model
      final productAttributes = widget.product.attributes;
      
      if (productAttributes.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      // Load attribute values for each type
      for (final productAttr in productAttributes) {
        if (productAttr.attributeType != null) {
          _attributeTypes[productAttr.attributeTypeId] = productAttr.attributeType!;
          
          // Load values for this type
          await AttributeValueCubit.get(context).loadAttributeValues(productAttr.attributeTypeId);
          if (!mounted) return;

          // Get the loaded values
          final valueState = AttributeValueCubit.get(context).state;
          if (valueState is AttributeValueLoaded) {
            // Filter to only include values that are in the product's available values
            _attributeValues[productAttr.attributeTypeId] = valueState.attributeValues
                .where((v) => productAttr.attributeValueIds.contains(v.id))
                .toList();
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading attributes: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  bool get _allAttributesSelected {
    return _attributeTypes.keys.every((typeId) => _selectedValues.containsKey(typeId));
  }

  void _handleAddToCart() {
    if (!_allAttributesSelected) return;

    final selectedAttributes = <SelectedAttribute>[];
    
    for (final entry in _selectedValues.entries) {
      final typeId = entry.key;
      final valueId = entry.value;
      
      final type = _attributeTypes[typeId];
      final value = _attributeValues[typeId]?.firstWhere((v) => v.id == valueId);
      
      if (type != null && value != null) {
        selectedAttributes.add(SelectedAttribute(
          attributeTypeId: typeId,
          attributeValueId: valueId,
          attributeTypeName: type.name,
          attributeTypeArName: type.arName,
          attributeValueName: value.name,
          attributeValueArName: value.arName,
        ));
      }
    }

    widget.onAttributesSelected(selectedAttributes);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 20)),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            if (_isLoading)
              Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primaryBlue),
                ),
              )
            else if (_attributeTypes.isEmpty)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(ResponsiveUI.padding(context, 20)),
                    child: Text(
                      'No attributes available for this product',
                      style: TextStyle(
                        fontSize: ResponsiveUI.fontSize(context, 16),
                        color: AppColors.darkGray,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              )
            else
              Expanded(child: _buildAttributesList()),
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
          colors: [AppColors.successGreen, AppColors.successGreen.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(ResponsiveUI.borderRadius(context, 20)),
          topRight: Radius.circular(ResponsiveUI.borderRadius(context, 20)),
        ),
      ),
      child: Row(
        children: [
          if (widget.product.image != null)
            Container(
              width: ResponsiveUI.value(context, 60),
              height: ResponsiveUI.value(context, 60),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
                color: AppColors.white,
                image: DecorationImage(
                  image: NetworkImage(widget.product.image!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          if (widget.product.image != null) SizedBox(width: ResponsiveUI.value(context, 16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.name,
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 20),
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                SizedBox(height: ResponsiveUI.value(context, 4)),
                Text(
                  'Select product attributes',
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 14),
                    color: AppColors.white.withValues(alpha: 0.9),
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

  Widget _buildAttributesList() {
    return ListView.builder(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
      itemCount: _attributeTypes.length,
      itemBuilder: (context, index) {
        final typeId = _attributeTypes.keys.elementAt(index);
        final type = _attributeTypes[typeId]!;
        final values = _attributeValues[typeId] ?? [];
        final selectedValueId = _selectedValues[typeId];

        return Container(
          margin: EdgeInsets.only(bottom: ResponsiveUI.padding(context, 16)),
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border.all(
              color: selectedValueId != null ? AppColors.successGreen : AppColors.lightGray,
              width: selectedValueId != null ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
            boxShadow: selectedValueId != null
                ? [
                    BoxShadow(
                      color: AppColors.successGreen.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Attribute Type Header
              Container(
                padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
                decoration: BoxDecoration(
                  color: selectedValueId != null
                      ? AppColors.successGreen.withValues(alpha: 0.05)
                      : AppColors.lightBlueBackground,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(ResponsiveUI.borderRadius(context, 12)),
                    topRight: Radius.circular(ResponsiveUI.borderRadius(context, 12)),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.tune,
                      size: ResponsiveUI.iconSize(context, 20),
                      color: selectedValueId != null ? AppColors.successGreen : AppColors.primaryBlue,
                    ),
                    SizedBox(width: ResponsiveUI.value(context, 12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            type.name,
                            style: TextStyle(
                              fontSize: ResponsiveUI.fontSize(context, 16),
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkGray,
                            ),
                          ),
                          if (type.arName.isNotEmpty)
                            Text(
                              type.arName,
                              style: TextStyle(
                                fontSize: ResponsiveUI.fontSize(context, 14),
                                color: AppColors.linkBlue,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (selectedValueId != null)
                      Icon(
                        Icons.check_circle,
                        size: ResponsiveUI.iconSize(context, 24),
                        color: AppColors.successGreen,
                      ),
                  ],
                ),
              ),
              
              // Attribute Values
              Padding(
                padding: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: values.map((value) {
                    final isSelected = selectedValueId == value.id;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedValues[typeId] = value.id;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveUI.padding(context, 16),
                          vertical: ResponsiveUI.padding(context, 10),
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.successGreen
                              : AppColors.lightBlueBackground,
                          borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 10)),
                          border: Border.all(
                            color: isSelected ? AppColors.successGreen : AppColors.lightGray,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.successGreen.withValues(alpha: 0.3),
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
                                padding: EdgeInsets.only(right: ResponsiveUI.padding(context, 6)),
                                child: Icon(
                                  Icons.check,
                                  size: ResponsiveUI.iconSize(context, 16),
                                  color: AppColors.white,
                                ),
                              ),
                            Text(
                              value.name,
                              style: TextStyle(
                                fontSize: ResponsiveUI.fontSize(context, 14),
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                color: isSelected ? AppColors.white : AppColors.darkGray,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 20)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(ResponsiveUI.borderRadius(context, 20)),
          bottomRight: Radius.circular(ResponsiveUI.borderRadius(context, 20)),
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
        children: [
          // Validation message
          if (!_allAttributesSelected)
            Container(
              margin: EdgeInsets.only(bottom: ResponsiveUI.padding(context, 12)),
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
              decoration: BoxDecoration(
                color: AppColors.warningOrange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 8)),
                border: Border.all(color: AppColors.warningOrange),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: ResponsiveUI.iconSize(context, 20),
                    color: AppColors.warningOrange,
                  ),
                  SizedBox(width: ResponsiveUI.value(context, 8)),
                  Expanded(
                    child: Text(
                      'Please select all attributes to continue',
                      style: TextStyle(
                        fontSize: ResponsiveUI.fontSize(context, 13),
                        color: AppColors.warningOrange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: ResponsiveUI.padding(context, 16)),
                    side: BorderSide(color: AppColors.lightGray, width: ResponsiveUI.value(context, 2)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 16),
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkGray,
                    ),
                  ),
                ),
              ),
              SizedBox(width: ResponsiveUI.value(context, 16)),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _allAttributesSelected ? _handleAddToCart : null,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: ResponsiveUI.padding(context, 16)),
                    backgroundColor: AppColors.successGreen,
                    disabledBackgroundColor: AppColors.lightGray,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
                    ),
                    elevation: _allAttributesSelected ? 2 : 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart,
                        size: ResponsiveUI.iconSize(context, 20),
                        color: _allAttributesSelected ? AppColors.white : AppColors.darkGray,
                      ),
                      SizedBox(width: ResponsiveUI.value(context, 8)),
                      Text(
                        'Add to Cart',
                        style: TextStyle(
                          fontSize: ResponsiveUI.fontSize(context, 16),
                          fontWeight: FontWeight.bold,
                          color: _allAttributesSelected ? AppColors.white : AppColors.darkGray,
                        ),
                      ),
                    ],
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
