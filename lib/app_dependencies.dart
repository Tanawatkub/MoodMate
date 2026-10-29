import 'features/auth/auth_service.dart';
import 'features/auth/firebase_auth_service.dart';
import 'repositories/diary_repository.dart';
import 'repositories/firestore_diary_repository.dart';
import 'services/gemini_reflection_service.dart';
import 'services/reflection_service.dart';

/// จุดประกอบระบบจุดเดียว: ที่นี่ที่เดียวที่รู้ว่าใช้ implementation ตัวไหน
/// หน้าจอรับ AppDependencies แล้วเรียกผ่าน interface เท่านั้น
/// ห้าม import Firebase ใน Widget
class AppDependencies {
  const AppDependencies({
    required this.auth,
    required this.diary,
    required this.reflection,
  });

  final AuthService auth;
  final DiaryRepository diary;
  final ReflectionService reflection;

  /// ตัวจริง (Firebase) ต้องเรียก Firebase.initializeApp ใน main() ก่อน
  factory AppDependencies.firebase() => AppDependencies(
    auth: FirebaseAuthService(),
    diary: FirestoreDiaryRepository(),
    reflection: GeminiReflectionService(
      apiKey: const String.fromEnvironment('GEMINI_API_KEY'),
    ),
  );
}
