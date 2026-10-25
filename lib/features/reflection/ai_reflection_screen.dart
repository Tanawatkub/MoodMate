import 'package:flutter/material.dart';
import '../../app_dependencies.dart';

class AiReflectionScreen extends StatelessWidget {
  final AppDependencies dependencies;
  final DateTime selectedDate; // เพิ่มตัวแปรรับวันที่

  const AiReflectionScreen({
    super.key, 
    required this.dependencies,
    required this.selectedDate, // กำหนดให้ต้องส่งค่าวันที่เข้ามา
  });

  // ฟังก์ชันแปลงวันที่เป็นภาษาไทยแบบเต็ม (เช่น 25 ต.ค. 2026)
  String getFormattedDate(DateTime date) {
    const months = ['ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.', 'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F5EE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF222222), size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'ข้อคิดเตือนใจ',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF222222)),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 72, height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFFDEADB),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome, color: Color(0xFFC48E66), size: 36),
            ),
            const SizedBox(height: 16),
            
            // แสดงวันที่ตรงกับวันที่ผู้ใช้กดเลือกเข้ามาจริง
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFEFECE2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'บันทึกสำหรับวันนี้ • ${getFormattedDate(selectedDate)}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF444444)),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'คำแนะนำจากใจ MoodMate ถึงคุณในค่ำคืนนี้',
              style: TextStyle(fontSize: 12, color: Color(0xFF888888)),
            ),
            const SizedBox(height: 24),

            // การ์ดข้อความ AI
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Row(
                        children: [
                          Icon(Icons.auto_awesome, size: 16, color: Color(0xFFC48E66)),
                          SizedBox(width: 8),
                          Text('บันทึกสะท้อนใจ (AI Reflection)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF222222))),
                        ],
                      ),
                      Text('21:42 น.', style: TextStyle(fontSize: 10, color: Color(0xFF888888))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'วันนี้คุณผ่านอะไรมามากมาย ทั้งการทุ่มเทกับงานและการจัดการเรื่องต่างๆ ในชีวิต การที่คุณรู้สึกเหนื่อยล้าหรืออยากพักใจบ้างไม่ใช่เรื่องผิดเลย ทุกก้าวที่คุณเดินมาในวันนี้มีความหมายมาก ลองให้เวลาตัวเองได้ผ่อนคลาย หายใจเข้าลึกๆ และนอนหลับพักผ่อนให้เต็มที่นะ พรุ่งนี้ค่อยเริ่มต้นใหม่อีกครั้งอย่างอ่อนโยน',
                    style: TextStyle(fontSize: 14, color: Color(0xFF444444), height: 1.6),
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Color(0xFFEFECE2)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('— อยู่เคียงข้างเสมอ, MoodMate', style: TextStyle(fontSize: 11, color: Color(0xFF888888), fontStyle: FontStyle.italic)),
                      Icon(Icons.favorite_border, size: 18, color: Color(0xFF888888)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: const [
                      Icon(Icons.lock_outline, size: 12, color: Color(0xFF888888)),
                      SizedBox(width: 6),
                      Text('บันทึกส่วนตัวของคุณถูกเข้ารหัสอย่างปลอดภัย', style: TextStyle(fontSize: 10, color: Color(0xFF888888))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // เมนูด้านล่าง
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFEFECE2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Icon(Icons.nightlight_outlined, color: Color(0xFFC48E66), size: 20),
                        SizedBox(height: 8),
                        Text('ช่วงเวลาผ่อนคลาย', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF222222))),
                        SizedBox(height: 4),
                        Text('ดื่มนมุ่นๆ หรือฟังเสียงฝนเบาๆ', style: TextStyle(fontSize: 10, color: Color(0xFF888888))),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFEFECE2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Icon(Icons.air, color: Color(0xFF8DC49B), size: 20),
                        SizedBox(height: 8),
                        Text('ฝึกหายใจ 4-7-8', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF222222))),
                        SizedBox(height: 4),
                        Text('คลายความตึงเครียดของกล้ามเนื้อ', style: TextStyle(fontSize: 10, color: Color(0xFF888888))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // ปุ่มกลับหน้าหลัก
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: () {
                  // กลับไปหน้าแรกสุด (Root) ของแอป
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF222222),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.home_outlined, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text('กลับหน้าหลัก', style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}