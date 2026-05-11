import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import '../../cubit/attribute_type_cubit/attribute_type_cubit.dart';
import '../../cubit/attribute_type_cubit/attribute_type_state.dart';
import '../../cubit/attribute_value_cubit/attribute_value_cubit.dart';
import '../../cubit/attribute_value_cubit/attribute_value_state.dart';
import '../../cubit/product_attribute_cubit/product_attribute_cubit.dart';
import '../../cubit/product_attribute_cubit/product_attribute_state.dart';
import '../../models/attribute_type_model.dart';
import '../../models/attribute_value_model.dart';
import '../../models/product_attribute_model.dart';

class ProductAttributeAssignmentWidget extends StatefulWidget {
  final String productId;

  const ProductAttributeAssignmentWidget({
    super.key,
    required this.productId,
  });

  @override
  State<ProductAttributeAssignmentWidget> createState() => _ProductAttributeAssignmentWidgetState();
}

class _ProductAttributeAssignmentWidgetState extends State<ProductAttributeAssignmentWidget> {
  final Map<String, List<String>> _selectedAttributeValues = {}; // attributeTypeId -> selected value IDs

  @override
  void initState() {
    super.initState();
    AttributeTypeCubit.get(context).loadAttributeTypes();
    ProductAttributeCubit.get(context).loadProductAttributes(widget.productId);
  }

  void _loadValuesForType(String attributeTypeId) {
    AttributeValueCubit.get(context).loadAttributeValues(attributeTypeId);
  }

  void _toggleAttributeValue(String attributeTypeId, String valueId) {
    setState(() {
      if (!_selectedAttributeValues.containsKey(attributeTypeId)) {
        _selectedAttributeValues[attributeTypeId] = [];
      }
      if (_selectedAttributeValues[attributeTypeId]!.contains(valueId)) {
        _selectedAttributeValues[attributeTypeId]!.remove(valueId);
      } else {
        _selectedAttributeValues[attributeTypeId]!.add(valueId);
      }
    });
  }

  Future<void> _saveAttributes() async {
    for (final entry in _selectedAttributeValues.entries) {
      if (entry.value.isNotEmpty) {
        await ProductAttributeCubit.get(context).assignAttributeToProduct(
          productId: widget.productId,
          attributeTypeId: entry.key,
          attributeValueIds: entry.value,
        );
      }
    }
  }

  Future<void> _removeAttribute(String productAttributeId) async {
    await ProductAttributeCubit.get(context).removeAttributeFromProduct(productAttributeId);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BlocBuilder<ProductAttributeCubit, ProductAttributeState>(
          builder: (context, state) {
            if (state is ProductAttributeLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final currentAttributes = state is ProductAttributeLoaded
                ? state.productAttributes
                : <ProductAttribute>[];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (currentAttributes.isNotEmpty) ...[
                  Text(
                    'current_attributes'.tr(),
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 18),
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGray,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...currentAttributes.map((attr) => _buildCurrentAttributeCard(attr)),
                  const SizedBox(height: 24),
                ],
                Text(
                  'assign_new_attributes'.tr(),
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 18),
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGray,
                  ),
                ),
                const SizedBox(height: 12),
                  BlocBuilder<AttributeTypeCubit, AttributeTypeState>(
                    builder: (context, state) {
                      if (state is AttributeTypeLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final attributeTypes = state is AttributeTypeLoaded
                          ? state.attributeTypes
                          : <AttributeType>[];

                      if (attributeTypes.isEmpty) {
                        return Text('no_attribute_types_available'.tr());
                      }

                      return Column(
                        children: attributeTypes.map((type) {
                          return _buildAttributeTypeSelector(type, currentAttributes);
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _selectedAttributeValues.values.any((list) => list.isNotEmpty)
                        ? _saveAttributes
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                    ),
                    child: Text('save_attributes'.tr()),
                  ),
                ],
              );
          },
        ),
      ],
    );
  }

  Widget _buildCurrentAttributeCard(ProductAttribute attr) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    attr.attributeType?.name ?? 'unknown'.tr(),
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 16),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'values_selected_count'.tr(namedArgs: {'count': attr.attributeValueIds.length.toString()}),
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 14),
                      color: AppColors.linkBlue,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.red),
              onPressed: () => _removeAttribute(attr.id),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttributeTypeSelector(AttributeType type, List<ProductAttribute> currentAttributes) {
    final isAssigned = currentAttributes.any((attr) => attr.attributeTypeId == type.id);

    if (isAssigned) {
      return const SizedBox.shrink(); // Already assigned, don't show in new assignment
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(type.name),
        onExpansionChanged: (expanded) {
          if (expanded) {
            _loadValuesForType(type.id);
          }
        },
        children: [
          BlocBuilder<AttributeValueCubit, AttributeValueState>(
            builder: (context, state) {
              if (state is AttributeValueLoading) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final values = state is AttributeValueLoaded
                  ? state.attributeValues
                  : <AttributeValue>[];

              if (values.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('no_values_for_attribute_type'.tr()),
                );
              }

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: values.map((value) {
                    final isSelected = _selectedAttributeValues[type.id]?.contains(value.id) ?? false;
                    return CheckboxListTile(
                      title: Text(value.name),
                      value: isSelected,
                      onChanged: (_) => _toggleAttributeValue(type.id, value.id),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
