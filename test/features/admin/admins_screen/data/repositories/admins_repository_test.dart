import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:GoSystem/core/supabase/supabase_client.dart';
import 'package:GoSystem/features/admin/admins_screen/data/repositories/admin_repository.dart';
import 'package:GoSystem/features/admin/admins_screen/model/admins_model.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}
class MockPostgrestFilterBuilder extends Mock implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {}

void main() {
  late AdminRepository repository;
  late MockSupabaseClient mockClient;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late MockPostgrestFilterBuilder mockFilterBuilder;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockFilterBuilder = MockPostgrestFilterBuilder();
    
    SupabaseClientWrapper.setMockInstance(mockClient);
    repository = AdminRepository();
    repository.enableSupabase();
  });

  tearDown(() {
    SupabaseClientWrapper.dispose();
  });

  group('AdminsRepository Supabase Implementation Tests', () {
    test('getAllAdmins maps Supabase JSON correctly', () async {
      final mockData = [
        {
          'id': 'admin-123',
          'username': 'superadmin',
          'phone': '123',
          'role': 'user',
          'role_id': 'role-1',
          'role_data': {'id': 'role-1', 'name': 'owner'},
          'warehouse_id': 'wh-1',
          'warehouse': {'id': 'wh-1', 'name': 'Main Warehouse'},
          'is_active': true,
          'created_at': '2024-01-01T00:00:00Z',
          'updated_at': '2024-01-01T00:00:00Z',
        }
      ];

      when(() => mockClient.from('user_profiles')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select(any())).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.order(any(), ascending: any(named: 'ascending')))
          .thenReturn(mockFilterBuilder);

      when(() => mockFilterBuilder.then(any())).thenAnswer((invocation) async {
        final callback = invocation.positionalArguments[0]
            as dynamic Function(List<Map<String, dynamic>>);
        return callback(mockData);
      });

      final result = await repository.getAllAdmins();

      expect(result.first.id, 'admin-123');
      expect(result.first.roleData?.name, 'owner');
    });
  });
}
