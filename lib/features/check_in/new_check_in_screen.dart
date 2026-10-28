import 'package:flutter/material.dart';
import '../../app_dependencies.dart';
import '../../models/mood_entry.dart';
import '../../core/constants/moodmate_constants.dart';

class NewCheckInScreen extends StatefulWidget {
  final AppDependencies dependencies;
  const NewCheckInScreen({super.key, required this.dependencies});

  @override
  State<NewCheckInScreen> createState() => _NewCheckInScreenState();
}

class _NewCheckInScreenState extends State<NewCheckInScreen> {
  String _selectedMood = '';
  final TextEditingController _diaryController = TextEditingController();
  final Set<String> _selectedTags = {};
  bool _isSaving = false;

  static const _tagLabels = <String, String>{
    'Coding': 'โค้ดดิ้ง',
    'Lab': 'แล็บ',
    'Project': 'โปรเจกต์',
    'Group Work': 'งานกลุ่ม',
    'Presentation': 'พรีเซนต์',
    'Deadline': 'เดดไลน์',
    'Personal': 'เรื่องส่วนตัว',
  };

  @override
  void dispose() {
    _diaryController.dispose();
    super.dispose();
  }

  Future<void> _saveEntry() async {
    final userId = widget.dependencies.auth.currentUserId;
    if (userId == null) {
      _showMessage('เซสชันหมดอายุ กรุณาเข้าสู่ระบบใหม่');
      return;
    }
    if (!MoodMateConstants.moods.contains(_selectedMood)) {
      _showMessage('กรุณาเลือกอารมณ์ก่อนบันทึก');
      return;
    }

    setState(() => _isSaving = true);
    final now = DateTime.now();
    try {
      await widget.dependencies.diary.createEntry(
        MoodEntry(
          id: '',
          userId: userId,
          mood: _selectedMood,
          contextTags: _selectedTags.toList(growable: false),
          diaryText: _diaryController.text,
          createdAt: now,
          updatedAt: now,
        ),
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } on Exception {
      _showMessage('บันทึกไม่สำเร็จ กรุณาตรวจสอบอินเทอร์เน็ตและลองใหม่');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showWritingPrompt() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('หัวข้อช่วยคิด'),
        content: const Text(
          'วันนี้มีเรื่องอะไรเกิดขึ้นบ้าง?\n'
          'เรื่องนั้นทำให้คุณรู้สึกอย่างไร?\n'
          'ตอนนี้อยากบอกอะไรกับตัวเอง?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('เข้าใจแล้ว'),
          ),
        ],
      ),
    );
  }

  String getThaiDate(DateTime date) {
    const months = [
      'ม.ค.',
      'ก.พ.',
      'มี.ค.',
      'เม.ย.',
      'พ.ค.',
      'มิ.ย.',
      'ก.ค.',
      'ส.ค.',
      'ก.ย.',
      'ต.ค.',
      'พ.ย.',
      'ธ.ค.',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F5EE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF222222)),
          onPressed: () => Navigator.pop(context),
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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFEFECE2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: Color(0xFFC48E66),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'วันนี้ - ${getThaiDate(now)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF444444),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            const Text(
              'วันนี้คุณรู้สึกอย่างไรบ้าง?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF222222),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'หยุดพักสักครู่ สังเกตความรู้สึกที่เกิดขึ้นในใจ',
              style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
            ),
            const SizedBox(height: 24),

            // แก้ไขค่าอารมณ์ทั้ง 4 ให้ตรงกับ Constants ตามที่เพื่อนคอมเมนต์ใน PR
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMoodOption(
                  'มีความสุข',
                  Icons.sentiment_satisfied_alt,
                  const Color(0xFFFDEADB),
                  'happy',
                ),
                _buildMoodOption(
                  'โกรธ',
                  Icons.sentiment_very_dissatisfied,
                  const Color(0xFFF4C8C8),
                  'angry',
                ),
                _buildMoodOption(
                  'เศร้า',
                  Icons.sentiment_dissatisfied,
                  const Color(0xFFE2ECF5),
                  'sad',
                ),
                _buildMoodOption(
                  'เฉยๆ',
                  Icons.sentiment_neutral,
                  const Color(0xFFEFECE2),
                  'neutral',
                ),
              ],
            ),
            const SizedBox(height: 32),

            const Text(
              'สิ่งที่อยู่ในใจคุณวันนี้',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF222222),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final tag in MoodMateConstants.contextTags)
                  _buildTagChip(tag, _tagLabels[tag]!),
              ],
            ),
            const SizedBox(height: 32),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFEFECE2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Row(
                        children: [
                          Icon(
                            Icons.edit_note,
                            size: 16,
                            color: Color(0xFFC48E66),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'บันทึกส่วนตัว • ปลอดภัย',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF444444),
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.format_align_left,
                        size: 16,
                        color: Color(0xFF888888),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _diaryController,
                    maxLines: 4,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText:
                          'เขียนบันทึกส่วนตัวของคุณที่นี่... ปล่อยความคิดให้ไหลลื่น ไม่ต้องกังวลว่ามันจะสมบูรณ์แบบ',
                      hintStyle: TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_diaryController.text.trim().isEmpty ? 0 : _diaryController.text.trim().split(RegExp(r'\s+')).length} คำ',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF888888),
                        ),
                      ),
                      InkWell(
                        onTap: _showWritingPrompt,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFFDEADB,
                            ).withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: const [
                              Icon(
                                Icons.lightbulb_outline,
                                size: 14,
                                color: Color(0xFFC48E66),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'อยากได้หัวข้อช่วยคิด?',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFC48E66),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFCF4EE),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.eco,
                      color: Color(0xFF8DC49B),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'ทุกความรู้สึกมีคุณค่าเสมอ',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF222222),
                          ),
                        ),
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
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveEntry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF222222),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'บันทึกความรู้สึก',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodOption(
    String label,
    IconData icon,
    Color color,
    String moodKey,
  ) {
    bool isSelected = _selectedMood == moodKey;
    return GestureDetector(
      onTap: () => setState(() => _selectedMood = moodKey),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: const Color(0xFF333333), width: 2)
                  : null,
            ),
            child: Icon(icon, size: 36, color: const Color(0xFF333333)),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: const Color(0xFF444444),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagChip(String tag, String label) {
    final selected = _selectedTags.contains(tag);
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (value) => setState(() {
        if (value) {
          _selectedTags.add(tag);
        } else {
          _selectedTags.remove(tag);
        }
      }),
    );
  }
}
