import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/attribute_type_cubit/attribute_type_cubit.dart';
import '../../cubit/attribute_type_cubit/attribute_type_state.dart';

class DeleteAttributeTypeDialog extends StatelessWidget {
  final String attributeTypeName;
  final VoidCallback onDelete;

  const DeleteAttributeTypeDialog({
    super.key,
    required this.attributeTypeName,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Attribute Type'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Are you sure you want to delete this attribute type?'),
          const SizedBox(height: 8),
          Text(
            'Name: $attributeTypeName',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            'Warning: This will also delete all associated attribute values and remove them from products.',
            style: TextStyle(color: Colors.orange, fontSize: 12),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        BlocBuilder<AttributeTypeCubit, AttributeTypeState>(
          builder: (context, state) {
            final isLoading = state is AttributeTypeDeleting;
            return ElevatedButton(
              onPressed: isLoading ? null : onDelete,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
