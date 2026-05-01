import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:GoSystem/core/widgets/custom_loading/build_overlay_loading.dart';
import 'package:GoSystem/core/widgets/custom_snack_bar/custom_snackbar.dart';
import 'package:GoSystem/features/admin/purchase_returns/cubit/purchase_return_cubit.dart';
import 'package:GoSystem/features/admin/purchase_returns/model/purchase_return_model.dart';

class PurchaseReturnFormDialog extends StatefulWidget {
  final PurchaseReturnModel? returnModel;
  const PurchaseReturnFormDialog({super.key, this.returnModel});

  @override
  State<PurchaseReturnFormDialog> createState() =>
      _PurchaseReturnFormDialogState();
}

class _PurchaseReturnFormDialogState extends State<PurchaseReturnFormDialog>
    with SingleTickerProviderStateMixin {
  final _noteCtrl = TextEditingController();
  final _refundMethodCtrl = TextEditingController();
  late AnimationController _animCtrl;
  late Animation<double> _scaleAnim;

  bool get _isEdit => widget.returnModel != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _noteCtrl.text = widget.returnModel!.note;
      _refundMethodCtrl.text = widget.returnModel!.refundMethod;
    }
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _scaleAnim =
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutBack);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    _refundMethodCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_refundMethodCtrl.text.trim().isEmpty) {
      CustomSnackbar.showWarning(context, 'Please enter refund method');
      return;
    }
    context.read<PurchaseReturnCubit>().updateReturn(
          id: widget.returnModel!.id,
          note: _noteCtrl.text.trim(),
          refundMethod: _refundMethodCtrl.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = ResponsiveUI.isMobile(context)
        ? ResponsiveUI.screenWidth(context) * 0.95
        : ResponsiveUI.contentMaxWidth(context);

    return ScaleTransition(
      scale: _scaleAnim,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: BlocConsumer<PurchaseReturnCubit, PurchaseReturnState>(
          listener: (context, state) {
            if (state is UpdateReturnSuccess) {
              Navigator.pop(context);
              CustomSnackbar.showSuccess(context, state.message);
            } else if (state is UpdateReturnError) {
              CustomSnackbar.showError(context, state.error);
            }
          },
          builder: (context, state) {
            final isLoading = state is UpdateReturnLoading;
            return Container(
              constraints: BoxConstraints(maxWidth: maxWidth),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(
                    ResponsiveUI.borderRadius(context, 24)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.2),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Header ──
                  _DialogHeader(isEdit: _isEdit),

                  // ── Body ──
                  Flexible(
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          padding: EdgeInsets.all(
                              ResponsiveUI.padding(context, 24)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_isEdit) ...[
                                _InfoRow(
                                  label: 'Reference',
                                  value: widget.returnModel!.reference,
                                ),
                                _InfoRow(
                                  label: 'Purchase Ref',
                                  value:
                                      widget.returnModel!.purchaseReference,
                                ),
                                _InfoRow(
                                  label: 'Total Amount',
                                  value:
                                      '${widget.returnModel!.totalAmount.toStringAsFixed(2)} EGP',
                                ),
                                SizedBox(
                                    height:
                                        ResponsiveUI.spacing(context, 16)),
                              ],
                              _FieldLabel('Refund Method'),
                              SizedBox(
                                  height: ResponsiveUI.spacing(context, 6)),
                              _TextField(controller: _refundMethodCtrl),
                              SizedBox(
                                  height: ResponsiveUI.spacing(context, 16)),
                              _FieldLabel('Note'),
                              SizedBox(
                                  height: ResponsiveUI.spacing(context, 6)),
                              _TextField(
                                  controller: _noteCtrl, maxLines: 3),
                            ],
                          ),
                        ),
                        if (isLoading) buildLoadingOverlay(context, 45),
                      ],
                    ),
                  ),

                  // ── Buttons ──
                  _DialogButtons(
                    isEdit: _isEdit,
                    isLoading: isLoading,
                    onCancel: () => Navigator.pop(context),
                    onSubmit: _submit,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _DialogHeader extends StatelessWidget {
  final bool isEdit;
  const _DialogHeader({required this.isEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUI.padding(context, 24),
        vertical: ResponsiveUI.padding(context, 20),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryBlue,
            AppColors.darkBlue,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft:
              Radius.circular(ResponsiveUI.borderRadius(context, 24)),
          topRight:
              Radius.circular(ResponsiveUI.borderRadius(context, 24)),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(ResponsiveUI.padding(context, 10)),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              borderRadius:
                  BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
            ),
            child: Icon(
              isEdit ? Icons.edit : Icons.assignment_return_rounded,
              color: AppColors.white,
              size: ResponsiveUI.iconSize(context, 28),
            ),
          ),
          SizedBox(width: ResponsiveUI.spacing(context, 16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEdit ? 'Edit Return' : 'New Return',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: ResponsiveUI.fontSize(context, 22),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  isEdit
                      ? 'Update return details'
                      : 'Add a new purchase return',
                  style: TextStyle(
                    color: AppColors.white.withValues(alpha: 0.9),
                    fontSize: ResponsiveUI.fontSize(context, 13),
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 20)),
            child: Padding(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 8)),
              child: Icon(Icons.close,
                  color: AppColors.white,
                  size: ResponsiveUI.iconSize(context, 24)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Buttons ──────────────────────────────────────────────────────────────────

class _DialogButtons extends StatelessWidget {
  final bool isEdit;
  final bool isLoading;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;
  const _DialogButtons(
      {required this.isEdit,
      required this.isLoading,
      required this.onCancel,
      required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 24)),
      decoration: BoxDecoration(
        color: AppColors.shadowGray[50],
        borderRadius: BorderRadius.only(
          bottomLeft:
              Radius.circular(ResponsiveUI.borderRadius(context, 24)),
          bottomRight:
              Radius.circular(ResponsiveUI.borderRadius(context, 24)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: isLoading ? null : onCancel,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                    vertical: ResponsiveUI.padding(context, 16)),
                side: BorderSide(color: AppColors.shadowGray[300]!),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        ResponsiveUI.borderRadius(context, 12))),
              ),
              child: Text('Cancel',
                  style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 16),
                      fontWeight: FontWeight.w600,
                      color: AppColors.shadowGray[700])),
            ),
          ),
          SizedBox(width: ResponsiveUI.spacing(context, 16)),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : onSubmit,
              icon: Icon(
                  isEdit
                      ? Icons.check_circle_outline
                      : Icons.add_circle_outline,
                  size: ResponsiveUI.iconSize(context, 20)),
              label: Text(
                isEdit ? 'Update Return' : 'Create Return',
                style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 14),
                    fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: AppColors.white,
                padding: EdgeInsets.symmetric(
                    vertical: ResponsiveUI.padding(context, 16)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        ResponsiveUI.borderRadius(context, 12))),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(bottom: ResponsiveUI.spacing(context, 8)),
        child: Row(
          children: [
            Text('$label: ',
                style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 13),
                    color: AppColors.shadowGray)),
            Expanded(
              child: Text(value,
                  style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 13),
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkGray)),
            ),
          ],
        ),
      );
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: TextStyle(
          fontSize: ResponsiveUI.fontSize(context, 14),
          fontWeight: FontWeight.w600,
          color: AppColors.darkGray));
}

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final int maxLines;
  const _TextField({required this.controller, this.maxLines = 1});
  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 14),
            color: AppColors.darkGray),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(
              horizontal: ResponsiveUI.padding(context, 12),
              vertical: ResponsiveUI.padding(context, 12)),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 8)),
              borderSide: BorderSide(color: AppColors.lightGray)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 8)),
              borderSide: BorderSide(color: AppColors.lightGray)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 8)),
              borderSide: BorderSide(
                  color: AppColors.primaryBlue, width: ResponsiveUI.value(context, 1.5))),
        ),
      );
}

