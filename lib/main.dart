import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app_dependencies.dart';
import 'features/auth/login_screen.dart';
import 'features/home/main_navigation.dart'; // นำเข้า MainNavigation

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MoodMateApp(dependencies: AppDependencies.firebase()));
}

class MoodMateApp extends StatelessWidget {
  final AppDependencies dependencies;

  const MoodMateApp({
    super.key,
    required this.dependencies,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoodMate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFC48E66),
          surface: const Color(0xFFF6F5EE),
        ),
        useMaterial3: true,
      ),
      // ใช้ StreamBuilder ฟังสถานะการล็อกอิน
      home: StreamBuilder<String?>(
        stream: dependencies.auth.userIdChanges,
        builder: (context, snapshot) {
          // 1. ถ้ากำลังโหลดเช็คสถานะ ให้แสดงตัวหมุน
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Color(0xFFF6F5EE),
              body: Center(child: CircularProgressIndicator(color: Color(0xFFC48E66))),
            );
          }
          
          // 2. ถ้ามีไอดีผู้ใช้งาน (ล็อกอินแล้ว) ให้เข้าแอปไปหน้า MainNavigation
          if (snapshot.hasData && snapshot.data != null) {
            return MainNavigation(dependencies: dependencies);
          }
          
          // 3. ถ้าไม่มีข้อมูล (ยังไม่ล็อกอิน หรือเพิ่งล็อกเอาต์) ให้ไปหน้า Login
          return LoginScreen(dependencies: dependencies);
        },
      ),
    );
  }
}