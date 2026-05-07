import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      title: const Text('حذف نوع الخاصية'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('هل أنت متأكد أنك تريد حذف نوع الخاصية هذا؟'),
          const SizedBox(height: 8),
          Text(
            'الاسم: $attributeTypeName',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            'تحذير: سيؤدي هذا أيضاً إلى حذف جميع قيم الخصائص المرتبطة وإزالتها من المنتجات.',
            style: TextStyle(color: AppColors.warningOrange, fontSize: 12),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
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
                  : const Text('حذف'),
            );
          },
        ),
      ],
    );
  }
}
