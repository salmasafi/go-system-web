import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:GoSystem/core/supabase/supabase_client.dart';
import 'package:GoSystem/features/admin/auth/cubit/login_cubit.dart';
import 'package:GoSystem/features/admin/auth/cubit/login_state.dart';
import 'package:GoSystem/features/admin/auth/data/repositories/auth_repository.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockUser extends Mock implements User {}
class MockSession extends Mock implements Session {}
class MockAuthResponse extends Mock implements AuthResponse {}

void main() {
  late LoginCubit loginCubit;
  late AuthRepository authRepository;
  late MockSupabaseClient mockClient;
  late MockGoTrueClient mockAuth;
  late MockUser mockUser;
  late MockSession mockSession;
  late MockAuthResponse mockAuthResponse;

  setUp(() async {
    mockClient = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    mockUser = MockUser();
    mockSession = MockSession();
    mockAuthResponse = MockAuthResponse();

    SupabaseClientWrapper.setMockInstance(mockClient);
    
    when(() => mockClient.auth).thenReturn(mockAuth);
    when(() => mockAuth.currentUser).thenReturn(null);
    
    // AuthRepository needs Supabase enabled
    authRepository = AuthRepository();
    // Assuming we have a way to force Supabase for testing if feature flags aren't enough
    // But since AuthRepository uses MigrationService.isUsingSupabase('auth'), we should ensure it returns true.
    
    loginCubit = LoginCubit(authRepository);
  });

  group('Authentication Flow Integration Tests', () {
    test('Successful login updates state and saves token', () async {
      final email = 'test@example.com';
      final password = 'password123';
      final accessToken = 'mock-token';

      when(() => mockAuth.signInWithPassword(
            email: email,
            password: password,
          )).thenAnswer((_) async => mockAuthResponse);

      when(() => mockAuthResponse.user).thenReturn(mockUser);
      when(() => mockAuthResponse.session).thenReturn(mockSession);
      when(() => mockUser.id).thenReturn('user-123');
      when(() => mockUser.email).thenReturn(email);
      when(() => mockSession.accessToken).thenReturn(accessToken);

      // Trigger login
      final future = loginCubit.userLogin(email: email, password: password);

      expect(loginCubit.state, isA<LoginLoading>());
      
      await future;

      expect(loginCubit.state, isA<LoginSuccess>());
      expect(loginCubit.userModel?.success, true);
      expect(loginCubit.userModel?.data?.token, accessToken);
      
      verify(() => mockAuth.signInWithPassword(email: email, password: password)).called(1);
    });

    test('Failed login emits error state', () async {
      final email = 'wrong@example.com';
      final password = 'wrong';

      when(() => mockAuth.signInWithPassword(
            email: email,
            password: password,
          )).thenThrow(AuthException('Invalid login credentials', statusCode: '400'));

      await loginCubit.userLogin(email: email, password: password);

      expect(loginCubit.state, isA<LoginError>());
      expect((loginCubit.state as LoginError).error, contains('Invalid login credentials'));
    });

    test('Logout clears session and state', () async {
      when(() => mockAuth.signOut()).thenAnswer((_) async => {});

      await loginCubit.logout();

      expect(loginCubit.state, isA<LoginInitial>());
      expect(loginCubit.savedUser, isNull);
      verify(() => mockAuth.signOut()).called(1);
    });
  });
}
