# MoodMate — Data Contracts (ข้อตกลงข้อมูลและบัญชีผู้ใช้)

> เอกสารนี้อธิบายสิ่งที่ **มีอยู่จริงใน `main`** ฝั่ง Firebase & Data ให้สมาชิกและ AI อ่านก่อนเขียนโค้ดที่ต้องเชื่อมกับข้อมูลหรือบัญชี
> ใช้ร่วมกับ `MOODMATE_PROJECT_CONTEXT.md` และ `MOODMATE_PROJECT_GIT.md` (สัญญากลางของ `ReflectionService`, `ReflectionResult`, `WeeklyInsight` อยู่ใน `MOODMATE_PROJECT_GIT.md` หัวข้อ 4-5)
> **กติกา:** ห้ามเปลี่ยนชื่อไฟล์ class method field หรือค่าที่เก็บในเอกสารนี้โดยไม่คุยทีม หากเปลี่ยน ต้องแก้เอกสารนี้ `firestore.rules` และทุกส่วนที่เชื่อมต่อในงานเดียวกัน

อัปเดตล่าสุด: 24 ต.ค. 2026 (ผู้รับผิดชอบ: คนที่ 2 — Firebase & Data)

---

## 1. ไฟล์กลางและเจ้าของ

| ไฟล์ | หน้าที่ | เจ้าของ |
|---|---|---|
| `lib/core/constants/moodmate_constants.dart` | ค่า mood และ context tags | ของกลาง |
| `lib/models/mood_entry.dart` | รูปแบบหนึ่งรายการบันทึก | ของกลาง |
| `lib/repositories/diary_repository.dart` | interface อ่าน/เขียนบันทึก | คนที่ 2 + คนที่ 1 ตกลงร่วมกัน |
| `lib/repositories/firestore_diary_repository.dart` | ตัวจริง (Cloud Firestore) | คนที่ 2 |
| `lib/repositories/mock_diary_repository.dart` | ตัวจำลองในหน่วยความจำ + ข้อมูลตัวอย่าง | คนที่ 2 |
| `lib/features/auth/auth_service.dart` | interface บัญชีผู้ใช้ + `AuthException` | คนที่ 2 + คนที่ 1 ตกลงร่วมกัน |
| `lib/features/auth/firebase_auth_service.dart` | ตัวจริง (Firebase Authentication) | คนที่ 2 |
| `lib/app_dependencies.dart` | จุดประกอบระบบจุดเดียว | คนที่ 2 (ข้อเสนอ ต้องให้ทีมยืนยัน) |
| `firestore.rules`, `firebase.json`, `lib/firebase_options.dart` | การตั้งค่า Firebase และ Security Rules | คนที่ 2 |

หน้าจอ (Widget) **ห้าม import Firebase โดยตรง** ให้เรียกผ่าน interface เท่านั้น

## 2. ค่ากลาง (`MoodMateConstants`)

ค่าที่ **เก็บ** ใน Model/Database (Security Rules ตรวจค่าชุดเดียวกัน):

| ประเภท | ค่า |
|---|---|
| `moods` | `happy`, `angry`, `sad`, `neutral` |
| `contextTags` | `Coding`, `Lab`, `Project`, `Group Work`, `Presentation`, `Deadline`, `Personal` |

ป้ายบน UI (`MoodMateConstants.moodLabels`): `happy` → ยิ้ม, `angry` → โกรธ, `sad` → เศร้า, `neutral` → เฉย ๆ

ถ้าเพิ่ม/แก้ค่าเหล่านี้ ต้องแก้ `firestore.rules` และ deploy ด้วย ไม่เช่นนั้น Firestore จะปฏิเสธการบันทึก

## 3. Model: `MoodEntry`

| Field | Type | หมายเหตุ |
|---|---|---|
| `id` | `String` | repository เป็นผู้กำหนด |
| `userId` | `String` | UID ของเจ้าของ ต้องมาจาก `AuthService.currentUserId` เท่านั้น |
| `mood` | `String` | หนึ่งค่าจาก `moods` |
| `contextTags` | `List<String>` | ว่างได้ ทุกตัวต้องอยู่ใน `contextTags` |
| `diaryText` | `String` | ว่างได้ |
| `createdAt` | `DateTime` | repository เป็นผู้กำหนด ห้ามเปลี่ยนหลังสร้าง |
| `updatedAt` | `DateTime` | repository เป็นผู้กำหนด |

มี `copyWith` ไม่มี `toMap`/`fromMap` Model ไม่ผูกกับ Firebase การแปลง Timestamp ↔ DateTime ทำใน repository เท่านั้น

## 4. สัญญา `DiaryRepository`

```dart
abstract class DiaryRepository {
  Future<List<MoodEntry>> getEntries({required String userId, DateTime? from, DateTime? to});
  Future<MoodEntry> createEntry(MoodEntry entry);
  Future<MoodEntry> updateEntry(MoodEntry entry);
  Future<void> deleteEntry({required String userId, required String entryId});
}
```

พฤติกรรมที่ **ทุก implementation ต้องทำเหมือนกัน** (Mock และ Firestore ผ่านการทดสอบแล้ว):

| ข้อ | พฤติกรรม |
|---|---|
| `getEntries` | คืนเฉพาะของ `userId` ที่ระบุ เรียง **ใหม่สุดก่อน** (`createdAt` จากมากไปน้อย) |
| ช่วงเวลา | `createdAt` อยู่ใน **`[from, to)`** รวม `from` ไม่รวม `to` ไม่ระบุฝั่งใด = ไม่จำกัดฝั่งนั้น |
| `createEntry` | repository กำหนด `id`, `createdAt`, `updatedAt` เอง (ค่าที่ UI ส่งมาเป็นค่าชั่วคราว) คืนรายการที่บันทึกแล้ว |
| `updateEntry` | แก้ `mood`, `contextTags`, `diaryText` และ `updatedAt` ไม่เปลี่ยน `createdAt` ถ้าไม่พบรายการ โยน `StateError` |
| `deleteEntry` | ลบรายการของ `userId` นั้น ถ้าไม่มีรายการ **ไม่โยน error** |
| เวลา | `createdAt`/`updatedAt` ใช้นาฬิกาของเครื่อง (`DateTime.now()`) ไม่ใช่เวลาเซิร์ฟเวอร์ |

ข้อผิดพลาด: ตัวจริงส่งต่อ `FirebaseException` (เช่น `permission-denied`, `unavailable`) ตรง ๆ UI ต้องจับและแสดงสถานะ error ยังไม่มี `AppException` กลาง (ถ้าทีมตกลงให้มี จะแปลงที่ repository ที่เดียว)

## 5. สัญญา `AuthService`

```dart
abstract class AuthService {
  String? get currentUserId;                 // null = ยังไม่ login
  Stream<String?> get userIdChanges;         // UID หรือ null เมื่อ logout
  String? get currentDisplayName;            // ชื่อที่แสดง null = ยังไม่ตั้ง (UI ใช้ชื่อเริ่มต้นเอง)
  Future<void> signUp({required String email, required String password});
  Future<void> signIn({required String email, required String password});
  Future<void> signOut();
  Future<void> updateDisplayName(String name);   // ตัดช่องว่างหัวท้าย ไม่ว่าง ไม่เกิน 50 ตัวอักษร
}
```

- วิธีเข้าสู่ระบบ: **Email/Password เท่านั้น** ไม่มีชื่อผู้ใช้ รหัสผ่านอย่างน้อย 6 ตัวอักษร (ข้อกำหนดของ Firebase)
- `signUp` สำเร็จแล้ว login ให้ทันที
- **ชื่อที่แสดง** เก็บกับบัญชีใน Firebase Authentication (`displayName`) ไม่ใช่ใน Firestore จึงไม่แตะ Security Rules ตามเข้าเครื่องอื่นเมื่อ login บัญชีเดิม ถ้ายังไม่ตั้ง `currentDisplayName` เป็น `null` และ UI ใช้ชื่อเริ่มต้นเอง ข้อมูลโปรไฟล์อื่นนอกจากชื่อยังไม่มีที่เก็บ
- ข้อผิดพลาดทั้งหมดเป็น `AuthException(code, message)` โดย `message` เป็นภาษาไทยพร้อมแสดงบน UI

| `code` | ความหมาย |
|---|---|
| `invalid-email` | รูปแบบอีเมลไม่ถูกต้อง |
| `invalid-credential` | อีเมลหรือรหัสผ่านไม่ถูกต้อง (ไม่แยกว่าผิดอะไร) |
| `email-already-in-use` | อีเมลนี้ถูกใช้สมัครแล้ว |
| `weak-password` | รหัสผ่านสั้นเกินไป |
| `user-disabled` | บัญชีถูกระงับ |
| `too-many-requests` | ลองบ่อยเกินไป |
| `network-request-failed` | เชื่อมต่ออินเทอร์เน็ตไม่ได้ |
| `operation-not-allowed` | ยังไม่ได้เปิด Email/Password ใน Firebase |
| `invalid-display-name` | ชื่อว่างหรือยาวเกิน 50 ตัวอักษร |
| `not-signed-in` | เรียก `updateDisplayName` ตอนยังไม่ได้ login |
| (อื่น ๆ) | ข้อความทั่วไป พร้อมรหัสเดิมของ Firebase |

เมื่อ logout ต้องเคลียร์ข้อมูลที่ค้างบนหน้าจอ เพื่อไม่ให้ผู้ใช้ถัดไปเห็นข้อมูลเดิม

## 6. การประกอบระบบ (`AppDependencies`)

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MoodMateApp(dependencies: AppDependencies.firebase())); // ชื่อ app ตามที่คนที่ 1 ตั้ง
}
```

หน้าจอรับ `AppDependencies` (`auth`, `diary`) แล้วเรียกผ่าน interface ระหว่างพัฒนา UI ใช้ `MockDiaryRepository(sampleUserId: 'mock-user')` แทนได้ที่จุดนี้จุดเดียว

## 7. โครงสร้างบน Cloud Firestore

- Project: `moodmate-15d92` ฐานข้อมูล `(default)` ภูมิภาค `asia-southeast1` (เลือกแล้วเปลี่ยนไม่ได้)
- Path: `users/{userId}/mood_entries/{entryId}` โดย `{userId}` คือ UID จาก Firebase Authentication
- `{entryId}` เป็น ID อัตโนมัติ ไม่เก็บ `id` ซ้ำเป็น field ในเอกสาร

```json
{
  "userId": "firebase-auth-uid",
  "mood": "sad",
  "contextTags": ["Lab", "Deadline"],
  "diaryText": "รู้สึกกดดันกับงานที่ต้องส่ง",
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp"
}
```

เอกสารต้องมี field **เท่านี้เท่านั้น** (Rules ตรวจด้วย `hasOnly`)

### Security Rules (`firestore.rules`) สรุป

| การกระทำ | เงื่อนไข |
|---|---|
| อ่าน / ลบ | login แล้ว และ `request.auth.uid == userId` ใน path |
| สร้าง | เหมือนข้างบน + ข้อมูลผ่าน `validEntry`: field ครบเท่าที่กำหนด, `userId` ตรงกับ uid, `mood` และ `contextTags` อยู่ในรายการกลาง, `diaryText` เป็น string ไม่เกิน 20,000 ตัวอักษร, `createdAt`/`updatedAt` เป็น timestamp |
| แก้ไข | เหมือนสร้าง + ห้ามเปลี่ยน `createdAt` |
| path อื่นทั้งหมด | ปฏิเสธ |

ค่าเพดาน 20,000 ตัวอักษรเป็นตาข่ายนิรภัย ไม่ใช่ข้อจำกัดที่แสดงให้ผู้ใช้เห็น (UI ไม่จำกัดความยาว) ผู้ใช้ข้ามบัญชีอ่าน/เขียน/แก้/ลบข้อมูลของกันไม่ได้

## 8. สถานะการทดสอบ

ทดสอบบน Android emulator (API 34) กับ Firebase จริง เมื่อ 24 ต.ค. 2026 ด้วยสคริปต์ชั่วคราว ผ่าน 25 จาก 25 เคส:

- **AuthService:** สมัคร, อีเมลซ้ำ, รหัสผิด, รหัสสั้น, login
- **FirestoreDiaryRepository:** สร้าง/อ่าน/แก้/ลบ, ช่วงเวลา `[from, to)`, diary ว่าง, เรียงใหม่สุดก่อน, แก้รายการที่ไม่มี → `StateError`
- **Rules ปฏิเสธข้อมูลผิดรูปแบบ:** mood/tag นอกรายการ, field เกิน, `userId` ไม่ตรง, diary เกินเพดาน (ทดสอบด้วยอักษรอังกฤษ), แก้ `createdAt`
- **Rules ข้ามบัญชี:** ผู้ใช้ B อ่าน/เขียน/แก้/ลบของ A ไม่ได้ แต่ใช้ของตัวเองได้

`MockDiaryRepository` มี unit test ใน `test/repositories/`

**ยังไม่ได้ทดสอบ:** พฤติกรรมตอนออฟไลน์, ข้อความภาษาไทยยาวใกล้เพดาน, iOS, การทดสอบ Rules แบบอัตโนมัติด้วย Firebase Emulator, ผลกับอุปกรณ์จริง

## 9. การปฏิบัติงานและความปลอดภัย

- **API key ของ Firebase** ใน `google-services.json` และ `lib/firebase_options.dart` ไม่ใช่ความลับระดับ admin (ข้อมูลปกป้องด้วย Security Rules) และถูกจำกัดเหลือ 3 API: Cloud Firestore, Identity Toolkit, Token Service **ถ้าเพิ่มบริการ Firebase/Google อื่น ต้องเพิ่ม API ในข้อจำกัดของคีย์ด้วย** ไม่เช่นนั้นจะถูกบล็อก
- **ห้าม commit:** service account, `.env` ที่มีค่าจริง, Gemini API key (ควรเป็นคีย์แยกจากคีย์ Firebase)
- **ห้าม log** `diaryText`, อีเมล, รหัสผ่าน, token
- แก้ Rules: แก้ `firestore.rules` แล้ว `firebase deploy --only firestore:rules --project moodmate-15d92` และทดสอบก่อนเสมอ
- ข้อมูลตอนพัฒนาใช้ Firebase project เดียวกันทั้งทีม แต่ละคนใช้บัญชีทดสอบของตัวเอง ข้อมูลแยกตาม UID

## 10. ข้อที่ทีมตัดสินแล้ว

| เรื่อง | ข้อสรุป |
|---|---|
| วิธี Login | Email/Password |
| แพลตฟอร์มหลัก | Android (ยังไม่ตั้งค่า iOS) |
| Diary ว่าง | บันทึกได้ |
| ความยาว Diary บน UI | ไม่จำกัด (Rules กันที่ 20,000 ตัวอักษร) |
| การเรียงรายการ | ใหม่สุดก่อน |
| ช่วงเวลา `getEntries` | `[from, to)` |
| ที่เก็บชื่อผู้ใช้ | Firebase Authentication `displayName` (ไม่ใช้ Firestore) |
| พฤติกรรมออฟไลน์ | ใช้แคชในตัว Firestore (ยังไม่ได้ทดสอบ ดูหัวข้อ 12.1) |
| ช่วงเวลาของ Dashboard | 7 วันย้อนหลังจากวันนี้ ใช้เวลาของเครื่อง (รายละเอียดเป็นข้อเสนอ ดูหัวข้อ 12.2) |
| Local database | ไม่ใช้ (ไม่ใช้ Hive/Isar/SQLite) ใช้เฉพาะแคชในตัว Firestore ดูหัวข้อ 12.3 |

## 11. ข้อที่ทีมยังต้องตัดสิน

| เรื่อง | ตัวเลือก | ผลที่ต้องกรอก |
|---|---|---|
| `AppException` กลาง | มี / ไม่มี | ⬜ |
| `MockAuthService` สำหรับทำหน้า Login | ต้องการ / ไม่ต้องการ | ⬜ |
| นโยบายเก็บ ลบ และส่ง Diary ไป Gemini API | ต้องกำหนดก่อนเปิดใช้จริง | ⬜ |

หลังตัดสินแล้ว ให้ย้ายแถวขึ้นไปที่หัวข้อ 10 และอัปเดตเอกสารนี้

---

## 12. รายละเอียดของข้อที่ตัดสินใหม่

### 12.1 ออฟไลน์: ใช้แคชในตัว Firestore

Firestore บน Android เปิดแคชในเครื่องเป็นค่าเริ่มต้น ผู้ใช้อาจเปิดดูข้อมูลเก่าได้ตอนไม่มีเน็ต และคำสั่งเขียนจะถูกคิวไว้ส่งเมื่อกลับมาออนไลน์ **ทีมยังไม่เคยทดสอบพฤติกรรมนี้** ข้อควรระวังที่ต้องออกแบบก่อนถือว่ารองรับออฟไลน์:

- `createEntry`, `updateEntry`, `deleteEntry` รอจนเซิร์ฟเวอร์ตอบรับ ถ้าออฟไลน์ `Future` จะค้างจนกลับมาออนไลน์ หน้า loading ของ UI อาจหมุนไม่หยุด
- ถ้าเขียนตอนออฟไลน์แล้วภายหลัง Rules ปฏิเสธ ผู้ใช้จะไม่เห็นข้อผิดพลาดตอนกดบันทึก
- งานที่ต้องทำ: ทดสอบด้วยโหมดเครื่องบิน แล้วตัดสินรูปแบบ UI (เช่น แสดง "บันทึกแล้ว รอซิงก์" หรือกำหนด timeout) และอาจปรับ `FirestoreDiaryRepository`

### 12.2 Dashboard: 7 วันย้อนหลังจากวันนี้ (ข้อเสนอ รอทีมยืนยัน)

ตีความเป็น **7 วันปฏิทินรวมวันนี้** (วันนี้ + 6 วันก่อนหน้า) เพื่อให้ขอบเขตคงที่ตลอดวัน ไม่เลื่อนตามเวลาที่เปิดแอป ใช้ช่วง `[weekStart, weekEnd)` เหมือนเดิม จึงไม่ต้องเปลี่ยนชื่อ field หรือ signature ของ `WeeklyInsightCalculator`:

```dart
final now = DateTime.now();
final weekStart = DateTime(now.year, now.month, now.day - 6); // เที่ยงคืนของ 6 วันก่อน
final weekEnd = DateTime(now.year, now.month, now.day + 1);   // เที่ยงคืนต้นวันพรุ่งนี้ (ไม่รวม)
final entries = await repo.getEntries(userId: uid, from: weekStart, to: weekEnd);
final insight = WeeklyInsightCalculator().calculate(
    entries: entries, weekStart: weekStart, weekEnd: weekEnd);
```

- ใช้เวลาของเครื่อง (เวลาไทย) ทุกที่ ห้ามผสมกับเวลา UTC
- หน้าจอควรใช้คำว่า "7 วันล่าสุด" ไม่ใช่ "สัปดาห์นี้"
- ถ้าข้อมูลน้อย แสดงสถานะ "ข้อมูลไม่เพียงพอ" ตามที่เอกสารกลางกำหนด

### 12.3 Local database: ไม่ใช้

ทีมตัดสินไม่ใช้ Hive, Isar หรือ SQLite เพราะแคชในตัว Firestore ทำหน้าที่เก็บข้อมูลไว้ในเครื่องอยู่แล้ว ผลที่ตามมา:

- ไม่เพิ่ม dependency และไม่ต้องออกแบบ sync/merge เอง
- `MOODMATE_PROJECT_CONTEXT.md` ระบุ Hive/Isar/SQLite เป็น **ตัวเลือก** ที่ยังไม่ตัดสิน ข้อนี้จึงเป็นการเลือกตัวเลือกหนึ่ง ถ้ารายวิชาหรือผู้ตรวจงานกำหนดให้ต้องมี Local database ให้กลับมาทบทวน
- ข้อมูลที่ยังไม่ถูกส่งขึ้นเซิร์ฟเวอร์ (ตอนออฟไลน์) อยู่ในแคชของ Firestore เท่านั้น ถ้าผู้ใช้ล้างข้อมูลแอปหรือถอนการติดตั้งก่อนซิงก์ ข้อมูลนั้นหายได้
- ร่าง Diary ที่ยังไม่กดบันทึก ไม่ถูกเก็บถาวร (ปิดแอปแล้วหาย) ถ้าต้องการ ค่อยตัดสินใหม่เป็นฟีเจอร์แยก