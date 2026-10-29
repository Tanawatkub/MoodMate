import 'package:flutter/material.dart';

import '../../app_dependencies.dart';
import '../../core/constants/moodmate_constants.dart';
import '../../core/constants/moodmate_mood_style.dart';
import '../../models/mood_entry.dart';
import 'ai_reflection_screen.dart';

class DiaryDetailScreen extends StatefulWidget {
  const DiaryDetailScreen({
    super.key,
    required this.dependencies,
    required this.entry,
  });

  final AppDependencies dependencies;
  final MoodEntry entry;

  @override
  State<DiaryDetailScreen> createState() => _DiaryDetailScreenState();
}

class _DiaryDetailScreenState extends State<DiaryDetailScreen> {
  bool _isDeleting = false;

  String _formatDate(DateTime date) {
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
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _confirmDelete() async {
    if (_isDeleting) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ลบบันทึกนี้หรือไม่?'),
        content: const Text('เมื่อลบแล้วจะไม่สามารถกู้คืนบันทึกนี้ได้'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final userId = widget.dependencies.auth.currentUserId;
    if (userId == null || userId != widget.entry.userId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ไม่พบสิทธิ์สำหรับลบบันทึกนี้')),
      );
      return;
    }

    setState(() => _isDeleting = true);
    final navigator = Navigator.of(context);
    try {
      await widget.dependencies.diary.deleteEntry(
        userId: userId,
        entryId: widget.entry.id,
      );
      if (mounted) navigator.pop(true);
    } on Exception {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'ลบบันทึกไม่สำเร็จ กรุณาตรวจสอบการเชื่อมต่อแล้วลองใหม่',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  Future<void> _openReflection() async {
    final consented = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ส่งบันทึกไปให้ AI สะท้อนความรู้สึก?'),
        content: const Text(
          'หากตั้งค่า Gemini API key และเรียกใช้งานสำเร็จ เนื้อหาบันทึกนี้และข้อมูล'
          'อารมณ์/แท็กจะถูกส่งไปยังผู้ให้บริการ AI หากไม่มี key หรือเรียก Gemini '
          'ไม่สำเร็จ แอปจะแสดงข้อความสำรองจาก MoodMate ซึ่งไม่ได้มาจาก Gemini '
          'โปรดหลีกเลี่ยงข้อมูลที่ระบุตัวตนได้',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ดำเนินการต่อ'),
          ),
        ],
      ),
    );
    if (consented != true || !mounted) return;
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => AiReflectionScreen(
          dependencies: widget.dependencies,
          entry: widget.entry,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final moodLabel =
        MoodMateConstants.moodLabels[widget.entry.mood] ?? widget.entry.mood;
    return Scaffold(
      backgroundColor: const Color(0xFFF6F5EE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(_formatDate(widget.entry.createdAt)),
        actions: [
          IconButton(
            tooltip: 'ลบบันทึก',
            onPressed: _isDeleting ? null : _confirmDelete,
            icon: const Icon(Icons.delete_outline, color: Colors.red),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          CircleAvatar(
            radius: 44,
            backgroundColor: MoodMateMoodStyle.backgroundColorFor(
              widget.entry.mood,
            ),
            child: Icon(
              _moodIcon(widget.entry.mood),
              size: 48,
              color: MoodMateMoodStyle.foregroundColor,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              moodLabel,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              '${widget.entry.createdAt.hour.toString().padLeft(2, '0')}:'
              '${widget.entry.createdAt.minute.toString().padLeft(2, '0')} น.',
              style: const TextStyle(color: Color(0xFF888888)),
            ),
          ),
          const SizedBox(height: 24),
          if (widget.entry.contextTags.isNotEmpty)
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: widget.entry.contextTags
                  .map((tag) => Chip(label: Text(tag)))
                  .toList(),
            ),
          const SizedBox(height: 24),
          Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                widget.entry.diaryText.isEmpty
                    ? 'ไม่มีข้อความบันทึก'
                    : widget.entry.diaryText,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF444444),
                  height: 1.8,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            color: Colors.white,
            child: ListTile(
              leading: const Icon(Icons.auto_awesome, color: Color(0xFFC48E66)),
              title: const Text('สะท้อนความรู้สึกด้วย MoodMate'),
              subtitle: const Text('ผลลัพธ์อ้างอิงจากบันทึกนี้เท่านั้น'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _openReflection,
            ),
          ),
        ],
      ),
    );
  }

  IconData _moodIcon(String mood) {
    switch (mood) {
      case 'happy':
        return Icons.sentiment_satisfied_alt;
      case 'angry':
        return Icons.sentiment_very_dissatisfied;
      case 'sad':
        return Icons.sentiment_dissatisfied;
      default:
        return Icons.sentiment_neutral;
    }
  }
}
