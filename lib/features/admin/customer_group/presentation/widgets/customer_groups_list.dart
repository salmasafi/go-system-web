import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/custom_snack_bar/custom_snackbar.dart';
import 'package:systego/features/admin/customer/cubit/customer_cubit.dart';
import 'package:systego/features/admin/customer_group/presentation/widgets/customer_group_animated_card.dart';
import 'package:systego/features/admin/customer_group/presentation/widgets/customer_group_form_dialog.dart';
import 'package:systego/features/admin/warehouses/view/widgets/custom_delete_dialog.dart';
import 'package:systego/generated/locale_keys.g.dart';

import '../../model/customer_group_model.dart';

class CustomerGroupList extends StatelessWidget {
  final List<CustomerGroup> customerGroups;
  const CustomerGroupList({super.key, required this.customerGroups});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.only(
        right: ResponsiveUI.padding(context, 16),
        left: ResponsiveUI.padding(context, 16),
        top: ResponsiveUI.padding(context, 16),
      ),
      itemCount: customerGroups.length,
      itemBuilder: (context, index) {
        return AnimatedCustomerGroupCard(
          customerGroup: customerGroups[index],
          index: index,
          onDelete: () => _showDeleteDialog(context, customerGroups[index]),
          onEdit: () => _showEditDialog(context, customerGroups[index]),
        );
      },
    );
  }


    void _showEditDialog(BuildContext context, CustomerGroup group) {
    showDialog(
      context: context,
      builder: (context) => CustomerGroupFormDialog(customerGroup: group),
    );
  }

  void _showDeleteDialog(BuildContext context, CustomerGroup group) {
    if (group.id.isEmpty) {
      CustomSnackbar.showError(context, LocaleKeys.invalid_group_id.tr());
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => CustomDeleteDialog(
        title: LocaleKeys.delete_group.tr(),
        message:
            '${LocaleKeys.delete_group_message.tr()} \n"${group.name}"',
        onDelete: () {
          Navigator.pop(dialogContext);
          context.read<CustomerCubit>().deleteCustomerGroup(group.id);
        },
      ),
    );
  }

}
