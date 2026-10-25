import 'package:flutter/material.dart';
import '../../app_dependencies.dart';
// import 'edit_profile_screen.dart'; // อย่าลืม import หน้าแก้ไขโปรไฟล์ของคุณตรงนี้

class ProfileScreen extends StatefulWidget {
  final AppDependencies dependencies;
  const ProfileScreen({super.key, required this.dependencies});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = "ผู้ใช้งาน MoodMate"; // ตัวแปรเก็บชื่อ
  String userId = "MgyvNYiXDffQpDuKshX3kx8aidv2"; // ตัวแปรเก็บ ID

  @override
  void initState() {
    super.initState();
    _loadUserData(); // โหลดข้อมูลครั้งแรกตอนเปิดหน้า
  }

  // ฟังก์ชันจำลองการโหลดข้อมูลล่าสุด (ถ้ามี Firebase ให้ดึงจาก Firebase ตรงนี้)
  Future<void> _loadUserData() async {
    // ตัวอย่างการดึงข้อมูล: 
    // final user = FirebaseAuth.instance.currentUser;
    // await user?.reload();
    // userName = user?.displayName ?? "ผู้ใช้งาน MoodMate";
    
    setState(() {
      // อัปเดตข้อมูลบนหน้าจอ
    });
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
            Text(userName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF222222))),
            const SizedBox(height: 8),
            Text(userId, style: const TextStyle(fontSize: 12, color: Color(0xFF888888))),
            const SizedBox(height: 40),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  _buildMenuRow(
                    icon: Icons.edit_outlined, 
                    title: 'แก้ไขโปรไฟล์',
                    onTap: () async {
                      // สมมติว่าเปิดหน้า EditProfileScreen
                      /* 
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EditProfileScreen(dependencies: widget.dependencies)),
                      );
                      */
                      // รอจนแก้ข้อมูลเสร็จ พอกลับมาหน้านี้ จะโหลดข้อมูลชื่อล่าสุดมาแสดงใหม่
                      await _loadUserData(); 
                    }
                  ),
                  const Divider(height: 1, color: Color(0xFFEFECE2)),
                  _buildMenuRow(icon: Icons.notifications_none, title: 'การแจ้งเตือน', onTap: () {}),
                  const Divider(height: 1, color: Color(0xFFEFECE2)),
                  _buildMenuRow(icon: Icons.lock_outline, title: 'ความเป็นส่วนตัว', onTap: () {}),
                  const Divider(height: 1, color: Color(0xFFEFECE2)),
                  _buildMenuRow(icon: Icons.logout, title: 'ออกจากระบบ', color: Colors.red, onTap: () {}),
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