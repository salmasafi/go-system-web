import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/features/admin/reason/cubit/reason_cubit.dart';
import 'package:GoSystem/features/admin/reason/cubit/reason_state.dart';
import 'package:GoSystem/features/admin/reason/model/reason_model.dart';
import '../cubit/return_cubit.dart';
import '../models/return_item_model.dart';

class ReturnItemsTable extends StatelessWidget {
  final List<ReturnItemModel> items;
  final bool disabled;

  const ReturnItemsTable({
    super.key,
    required this.items,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveUI.borderRadius(context, 14),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          const _TableHeader(),
          if (items.isEmpty)
            Padding(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 24)),
              child: Center(
                child: Text(
                  'No items',
                  style: TextStyle(
                    color: Color(0xFFAAAAAA),
                    fontSize: ResponsiveUI.fontSize(context, 14),
                  ),
                ),
              ),
            )
          else
            ...items.asMap().entries.map(
              (e) => _ItemRow(
                index: e.key,
                item: e.value,
                disabled: disabled,
                isLast: e.key == items.length - 1,
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Table Header ─────────────────────────────────────────────────────────────

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUI.padding(context, 14),
        vertical: ResponsiveUI.padding(context, 10),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFEDE7F6), Color(0xFFF3E5F5)],
        ),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: _HeaderCell('product'.tr())),
          Expanded(flex: 2, child: _HeaderCell('code'.tr())),
          _HeaderCell('qty'.tr(), width: ResponsiveUI.value(context, 40)),
          _HeaderCell(
            'available_to_return'.tr(),
            width: ResponsiveUI.value(context, 60),
          ),
          _HeaderCell(
            'return_qty'.tr(),
            width: ResponsiveUI.value(context, 100),
          ),
          _HeaderCell('reason'.tr(), width: ResponsiveUI.value(context, 130)),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  final double? width;
  const _HeaderCell(this.text, {this.width});

  @override
  Widget build(BuildContext context) {
    final child = Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: ResponsiveUI.fontSize(context, 12),
        color: Color(0xFF6A1B9A),
        letterSpacing: 0.3,
      ),
      textAlign: TextAlign.center,
    );
    if (width != null) return SizedBox(width: width, child: child);
    return child;
  }
}

// ─── Item Row ─────────────────────────────────────────────────────────────────

class _ItemRow extends StatelessWidget {
  final int index;
  final ReturnItemModel item;
  final bool disabled;
  final bool isLast;

  const _ItemRow({
    required this.index,
    required this.item,
    required this.disabled,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final isEven = index % 2 == 0;
    return Container(
      decoration: BoxDecoration(
        color: isEven ? AppColors.white : Color(0xFFFAF7FF),
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: Color(0xFFF0F0F0),
                  width: ResponsiveUI.value(context, 1),
                ),
              ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUI.padding(context, 14),
        vertical: ResponsiveUI.padding(context, 10),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              item.productName,
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 13),
                fontWeight: FontWeight.w500,
                color: AppColors.darkGray,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUI.padding(context, 6),
                vertical: ResponsiveUI.padding(context, 3),
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFEDE7F6),
                borderRadius: BorderRadius.circular(
                  ResponsiveUI.borderRadius(context, 6),
                ),
              ),
              child: Text(
                item.productCode,
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 11),
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6A1B9A),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(
            width: ResponsiveUI.value(context, 40),
            child: Text(
              '${item.quantity}',
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 13),
                color: AppColors.darkGray,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: ResponsiveUI.value(context, 60),
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUI.padding(context, 8),
                  vertical: ResponsiveUI.padding(context, 3),
                ),
                decoration: BoxDecoration(
                  color: item.availableToReturn > 0
                      ? AppColors.successGreen.withValues(alpha: 0.12)
                      : AppColors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    ResponsiveUI.borderRadius(context, 20),
                  ),
                ),
                child: Text(
                  '${item.availableToReturn}',
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 12),
                    fontWeight: FontWeight.w700,
                    color: item.availableToReturn > 0
                        ? AppColors.successGreen
                        : AppColors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          SizedBox(
            width: ResponsiveUI.value(context, 100),
            child: _StepperCell(
              index: index,
              value: item.returnQuantity,
              max: item.availableToReturn,
              disabled: disabled,
            ),
          ),
          SizedBox(
            width: ResponsiveUI.value(context, 130),
            child: _ReasonDropdown(
              index: index,
              selectedReasonId: item.reason,
              disabled: disabled,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Reason Dropdown ──────────────────────────────────────────────────────────

class _ReasonDropdown extends StatelessWidget {
  final int index;
  final String selectedReasonId;
  final bool disabled;

  const _ReasonDropdown({
    required this.index,
    required this.selectedReasonId,
    required this.disabled,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReasonCubit, ReasonState>(
      builder: (context, state) {
        final reasons = state is GetReasonsSuccess
            ? state.reasonData.reasons
            : <ReasonModel>[];

        ReasonModel? selected;
        if (selectedReasonId.isNotEmpty) {
          try {
            selected = reasons.firstWhere((r) => r.id == selectedReasonId);
          } catch (_) {
            selected = null;
          }
        }

        return DropdownButtonHideUnderline(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUI.padding(context, 8),
            ),
            decoration: BoxDecoration(
              color: disabled
                  ? const Color(0xFFF5F5F5)
                  : AppColors.lightBlueBackground,
              borderRadius: BorderRadius.circular(
                ResponsiveUI.borderRadius(context, 8),
              ),
              border: Border.all(
                color: selected != null
                    ? AppColors.categoryPurple.withValues(alpha: 0.4)
                    : const Color(0xFFDDDDDD),
              ),
            ),
            child: DropdownButton<ReasonModel>(
              value: selected,
              isExpanded: true,
              isDense: true,
              hint: Text(
                'reason'.tr(),
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 11),
                  color: Color(0xFFAAAAAA),
                ),
                overflow: TextOverflow.ellipsis,
              ),
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: ResponsiveUI.iconSize(context, 16),
                color: AppColors.categoryPurple,
              ),
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 11),
                color: AppColors.darkGray,
                fontFamily: 'Rubik',
              ),
              items: [
                DropdownMenuItem<ReasonModel>(
                  value: null,
                  child: Text(
                    'none'.tr(),
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 11),
                      color: Color(0xFFAAAAAA),
                    ),
                  ),
                ),
                ...reasons.map(
                  (r) => DropdownMenuItem<ReasonModel>(
                    value: r,
                    child: Text(
                      r.reason,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: ResponsiveUI.fontSize(context, 11),
                      ),
                    ),
                  ),
                ),
              ],
              onChanged: disabled
                  ? null
                  : (r) => context.read<ReturnCubit>().updateItemReason(
                      index,
                      r?.id ?? '',
                    ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Stepper Cell ─────────────────────────────────────────────────────────────

class _StepperCell extends StatelessWidget {
  final int index;
  final int value;
  final int max;
  final bool disabled;

  const _StepperCell({
    required this.index,
    required this.value,
    required this.max,
    required this.disabled,
  });

  void _update(BuildContext context, int newValue) {
    if (newValue > max) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('return_qty_exceeded'.tr()),
          duration: const Duration(seconds: 2),
          backgroundColor: AppColors.warningOrange,
        ),
      );
      return;
    }
    context.read<ReturnCubit>().updateReturnQuantity(index, newValue);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepBtn(
          icon: Icons.remove,
          onTap: (disabled || value <= 0)
              ? null
              : () => _update(context, value - 1),
        ),
        Container(
          width: ResponsiveUI.value(context, 32),
          alignment: Alignment.center,
          child: Text(
            '$value',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: ResponsiveUI.fontSize(context, 15),
              color: value > 0 ? AppColors.categoryPurple : AppColors.darkGray,
            ),
          ),
        ),
        _StepBtn(
          icon: Icons.add,
          onTap: (disabled || value >= max)
              ? null
              : () => _update(context, value + 1),
        ),
      ],
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _StepBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final active = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: ResponsiveUI.value(context, 28),
        height: ResponsiveUI.value(context, 28),
        decoration: BoxDecoration(
          color: active
              ? AppColors.categoryPurple.withValues(alpha: 0.12)
              : const Color(0xFFF0F0F0),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: ResponsiveUI.iconSize(context, 16),
          color: active ? AppColors.categoryPurple : const Color(0xFFCCCCCC),
        ),
      ),
    );
  }
}
