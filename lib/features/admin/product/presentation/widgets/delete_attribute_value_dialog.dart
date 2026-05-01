import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../cubit/attribute_value_cubit/attribute_value_cubit.dart';
import '../../cubit/attribute_value_cubit/attribute_value_state.dart';

class DeleteAttributeValueDialog extends StatelessWidget {
  final String attributeValueName;
  final VoidCallback onDelete;

  const DeleteAttributeValueDialog({
    super.key,
    required this.attributeValueName,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Attribute Value'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Are you sure you want to delete this attribute value?'),
          const SizedBox(height: 8),
          Text(
            'Value: $attributeValueName',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            'Warning: This will remove the value from all products that use it.',
            style: TextStyle(
              color: Colors.orange,
              fontSize: 12,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        BlocBuilder<AttributeValueCubit, AttributeValueState>(
          builder: (context, state) {
            final isLoading = state is AttributeValueDeleting;
            return ElevatedButton(
              onPressed: isLoading ? null : onDelete,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
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
                  : const Text('Delete'),
            );
          },
        ),
      ],
    );
  }
}
