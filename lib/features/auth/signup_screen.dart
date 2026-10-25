import 'package:flutter/material.dart';
import '../../app_dependencies.dart';

class SignupScreen extends StatefulWidget {
  final AppDependencies dependencies;
  const SignupScreen({super.key, required this.dependencies});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F5EE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF222222), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 24, top: 12, bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFECE2),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Row(
              children: [
                Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFFF4B886), shape: BoxShape.circle)),
                const SizedBox(width: 6),
                const Text('ขั้นตอน 1 จาก 1', style: TextStyle(fontSize: 12, color: Color(0xFF666666), fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 80, height: 80,
                decoration: const BoxDecoration(color: Color(0xFFFDEADB), shape: BoxShape.circle),
                child: const Icon(Icons.sentiment_satisfied_alt, size: 40, color: Color(0xFF333333)),
              ),
              const SizedBox(height: 24),
              const Text('เริ่มต้นกับ MoodMate', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF222222))),
              const SizedBox(height: 8),
              const Text('สร้างพื้นที่ปลอดภัยสำหรับใจของคุณวันนี้', style: TextStyle(fontSize: 14, color: Color(0xFF888888))),
              const SizedBox(height: 40),

              // ชื่อผู้ใช้งาน
              _buildTextField(hint: 'ชื่อผู้ใช้งาน', icon: Icons.person_outline),
              const SizedBox(height: 16),
              
              // อีเมล
              _buildTextField(hint: 'อีเมล', icon: Icons.mail_outline, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),

              // รหัสผ่าน (แก้ไข Hint และเพิ่ม Validator)
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFEFECE2),
                  hintText: 'รหัสผ่าน (ขั้นต่ำ 8 ตัว, พิมพ์เล็ก, พิมพ์ใหญ่, อักขระพิเศษ)', // อัปเดตข้อความ
                  hintStyle: const TextStyle(color: Color(0xFF888888), fontSize: 13),
                  prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF888888)),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: const Color(0xFF888888)),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'กรุณากรอกรหัสผ่าน';
                  // เช็คเงื่อนไข: ความยาว >= 8, มีตัวพิมพ์เล็ก, ตัวพิมพ์ใหญ่ และอักขระพิเศษ
                  if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\W).{8,}$').hasMatch(value)) {
                    return 'ต้องมี 8 ตัวอักษรขึ้นไป ประกอบด้วยพิมพ์เล็ก พิมพ์ใหญ่ และอักขระพิเศษ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ยืนยันรหัสผ่าน
              TextFormField(
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFEFECE2),
                  hintText: 'ยืนยันรหัสผ่าน',
                  hintStyle: const TextStyle(color: Color(0xFF888888), fontSize: 14),
                  prefixIcon: const Icon(Icons.replay_outlined, color: Color(0xFF888888)),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: const Color(0xFF888888)),
                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
                validator: (value) {
                  if (value != _passwordController.text) return 'รหัสผ่านไม่ตรงกัน';
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // ปุ่มสมัคร
              SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // TODO: ทำงานต่อเมื่อผ่านเงื่อนไขรหัสผ่านแล้ว
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF222222),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text('สมัครสมาชิก', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('มีบัญชีอยู่แล้ว? ', style: TextStyle(color: Color(0xFF666666))),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text('เข้าสู่ระบบ', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF222222), decoration: TextDecoration.underline)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.shield_outlined, size: 14, color: Color(0xFF888888)),
                  SizedBox(width: 6),
                  Text('ข้อมูลปลอดภัยและเป็นส่วนตัวเสมอ', style: TextStyle(fontSize: 12, color: Color(0xFF888888))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required String hint, required IconData icon, TextInputType? keyboardType}) {
    return TextFormField(
      keyboardType: keyboardType,
      decoration: InputDecoration(
        filled: true, fillColor: const Color(0xFFEFECE2),
        hintText: hint, hintStyle: const TextStyle(color: Color(0xFF888888), fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFF888888)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
      validator: (value) => value!.isEmpty ? 'กรุณากรอกข้อมูล' : null,
    );
  }
}