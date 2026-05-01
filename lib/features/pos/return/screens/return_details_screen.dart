import 'package:systego/core/utils/responsive_ui.dart';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/widgets/custom_snack_bar/custom_snackbar.dart';
import 'package:systego/features/pos/home/cubit/pos_home_cubit.dart';
import 'package:systego/features/pos/return/cubit/return_cubit.dart';
import 'package:systego/features/pos/return/widgets/return_items_table.dart';
import 'package:systego/features/admin/reason/cubit/reason_cubit.dart';

class ReturnDetailsScreen extends StatefulWidget {
  const ReturnDetailsScreen({super.key});

  @override
  State<ReturnDetailsScreen> createState() => _ReturnDetailsScreenState();
}

class _ReturnDetailsScreenState extends State<ReturnDetailsScreen> {
  final _noteController = TextEditingController();
  File? _attachedFile;
  String? _attachedFileName;

  @override
  void initState() {
    super.initState();
    // Load reasons for the dropdown
    context.read<ReasonCubit>().getReasons();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _attachedFile = File(result.files.single.path!);
        _attachedFileName = result.files.single.name;
      });
    }
  }

  void _removeFile() {
    setState(() {
      _attachedFile = null;
      _attachedFileName = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReturnCubit, ReturnState>(
      listener: (context, state) {
        if (state is ReturnSubmitSuccess) {
          Navigator.of(context).pop();
          CustomSnackbar.showSuccess(context, 'return_success'.tr());
          context.read<ReturnCubit>().reset();
        }
      },
      builder: (context, state) {
        if (state is! ReturnSaleLoaded &&
            state is! ReturnSubmitting &&
            state is! ReturnSubmitError) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final sale = state is ReturnSaleLoaded
            ? state.sale
            : state is ReturnSubmitting
            ? state.sale
            : (state as ReturnSubmitError).sale;

        final items = state is ReturnSaleLoaded
            ? state.items
            : state is ReturnSubmitting
            ? state.items
            : (state as ReturnSubmitError).items;

        final isSubmitting = state is ReturnSubmitting;
        final errorMsg = state is ReturnSubmitError ? state.message : null;

        return Scaffold(
          backgroundColor: const Color(0xFFF4F6FB),
          appBar: AppBar(
            title: Text(
              'return_sale'.tr(),
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: ResponsiveUI.fontSize(context, 18),
              ),
            ),
            backgroundColor: AppColors.white,
            foregroundColor: AppColors.darkGray,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                height: ResponsiveUI.value(context, 1),
                color: AppColors.lightGray,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SaleInfoCard(sale: sale),
                SizedBox(height: ResponsiveUI.value(context, 16)),
                _SectionLabel(label: 'product'.tr()),
                SizedBox(height: ResponsiveUI.value(context, 8)),
                ReturnItemsTable(items: items, disabled: isSubmitting),
                SizedBox(height: ResponsiveUI.value(context, 16)),
                // ── Attach Document ──
                _SectionLabel(label: 'attach_document'.tr()),
                SizedBox(height: ResponsiveUI.value(context, 8)),
                _AttachFileWidget(
                  fileName: _attachedFileName,
                  disabled: isSubmitting,
                  onPick: _pickFile,
                  onRemove: _removeFile,
                ),
                SizedBox(height: ResponsiveUI.value(context, 16)),
                _SectionLabel(label: 'return_note'.tr()),
                SizedBox(height: ResponsiveUI.value(context, 8)),
                _NoteField(controller: _noteController, enabled: !isSubmitting),
                if (errorMsg != null) ...[
                  SizedBox(height: ResponsiveUI.value(context, 10)),
                  _ErrorBanner(message: errorMsg),
                ],
                SizedBox(height: ResponsiveUI.value(context, 20)),
                _ActionButtons(
                  isSubmitting: isSubmitting,
                  onCancel: () => _cancelReturn(context),
                  onSubmit: () => _submit(context),
                ),
                SizedBox(height: ResponsiveUI.value(context, 16)),
              ],
            ),
          ),
        );
      },
    );
  }

  void _cancelReturn(BuildContext context) {
    context.read<ReturnCubit>().reset();
    Navigator.of(context).pop();
  }

  void _submit(BuildContext context) {
    final accountId = context.read<PosCubit>().selectedAccount?.id ?? '';
    if (accountId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('select_at_least_one_item'.tr())));
      return;
    }
    context.read<ReturnCubit>().submitReturn(
      refundAccountId: accountId,
      note: _noteController.text,
      attachedFile: _attachedFile,
    );
  }
}

// ─── Attach File Widget ───────────────────────────────────────────────────────

class _AttachFileWidget extends StatelessWidget {
  final String? fileName;
  final bool disabled;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const _AttachFileWidget({
    required this.fileName,
    required this.disabled,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUI.padding(context, 14),
        vertical: ResponsiveUI.padding(context, 12),
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveUI.borderRadius(context, 12),
        ),
        border: Border.all(
          color: fileName != null
              ? AppColors.categoryPurple.withValues(alpha: 0.4)
              : const Color(0xFFDDDDDD),
          style: BorderStyle.solid,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            fileName != null ? Icons.attach_file : Icons.upload_file_outlined,
            color: fileName != null
                ? AppColors.categoryPurple
                : AppColors.shadowGray,
            size: ResponsiveUI.iconSize(context, 20),
          ),
          SizedBox(width: ResponsiveUI.value(context, 10)),
          Expanded(
            child: Text(
              fileName ?? 'attach_document_optional'.tr(),
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 13),
                color: fileName != null
                    ? AppColors.darkGray
                    : AppColors.shadowGray,
                fontWeight: fileName != null
                    ? FontWeight.w500
                    : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (fileName != null)
            GestureDetector(
              onTap: disabled ? null : onRemove,
              child: Icon(
                Icons.close,
                size: ResponsiveUI.iconSize(context, 18),
                color: AppColors.red,
              ),
            )
          else
            TextButton.icon(
              onPressed: disabled ? null : onPick,
              icon: Icon(
                Icons.folder_open_outlined,
                size: ResponsiveUI.iconSize(context, 16),
              ),
              label: Text(
                'choose_file'.tr(),
                style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 12)),
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.categoryPurple,
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUI.padding(context, 10),
                  vertical: ResponsiveUI.padding(context, 6),
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Sale Info Card ───────────────────────────────────────────────────────────

class _SaleInfoCard extends StatelessWidget {
  final dynamic sale;
  const _SaleInfoCard({required this.sale});

  @override
  Widget build(BuildContext context) {
    String formattedDate = sale.date;
    try {
      final dt = DateTime.parse(sale.date);
      formattedDate =
          '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}  '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {}

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveUI.borderRadius(context, 16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUI.padding(context, 16),
              vertical: ResponsiveUI.padding(context, 12),
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
              ),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(ResponsiveUI.borderRadius(context, 16)),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.receipt_long,
                  color: Colors.white,
                  size: ResponsiveUI.iconSize(context, 20),
                ),
                SizedBox(width: ResponsiveUI.value(context, 8)),
                Text(
                  '#${sale.reference}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: ResponsiveUI.fontSize(context, 16),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
            child: Column(
              children: [
                _InfoTile(
                  icon: Icons.calendar_today_outlined,
                  label: 'Date',
                  value: formattedDate,
                ),
                _Divider(),
                _InfoTile(
                  icon: Icons.person_outline,
                  label: 'Customer',
                  value: sale.displayCustomerName,
                ),
                if (sale.warehouseName.isNotEmpty) ...[
                  _Divider(),
                  _InfoTile(
                    icon: Icons.warehouse_outlined,
                    label: 'Warehouse',
                    value: sale.warehouseName,
                  ),
                ],
                if (sale.cashierName.isNotEmpty) ...[
                  _Divider(),
                  _InfoTile(
                    icon: Icons.badge_outlined,
                    label: 'Cashier',
                    value: sale.cashierName,
                  ),
                ],
                if (sale.cashierManName.isNotEmpty) ...[
                  _Divider(),
                  _InfoTile(
                    icon: Icons.manage_accounts_outlined,
                    label: 'Manager',
                    value: sale.cashierManName,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: ResponsiveUI.padding(context, 6)),
      child: Row(
        children: [
          Icon(
            icon,
            size: ResponsiveUI.iconSize(context, 18),
            color: AppColors.categoryPurple,
          ),
          SizedBox(width: ResponsiveUI.value(context, 10)),
          SizedBox(
            width: ResponsiveUI.value(context, 80),
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 13),
                fontWeight: FontWeight.w600,
                color: Color(0xFF888888),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 14),
                fontWeight: FontWeight.w600,
                color: AppColors.darkGray,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  _Divider();
  @override
  Widget build(BuildContext context) => Divider(
    height: ResponsiveUI.value(context, 1),
    thickness: ResponsiveUI.value(context, 1),
    color: Color(0xFFF0F0F0),
  );
}

// ─── Section Label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: ResponsiveUI.value(context, 4),
          height: ResponsiveUI.value(context, 18),
          decoration: BoxDecoration(
            color: AppColors.categoryPurple,
            borderRadius: BorderRadius.circular(
              ResponsiveUI.borderRadius(context, 2),
            ),
          ),
        ),
        SizedBox(width: ResponsiveUI.value(context, 8)),
        Text(
          label,
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 15),
            fontWeight: FontWeight.w700,
            color: AppColors.darkGray,
          ),
        ),
      ],
    );
  }
}

// ─── Note Field ───────────────────────────────────────────────────────────────

class _NoteField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  const _NoteField({required this.controller, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveUI.borderRadius(context, 12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        maxLines: 3,
        style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 14)),
        decoration: InputDecoration(
          hintText: 'return_note'.tr(),
          hintStyle: TextStyle(
            color: Color(0xFFAAAAAA),
            fontSize: ResponsiveUI.fontSize(context, 14),
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.only(
              left: ResponsiveUI.padding(context, 12),
              right: ResponsiveUI.padding(context, 8),
              top: ResponsiveUI.padding(context, 12),
            ),
            child: Icon(
              Icons.notes_outlined,
              color: AppColors.categoryPurple,
              size: ResponsiveUI.iconSize(context, 20),
            ),
          ),
          prefixIconConstraints: const BoxConstraints(),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              ResponsiveUI.borderRadius(context, 12),
            ),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppColors.white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: ResponsiveUI.padding(context, 16),
            vertical: ResponsiveUI.padding(context, 14),
          ),
        ),
      ),
    );
  }
}

// ─── Error Banner ─────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUI.padding(context, 14),
        vertical: ResponsiveUI.padding(context, 10),
      ),
      decoration: BoxDecoration(
        color: AppColors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(
          ResponsiveUI.borderRadius(context, 10),
        ),
        border: Border.all(color: AppColors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.red,
            size: ResponsiveUI.iconSize(context, 18),
          ),
          SizedBox(width: ResponsiveUI.value(context, 8)),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: AppColors.red,
                fontSize: ResponsiveUI.fontSize(context, 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Action Buttons ───────────────────────────────────────────────────────────

class _ActionButtons extends StatelessWidget {
  final bool isSubmitting;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;
  const _ActionButtons({
    required this.isSubmitting,
    required this.onCancel,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: isSubmitting ? null : onCancel,
            icon: Icon(Icons.close, size: ResponsiveUI.iconSize(context, 18)),
            label: Text('cancel'.tr()),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.darkGray,
              side: const BorderSide(color: Color(0xFFCCCCCC)),
              padding: EdgeInsets.symmetric(
                vertical: ResponsiveUI.padding(context, 14),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  ResponsiveUI.borderRadius(context, 12),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: ResponsiveUI.value(context, 12)),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: isSubmitting ? null : onSubmit,
            icon: isSubmitting
                ? SizedBox(
                    width: ResponsiveUI.value(context, 16),
                    height: ResponsiveUI.value(context, 16),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(
                    Icons.undo_rounded,
                    size: ResponsiveUI.iconSize(context, 18),
                  ),
            label: Text(
              isSubmitting ? '...' : 'submit_return'.tr(),
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: ResponsiveUI.fontSize(context, 15),
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.categoryPurple,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                vertical: ResponsiveUI.padding(context, 14),
              ),
              elevation: ResponsiveUI.value(context, 3),
              shadowColor: AppColors.categoryPurple.withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  ResponsiveUI.borderRadius(context, 12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
