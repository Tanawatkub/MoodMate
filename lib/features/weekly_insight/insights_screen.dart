import 'package:flutter/material.dart';
import '../../app_dependencies.dart';

class InsightsScreen extends StatefulWidget {
  final AppDependencies dependencies;
  const InsightsScreen({super.key, required this.dependencies});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  String _selectedRange = '7 วันที่ผ่านมา';

  void _showRangeSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('เลือกช่วงเวลาสถิติ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF222222))),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('7 วันที่ผ่านมา'),
              onTap: () { setState(() => _selectedRange = '7 วันที่ผ่านมา'); Navigator.pop(ctx); },
            ),
            ListTile(
              title: const Text('30 วันที่ผ่านมา'),
              onTap: () { setState(() => _selectedRange = '30 วันที่ผ่านมา'); Navigator.pop(ctx); },
            ),
            ListTile(
              title: const Text('3 เดือนล่าสุด'),
              onTap: () { setState(() => _selectedRange = '3 เดือนล่าสุด'); Navigator.pop(ctx); },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F5EE),
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        title: const Text('สถิติ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF222222))),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: Color(0xFF222222)),
            onPressed: _showRangeSelector,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('ภาพรวมรายสัปดาห์', style: TextStyle(fontSize: 14, color: Color(0xFF666666))),
                GestureDetector(
                  onTap: _showRangeSelector,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFEFECE2))),
                    child: Row(
                      children: [
                        Text(_selectedRange, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF222222))),
                        const SizedBox(width: 4),
                        const Icon(Icons.keyboard_arrow_down, size: 16, color: Color(0xFF888888)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('อารมณ์หลัก', style: TextStyle(fontSize: 14, color: Color(0xFF888888))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFFDEADB), borderRadius: BorderRadius.circular(12)),
                        child: const Text('78% ยอดสัปดาห์นี้', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFC48E66))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: 80, height: 80,
                    decoration: const BoxDecoration(color: Color(0xFFFDEADB), shape: BoxShape.circle),
                    child: const Icon(Icons.sentiment_satisfied_alt, size: 44, color: Color(0xFF333333)),
                  ),
                  const SizedBox(height: 16),
                  const Text('มีความสุขเป็นส่วนใหญ่', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF222222))),
                  const SizedBox(height: 4),
                  const Text('คุณรู้สึกเบิกบานและผ่อนคลายต่อเนื่อง 5 จาก 7 วันในสัปดาห์นี้', style: TextStyle(fontSize: 12, color: Color(0xFF666666)), textAlign: TextAlign.center),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text('ปัจจัยหลัก', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF222222))),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: [
                _buildTagStat('แล็บ', '5 ครั้ง'),
                _buildTagStat('เดดไลน์', '4 ครั้ง'),
                _buildTagStat('โปรเจกต์', '4 ครั้ง'),
                _buildTagStat('กาแฟ', '3 ครั้ง'),
                _buildTagStat('พักผ่อน', '3 ครั้ง'),
              ],
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFEFECE2))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.star, size: 18, color: Color(0xFFC48E66)),
                      SizedBox(width: 8),
                      Text('บทสรุปจาก AI', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF222222))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'แม้ช่วงสัปดาห์นี้จะมีงานล้นมือและกำหนดเดดไลน์ที่กระชั้นชิด แต่คุณยังคงรักษาพลังบวกและความสงบใจไว้ได้เป็นอย่างดี ชื่นชมตัวเองที่ก้าวผ่านความกดดันมาได้นะ พักผ่อนให้เต็มที่แล้วเริ่มสัปดาห์ใหม่ให้อย่างสดใส',
                    style: TextStyle(fontSize: 13, color: Color(0xFF666666), height: 1.6),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('วิเคราะห์จาก 7 บันทึกล่าสุด', style: TextStyle(fontSize: 11, color: Color(0xFF888888))),
                      Text('อัปเดตเมื่อสักครู่', style: TextStyle(fontSize: 11, color: Color(0xFF888888))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagStat(String label, String count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFEFECE2))),
      child: Text('$label $count', style: const TextStyle(fontSize: 12, color: Color(0xFF444444))),
    );
  }
}