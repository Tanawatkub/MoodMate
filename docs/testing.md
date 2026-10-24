# คู่มือทดสอบ — Weekly Insight

## วิธีรัน

```bash
flutter analyze
flutter test
flutter test test/features/weekly_insight/
```

## ที่ครอบคลุมแล้ว (WeeklyInsightCalculator)

- รายการว่าง
- นับ mood
- นับ context tag (หลาย tag ในรายการเดียว, tag ซ้ำนับครั้งเดียว)
- ขอบเวลา [weekStart, weekEnd): weekStart ถูกนับ, weekEnd ไม่ถูกนับ
- รายการนอกสัปดาห์ไม่ถูกนับ

## ที่ครอบคลุมแล้ว (WeeklyInsightPage)

- Empty state เมื่อ totalEntries = 0
- แสดงจำนวนรวมและ tag เมื่อมีข้อมูล

## ที่ต้องทำหลัง Integration (คนที่ 1-3 ส่งงาน)

- [ ] login → สร้างรายการ → อ่านรายการ → AI reflection → Dashboard
- [ ] ผู้ใช้ A กับ B เห็น Dashboard คนละชุด
- [ ] logout แล้วข้อมูลเดิมไม่ปรากฏแก่ผู้ใช้ถัดไป
- [ ] ตรวจ timezone และวันเริ่มสัปดาห์ให้ตรงกับที่ทีมตกลง

## ข้อตกลงที่ยังรอยืนยัน

- วันเริ่มต้นสัปดาห์ (ตอนนี้ test ใช้วันจันทร์)
- timezone ที่ใช้ตัดวัน