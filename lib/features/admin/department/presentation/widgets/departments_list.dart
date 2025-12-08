import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/features/admin/department/cubit/department_cubit.dart';
import 'package:systego/features/admin/department/model/department_model.dart';
import 'package:systego/generated/locale_keys.g.dart';
import '../../../../../core/widgets/custom_snack_bar/custom_snackbar.dart';
import '../../../warehouses/view/widgets/custom_delete_dialog.dart';
import 'animated_department_card.dart';
import 'department_form_dialog.dart';

class DepartmentsList extends StatelessWidget {
  final List<DepartmentModel> departments;
  const DepartmentsList({super.key, required this.departments});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.only(
        right: ResponsiveUI.padding(context, 16),
        left: ResponsiveUI.padding(context, 16),
        top: ResponsiveUI.padding(context, 16),
      ),
      itemCount: departments.length,
      itemBuilder: (context, index) {
        return AnimatedDepartmentCard(
          department: departments[index],
          index: index,
          onDelete: () => _showDeleteDialog(context, departments[index]),
          onEdit: () => _showEditDialog(context, departments[index]),
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, DepartmentModel department) {
    showDialog(
      context: context,
      builder: (context) => DepartmentFormDialog(department: department),
    );
  }

  void _showDeleteDialog(BuildContext context, DepartmentModel department) {
    if (department.id.isEmpty) {
      CustomSnackbar.showError(context, LocaleKeys.invalid_department_id.tr());
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => CustomDeleteDialog(
        title: LocaleKeys.delete_department_title.tr(),
        message:
            '${LocaleKeys.delete_department_message.tr()} \n"${department.name}"',
        onDelete: () {
          Navigator.pop(dialogContext);
          context.read<DepartmentCubit>().deleteDepartment(department.id);
        },
      ),
    );
  }

}
