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
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  // ฟังก์ชันตรวจสอบรหัสผ่านด้วย Regex (ขั้นต่ำ 8 ตัว, มีพิมพ์เล็ก, พิมพ์ใหญ่, ตัวเลข, อักขระพิเศษ)
  bool _isPasswordValid(String password) {
    final regex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_])[A-Za-z\d\W_]{8,}$');
    return regex.hasMatch(password);
  }

  void _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      // TODO: ใส่ Logic สมัครสมาชิกกับ Firebase ของคุณตรงนี้
      await Future.delayed(const Duration(seconds: 1)); // จำลองการโหลด
      
      if (mounted) {
        setState(() => _isLoading = false);
        // เมื่อสมัครเสร็จ สามารถเด้งกลับไปหน้า Login หรือไปหน้า Home ได้เลย
        Navigator.pop(context); 
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F5EE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF222222)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // เอาป้าย "ขั้นตอน 1 จาก 1" ออกจากตรงนี้แล้ว
                const Text('สร้างบัญชีใหม่', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF222222))),
                const SizedBox(height: 8),
                const Text('เริ่มต้นบันทึกอารมณ์และดูแลใจไปกับ MoodMate', style: TextStyle(fontSize: 14, color: Color(0xFF888888))),
                const SizedBox(height: 40),

                // ช่องกรอกชื่อ
                _buildTextField(
                  controller: _nameController,
                  hintText: 'ชื่อผู้ใช้งาน',
                  icon: Icons.person_outline,
                  validator: (value) => value!.isEmpty ? 'กรุณากรอกชื่อผู้ใช้งาน' : null,
                ),
                const SizedBox(height: 16),

                // ช่องกรอกอีเมล
                _buildTextField(
                  controller: _emailController,
                  hintText: 'อีเมล',
                  icon: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'กรุณากรอกอีเมล';
                    if (!value.contains('@')) return 'รูปแบบอีเมลไม่ถูกต้อง';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ช่องกรอกรหัสผ่าน
                _buildTextField(
                  controller: _passwordController,
                  hintText: 'รหัสผ่าน (8+ ตัวอักษร, พิมพ์ใหญ่, เล็ก, พิเศษ)',
                  icon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'กรุณากรอกรหัสผ่าน';
                    if (!_isPasswordValid(value)) {
                      return 'ต้องมี 8+ ตัวอักษร, พิมพ์เล็ก, ใหญ่, ตัวเลข และอักขระพิเศษ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ช่องยืนยันรหัสผ่าน
                _buildTextField(
                  controller: _confirmPasswordController,
                  hintText: 'ยืนยันรหัสผ่าน',
                  icon: Icons.lock_outline,
                  obscureText: _obscureConfirmPassword,
                  onToggleVisibility: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'กรุณายืนยันรหัสผ่าน';
                    if (value != _passwordController.text) return 'รหัสผ่านไม่ตรงกัน';
                    return null;
                  },
                ),
                const SizedBox(height: 40),

                // ปุ่มสมัครสมาชิก
                SizedBox(
                  width: double.infinity, height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSignup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF222222),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    ),
                    child: _isLoading 
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('สมัครสมาชิก', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 32),

                // ปุ่มกลับไปหน้า Login
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget ช่วยสร้างช่องกรอกข้อมูลให้โค้ดคลีนขึ้น
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    VoidCallback? onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        filled: true, fillColor: const Color(0xFFEFECE2),
        hintText: hintText, hintStyle: const TextStyle(color: Color(0xFF888888), fontSize: 13),
        prefixIcon: Icon(icon, color: const Color(0xFF888888)),
        suffixIcon: onToggleVisibility != null
            ? IconButton(
                icon: Icon(obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: const Color(0xFF888888)),
                onPressed: onToggleVisibility,
              )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
      validator: validator,
    );
  }
}