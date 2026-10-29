
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_exceptions/mock_exceptions.dart';

import 'package:moodmate/features/auth/auth_service.dart';
import 'package:moodmate/features/auth/firebase_auth_service.dart';

void main() {
  group('FirebaseAuthService', () {
    group('currentUserId', () {
      test('returns null when no user is signed in', () {
        final auth = MockFirebaseAuth();
        final service = FirebaseAuthService(auth: auth);

        expect(service.currentUserId, isNull);
      });

      test('returns the current user UID when signed in', () {
        final auth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(
            uid: 'u1',
            displayName: 'สมชาย',
          ),
        );
        final service = FirebaseAuthService(auth: auth);

        expect(service.currentUserId, 'u1');
      });
    });

    group('currentDisplayName', () {
      test('returns null when no user is signed in', () {
        final auth = MockFirebaseAuth();
        final service = FirebaseAuthService(auth: auth);

        expect(service.currentDisplayName, isNull);
      });

      test('returns the current display name', () {
        final auth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(
            uid: 'u1',
            displayName: 'สมชาย',
          ),
        );
        final service = FirebaseAuthService(auth: auth);

        expect(service.currentDisplayName, 'สมชาย');
      });

      test('returns null when display name is empty', () {
        final auth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(
            uid: 'u1',
            displayName: '',
          ),
        );
        final service = FirebaseAuthService(auth: auth);

        expect(service.currentDisplayName, isNull);
      });
    });

    group('updateDisplayName', () {
      test('throws not-signed-in when no user is signed in', () async {
        final auth = MockFirebaseAuth();
        final service = FirebaseAuthService(auth: auth);

        await expectLater(
          service.updateDisplayName('สมชาย'),
          throwsA(
            isA<AuthException>().having(
              (error) => error.code,
              'code',
              'not-signed-in',
            ),
          ),
        );
      });

      test('rejects an empty display name', () async {
        final auth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: 'u1'),
        );
        final service = FirebaseAuthService(auth: auth);

        await expectLater(
          service.updateDisplayName(''),
          throwsA(
            isA<AuthException>().having(
              (error) => error.code,
              'code',
              'invalid-display-name',
            ),
          ),
        );
      });

      test('rejects a display name containing only whitespace', () async {
        final auth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: 'u1'),
        );
        final service = FirebaseAuthService(auth: auth);

        await expectLater(
          service.updateDisplayName('   '),
          throwsA(
            isA<AuthException>().having(
              (error) => error.code,
              'code',
              'invalid-display-name',
            ),
          ),
        );
      });

      test('rejects a display name longer than 50 characters', () async {
        final auth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: 'u1'),
        );
        final service = FirebaseAuthService(auth: auth);

        await expectLater(
          service.updateDisplayName('ก' * 51),
          throwsA(
            isA<AuthException>().having(
              (error) => error.code,
              'code',
              'invalid-display-name',
            ),
          ),
        );
      });

      test('accepts a display name of exactly 50 characters', () async {
        final auth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: 'u1'),
        );
        final service = FirebaseAuthService(auth: auth);
        final name = 'a' * 50;

        await service.updateDisplayName(name);

        expect(service.currentDisplayName, name);
      });

      test('trims whitespace around the display name', () async {
        final auth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(
            uid: 'u1',
            displayName: 'ชื่อเดิม',
          ),
        );
        final service = FirebaseAuthService(auth: auth);

        await service.updateDisplayName('  สมชาย  ');

        expect(service.currentDisplayName, 'สมชาย');
      });
    });

    group('signUp', () {
      test('creates an account and signs in the user', () async {
        final auth = MockFirebaseAuth();
        final service = FirebaseAuthService(auth: auth);

        await service.signUp(
          email: 'newuser@example.com',
          password: 'StrongPassword123!',
        );

        expect(service.currentUserId, isNotNull);
      });

test('maps email-already-in-use to AuthException', () async {
        final auth = MockFirebaseAuth();

        whenCalling(
          Invocation.method(
            #createUserWithEmailAndPassword, // เปลี่ยนจาก signInWithEmailAndPassword เป็น createUserWithEmailAndPassword
            null,
            {
              #email: 'existing@example.com',
              #password: 'StrongPassword123!',
            }, // ระบุ named arguments ให้ตรงกับที่ signUp เรียก
          ),
        ).on(auth).thenThrow(FirebaseAuthException(code: 'email-already-in-use'));

        final service = FirebaseAuthService(auth: auth);

        await expectLater(
          service.signUp(
            email: 'existing@example.com',
            password: 'StrongPassword123!',
          ),
          throwsA(
            isA<AuthException>().having(
              (error) => error.code,
              'code',
              'email-already-in-use',
            ),
          ),
        );
      });

      test('maps weak-password to AuthException', () async {
        final auth = MockFirebaseAuth();

        whenCalling(
          Invocation.method(
            #createUserWithEmailAndPassword,
            null,
          ),
        ).on(auth).thenThrow(
          FirebaseAuthException(code: 'weak-password'),
        );

        final service = FirebaseAuthService(auth: auth);

        await expectLater(
          service.signUp(
            email: 'newuser@example.com',
            password: '123',
          ),
          throwsA(
            isA<AuthException>().having(
              (error) => error.code,
              'code',
              'weak-password',
            ),
          ),
        );
      });
    });

    group('signIn', () {
      test('signs in successfully', () async {
        final auth = MockFirebaseAuth(
          mockUser: MockUser(
            uid: 'u1',
            email: 'user@example.com',
            displayName: 'สมชาย',
          ),
        );
        final service = FirebaseAuthService(auth: auth);

        await service.signIn(
          email: 'user@example.com',
          password: 'Password123!',
        );

        expect(service.currentUserId, 'u1');
      });

      test('maps wrong-password to invalid-credential', () async {
        final auth = MockFirebaseAuth();

        whenCalling(
          Invocation.method(
            #signInWithEmailAndPassword,
            null,
          ),
        ).on(auth).thenThrow(
          FirebaseAuthException(code: 'wrong-password'),
        );

        final service = FirebaseAuthService(auth: auth);

        await expectLater(
          service.signIn(
            email: 'user@example.com',
            password: 'wrong-password',
          ),
          throwsA(
            isA<AuthException>().having(
              (error) => error.code,
              'code',
              'invalid-credential',
            ),
          ),
        );
      });

      test('maps user-not-found to invalid-credential', () async {
        final auth = MockFirebaseAuth();

        whenCalling(
          Invocation.method(
            #signInWithEmailAndPassword,
            null,
          ),
        ).on(auth).thenThrow(
          FirebaseAuthException(code: 'user-not-found'),
        );

        final service = FirebaseAuthService(auth: auth);

        await expectLater(
          service.signIn(
            email: 'missing@example.com',
            password: 'Password123!',
          ),
          throwsA(
            isA<AuthException>().having(
              (error) => error.code,
              'code',
              'invalid-credential',
            ),
          ),
        );
      });

      test('maps network errors to AuthException', () async {
        final auth = MockFirebaseAuth();

        whenCalling(
          Invocation.method(
            #signInWithEmailAndPassword,
            null,
          ),
        ).on(auth).thenThrow(
          FirebaseAuthException(code: 'network-request-failed'),
        );

        final service = FirebaseAuthService(auth: auth);

        await expectLater(
          service.signIn(
            email: 'user@example.com',
            password: 'Password123!',
          ),
          throwsA(
            isA<AuthException>().having(
              (error) => error.code,
              'code',
              'network-request-failed',
            ),
          ),
        );
      });

      test('maps unknown Firebase errors to the default error', () async {
        final auth = MockFirebaseAuth();

        whenCalling(
          Invocation.method(
            #signInWithEmailAndPassword,
            null,
          ),
        ).on(auth).thenThrow(
          FirebaseAuthException(code: 'some-unexpected-error'),
        );

        final service = FirebaseAuthService(auth: auth);

        await expectLater(
          service.signIn(
            email: 'user@example.com',
            password: 'Password123!',
          ),
          throwsA(isA<AuthException>()),
        );
      });
    });

    group('signOut', () {
      test('clears the current user after signing out', () async {
        final auth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(
            uid: 'u1',
            displayName: 'สมชาย',
          ),
        );
        final service = FirebaseAuthService(auth: auth);

        expect(service.currentUserId, 'u1');

        await service.signOut();

        expect(service.currentUserId, isNull);
        expect(service.currentDisplayName, isNull);
      });
    });
  });
}
