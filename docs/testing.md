# คู่มือทดสอบ — Weekly Insight

## วิธีรัน

```bash
flutter analyze
flutter test
flutter test test/features/weekly_insight/ --reporter expanded
```

## ดูหน้าจอบน Android Emulator (ไม่ต้องใช้ข้อมูลจริง)

สร้างไฟล์ `lib/dev_preview.dart` ในเครื่อง (ไม่ commit) ที่เปิด `WeeklyInsightScreen`
ด้วย mock data แล้วรัน:

```bash
flutter run -t lib/dev_preview.dart -d <device-id>
```

## กติกาที่ทดสอบ

- ช่วงเวลา [weekStart, weekEnd): รวมต้น ไม่รวมปลาย
- บันทึกอารมณ์ครั้งแรกของวันสร้างรายการ; บันทึกซ้ำในวันเดียวกันแก้รายการล่าสุดโดยไม่เปลี่ยน createdAt
- หากวันปัจจุบันมีรายการซ้ำอยู่ก่อนแล้ว การบันทึกใหม่เก็บรายการล่าสุดและลบรายการซ้ำที่เหลือ
- หนึ่ง MoodEntry = หนึ่ง totalEntries
- mood ที่ไม่อยู่ใน happy/angry/sad/neutral ถูกข้ามทั้งรายการ
- tag ที่ไม่อยู่ในรายการกลางถูกเมิน (รายการยังถูกนับ)
- tag แต่ละตัวนับหนึ่งครั้งต่อรายการ
- ผลรวม moodCounts เท่ากับ totalEntries เสมอ
- ช่วงสถิติที่เลือกถูกจำกัดไม่ให้เริ่มก่อนวันสมัคร และ AI ได้รับช่วงเดียวกับที่ UI แสดง
- สีพื้นอารมณ์ในหน้าหลัก/รายละเอียดต้องตรงกับตัวเลือกหน้าเช็กอิน
- วงกลมอารมณ์หลักในหน้าสถิติต้องใช้สีเดียวกับอารมณ์ที่พบบ่อยที่สุด
- หลังยืนยันลบรายการจากหน้ารายละเอียด รายการและอารมณ์ของวันนั้นหายจากหน้าหลักทันที
- หน้าสะท้อนใจระบุว่าเป็นผลจาก Gemini หรือข้อความสำรองในเครื่อง

## ทดสอบ Gemini API ในเครื่อง

1. สร้าง `gemini.local.json` ที่ root (อย่า commit) โดยใส่ key ที่ได้รับอนุญาตให้ใช้:

   ```json
   {
     "GEMINI_API_KEY": "ใส่คีย์สำหรับทดสอบของคุณ"
   }
   ```

2. รันแอปโดยส่งไฟล์เป็น compile-time defines:

   ```powershell
   flutter run --dart-define-from-file=gemini.local.json -d <device_id>
   ```

3. ผู้ทดสอบแต่ละคนที่ต้องการทดสอบการเรียก Gemini จริง ต้องมี key ที่ได้รับอนุญาตและใช้ไฟล์ local ของตนเอง ไม่ต้องใส่ key ซ้ำทุกครั้งที่ Gemini ส่งคำขอ แต่ต้อง build/run ด้วย define นี้เมื่อสร้าง binary ใหม่

ถ้าไม่ส่ง key สถิติยังทดสอบได้ แต่บทสรุป AI ที่ต้องเรียก Gemini จะแสดง error ว่ายังไม่ได้ตั้งค่า key; Firebase API key ไม่ใช่ Gemini API key. คีย์ที่ฝังในแอป client อ่านย้อนกลับได้ จึงห้ามใช้ key นี้ในแอปที่เผยแพร่สาธารณะ ให้ใช้ backend เก็บ secret สำหรับ production.

## ไฟล์ test และสิ่งที่ครอบคลุม

| ไฟล์ | ครอบคลุม |
|---|---|
| weekly_insight_calculator_test.dart | นับ mood/tag, ขอบเวลา, Validation |
| week_range_test.dart | สัปดาห์เริ่มวันจันทร์, ข้ามเดือน/ปี |
| weekly_insight_page_test.dart | empty state, ช่วงวันที่, tag เรียงตามความถี่, ข้อความกำกับ |
| weekly_insight_screen_test.dart | loading, error, ลองใหม่ |
| weekly_insight_mock_pipeline_test.dart | ข้อมูลดิบ -> สัปดาห์ -> ผลสรุป ด้วย mock data |

## ที่ต้องทำหลัง Integration (รอคนที่ 1-3 ส่งงาน)

- [ ] เปลี่ยนต้นทางข้อมูลเป็น DiaryRepository จริง
- [ ] login -> สร้างรายการ -> อ่านรายการ -> AI reflection -> Dashboard
- [ ] บันทึกซ้ำในวันเดียวกันแล้วต้องมีรายการเดียวในวันปัจจุบัน ทั้งบนหน้าหลักและสถิติ
- [ ] ผู้ใช้ A กับ B เห็น Dashboard คนละชุด
- [ ] logout แล้วข้อมูลเดิมไม่ปรากฏแก่ผู้ใช้ถัดไป
- [ ] ย้ายรายการ mood/tag ใน weekly_insight_config.dart ไปอ้างอิง moodmate_constants.dart

## ข้อตกลงที่ยังรอทีมยืนยัน

- วันเริ่มต้นสัปดาห์ (ตอนนี้ใช้วันจันทร์)
- timezone ที่ใช้ตัดวัน (ตอนนี้ใช้เวลาท้องถิ่นของเครื่อง)