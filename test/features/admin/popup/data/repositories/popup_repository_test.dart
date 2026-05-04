import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:GoSystem/core/supabase/supabase_client.dart';
import 'package:GoSystem/features/admin/popup/data/repositories/popup_repository.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {}

void main() {
  late PopupRepository repository;
  late MockSupabaseClient mockClient;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late MockPostgrestFilterBuilder mockFilterBuilder;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockFilterBuilder = MockPostgrestFilterBuilder();
    SupabaseClientWrapper.setMockInstance(mockClient);
    repository = PopupRepository();
  });

  tearDown(() {
    SupabaseClientWrapper.dispose();
  });

  group('PopupRepository', () {
    test('getAllPopups maps rows', () async {
      final mockData = [
        {
          'id': 'pop1',
          'title_ar': 'مرحبا',
          'title_en': 'Hello',
          'description_ar': 'd_ar',
          'description_en': 'd_en',
          'link': 'https://example.com',
          'image_url': 'https://example.com/i.png',
          'version': 1,
        },
      ];

      when(() => mockClient.from('popups')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.order('created_at', ascending: false)).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.then(any())).thenAnswer((invocation) async {
        final cb =
            invocation.positionalArguments[0] as dynamic Function(List<Map<String, dynamic>>);
        return cb(mockData);
      });

      final result = await repository.getAllPopups();
      expect(result.length, 1);
      expect(result.first.titleEn, 'Hello');
      expect(result.first.titleAr, 'مرحبا');
    });
  });
}