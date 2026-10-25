import 'package:flutter/material.dart';
import '../../app_dependencies.dart';
import '../check_in/new_check_in_screen.dart';
import '../diary/diary_detail_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final AppDependencies dependencies;
  const HomeScreen({super.key, required this.dependencies});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String getThaiDate(DateTime date) {
    const months = ['ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.', 'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'];
    return '${date.day} ${months[date.month - 1]}';
  }

  String getThaiDayOfWeek(DateTime date) {
    const days = ['จ', 'อ', 'พ', 'พฤ', 'ศ', 'ส', 'อา'];
    return days[date.weekday - 1];
  }

  String getThaiMonthYear(DateTime date) {
    const monthsFull = ['มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน', 'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม'];
    return '${monthsFull[date.month - 1]} ${date.year}';
  }

  Map<String, dynamic> _getMoodUI(String mood) {
    switch (mood) {
      case 'happy':
        return {'icon': Icons.sentiment_satisfied_alt, 'bgColor': const Color(0xFFFDEADB), 'color': const Color(0xFFF4B886)};
      case 'neutral':
        return {'icon': Icons.sentiment_neutral, 'bgColor': const Color(0xFFEFECE2), 'color': const Color(0xFF888888)};
      case 'sad':
        return {'icon': Icons.sentiment_dissatisfied, 'bgColor': const Color(0xFFE2ECF5), 'color': const Color(0xFF7189A1)};
      case 'angry':
        return {'icon': Icons.sentiment_very_dissatisfied, 'bgColor': const Color(0xFFF4C8C8), 'color': const Color(0xFFE5989B)};
      default:
        return {'icon': Icons.sentiment_satisfied_alt, 'bgColor': const Color(0xFFFDEADB), 'color': const Color(0xFFF4B886)};
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    DateTime weekStart = now.subtract(const Duration(days: 6));

    return Scaffold(
      backgroundColor: const Color(0xFFF6F5EE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('MoodMate', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF222222))),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(dependencies: widget.dependencies),
                  ),
                );
              },
              child: const CircleAvatar(
                radius: 18, backgroundColor: Color(0xFF222222),
                child: Icon(Icons.person_outline, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('บันทึกความรู้สึกอย่างเบามือ', style: TextStyle(color: Color(0xFF666666), fontSize: 13)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0xFFEFECE2), borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFF4B886), shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Text('วันนี้ • ${getThaiDate(now)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF444444))),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('สัปดาห์นี้', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF222222))),
                      Text('${getThaiDate(weekStart)} - ${getThaiDate(now)} ${now.year}', style: const TextStyle(fontSize: 12, color: Color(0xFF888888))),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        width: 56, height: 56,
                        decoration: const BoxDecoration(color: Color(0xFFFDEADB), shape: BoxShape.circle),
                        child: const Icon(Icons.sentiment_satisfied_alt, size: 32, color: Color(0xFF333333)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('ภาพรวม: มีความสุขเป็นส่วนใหญ่', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF222222))),
                            SizedBox(height: 4),
                            Text('คุณรักษาพลังบวกไว้ได้ดีมากในสัปดาห์นี้ ✨', style: TextStyle(fontSize: 12, color: Color(0xFF666666))),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(7, (index) {
                      DateTime day = now.subtract(Duration(days: 6 - index));
                      bool isToday = index == 6;
                      bool mockHasRecord = index % 2 != 0; 
                      return _buildDayDot(getThaiDayOfWeek(day), mockHasRecord, isToday: isToday);
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: Column(
                children: [
                  Text(getThaiMonthYear(now), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF222222))),
                  const SizedBox(height: 4),
                  const Text('ประวัติการบันทึกของคุณ', style: TextStyle(fontSize: 12, color: Color(0xFF888888))),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            GridView.count(
              crossAxisCount: 3, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 24, crossAxisSpacing: 16, childAspectRatio: 0.85,
              children: List.generate(12, (index) {
                DateTime day = now.subtract(Duration(days: index));
                bool isDashed = index % 4 == 3; 
                
                List<String> sampleMoods = ['happy', 'neutral', 'sad', 'happy', 'angry', 'neutral'];
                String moodKey = sampleMoods[index % sampleMoods.length];
                var moodUI = _getMoodUI(moodKey);

                return _buildGridItem(
                  context, 
                  day, 
                  isDashed ? null : moodUI['icon'], 
                  isDashed ? const Color(0xFFF6F5EE) : moodUI['bgColor'], 
                  isDashed: isDashed,
                );
              }),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewCheckInScreen(dependencies: widget.dependencies),
            ),
          );
        },
        backgroundColor: const Color(0xFF222222), elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildDayDot(String day, bool hasRecord, {bool isToday = false}) {
    return Column(
      children: [
        Text(day, style: TextStyle(fontSize: 12, fontWeight: isToday ? FontWeight.bold : FontWeight.normal, color: isToday ? const Color(0xFF222222) : const Color(0xFF888888))),
        const SizedBox(height: 8),
        Container(width: 8, height: 8, decoration: BoxDecoration(color: hasRecord ? const Color(0xFFF4B886) : const Color(0xFFEFECE2), shape: BoxShape.circle)),
      ],
    );
  }

  Widget _buildGridItem(BuildContext context, DateTime day, IconData? icon, Color bgColor, {bool isDashed = false}) {
    return GestureDetector(
      onTap: () {
        if (!isDashed) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DiaryDetailScreen(
                dependencies: widget.dependencies,
                selectedDate: day,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ยังไม่มีบันทึกครับ แตะปุ่ม + ด้านล่างเพื่อเพิ่มได้เลย ✨')),
          );
        }
      },
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: bgColor, 
                shape: BoxShape.circle, 
                border: isDashed ? Border.all(color: const Color(0xFFE8E5D6), width: 1.5) : null,
              ),
              child: isDashed 
                ? Center(child: Container(width: 16, height: 2, color: const Color(0xFFCCCCCC))) 
                : Icon(icon, size: 32, color: const Color(0xFF333333)),
            ),
          ),
          const SizedBox(height: 8),
          Text(getThaiDate(day), style: const TextStyle(fontSize: 12, color: Color(0xFF666666))),
        ],
      ),
    );
  }
}