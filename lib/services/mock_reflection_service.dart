// lib/services/mock_reflection_service.dart
//
// MoodMate — คนที่ 3 (Gemini AI) | branch: feature/gemini-ai
//
// ใช้ 2 งาน:
//  1) เป็น ReflectionService จำลองให้ UI (คนที่ 1) ใช้ตอนพัฒนาแยกใน Phase 2
//  2) เป็น Fallback กลางของ GeminiReflectionService เมื่อ API มีปัญหา/Offline
//     (ข้อความ fallback, ข้อความวิกฤต และ disclaimer จึงอยู่ที่ไฟล์นี้ที่เดียว)
//
// ผลลัพธ์เป็น deterministic (อินพุตเดิม → ผลเดิม) เพื่อให้ทดสอบได้ง่าย
// ไม่ log diary text

import '../core/constants/moodmate_constants.dart';
import '../models/reflection_result.dart';
import '../models/weekly_insight.dart';
import 'reflection_service.dart';

class MockReflectionService implements ReflectionService {
  /// [delay] ใช้จำลอง loading ใน UI (ค่าเริ่มต้น = ไม่หน่วง เหมาะกับ test/fallback)
  const MockReflectionService({this.delay = Duration.zero});

  final Duration delay;

  @override
  Future<String> summarizeInsight({required WeeklyInsight insight}) async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    if (insight.totalEntries == 0) {
      return 'ยังไม่มีบันทึกในช่วงเวลานี้ เมื่อเริ่มบันทึกอารมณ์ MoodMate '
          'จะแสดงแนวโน้มจากข้อมูลของคุณที่นี่';
    }

    final topMood = insight.moodCounts.entries.reduce(
      (a, b) => a.value >= b.value ? a : b,
    );
    final topTag = insight.contextCounts.entries.isEmpty
        ? null
        : insight.contextCounts.entries.reduce(
            (a, b) => a.value >= b.value ? a : b,
          );
    final moodLabel = MoodMateConstants.moodLabels[topMood.key] ?? topMood.key;
    final tagLabel = topTag == null
        ? null
        : MoodMateConstants.contextTagLabels[topTag.key] ?? topTag.key;
    final tagText = topTag == null
        ? 'ยังไม่มีบริบทที่บันทึกซ้ำเด่นชัด'
        : 'บริบทที่พบบ่อยคือ $tagLabel (${topTag.value} ครั้ง)';
    return 'ช่วงนี้คุณบันทึกความรู้สึก ${insight.totalEntries} ครั้ง '
        'อารมณ์ที่พบมากที่สุดคือ$moodLabel (${topMood.value} ครั้ง) '
        'และ$tagText สถิตินี้บอกเพียงสิ่งที่ถูกบันทึก ไม่ได้ยืนยันสาเหตุ';
  }

  /// Disclaimer เรื่องสุขภาพจิต แนบกับผลลัพธ์ทุกครั้ง
  static const String disclaimerText =
      'ข้อความนี้สร้างโดย AI เพื่อช่วยให้คุณทบทวนความรู้สึกของตัวเองเท่านั้น '
      'ไม่ใช่การวินิจฉัยหรือคำแนะนำทางการแพทย์ หากรู้สึกไม่ไหวหรือกังวลเกี่ยวกับ'
      'สุขภาพใจ ควรปรึกษานักจิตวิทยา แพทย์ หรือสายด่วนสุขภาพจิต 1323 (กรมสุขภาพจิต)';

  /// ข้อความสะท้อนตาม mood — key ต้องครอบคลุม MoodMateConstants.moods ทุกค่า
  /// (มี test ตรวจไว้)
  static const Map<String, String> _reflectionByMood = {
    'happy':
        'ดูเหมือนวันนี้มีบางอย่างที่ทำให้รู้สึกดี ขอบคุณที่เก็บช่วงเวลานี้ไว้ในบันทึก '
        'การสังเกตว่าอะไรทำให้เรารู้สึกดีอาจช่วยให้เราจดจำมันได้ชัดขึ้น',
    'angry':
        'ฟังดูเหมือนวันนี้มีบางอย่างที่ทำให้รู้สึกหงุดหงิดหรือไม่เป็นไปตามที่หวัง '
        'ความรู้สึกแบบนี้เกิดขึ้นได้ และการได้เขียนออกมาก็เป็นก้าวหนึ่งของการรับฟังตัวเอง',
    'sad':
        'ดูเหมือนว่าวันนี้อาจมีบางเรื่องที่กระทบใจอยู่ ขอบคุณที่เล่าให้ MoodMate ฟัง '
        'ไม่ต้องรีบทำให้ความรู้สึกนี้หายไปก็ได้ ให้เวลากับตัวเองสักครู่',
    'neutral':
        'ขอบคุณที่ใช้เวลาเขียนบันทึกวันนี้ แม้เป็นวันที่ไม่ได้มีอะไรพิเศษ '
        'การหยุดสังเกตความรู้สึกของตัวเองก็มีคุณค่าในตัวมันเอง',
  };

  /// Micro-action ตาม mood — key ต้องครอบคลุม MoodMateConstants.moods ทุกค่า
  static const Map<String, String> _actionByMood = {
    'happy': 'ลองจดสั้น ๆ สักบรรทัดว่าอะไรทำให้วันนี้ดี',
    'angry': 'ลองหายใจเข้าลึก ๆ ช้า ๆ สามครั้ง แล้วดื่มน้ำสักแก้ว',
    'sad': 'ลองพักสายตาจากหน้าจอสักหนึ่งนาที แล้วดื่มน้ำสักอึก',
    'neutral': 'ลองยืดเส้นยืดสายเบา ๆ หรือพักสายตาจากหน้าจอสักครู่',
  };

  static const String _emptyText =
      'ตอนนี้ยังไม่มีข้อความในบันทึก ถ้าพร้อมเมื่อไหร่ ลองเขียนสิ่งที่อยู่ในใจสั้น ๆ '
      'สักประโยคก็ได้ แล้วค่อยกลับมาให้ MoodMate ช่วยสะท้อนอีกครั้งนะ';

  static const String _emptyAction =
      'ลองหายใจเข้าลึก ๆ ช้า ๆ สักสองสามครั้งก่อนเริ่มเขียน';

  static const String _crisisText =
      'ขอบคุณที่ไว้ใจเขียนเรื่องนี้ลงมา สิ่งที่เล่าฟังดูหนักมากจริง ๆ '
      'และคุณไม่จำเป็นต้องแบกมันไว้คนเดียว ถ้ารู้สึกว่าอาจทำร้ายตัวเอง '
      'ขอให้ติดต่อคนที่ไว้ใจหรือสายด่วนสุขภาพจิต 1323 (กรมสุขภาพจิต) ได้เลยนะ';

  static const String _crisisAction =
      'ลองบอกคนที่ไว้ใจสักคนตอนนี้ว่า "ตอนนี้ฉันรู้สึกไม่ไหว อยู่เป็นเพื่อนหน่อยได้ไหม"';

  /// คำที่บ่งชี้ความเสี่ยงสูง (keyword แบบง่าย — เป็นชั้นป้องกันเสริม
  /// ไม่ใช่ระบบคัดกรองทางคลินิก)
  static const List<String> _crisisKeywords = [
    'ฆ่าตัวตาย',
    'อยากตาย',
    'ไม่อยากมีชีวิต',
    'ไม่อยากอยู่ต่อ',
    'จบชีวิต',
    'ทำร้ายตัวเอง',
    'กรีดแขน',
    'suicide',
  ];

  static bool containsCrisisSignal(String text) {
    final lower = text.toLowerCase();
    return _crisisKeywords.any(lower.contains);
  }

  /// Micro-action ตาม mood (mood ที่ไม่รู้จักใช้ของ neutral)
  static String actionFor(String mood) =>
      _actionByMood[mood] ?? _actionByMood['neutral']!;

  @override
  Future<ReflectionResult> reflect({
    required String diaryText,
    required String mood,
    required List<String> contextTags,
  }) async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }

    final text = diaryText.trim();

    if (text.isEmpty) {
      return ReflectionResult(
        reflectionText: _emptyText,
        suggestedAction: _emptyAction,
        disclaimer: disclaimerText,
      );
    }

    if (containsCrisisSignal(text)) {
      return ReflectionResult(
        reflectionText: _crisisText,
        suggestedAction: _crisisAction,
        disclaimer: disclaimerText,
      );
    }

    final safeMood = MoodMateConstants.moods.contains(mood) ? mood : 'neutral';
    final tags = contextTags
        .where(MoodMateConstants.contextTags.contains)
        .toList(growable: false);

    final base = _reflectionByMood[safeMood]!;
    final tagNote = tags.isEmpty
        ? ''
        : ' (วันนี้คุณเลือกบริบท: ${tags.join(', ')})';

    return ReflectionResult(
      reflectionText: '$base$tagNote',
      suggestedAction: actionFor(safeMood),
      disclaimer: disclaimerText,
    );
  }
}
