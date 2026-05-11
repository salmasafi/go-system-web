import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
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
      title: Text('delete_attribute_value_title'.tr()),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('delete_attribute_value_msg'.tr()),
          const SizedBox(height: 8),
          Text(
            'value_label'.tr(namedArgs: {'value': attributeValueName}),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'delete_attribute_value_warning'.tr(),
            style: const TextStyle(color: AppColors.warningOrange, fontSize: 12),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('cancel'.tr()),
        ),
        BlocBuilder<AttributeValueCubit, AttributeValueState>(
          builder: (context, state) {
            final isLoading = state is AttributeValueDeleting;
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
