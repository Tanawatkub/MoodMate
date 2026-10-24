/// ค่ากลางของ MoodMate — ห้ามแก้โดยไม่คุยทีม
/// ค่าในรายการเหล่านี้คือค่าที่บันทึกลง Model/Database
/// (Firestore Security Rules ตรวจค่าชุดเดียวกันนี้ ถ้าแก้ต้องแก้ firestore.rules ด้วย)
class MoodMateConstants {
  const MoodMateConstants._();

  /// Mood values ที่เก็บใน Model/Database
  static const moods = <String>['happy', 'angry', 'sad', 'neutral'];

  /// ป้ายที่แสดงบน UI (ไม่ใช่ค่าที่เก็บ)
  static const moodLabels = <String, String>{
    'happy': 'ยิ้ม',
    'angry': 'โกรธ',
    'sad': 'เศร้า',
    'neutral': 'เฉย ๆ',
  };

  /// Context tags ที่เก็บใน Model/Database
  static const contextTags = <String>[
    'Coding',
    'Lab',
    'Project',
    'Group Work',
    'Presentation',
    'Deadline',
    'Personal',
  ];
}