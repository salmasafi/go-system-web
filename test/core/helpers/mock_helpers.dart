import 'package:GoSystem/core/supabase/supabase_client.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {}

class MockPostgrestTransformBuilder extends Mock
    implements PostgrestTransformBuilder<Map<String, dynamic>?> {}

void useMockSupabase(MockSupabaseClient client) {
  SupabaseClientWrapper.setMockInstance(client);
}

void disposeMockSupabase() {
  SupabaseClientWrapper.dispose();
}