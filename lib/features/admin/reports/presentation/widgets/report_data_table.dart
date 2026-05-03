import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:GoSystem/core/constants/app_colors.dart';

/// Reusable data table widget for reports
class ReportDataTable extends StatelessWidget {
  final String title;
  final List<DataColumn> columns;
  final List<DataRow> rows;

  const ReportDataTable({
    super.key,
    required this.title,
    required this.columns,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (rows.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 48,
                        color: AppColors.lightGray,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'لا توجد بيانات'.tr(),
                        style: TextStyle(
                          color: AppColors.darkGray.withAlpha(150),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: columns,
                  rows: rows,
                  headingRowColor: WidgetStateProperty.all(
                    AppColors.primaryBlue.withAlpha(20),
                  ),
                  border: TableBorder(
                    horizontalInside: BorderSide(
                      color: AppColors.lightGray.withAlpha(50),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
