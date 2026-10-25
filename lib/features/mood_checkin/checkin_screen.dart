import 'package:flutter/material.dart';

class NewCheckInScreen extends StatelessWidget {
  const NewCheckInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F5EE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF222222)),
          onPressed: () {
            // TODO: ใส่ลอจิกย้อนกลับ เช่น Navigator.pop(context);
          },
        ),
        title: const Text(
          'บันทึกใหม่',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF222222),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // วันที่ และ สถานะกำลังบันทึก
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF888888)),
                    SizedBox(width: 6),
                    Text(
                      'วันนี้ • 25 ต.ค.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFFC48E66), // สีน้ำตาล
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'กำลังบันทึก',
                      style: TextStyle(fontSize: 12, color: Color(0xFF888888)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // คำถามหลัก
            const Text(
              'วันนี้คุณรู้สึกอย่างไรบ้าง?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF222222),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'หยุดพักสักครู่ สังเกตความรู้สึกที่เกิดขึ้นในใจ',
              style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
            ),
            const SizedBox(height: 24),

            // เลือกอารมณ์ (Mood Selection)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMoodOption('มีความสุข', Icons.sentiment_satisfied_alt, const Color(0xFFFDEADB), false),
                _buildMoodOption('สงบใจ', Icons.sentiment_neutral, Colors.transparent, true), // เลือกตัวนี้
                _buildMoodOption('เฉยๆ', Icons.sentiment_neutral, const Color(0xFFEFECE2), false),
                _buildMoodOption('เหนื่อยล้า', Icons.sentiment_dissatisfied, const Color(0xFFF4C8C8), false),
              ],
            ),
            const SizedBox(height: 32),

            // หัวข้อ Tag
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                Text(
                  'สิ่งที่อยู่ในใจคุณวันนี้',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF222222),
                  ),
                ),
                Text(
                  'แตะเพื่อเลือก',
                  style: TextStyle(fontSize: 12, color: Color(0xFF888888)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tags แบบ Wrap (ปัดบรรทัดอัตโนมัติ)
            Wrap(
              spacing: 10,
              runSpacing: 12,
              children: [
                _buildTagChip('โค้ดดิ้ง', isSelected: true),
                _buildTagChip('แล็บ', isSelected: false),
                _buildTagChip('โปรเจกต์', isSelected: true),
                _buildTagChip('งานกลุ่ม', isSelected: false),
                _buildTagChip('พรีเซนต์', isSelected: false),
                _buildTagChip('เดดไลน์', isSelected: false),
                _buildTagChip('เรื่องส่วนตัว', isSelected: false),
              ],
            ),
            const SizedBox(height: 32),

            // กล่องเขียนบันทึกส่วนตัว
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEFECE2),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Row(
                        children: [
                          Icon(Icons.lock_outline, size: 16, color: Color(0xFF888888)),
                          SizedBox(width: 6),
                          Text(
                            'บันทึกส่วนตัว • ปลอดภัย',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF666666),
                            ),
                          ),
                        ],
                      ),
                      Icon(Icons.edit_outlined, size: 18, color: Color(0xFF888888)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const TextField(
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'เขียนบันทึกส่วนตัวของคุณที่นี่... ปล่อยความคิดให้ไหลลื่น ไม่ต้องกังวลว่ามันจะสมบูรณ์แบบ',
                      hintStyle: TextStyle(color: Color(0xFF888888), fontSize: 14, height: 1.5),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '0 คำ',
                        style: TextStyle(fontSize: 12, color: Color(0xFF888888)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2DFD3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.lightbulb_outline, size: 16, color: Color(0xFFC48E66)),
                            SizedBox(width: 6),
                            Text(
                              'อยากได้หัวข้อช่วยคิด?',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF666666),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // การ์ด Streak (เช็คอินต่อเนื่อง)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEFECE2).withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFDEADB),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('🌱', style: TextStyle(fontSize: 20)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'เช็คอินต่อเนื่อง 5 วันแล้วนะ!',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF222222),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'ทุกความรู้สึกมีคุณค่าเสมอ ค่อยๆ รับรู้และโอบกอดตัวเอง',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ปุ่มบันทึกและทบทวน
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: เพิ่มลอจิกบันทึกและเด้งไปหน้า AI Reflection
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF222222),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'บันทึกและทบทวน',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32), // ระยะห่างด้านล่าง
          ],
        ),
      ),
      // แถบเมนูด้านล่าง (คุณสามารถเอาออกได้ถ้ารันผ่าน main_navigation.dart)
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: 0,
        selectedItemColor: const Color(0xFF333333),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'หน้าหลัก',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'สถิติ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'โปรไฟล์',
          ),
        ],
      ),
    );
  }

  // Widget สร้างปุ่มเลือกอารมณ์
  Widget _buildMoodOption(String label, IconData icon, Color bgColor, bool isSelected) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
                border: isSelected ? Border.all(color: const Color(0xFF222222), width: 2) : null,
              ),
              child: Icon(
                icon,
                size: 36,
                color: const Color(0xFF333333),
              ),
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 2, right: 2),
                decoration: const BoxDecoration(
                  color: Color(0xFF222222),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 14),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: const Color(0xFF222222),
          ),
        ),
      ],
    );
  }

  // Widget สร้างปุ่ม Tag
  Widget _buildTagChip(String label, {required bool isSelected}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF222222) : const Color(0xFFEFECE2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(right: 6),
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Color(0xFFF4B886),
                shape: BoxShape.circle,
              ),
            ),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : const Color(0xFF444444),
            ),
          ),
        ],
      ),
    );
  }
}