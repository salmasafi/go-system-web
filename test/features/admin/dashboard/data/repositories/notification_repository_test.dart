import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:GoSystem/core/supabase/supabase_client.dart';
import 'package:GoSystem/features/admin/dashboard/data/repositories/notification_repository.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}
class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {}
class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockUser extends Mock implements User {}

void main() {
  late NotificationRepository repository;
  late MockSupabaseClient mockClient;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late MockPostgrestFilterBuilder mockFilterBuilder;
  late MockGoTrueClient mockAuth;
  late MockUser mockUser;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockFilterBuilder = MockPostgrestFilterBuilder();
    mockAuth = MockGoTrueClient();
    mockUser = MockUser();

    SupabaseClientWrapper.setMockInstance(mockClient);

    when(() => mockClient.auth).thenReturn(mockAuth);
    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.id).thenReturn('user-123');

    repository = NotificationRepository();
  });

  tearDown(() {
    SupabaseClientWrapper.dispose();
  });

  group('NotificationRepository Supabase Tests', () {
    test('getAllNotifications returns list of notifications', () async {
      final mockData = [
        {
          'id': '1',
          'user_id': 'user-123',
          'title': 'Test Title',
          'body': 'Test Body',
          'type': 'general',
          'is_read': false,
          'created_at': '2026-05-01T10:00:00Z'
        }
      ];

      when(() => mockClient.from('notifications')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.order('created_at', ascending: false))
          .thenReturn(mockFilterBuilder);

      when(() => mockFilterBuilder.then(any())).thenAnswer((invocation) async {
        final callback = invocation.positionalArguments[0]
            as dynamic Function(List<Map<String, dynamic>>);
        return callback(mockData);
      });

      final result = await repository.getAllNotifications();

      expect(result.length, 1);
      expect(result.first.id, '1');
      expect(result.first.message, 'Test Body');
    });

    test('getUnreadCount returns correct count', () async {
      final mockData = [
        {'id': '1'},
        {'id': '2'},
      ];

      when(() => mockClient.from('notifications')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select('id')).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.eq('is_read', false)).thenReturn(mockFilterBuilder);

      when(() => mockFilterBuilder.then(any())).thenAnswer((invocation) async {
        final callback = invocation.positionalArguments[0]
            as dynamic Function(List<Map<String, dynamic>>);
        return callback(mockData);
      });

      final result = await repository.getUnreadCount();

      expect(result, 2);
    });

    test('markAsRead updates notification', () async {
      when(() => mockClient.from('notifications')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.update({'is_read': true}))
          .thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.eq('id', '1')).thenReturn(mockFilterBuilder);

      when(() => mockFilterBuilder.then(any()))
          .thenAnswer((_) async => <dynamic>[]);

      final result = await repository.markAsRead('1');

      expect(result, true);
      verify(() => mockQueryBuilder.update({'is_read': true})).called(1);
    });
  });
}
