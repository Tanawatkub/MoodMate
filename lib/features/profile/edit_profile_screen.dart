import 'package:flutter/material.dart';
import '../../app_dependencies.dart';

class EditProfileScreen extends StatefulWidget {
  final AppDependencies dependencies;
  const EditProfileScreen({super.key, required this.dependencies});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController(text: "ผู้ใช้งาน MoodMate");

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F5EE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF222222)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('แก้ไขโปรไฟล์', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF222222))),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 96, height: 96,
                    decoration: const BoxDecoration(color: Color(0xFFEFECE2), shape: BoxShape.circle),
                    child: const Icon(Icons.person_outline, size: 48, color: Color(0xFF444444)),
                  ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: Color(0xFF222222), shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text('ชื่อผู้ใช้งาน', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF222222))),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                filled: true, fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: เชื่อม AuthService.updateDisplayName()
                  // ส่งชื่อที่ถูกแก้ไขกลับไปให้หน้าก่อนหน้า
                  Navigator.pop(context, _nameController.text);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF222222),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                ),
                child: const Text('บันทึกข้อมูล', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}