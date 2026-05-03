import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:GoSystem/core/supabase/realtime_service.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockRealtimeChannel extends Mock implements RealtimeChannel {}

void main() {
  late RealtimeService realtimeService;
  late MockSupabaseClient mockClient;
  late MockRealtimeChannel mockChannel;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockChannel = MockRealtimeChannel();

    when(() => mockClient.channel(any())).thenReturn(mockChannel);
    when(() => mockChannel.onPostgresChanges(
          event: any(named: 'event'),
          schema: any(named: 'schema'),
          table: any(named: 'table'),
          filter: any(named: 'filter'),
          callback: any(named: 'callback'),
        )).thenReturn(mockChannel);
    
    when(() => mockChannel.subscribe(any())).thenReturn(mockChannel);
    when(() => mockChannel.unsubscribe()).thenAnswer((_) async => 'ok');

    realtimeService = RealtimeService(mockClient);
  });

  group('RealtimeService Tests', () {
    test('subscribeToTable creates a channel and subscribes', () {
      final table = 'products';
      
      realtimeService.subscribeToTable(
        table: table,
        onInsert: (_) {},
        onUpdate: (_) {},
        onDelete: (_) {},
      );

      verify(() => mockClient.channel(table)).called(1);
      verify(() => mockChannel.onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: table,
            filter: any(named: 'filter'),
            callback: any(named: 'callback'),
          )).called(1);
      verify(() => mockChannel.subscribe(any())).called(1);
    });

    test('onInsert creates insert-only subscription', () {
      final table = 'orders';
      
      realtimeService.onInsert(
        table: table,
        callback: (_) {},
      );

      verify(() => mockClient.channel(table)).called(1);
    });

    test('unsubscribe removes channel', () async {
      final table = 'chat';
      realtimeService.subscribeToTable(
        table: table,
        onInsert: (_) {},
        onUpdate: (_) {},
        onDelete: (_) {},
      );

      realtimeService.unsubscribe(table);

      expect(realtimeService.activeChannels, isEmpty);
      verify(() => mockChannel.unsubscribe()).called(1);
    });

    test('unsubscribeAll removes all channels', () {
      realtimeService.onInsert(table: 't1', callback: (_) {});
      realtimeService.onInsert(table: 't2', callback: (_) {});

      realtimeService.unsubscribeAll();

      expect(realtimeService.activeChannels, isEmpty);
      verify(() => mockChannel.unsubscribe()).called(2);
    });
  });
}
