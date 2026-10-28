import 'package:flutter/material.dart';
import '../../app_dependencies.dart';
import 'auth_service.dart';
import 'signup_screen.dart'; // เพิ่มการ Import ไฟล์หน้าสมัครสมาชิกตรงนี้

class LoginScreen extends StatefulWidget {
  final AppDependencies dependencies;
  final VoidCallback? onLoginSuccess;

  const LoginScreen({
    super.key,
    required this.dependencies,
    this.onLoginSuccess,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _handleLogin() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await widget.dependencies.auth.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (widget.dependencies.auth.currentUserId == null) {
        throw const AuthException(
          'session-not-ready',
          'ยืนยันตัวตนสำเร็จ แต่โหลดสถานะบัญชีไม่สำเร็จ กรุณาลองใหม่',
        );
      }
      if (mounted) widget.onLoginSuccess?.call();
    } on AuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handlePasswordReset() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรอกอีเมลก่อนเพื่อรับลิงก์ตั้งรหัสผ่านใหม่'),
        ),
      );
      return;
    }

    try {
      await widget.dependencies.auth.sendPasswordResetEmail(email: email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ส่งลิงก์ตั้งรหัสผ่านใหม่ไปยังอีเมลแล้ว'),
          ),
        );
      }
    } on AuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F5EE),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFDEADB),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.sentiment_satisfied_alt,
                    size: 40,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'ยินดีต้อนรับกลับมา',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF222222),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'เข้าสู่ระบบเพื่อบันทึกความรู้สึกของคุณต่อ',
                  style: TextStyle(fontSize: 14, color: Color(0xFF888888)),
                ),
                const SizedBox(height: 40),

                // ช่องกรอกอีเมล
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFEFECE2),
                    hintText: 'อีเมล',
                    hintStyle: const TextStyle(
                      color: Color(0xFF888888),
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.mail_outline,
                      color: Color(0xFF888888),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'กรุณากรอกอีเมล' : null,
                ),
                const SizedBox(height: 16),

                // ช่องกรอกรหัสผ่าน
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFEFECE2),
                    hintText: 'รหัสผ่าน',
                    hintStyle: const TextStyle(
                      color: Color(0xFF888888),
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: Color(0xFF888888),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: const Color(0xFF888888),
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'กรุณากรอกรหัสผ่าน' : null,
                ),
                const SizedBox(height: 12),

                // ลืมรหัสผ่าน
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: _handlePasswordReset,
                    child: const Text(
                      'ลืมรหัสผ่าน?',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF666666),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // ปุ่มเข้าสู่ระบบ
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF222222),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'เข้าสู่ระบบ',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: 20,
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 48),

                // ปุ่มไปหน้าสมัครสมาชิก (แก้ชื่อเป็น SignupScreen แล้ว)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'ยังไม่มีบัญชีใช่ไหม? ',
                      style: TextStyle(color: Color(0xFF666666)),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SignupScreen(dependencies: widget.dependencies),
                          ),
                        );
                      },
                      child: const Text(
                        'สมัครสมาชิก',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF222222),
                          decoration: TextDecoration.underline,
                        ),
                      ),
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
}
