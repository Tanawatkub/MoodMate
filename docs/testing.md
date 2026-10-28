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
- หนึ่ง MoodEntry = หนึ่ง totalEntries
- mood ที่ไม่อยู่ใน happy/angry/sad/neutral ถูกข้ามทั้งรายการ
- tag ที่ไม่อยู่ในรายการกลางถูกเมิน (รายการยังถูกนับ)
- tag แต่ละตัวนับหนึ่งครั้งต่อรายการ
- ผลรวม moodCounts เท่ากับ totalEntries เสมอ

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
- [ ] ผู้ใช้ A กับ B เห็น Dashboard คนละชุด
- [ ] logout แล้วข้อมูลเดิมไม่ปรากฏแก่ผู้ใช้ถัดไป
- [ ] ย้ายรายการ mood/tag ใน weekly_insight_config.dart ไปอ้างอิง moodmate_constants.dart

## ข้อตกลงที่ยังรอทีมยืนยัน

- วันเริ่มต้นสัปดาห์ (ตอนนี้ใช้วันจันทร์)
- timezone ที่ใช้ตัดวัน (ตอนนี้ใช้เวลาท้องถิ่นของเครื่อง)