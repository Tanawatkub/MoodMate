import 'package:flutter/material.dart';

import '../../app_dependencies.dart';
import '../auth/auth_service.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isSigningOut = false;

  Future<void> _editProfile() async {
    final name = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(dependencies: widget.dependencies),
      ),
    );
    if (name != null && mounted) setState(() {});
  }

  Future<void> _signOut() async {
    if (_isSigningOut) return;
    setState(() => _isSigningOut = true);
    try {
      await widget.dependencies.auth.signOut();
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } on AuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _isSigningOut = false);
    }
  }

  void _showNotice(String title, String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name =
        widget.dependencies.auth.currentDisplayName ?? 'ผู้ใช้งาน MoodMate';
    final userId = widget.dependencies.auth.currentUserId ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F5EE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('โปรไฟล์'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 16),
          const CircleAvatar(
            radius: 48,
            backgroundColor: Color(0xFFEFECE2),
            child: Icon(
              Icons.person_outline,
              size: 48,
              color: Color(0xFF444444),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: SelectableText(
              userId,
              style: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
            ),
          ),
          const SizedBox(height: 32),
          Card(
            color: Colors.white,
            child: Column(
              children: [
                _menuRow(
                  icon: Icons.edit_outlined,
                  title: 'แก้ไขโปรไฟล์',
                  onTap: _editProfile,
                ),
                const Divider(height: 1),
                _menuRow(
                  icon: Icons.notifications_none,
                  title: 'การแจ้งเตือน',
                  onTap: () => _showNotice(
                    'การแจ้งเตือน',
                    'แอปยังไม่มีระบบแจ้งเตือน การตั้งค่านี้จึงยังไม่ถูกบันทึก',
                  ),
                ),
                const Divider(height: 1),
                _menuRow(
                  icon: Icons.lock_outline,
                  title: 'ความเป็นส่วนตัว',
                  onTap: () => _showNotice(
                    'ความเป็นส่วนตัว',
                    'บันทึกจัดเก็บใน Firestore แยกตาม UID และ Security Rules '
                        'อนุญาตให้บัญชีเจ้าของอ่านหรือแก้ไขข้อมูลของตนเองเท่านั้น',
                  ),
                ),
                const Divider(height: 1),
                _menuRow(
                  icon: Icons.logout,
                  title: _isSigningOut ? 'กำลังออกจากระบบ...' : 'ออกจากระบบ',
                  color: Colors.red,
                  onTap: _isSigningOut ? null : _signOut,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Center(
            child: Text(
              'MoodMate v1.0 • บันทึกอารมณ์อย่างปลอดภัย',
              style: TextStyle(fontSize: 12, color: Color(0xFF888888)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuRow({
    required IconData icon,
    required String title,
    required VoidCallback? onTap,
    Color color = const Color(0xFF222222),
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      onTap: onTap,
    );
  }
}
