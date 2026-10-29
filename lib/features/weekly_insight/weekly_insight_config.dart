import '../../core/constants/moodmate_constants.dart';

// Weekly Insight ใช้ค่ากลางของทีม ไม่นิยามค่าเอง
const List<String> weeklyInsightMoods = MoodMateConstants.moods;

const Map<String, String> weeklyInsightMoodLabels =
    MoodMateConstants.moodLabels;

const List<String> weeklyInsightContextTags = MoodMateConstants.contextTags;

const Map<String, String> weeklyInsightContextTagLabels =
    MoodMateConstants.contextTagLabels;

/// จำนวนรายการขั้นต่ำที่ถือว่าข้อมูลเพียงพอ
/// (ข้อเสนอของคนที่ 4 รอทีมยืนยัน เอกสารกลางยังไม่กำหนดเกณฑ์ แก้ที่นี่ที่เดียว)
const int weeklyInsightMinEntries = 3;