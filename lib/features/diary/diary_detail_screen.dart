import 'package:flutter/material.dart';
import '../../app_dependencies.dart';
import 'ai_reflection_screen.dart'; // <--- สำคัญมาก ต้องมีบรรทัดนี้ครับ

class DiaryDetailScreen extends StatelessWidget {
  final AppDependencies dependencies;
  final DateTime selectedDate; 

  const DiaryDetailScreen({
    super.key, 
    required this.dependencies,
    required this.selectedDate,
  });

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
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF222222), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          getFormattedDate(selectedDate),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF222222)),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Color(0xFF222222)),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                builder: (ctx) => Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.share_outlined, color: Color(0xFF222222)),
                        title: const Text('แชร์บันทึกนี้'),
                        onTap: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('คัดลอกลิงก์บันทึกสำเร็จ')),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.delete_outline, color: Colors.red),
                        title: const Text('ลบบันทึกนี้', style: TextStyle(color: Colors.red)),
                        onTap: () {
                          Navigator.pop(ctx);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('ลบข้อมูลเรียบร้อยแล้ว')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 88, height: 88,
                  decoration: const BoxDecoration(color: Color(0xFFEFECE2), shape: BoxShape.circle),
                  child: const Icon(Icons.sentiment_satisfied_alt, size: 48, color: Color(0xFF333333)),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.light_mode_outlined, size: 16, color: Color(0xFFC48E66)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('มีความสุข', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF222222))),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.access_time, size: 14, color: Color(0xFF888888)),
                SizedBox(width: 4),
                Text('21:30 น.', style: TextStyle(fontSize: 12, color: Color(0xFF888888))),
              ],
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12, runSpacing: 12, alignment: WrapAlignment.center,
              children: [
                _buildTagChip('โปรเจกต์'),
                _buildTagChip('โค้ดดิ้ง'),
                _buildTagChip('พักผ่อนช่วงค่ำ', icon: Icons.coffee_outlined),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'วันนี้เป็นวันที่ยอดเยี่ยมมาก ได้จัดการงานที่ค้างไว้จนเสร็จลุล่วง รู้สึกภูมิใจในตัวเอง ได้พักผ่อนและทำกิจกรรมที่ชอบ สบายใจมากๆ',
              style: TextStyle(fontSize: 15, color: Color(0xFF444444), height: 1.8),
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 40),
            
            // กดการ์ด AI เพื่อไปหน้า AiReflectionScreen พร้อมส่ง selectedDate ไปด้วย
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AiReflectionScreen(
                      dependencies: dependencies,
                      selectedDate: selectedDate, 
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                  border: Border.all(color: const Color(0xFFFDEADB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.auto_awesome, size: 20, color: Color(0xFFC48E66)),
                            SizedBox(width: 8),
                            Text('ข้อความจาก AI', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF222222))),
                          ],
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF888888)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'การมีความสุขกับเรื่องเล็กๆ น้อยๆ ในแต่ละวัน คือพลังใจที่ยิ่งใหญ่ รักษาความรู้สึกดีๆ แบบนี้ไว้นะคะ (แตะเพื่อดูข้อคิดเตือนใจ)',
                      style: TextStyle(fontSize: 14, color: Color(0xFF666666), height: 1.6),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTagChip(String label, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFFEFECE2), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon == null)
            Container(margin: const EdgeInsets.only(right: 6), width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFFC48E66), shape: BoxShape.circle))
          else
            Container(margin: const EdgeInsets.only(right: 6), child: Icon(icon, size: 14, color: Color(0xFF666666))),
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF444444))),
        ],
      ),
    );
  }
}