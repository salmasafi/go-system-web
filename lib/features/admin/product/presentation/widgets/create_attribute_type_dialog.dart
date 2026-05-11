import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../cubit/attribute_type_cubit/attribute_type_cubit.dart';
import '../../cubit/attribute_type_cubit/attribute_type_state.dart';
import '../../models/attribute_type_model.dart';

class CreateAttributeTypeDialog extends StatefulWidget {
  final AttributeType? attributeType;

  const CreateAttributeTypeDialog({super.key, this.attributeType});

  @override
  State<CreateAttributeTypeDialog> createState() =>
      _CreateAttributeTypeDialogState();
}

class _CreateAttributeTypeDialogState extends State<CreateAttributeTypeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _status = true;

  @override
  void initState() {
    super.initState();
    if (widget.attributeType != null) {
      _nameController.text = widget.attributeType!.name;
      _status = widget.attributeType!.status;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (widget.attributeType == null) {
        AttributeTypeCubit.get(context).createAttributeType(
          name: _nameController.text.trim(),
          status: _status,
        );
      } else {
        AttributeTypeCubit.get(context).updateAttributeType(
          id: widget.attributeType!.id,
          name: _nameController.text.trim(),
          status: _status,
        );
      }
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.attributeType != null;

    return AlertDialog(
      title: Text(isEditing ? 'edit_attribute_type'.tr() : 'create_attribute_type'.tr()),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'name'.tr(),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'please_enter_name'.tr();
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('${'status_label'.tr()}:'),
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
          child: Text('cancel'.tr()),
        ),
        BlocBuilder<AttributeTypeCubit, AttributeTypeState>(
          builder: (context, state) {
            final isLoading =
                state is AttributeTypeCreating ||
                state is AttributeTypeUpdating;
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
                  : Text(isEditing ? 'update'.tr() : 'create'.tr()),
            );
          },
        ),
      ],
    );
  }
}
