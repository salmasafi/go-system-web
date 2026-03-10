import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/features/admin/transfer/cubit/transfers_cubit.dart';
import 'package:systego/features/admin/transfer/model/transfer_model.dart';
import 'package:systego/generated/locale_keys.g.dart';

enum TransferType { incoming, outgoing, history }

class TransferCard extends StatelessWidget {
  final TransferModel transfer;
  final TransferType type;
  final String currentWarehouseId;

  const TransferCard({
    super.key,
    required this.transfer,
    required this.type,
    required this.currentWarehouseId,
  });

  @override
  Widget build(BuildContext context) {
    // Format Date
    // final date = DateTime.tryParse(transfer.date);
    // final formattedDate = date != null
    //     ? DateFormat('MMM dd, yyyy - hh:mm a').format(date)
    //     : transfer.date;

    // Define Colors based on status
    final isDone =
        transfer.status.toLowerCase() == 'done' ||
        transfer.status.toLowerCase() == 'received';
    final statusColor = isDone ? Colors.green : Colors.orange;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border(left: BorderSide(color: statusColor, width: 4)),
      ),
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Reference & Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                transfer.reference,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  transfer.status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUI.spacing(context, 12)),

          // Body: Route
          Row(
            children: [
              _buildWarehouseInfo(
                context,
                label: "From",
                name: transfer.fromWarehouse?.name ?? "Unknown",
                icon: Icons.warehouse,
              ),
              const Expanded(
                child: Icon(Icons.arrow_forward, color: Colors.grey),
              ),
              _buildWarehouseInfo(
                context,
                label: "To",
                name: transfer.toWarehouse?.name ?? "Unknown",
                icon: Icons.store,
              ),
            ],
          ),
          SizedBox(height: ResponsiveUI.spacing(context, 12)),

          // Products Summary
          Text(
            "${transfer.products.length} ${LocaleKeys.products.tr()}: ${transfer.products.map((e) => e.productName).join(', ')}",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),

          if (type == TransferType.incoming && !isDone) ...[
            const Divider(),

            // Footer: Date & Action
            Row(
              children: [
                // Icon(Icons.access_time, size: 16, color: Colors.grey[400]),
                // const SizedBox(width: 4),
                // Text(formattedDate, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                // const Spacer(),

                // Only show Receive button if:
                // 1. It is the Incoming Tab
                // 2. Status is NOT 'done'/'received'
                ElevatedButton.icon(
                  onPressed: () {
                    // Call the API to mark as received
                    context.read<TransfersCubit>().markAsReceived(
                      transferId: transfer.id,
                      warehouseId: currentWarehouseId,
                    );
                  },
                  icon: const Icon(Icons.check, size: 16),
                  label: Text(LocaleKeys.receive.tr()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWarehouseInfo(
    BuildContext context, {
    required String label,
    required String name,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
        SizedBox(
          width: ResponsiveUI.screenWidth(context) * 0.35,
          child: Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
