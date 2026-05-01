import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/features/admin/auth/cubit/login_cubit.dart';
import 'package:systego/features/admin/auth/model/user_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<LoginCubit>().savedUser;

    return Scaffold(
      backgroundColor: Color(0xFFF4F6FB),
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: ResponsiveUI.fontSize(context, 18)),
        ),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.darkGray,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: ResponsiveUI.value(context, 1), color: AppColors.lightGray),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(ResponsiveUI.padding(context, 20)),
        child: Column(
          children: [
            SizedBox(height: ResponsiveUI.value(context, 16)),
            _ProfileCard(user: user),
            SizedBox(height: ResponsiveUI.value(context, 20)),
            if (user != null) _InfoSection(user: user),
          ],
        ),
      ),
    );
  }
}

// ─── Profile Card ─────────────────────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  final User? user;
  const _ProfileCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final name = user?.username ?? 'No Name';
    final status = user?.status ?? 'inactive';
    final isActive = status.toLowerCase() == 'active';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: ResponsiveUI.padding(context, 32), horizontal: ResponsiveUI.padding(context, 24)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: ResponsiveUI.value(context, 90),
            height: ResponsiveUI.value(context, 90),
            decoration: BoxDecoration(
              color: const Color(0xFFEDE7F6),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initial,
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 36),
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF9C27B0),
                ),
              ),
            ),
          ),
          SizedBox(height: ResponsiveUI.value(context, 16)),

          // Name
          Text(
            name,
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 22),
              fontWeight: FontWeight.w800,
              color: AppColors.darkGray,
            ),
          ),
          SizedBox(height: ResponsiveUI.value(context, 8)),

          // Status badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: ResponsiveUI.padding(context, 14), vertical: ResponsiveUI.padding(context, 5)),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.successGreen.withValues(alpha: 0.12)
                  : const Color(0xFFF3E5F5),
              borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 20)),
            ),
            child: Text(
              isActive ? 'Active' : 'Inactive',
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 13),
                fontWeight: FontWeight.w600,
                color: isActive ? AppColors.successGreen : const Color(0xFF9C27B0),
              ),
            ),
          ),
          SizedBox(height: ResponsiveUI.value(context, 20)),

          // Edit Profile button
          SizedBox(
            width: ResponsiveUI.value(context, 160),
            child: ElevatedButton.icon(
              onPressed: () => _showEditDialog(context, user),
              icon: Icon(Icons.edit_rounded, size: ResponsiveUI.iconSize(context, 16)),
              label: Text(
                'Edit Profile',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: ResponsiveUI.fontSize(context, 14)),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9C27B0),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: ResponsiveUI.padding(context, 12)),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 30)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, User? user) {
    showDialog(
      context: context,
      builder: (_) => _EditProfileDialog(user: user),
    );
  }
}

// ─── Info Section ─────────────────────────────────────────────────────────────

class _InfoSection extends StatelessWidget {
  final User user;
  const _InfoSection({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 20)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Info',
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 15),
              fontWeight: FontWeight.w700,
              color: AppColors.darkGray,
            ),
          ),
          SizedBox(height: ResponsiveUI.value(context, 16)),
          if (user.email != null && user.email!.isNotEmpty)
            _InfoRow(icon: Icons.email_outlined, label: 'Email', value: user.email!),
          if (user.role != null && user.role!.isNotEmpty) ...[
            Divider(height: ResponsiveUI.value(context, 20), color: Color(0xFFF0F0F0)),
            _InfoRow(icon: Icons.shield_outlined, label: 'Role', value: user.role!),
          ],
          if (user.position != null && user.position.toString().isNotEmpty) ...[
            Divider(height: ResponsiveUI.value(context, 20), color: Color(0xFFF0F0F0)),
            _InfoRow(
              icon: Icons.work_outline_rounded,
              label: 'Position',
              value: user.position.toString(),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(ResponsiveUI.padding(context, 8)),
          decoration: BoxDecoration(
            color: const Color(0xFFF3E5F5),
            borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 10)),
          ),
          child: Icon(icon, size: ResponsiveUI.iconSize(context, 18), color: const Color(0xFF9C27B0)),
        ),
        SizedBox(width: ResponsiveUI.value(context, 12)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 11), color: AppColors.shadowGray),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 14),
                fontWeight: FontWeight.w600,
                color: AppColors.darkGray,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Edit Profile Dialog ──────────────────────────────────────────────────────

class _EditProfileDialog extends StatefulWidget {
  final User? user;
  const _EditProfileDialog({required this.user});

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _passwordCtrl;
  String _status = 'active';
  String? _pickedFileName;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _usernameCtrl = TextEditingController(text: widget.user?.username ?? '');
    _passwordCtrl = TextEditingController();
    _status = widget.user?.status?.toLowerCase() == 'active' ? 'active' : 'inactive';
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _pickedFileName = result.files.single.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: ResponsiveUI.padding(context, 20), vertical: ResponsiveUI.padding(context, 40)),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 12, 0),
              child: Row(
                children: [
                  Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 18),
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkGray,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: AppColors.shadowGray),
                  ),
                ],
              ),
            ),

            Divider(height: ResponsiveUI.value(context, 16), color: Color(0xFFF0F0F0)),

            // Fields
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel('Username'),
                    SizedBox(height: ResponsiveUI.value(context, 6)),
                    _StyledTextField(
                      controller: _usernameCtrl,
                      hint: 'Enter username',
                    ),
                    SizedBox(height: ResponsiveUI.value(context, 16)),

                    _FieldLabel('Password'),
                    SizedBox(height: ResponsiveUI.value(context, 6)),
                    _StyledTextField(
                      controller: _passwordCtrl,
                      hint: '••••••••',
                      obscure: _obscurePassword,
                      suffix: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          size: ResponsiveUI.iconSize(context, 20),
                          color: AppColors.shadowGray,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    SizedBox(height: ResponsiveUI.value(context, 16)),

                    _FieldLabel('Status'),
                    SizedBox(height: ResponsiveUI.value(context, 6)),
                    _StatusDropdown(
                      value: _status,
                      onChanged: (v) => setState(() => _status = v ?? _status),
                    ),
                    SizedBox(height: ResponsiveUI.value(context, 16)),

                    _FieldLabel('Profile Image'),
                    SizedBox(height: ResponsiveUI.value(context, 6)),
                    _ImagePickerField(
                      fileName: _pickedFileName,
                      onTap: _pickImage,
                    ),
                    SizedBox(height: ResponsiveUI.value(context, 20)),
                  ],
                ),
              ),
            ),

            // Actions
            Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.darkGray,
                        side: const BorderSide(color: Color(0xFFDDDDDD)),
                        padding: EdgeInsets.symmetric(vertical: ResponsiveUI.padding(context, 13)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
                        ),
                      ),
                      child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  SizedBox(width: ResponsiveUI.value(context, 12)),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: wire up to API when endpoint is ready
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF9C27B0),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: ResponsiveUI.padding(context, 13)),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
                        ),
                      ),
                      child: Text('Save', style: TextStyle(fontWeight: FontWeight.w700, fontSize: ResponsiveUI.fontSize(context, 15))),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Small helpers ────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(
          fontSize: ResponsiveUI.fontSize(context, 13),
          fontWeight: FontWeight.w600,
          color: Color(0xFF6A1B9A),
        ),
      );
}

class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final Widget? suffix;

  const _StyledTextField({
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 14), color: AppColors.darkGray),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Color(0xFFAAAAAA), fontSize: ResponsiveUI.fontSize(context, 14)),
        suffixIcon: suffix,
        contentPadding: EdgeInsets.symmetric(horizontal: ResponsiveUI.padding(context, 14), vertical: ResponsiveUI.padding(context, 13)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
          borderSide: BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
          borderSide: BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
          borderSide: BorderSide(color: Color(0xFF9C27B0), width: ResponsiveUI.value(context, 1.5)),
        ),
        filled: true,
        fillColor: const Color(0xFFFAFAFA),
      ),
    );
  }
}

class _StatusDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;
  const _StatusDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: ResponsiveUI.padding(context, 14), vertical: ResponsiveUI.padding(context, 13)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
          borderSide: BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
          borderSide: BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
          borderSide: BorderSide(color: Color(0xFF9C27B0), width: ResponsiveUI.value(context, 1.5)),
        ),
        filled: true,
        fillColor: const Color(0xFFFAFAFA),
      ),
      style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 14), color: AppColors.darkGray),
      items: const [
        DropdownMenuItem(value: 'active', child: Text('Active')),
        DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
      ],
    );
  }
}

class _ImagePickerField extends StatelessWidget {
  final String? fileName;
  final VoidCallback onTap;
  const _ImagePickerField({required this.fileName, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: ResponsiveUI.padding(context, 14), vertical: ResponsiveUI.padding(context, 13)),
        decoration: BoxDecoration(
          color: Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
          border: Border.all(color: Color(0xFFE0E0E0)),
        ),
        child: Row(
          children: [
            Text(
              'Choose file',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: ResponsiveUI.fontSize(context, 14), color: AppColors.darkGray),
            ),
            SizedBox(width: ResponsiveUI.value(context, 8)),
            Expanded(
              child: Text(
                fileName ?? 'No file chosen',
                style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 14), color: Color(0xFFAAAAAA)),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
