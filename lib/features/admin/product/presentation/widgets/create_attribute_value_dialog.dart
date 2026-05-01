import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../cubit/attribute_value_cubit/attribute_value_cubit.dart';
import '../../cubit/attribute_value_cubit/attribute_value_state.dart';
import '../../models/attribute_value_model.dart';

class CreateAttributeValueDialog extends StatefulWidget {
  final String attributeTypeId;
  final AttributeValue? attributeValue;

  const CreateAttributeValueDialog({
    super.key,
    required this.attributeTypeId,
    this.attributeValue,
  });

  @override
  State<CreateAttributeValueDialog> createState() =>
      _CreateAttributeValueDialogState();
}

class _CreateAttributeValueDialogState
    extends State<CreateAttributeValueDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _arNameController = TextEditingController();
  bool _status = true;

  @override
  void initState() {
    super.initState();
    if (widget.attributeValue != null) {
      _nameController.text = widget.attributeValue!.name;
      _arNameController.text = widget.attributeValue!.arName;
      _status = widget.attributeValue!.status;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _arNameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (widget.attributeValue == null) {
        AttributeValueCubit.get(context).createAttributeValue(
          attributeTypeId: widget.attributeTypeId,
          name: _nameController.text.trim(),
          arName: _arNameController.text.trim(),
          status: _status,
        );
      } else {
        AttributeValueCubit.get(context).updateAttributeValue(
          id: widget.attributeValue!.id,
          name: _nameController.text.trim(),
          arName: _arNameController.text.trim(),
          status: _status,
        );
      }
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.attributeValue != null;

    return AlertDialog(
      title: Text(
        isEditing ? 'Edit Attribute Value' : 'Create Attribute Value',
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Value (English)',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a value';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _arNameController,
              decoration: const InputDecoration(
                labelText: 'Value (Arabic)',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter an Arabic value';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Status:'),
                const Spacer(),
                Switch(
                  value: _status,
                  onChanged: (value) {
                    setState(() {
                      _status = value;
                    });
                  },
                  activeColor: AppColors.primaryBlue,
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        BlocBuilder<AttributeValueCubit, AttributeValueState>(
          builder: (context, state) {
            final isLoading =
                state is AttributeValueCreating ||
                state is AttributeValueUpdating;
            return ElevatedButton(
              onPressed: isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(isEditing ? 'Update' : 'Create'),
            );
          },
        ),
      ],
    );
  }
}
