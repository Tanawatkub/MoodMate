import 'package:flutter/material.dart';
import '../../app_dependencies.dart';
import '../auth/login_screen.dart';
import 'edit_profile_screen.dart'; 

class ProfileScreen extends StatefulWidget {
  final AppDependencies dependencies;
  const ProfileScreen({super.key, required this.dependencies});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = "ผู้ใช้งาน MoodMate"; 
  String userId = "MgyvNYiXDffQpDuKshX3kx8aldv2";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    // ในอนาคตจะดึงข้อมูลจาก Firebase ตรงนี้
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F5EE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text('โปรไฟล์', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF222222))),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 24),
            Center(
              child: Container(
                width: 96, height: 96,
                decoration: const BoxDecoration(color: Color(0xFFEFECE2), shape: BoxShape.circle),
                child: const Icon(Icons.person_outline, size: 48, color: Color(0xFF444444)),
              ),
            ),
            const SizedBox(height: 24),
            // ชื่อตรงนี้จะเปลี่ยนไปตามตัวแปร userName
            Text(userName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF222222))),
            const SizedBox(height: 8),
            Text(userId, style: const TextStyle(fontSize: 12, color: Color(0xFF888888))),
            const SizedBox(height: 40),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  _buildMenuRow(
                    icon: Icons.edit_outlined, 
                    title: 'แก้ไขโปรไฟล์',
                    onTap: () async {
                      // รอรับค่าชื่อใหม่ที่ส่งกลับมาจากหน้า EditProfileScreen
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfileScreen(dependencies: widget.dependencies),
                        ),
                      );
                      
                      // ถ้ามีค่าส่งกลับมา (ไม่เป็น null) และมีข้อความ ให้เปลี่ยนชื่อบนจอ
                      if (result != null && result is String && result.isNotEmpty) {
                        setState(() {
                          userName = result;
                        });
                      }
                      await _loadUserData(); 
                    }
                  ),
                  const Divider(height: 1, color: Color(0xFFEFECE2)),
                  _buildMenuRow(icon: Icons.notifications_none, title: 'การแจ้งเตือน', onTap: () {}),
                  const Divider(height: 1, color: Color(0xFFEFECE2)),
                  _buildMenuRow(icon: Icons.lock_outline, title: 'ความเป็นส่วนตัว', onTap: () {}),
                  const Divider(height: 1, color: Color(0xFFEFECE2)),
                  _buildMenuRow(
                    icon: Icons.logout, 
                    title: 'ออกจากระบบ', 
                    color: Colors.red, 
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginScreen(dependencies: widget.dependencies),
                        ),
                        (route) => false,
                      );
                    }
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            const Text('MoodMate v1.0 • บันทึกอารมณ์อย่างปลอดภัย', style: TextStyle(fontSize: 12, color: Color(0xFF888888))),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuRow({required IconData icon, required String title, required VoidCallback onTap, Color color = const Color(0xFF222222)}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 16),
                Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: color)),
              ],
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: const Color(0xFFCCCCCC)),
          ],
        ),
      ),
    );
  }
}