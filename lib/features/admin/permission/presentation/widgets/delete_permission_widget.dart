import 'package:flutter/material.dart';
import 'package:systego/core/utils/responsive_ui.dart';

class DeletePermissionDialog extends StatelessWidget {
  final String permissionName;
  final VoidCallback onDelete;

  const DeletePermissionDialog({
    super.key,
    required this.permissionName,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(ResponsiveUI.borderRadius(context, 20)),
      ),
      elevation: 8,
      backgroundColor: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUI.padding(context, 20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIcon(context),
            SizedBox(height: ResponsiveUI.spacing(context, 16)),
            _buildTitle(context),
            SizedBox(height: ResponsiveUI.spacing(context, 12)),
            _buildMessage(context),
            SizedBox(height: ResponsiveUI.spacing(context, 24)),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ICON
  // ---------------------------------------------------------------------------

  Widget _buildIcon(BuildContext context) {
    return Container(
      width: ResponsiveUI.value(context, 70),
      height: ResponsiveUI.value(context, 70),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.lock_outline, // Permission-related icon
        color: Colors.red,
        size: ResponsiveUI.iconSize(context, 40),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TITLE
  // ---------------------------------------------------------------------------

  Widget _buildTitle(BuildContext context) {
    return Text(
      'Delete Permission',
      style: TextStyle(
        fontSize: ResponsiveUI.fontSize(context, 20),
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MESSAGE
  // ---------------------------------------------------------------------------

  Widget _buildMessage(BuildContext context) {
    return Text(
      'Are you sure you want to delete the permission "$permissionName"?\nThis action cannot be undone.',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: ResponsiveUI.fontSize(context, 14),
        color: Colors.grey[600],
        height: 1.5,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ACTION BUTTONS
  // ---------------------------------------------------------------------------

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildCancelButton(context)),
        SizedBox(width: ResponsiveUI.spacing(context, 12)),
        Expanded(child: _buildDeleteButton(context)),
      ],
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return OutlinedButton(
      onPressed: () => Navigator.pop(context),
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          vertical: ResponsiveUI.padding(context, 14),
        ),
        side: BorderSide(color: Colors.grey[300]!),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
        ),
      ),
      child: Text(
        'Cancel',
        style: TextStyle(
          fontSize: ResponsiveUI.fontSize(context, 15),
          color: Colors.grey[700],
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return ElevatedButton(
      onPressed: onDelete,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        padding: EdgeInsets.symmetric(
          vertical: ResponsiveUI.padding(context, 14),
        ),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
        ),
      ),
      child: Text(
        'Delete',
        style: TextStyle(
          fontSize: ResponsiveUI.fontSize(context, 15),
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
