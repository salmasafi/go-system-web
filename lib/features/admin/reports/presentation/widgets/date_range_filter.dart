import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:GoSystem/core/constants/app_colors.dart';

/// Date range filter widget for reports
class DateRangeFilter extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(DateTime?, DateTime?) onChanged;

  const DateRangeFilter({
    super.key,
    this.startDate,
    this.endDate,
    required this.onChanged,
  });

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: startDate != null && endDate != null
          ? DateTimeRange(start: startDate!, end: endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.darkGray,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onChanged(picked.start, picked.end);
    }
  }

  String get _dateRangeText {
    if (startDate == null && endDate == null) {
      return 'اختر نطاق التاريخ'.tr();
    }

    final format = DateFormat('yyyy-MM-dd');
    if (startDate != null && endDate != null) {
      return '${format.format(startDate!)} - ${format.format(endDate!)}';
    } else if (startDate != null) {
      return 'من ${format.format(startDate!)}';
    } else {
      return 'حتى ${format.format(endDate!)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.date_range,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'نطاق التاريخ'.tr(),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.darkGray.withAlpha(150),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _dateRangeText,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _selectDateRange(context),
              icon: const Icon(Icons.edit_calendar, size: 18),
              label: Text('تغيير'.tr()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
