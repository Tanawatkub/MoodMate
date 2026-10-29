# MoodMate — AI Project Context & Team Integration Guide

> **เป้าหมาย:** เป็นเอกสารกลางให้สมาชิกและ AI อ่านก่อนเขียนโค้ด เพื่อให้ใช้ชื่อไฟล์ โฟลเดอร์ Model, Interface และรูปแบบข้อมูลตรงกัน
>
> **กติกาหลัก:** ห้ามเปลี่ยนชื่อไฟล์, class, method, field หรือ Interface กลางโดยไม่คุยกับทีมก่อน หากเปลี่ยนต้องแก้เอกสารนี้และทุกส่วนที่เชื่อมต่อด้วย

## 1. ข้อมูลโครงการ

- **ชื่อ:** MoodMate — Daily Mood & Reflection Companion
- **แพลตฟอร์ม:** Flutter mobile app, Material Design 3
- **เป้าหมาย:** บันทึกอารมณ์และบริบทประจำวัน เขียน Diary ส่วนตัว รับการสะท้อนความคิดจาก AI และดูแนวโน้มรายสัปดาห์
- **Flow:** `Check-in → Vent → Reflect → Understand`
- **Stack ตามแนวคิดโครงการ:** Flutter, Firebase Authentication, Cloud Firestore, Local Database (ยังไม่เลือก Hive/Isar/SQLite), Gemini API, GitHub, GitHub Actions
- **ข้อเสนอ Backend:** Firebase Authentication + Cloud Firestore เพื่อให้ตรงกับ stack ที่วางไว้เดิม
- **ข้อควรระวัง:** โครงสร้างนี้เป็นมาตรฐานเริ่มต้น ต้องตรวจโค้ดจริงก่อนแก้/ย้ายไฟล์ ห้ามสร้างไฟล์ซ้ำหรือลบไฟล์เดิมโดยอัตโนมัติ

## 2. สมาชิกและ Branch

การจับคู่ชื่อกับหน้าที่นี้เป็น **ข้อเสนอเริ่มต้น** หากทีมแบ่งต่างออกไป ให้แก้ตารางนี้ แต่คง contract กลางไว้

| สมาชิก | Branch | หน้าที่ |
|---|---|---|
| **ยังไม่เลือก** | `feature/frontend-ui` | คนที่ 1 — Frontend & UI |
| **ยังไม่เลือก** | `feature/firebase-data` | คนที่ 2 — Firebase & Data |
| **ยังไม่เลือก** | `feature/gemini-ai` | คนที่ 3 — Gemini AI |
| **ยังไม่เลือก** | `feature/weekly-insight` | คนที่ 4 — Weekly Insight & Testing |

Branches กลาง: `main` (โค้ดที่ตรวจแล้ว), `feature/frontend-ui`, `feature/firebase-data`, `feature/gemini-ai`, `feature/weekly-insight` ห้าม push งานทดลองตรงเข้า `main`; ให้เปิด Pull Request (PR) และตรวจโค้ดก่อน merge

ตัวอย่างเริ่มงาน:

```bash
git switch main
git pull origin main
git switch -c feature/frontend-ui
```

เปลี่ยนชื่อ branch ตามหน้าที่ของแต่ละคน ห้าม commit `.env`, API key, password หรือ Firebase Admin credentials

## 3. โครงสร้างโฟลเดอร์มาตรฐาน

```text
moodmate/
├── README.md
├── MOODMATE_PROJECT_CONTEXT.md
├── pubspec.yaml
├── analysis_options.yaml
├── .gitignore
├── .env.example
├── docs/
│   ├── architecture.md
│   ├── data-contracts.md
│   └── testing.md
├── test/
│   ├── models/
│   ├── services/
│   ├── repositories/
│   └── features/
└── lib/
    ├── main.dart
    ├── app.dart
    ├── core/
    │   ├── constants/
    │   │   ├── moodmate_constants.dart
    │   │   └── app_routes.dart
    │   ├── errors/app_exception.dart
    │   ├── theme/app_theme.dart
    │   └── utils/date_utils.dart
    ├── models/
    │   ├── mood_entry.dart
    │   ├── reflection_result.dart
    │   └── weekly_insight.dart
    ├── repositories/
    │   ├── diary_repository.dart
    │   ├── firestore_diary_repository.dart
    │   └── mock_diary_repository.dart
    ├── services/
    │   ├── reflection_service.dart
    │   ├── gemini_reflection_service.dart
    │   └── mock_reflection_service.dart
    ├── features/
    │   ├── auth/
    │   │   ├── login_page.dart
    │   │   └── auth_service.dart
    │   ├── home/home_page.dart
    │   ├── mood_checkin/mood_checkin_page.dart
    │   ├── diary/
    │   │   ├── diary_page.dart
    │   │   ├── diary_form_page.dart
    │   │   └── diary_detail_page.dart
    │   ├── reflection/reflection_page.dart
    │   └── weekly_insight/
    │       ├── weekly_insight_page.dart
    │       └── weekly_insight_calculator.dart
    └── widgets/
        ├── primary_button.dart
        ├── mood_selector.dart
        ├── context_tag_selector.dart
        ├── diary_card.dart
        ├── loading_view.dart
        └── error_view.dart
```

### กติกาตั้งชื่อและการวางไฟล์

- ชื่อไฟล์ใช้ `snake_case.dart` เช่น `mood_entry.dart`
- ชื่อ class ใช้ `PascalCase` เช่น `MoodEntry`; method/variable ใช้ `camelCase`
- `features/` เก็บหน้าจอและ logic เฉพาะฟีเจอร์; `models/` เก็บข้อมูลกลาง; `repositories/` เก็บการอ่าน/เขียนข้อมูล; `services/` เก็บบริการภายนอก
- UI ห้ามเรียก Firestore หรือ Gemini SDK โดยตรง ให้เรียกผ่าน interface
- หากโปรเจกต์มีไฟล์/โครงสร้างอยู่แล้ว ให้ตรวจสอบก่อนสร้าง ห้ามสร้างชื่อซ้ำหรือย้ายไฟล์ทั้งหมดโดยไม่ตรวจผลกระทบ

## 4. Data Models ที่ต้องใช้ชื่อเดียวกัน

### `MoodEntry` — `lib/models/mood_entry.dart`

| Field | Type | ความหมาย |
|---|---|---|
| `id` | `String` | ID รายการ |
| `userId` | `String` | UID เจ้าของข้อมูล |
| `mood` | `String` | mood หนึ่งค่า |
| `contextTags` | `List<String>` | บริบทหลายค่าได้ |
| `diaryText` | `String` | ข้อความบันทึก |
| `createdAt` | `DateTime` | เวลาสร้าง |
| `updatedAt` | `DateTime` | เวลาแก้ไขล่าสุด |

ห้ามใช้ชื่อแทนโดยพลการ เช่น `emotion`, `tags`, `content`, `timestamp`

Mood values ที่เก็บใน Model/Database:

```dart
static const moods = <String>['happy', 'angry', 'sad', 'neutral'];
```

ป้าย UI: `happy` → `ยิ้ม`, `angry` → `โกรธ`, `sad` → `เศร้า`, `neutral` → `เฉย ๆ`

Context tags ที่เก็บใน Model/Database:

```dart
static const contextTags = <String>[
  'Coding', 'Lab', 'Project', 'Group Work',
  'Presentation', 'Deadline', 'Personal',
];
```

ให้ UI แสดง label ได้ แต่ค่าที่บันทึกต้องตรงตามรายการกลาง

### `ReflectionResult` — `lib/models/reflection_result.dart`

- `reflectionText: String` — ข้อความสะท้อนความคิด (จำเป็น)
- `suggestedAction: String?` — ข้อเสนอแนะเล็ก ๆ (ไม่บังคับ)
- `disclaimer: String?` — ข้อความกำกับ (ไม่บังคับ)
- `source: ReflectionSource` — แหล่งที่มาของผลลัพธ์ (`gemini` หรือ `localFallback`); ค่าเริ่มต้นเป็น `localFallback`

UI ต้องได้รับ `ReflectionResult` ไม่ใช่แกะ JSON ของ Gemini เอง

### `WeeklyInsight` — `lib/models/weekly_insight.dart`

- `weekStart: DateTime`
- `weekEnd: DateTime`
- `totalEntries: int`
- `moodCounts: Map<String, int>`
- `contextCounts: Map<String, int>`

วิธีนับ: หนึ่ง `MoodEntry` = หนึ่ง `totalEntries`; mood นับหนึ่งครั้งต่อรายการ; tag แต่ละตัวใน `contextTags` นับหนึ่งครั้งในรายการนั้น Dashboard ต้องใช้สูตรเดียวจาก `WeeklyInsightCalculator` ไม่คำนวณแยกกันในแต่ละ Widget

## 5. Interface กลาง — ห้ามเปลี่ยนเองโดยไม่คุยทีม

### `lib/repositories/diary_repository.dart`

```dart
abstract class DiaryRepository {
  Future<List<MoodEntry>> getEntries({
    required String userId,
    DateTime? from,
    DateTime? to,
  });

  Future<MoodEntry> createEntry(MoodEntry entry);
  Future<MoodEntry> updateEntry(MoodEntry entry);

  Future<void> deleteEntry({
    required String userId,
    required String entryId,
  });
}
```

- คนที่ 1 เรียก interface นี้เท่านั้น
- คนที่ 2 ทำ `FirestoreDiaryRepository` ให้ implement interface นี้
- mock repository ต้องมี method/signature เดียวกัน
- `getEntries()` ต้องใช้ขอบเขตเวลาแบบเดียวกันทุก implementation และคืนเฉพาะข้อมูลของ user ที่ระบุ
- repository จริงควรกำหนด ID และเวลาให้รายการใหม่อย่างสม่ำเสมอ

### `lib/services/reflection_service.dart`

```dart
abstract class ReflectionService {
  Future<ReflectionResult> reflect({
    required String diaryText,
    required String mood,
    required List<String> contextTags,
  });
}
```

- คนที่ 1 เรียก `ReflectionService`; คนที่ 3 ทำ `GeminiReflectionService` และ `MockReflectionService`
- ไม่ส่ง `userId`, email หรือข้อมูลระบุตัวตนไป Gemini หากไม่จำเป็น
- ห้าม log diary text หรือ API key

### `lib/features/weekly_insight/weekly_insight_calculator.dart`

```dart
class WeeklyInsightCalculator {
  WeeklyInsight calculate({
    required List<MoodEntry> entries,
    required DateTime weekStart,
    required DateTime weekEnd,
  });
}
```

คำนวณช่วง `[weekStart, weekEnd)` คือรวมเวลาเริ่มต้น แต่ไม่รวมเวลาสิ้นสุด ป้องกันการนับซ้ำที่ขอบช่วง รับ list เข้ามาและไม่เรียก Firebase เอง

## 6. Firestore Data Contract — คนที่ 2

โครงสร้างเริ่มต้นที่เสนอ:

```text
users/{userId}/mood_entries/{entryId}
```

ตัวอย่าง document:

```json
{
  "userId": "firebase-auth-uid",
  "mood": "sad",
  "contextTags": ["Lab", "Deadline"],
  "diaryText": "รู้สึกกดดันกับงานที่ต้องส่ง",
  "createdAt": "Firestore Timestamp",
  "updatedAt": "Firestore Timestamp"
}
```

- path ของข้อมูลต้องผูกกับ UID จาก Firebase Authentication
- Security Rules ต้องตรวจ `request.auth.uid` และให้ผู้ใช้เข้าถึงเฉพาะข้อมูลของตนเอง ห้ามเชื่อ `userId` จาก UI เพียงอย่างเดียว
- แปลง Firestore Timestamp ↔ `DateTime` ใน repository ไม่ให้ UI จัดการ Timestamp โดยตรง
- ตรวจ Firebase config จริงก่อนสร้าง collection/rules; โครงสร้างนี้เป็นข้อเสนอเริ่มต้น

## 7. รายละเอียดงานของแต่ละคน

### คนที่ 1 — Frontend & UI
**Branch:** `feature/frontend-ui`

**ไฟล์หลัก:** `lib/app.dart`, `lib/core/constants/app_routes.dart`, `lib/features/home/home_page.dart`, `lib/features/mood_checkin/mood_checkin_page.dart`, `lib/features/diary/diary_page.dart`, `lib/features/diary/diary_form_page.dart`, `lib/features/diary/diary_detail_page.dart`, `lib/features/reflection/reflection_page.dart`, `lib/widgets/`

**งาน:** ทำ Navigation และหน้าจอตาม flow; รับ mood/tags/diary text; validate ฟอร์ม; เรียก `DiaryRepository` และ `ReflectionService`; แสดง loading/empty/success/error; เริ่มด้วย mock ได้; ห้าม import Firestore/Gemini SDK ใน Widget

**ส่งมอบ:** หน้าจอและ Navigation ทำงาน รับข้อมูลได้ ใช้ Model/Interface กลาง และมีสถานะ loading/error/empty

### คนที่ 2 — Firebase & Data
**Branch:** `feature/firebase-data`

**ไฟล์หลัก:** `lib/features/auth/auth_service.dart`, `lib/repositories/diary_repository.dart` (ตกลง contract ร่วมกัน), `lib/repositories/firestore_diary_repository.dart`, `lib/repositories/mock_diary_repository.dart` (ประสานทีม), `firebase.json`, `firestore.rules`, `firestore.indexes.json` (ถ้าจำเป็น), Firebase config ที่ CLI สร้าง

**งาน:** ตั้ง Firebase; ทำ Authentication ตามวิธีที่ตกลง; ทำ CRUD และ mapping `MoodEntry`; เขียน Security Rules; เตรียมข้อมูลตัวอย่าง; ทดสอบ repository และสิทธิ์

**ส่งมอบ:** Auth และ CRUD ใช้ได้ตามขอบเขต, interface ตรงกัน, rules จำกัดข้อมูลตามผู้ใช้ และมีวิธีตั้งค่าสำหรับทีม

### คนที่ 3 — Gemini AI
**Branch:** `feature/gemini-ai`

**ไฟล์หลัก:** `lib/models/reflection_result.dart`, `lib/services/reflection_service.dart` (ร่วมตกลง contract), `lib/services/gemini_reflection_service.dart`, `lib/services/mock_reflection_service.dart`

**งาน:** ออกแบบ prompt ที่เข้าใจและไม่ตัดสิน; รับ input ตาม interface; แปลง response เป็น `ReflectionResult`; จัดการ timeout/error/empty/format ผิด; ทำ mock service; ไม่วินิจฉัยโรค ไม่กล่าวโทษบุคคลที่สาม ไม่แต่งรายละเอียดเพิ่ม; ไม่ log diary/key; ห้าม commit API key

**ส่งมอบ:** `reflect()` ทำงานตาม contract มีผลลัพธ์รูปแบบคงที่ และมี test สำหรับ success/error/empty input

### คนที่ 4 — Weekly Insight & Testing
**Branch:** `feature/weekly-insight`

**ไฟล์หลัก:** `lib/models/weekly_insight.dart`, `lib/features/weekly_insight/weekly_insight_page.dart`, `lib/features/weekly_insight/weekly_insight_calculator.dart`, `test/`, `docs/testing.md`

**งาน:** ทำ calculator ที่ไม่ผูก Firebase; สรุป mood/context รายสัปดาห์; ทำ Dashboard/กราฟและ empty state; ใช้ mock data; เขียน unit/integration tests; ทำคู่มือทดสอบ

**ส่งมอบ:** Dashboard ใช้ `WeeklyInsight`, มี test ที่ตรวจ expected result ได้ และอธิบายแนวโน้ม/ความถี่โดยไม่อ้างเป็นการวินิจฉัยหรือยืนยันสาเหตุ

## 8. ลำดับการทำงานร่วมกัน

### Phase 1 — ตกลงก่อนแยกงาน
- [ ] ยืนยันชื่อ field ใน `MoodEntry`
- [ ] ยืนยัน mood values และ context tags
- [ ] ยืนยัน signature ของ `DiaryRepository` และ `ReflectionService`
- [ ] ยืนยัน `ReflectionResult` และ `WeeklyInsight`
- [ ] ตกลงช่วงวัน/วันเริ่มต้นสัปดาห์
- [ ] ตกลงวิธี Login
- [ ] ตัดสินใจว่าจะใช้ Local Database หรือไม่ และใช้ตัวไหน
- [ ] ตกลง route names และขอบเขตหน้าจอ

### Phase 2 — ทำแยกด้วย Mock
- คนที่ 1 ทำ UI ด้วย `MockDiaryRepository` และ `MockReflectionService`
- คนที่ 2 ทำ Firebase/Auth/repository implementation
- คนที่ 3 ทำ Gemini service และ mock response
- คนที่ 4 ทำ calculator/dashboard/test ด้วย sample data

### Phase 3 — Integration
1. รวม Model และ interface กลางก่อน
2. เปลี่ยน mock เป็น Firestore repository ที่จุดประกอบระบบจุดเดียว
3. เชื่อม Reflection UI กับ `GeminiReflectionService`
4. ส่งรายการจาก repository เข้า `WeeklyInsightCalculator`
5. ทดสอบ flow: Login → Check-in/Diary → Save → เปิดรายการ → AI Reflection → Weekly Insight
6. ทดสอบ Security Rules ด้วยผู้ใช้มากกว่าหนึ่งบัญชี
7. ตรวจโค้ดผ่าน PR ก่อน merge เข้า `main`

## 9. ความเป็นส่วนตัวและขอบเขต AI

- Diary เป็นข้อมูลส่วนตัว ต้องแสดงเฉพาะเจ้าของข้อมูล
- ใช้ Security Rules ตรวจสิทธิ์จริง ไม่พึ่งการซ่อน UI
- ส่งข้อมูลไป AI เท่าที่จำเป็น ไม่ส่งข้อมูลระบุตัวตนโดยไม่จำเป็น
- AI ช่วยทบทวนความคิด ไม่ใช่เครื่องมือวินิจฉัยโรคหรือคำแนะนำทางการแพทย์
- AI ต้องไม่แต่งข้อเท็จจริงหรือสรุปเกินข้อความที่ได้รับ
- จัดการ API ล้มเหลวโดยไม่ทำให้ Diary ที่บันทึกไว้หาย
- ห้ามพิมพ์ diary text, token, password หรือ API key ลง log
- ต้องตกลงวิธีเก็บ ลบ และ sync ข้อมูลก่อนเปิดใช้จริง

## 10. Checklist การทดสอบ

- **Validation:** mood ต้องเป็นค่าที่กำหนด; tags ต้องตรงรายการ; ตรวจ diary text ว่าง/ไม่ว่างตามกติกาฟอร์ม
- **Repository/Auth:** CRUD ทำงาน; ผู้ใช้ A อ่าน/แก้/ลบข้อมูล B ไม่ได้; Timestamp map ถูกต้อง; network error ไม่ทำให้แอป crash
- **Gemini:** success, timeout, error, empty response, response format ผิด; ไม่มี key ใน Git; prompt ไม่วินิจฉัย/กล่าวโทษ/แต่งเรื่อง
- **Weekly Insight:** รายการว่าง; mood counts; tag counts; ขอบเวลา `[weekStart, weekEnd)`; timezone/วันเริ่มสัปดาห์ใช้กติกาเดียวกัน
- **Integration:** login → create entry → read entry → AI reflection → dashboard; logout แล้วข้อมูลเดิมต้องไม่ปรากฏแก่ผู้ใช้ถัดไป; UI ทดสอบได้ด้วย mock

## 11. กติกาสำหรับ AI Coding Assistant

เมื่อ AI ช่วยเขียนโค้ด ให้ทำตามนี้:

1. อ่าน `MOODMATE_PROJECT_CONTEXT.md`, `docs/architecture.md`, `docs/data-contracts.md` ก่อนแก้ หากมีไฟล์เหล่านั้น
2. ตรวจโครงสร้างจริงและ `pubspec.yaml` ก่อนสร้าง/แก้ไฟล์
3. ใช้ชื่อไฟล์, class, field, method, mood values, tags และ Interface ตามเอกสาร
4. ห้ามสร้าง Model/repository/service/widget ซ้ำ หากมีอยู่แล้วให้แก้ของเดิมอย่างระมัดระวัง
5. ห้ามเปลี่ยน signature/data contract โดยไม่แจ้งเหตุผลและไฟล์ที่ได้รับผลกระทบ
6. ทำเฉพาะ scope ของ branch ที่รับผิดชอบ หากพบปัญหาข้ามส่วนให้แจ้งทีมก่อนแก้ไฟล์ของคนอื่น
7. สำหรับงานหลายไฟล์ ให้บอกไฟล์ที่จะสร้าง/แก้ก่อนลงมือ
8. หลังแก้ ให้สรุปไฟล์ที่เปลี่ยน วิธีทดสอบ และงานที่ยังไม่เสร็จ
9. ห้ามใส่ secrets, API keys หรือ diary จริงใน source, committed fixtures หรือ logs
10. หากเอกสารไม่พอหรือขัดกับโค้ดจริง ให้ถาม/เสนอทางเลือกก่อน ห้ามเดาแล้วตั้งมาตรฐานใหม่เอง
11. ห้ามอ้างว่าทดสอบผ่านหากไม่ได้รันคำสั่งทดสอบจริง

**Prompt สั้นสำหรับคัดลอกไปให้ AI:**

> อ่าน `MOODMATE_PROJECT_CONTEXT.md` ก่อนเริ่มงาน ตรวจไฟล์จริงในโปรเจกต์ก่อนแก้ไข และทำเฉพาะงานของ branch ที่ฉันรับผิดชอบ ใช้ชื่อ Model, field, Interface, method และโครงสร้างโฟลเดอร์ตามเอกสารนี้ ห้ามสร้างชื่อซ้ำหรือเปลี่ยน contract เอง หากต้องเปลี่ยนให้บอกเหตุผลและไฟล์ที่ได้รับผลกระทบก่อน จากนั้นสรุปไฟล์ที่แก้และวิธีทดสอบ โดยห้ามใส่ secret ลง Git

## 12. เรื่องที่ทีมต้องยืนยันก่อนถือเป็นมาตรฐานสุดท้าย

- [ ] การจับคู่สมาชิกกับหน้าที่ตรงตามตารางหรือไม่
- [ ] วิธี Login: Email/Password, Google หรือวิธีอื่น
- [ ] จะใช้ Local Database หรือไม่ (Hive/Isar/SQLite)
- [ ] Diary ต้องมี mood check-in ทุกครั้งหรือไม่
- [ ] ต้องรองรับแก้ไข/ลบ Diary และเก็บประวัติ Reflection หรือไม่
- [ ] วิธีเก็บ Gemini API key ให้ปลอดภัยสำหรับการทดลอง
- [ ] timezone และวันเริ่มต้นสัปดาห์ของ Dashboard
- [ ] ต้อง sync offline หรือใช้งานออนไลน์อย่างเดียว
- [ ] Flutter/Dart version และ dependencies ที่ใช้จริง

ก่อนเริ่มเขียนโค้ดจริง ให้ทีมตรวจรายการนี้ และอัปเดต `docs/data-contracts.md` ให้ตรงกับข้อตกลงสุดท้าย จากนั้นทุกคนยึดเอกสารเดียวกัน
