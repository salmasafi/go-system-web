import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
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
      title: Text('delete_attribute_type_title'.tr()),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('delete_attribute_type_msg'.tr()),
          const SizedBox(height: 8),
          Text(
            'name_with_value'.tr(namedArgs: {'name': attributeTypeName}),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'delete_attribute_type_warning'.tr(),
            style: const TextStyle(color: AppColors.warningOrange, fontSize: 12),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('cancel'.tr()),
        ),
        BlocBuilder<AttributeTypeCubit, AttributeTypeState>(
          builder: (context, state) {
            final isLoading = state is AttributeTypeDeleting;
            return ElevatedButton(
              onPressed: isLoading ? null : onDelete,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text('delete'.tr()),
            );
          },
        ),
      ],
    );
  }
}
