import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_error_handler.dart';

/// Service for managing real-time subscriptions to Supabase tables.
/// Provides live updates for INSERT, UPDATE, and DELETE operations.
class RealtimeService {
  final SupabaseClient _client;
  final Map<String, RealtimeChannel> _channels = {};
  final Map<String, List<Function>> _listeners = {};

  RealtimeService(this._client);

  /// Subscribe to changes on a specific table
  ///
  /// [table] - The table name to subscribe to
  /// [onInsert] - Callback when a new record is inserted
  /// [onUpdate] - Callback when a record is updated
  /// [onDelete] - Callback when a record is deleted
  /// [filterColumn] - Optional column to filter by
  /// [filterValue] - Optional value to filter by
  /// [schema] - Database schema (default: 'public')
  void subscribeToTable({
    required String table,
    required Function(Map<String, dynamic> payload) onInsert,
    required Function(Map<String, dynamic> payload) onUpdate,
    required Function(Map<String, dynamic> payload) onDelete,
    String? filterColumn,
    dynamic filterValue,
    String schema = 'public',
  }) {
    // Create unique channel name
    final channelName = _buildChannelName(table, filterColumn, filterValue);

    // Unsubscribe if already exists
    if (_channels.containsKey(channelName)) {
      unsubscribe(channelName);
    }

    // Build filter if provided
    PostgresChangeFilter? filter;
    if (filterColumn != null && filterValue != null) {
      filter = PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: filterColumn,
        value: filterValue,
      );
    }

    // Create and configure channel
    final channel = _client
        .channel(channelName)
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: schema,
          table: table,
          filter: filter,
          callback: (payload) {
            _handlePostgresChange(payload, onInsert, onUpdate, onDelete);
          },
        )
        .subscribe((status, error) {
          if (error != null) {
            final errorMessage = SupabaseErrorHandler.handleError(error);
            throw AppException(
              message: errorMessage,
              type: ErrorType.realtime,
              originalError: error,
            );
          }
        });

    _channels[channelName] = channel;
  }

  /// Subscribe only to INSERT events on a table
  void onInsert({
    required String table,
    required Function(Map<String, dynamic> payload) callback,
    String? filterColumn,
    dynamic filterValue,
  }) {
    subscribeToTable(
      table: table,
      onInsert: callback,
      onUpdate: (_) {},
      onDelete: (_) {},
      filterColumn: filterColumn,
      filterValue: filterValue,
    );
  }

  /// Subscribe only to UPDATE events on a table
  void onUpdate({
    required String table,
    required Function(Map<String, dynamic> payload) callback,
    String? filterColumn,
    dynamic filterValue,
  }) {
    subscribeToTable(
      table: table,
      onInsert: (_) {},
      onUpdate: callback,
      onDelete: (_) {},
      filterColumn: filterColumn,
      filterValue: filterValue,
    );
  }

  /// Subscribe only to DELETE events on a table
  void onDelete({
    required String table,
    required Function(Map<String, dynamic> payload) callback,
    String? filterColumn,
    dynamic filterValue,
  }) {
    subscribeToTable(
      table: table,
      onInsert: (_) {},
      onUpdate: (_) {},
      onDelete: callback,
      filterColumn: filterColumn,
      filterValue: filterValue,
    );
  }

  /// Unsubscribe from a specific channel
  void unsubscribe(String channelName) {
    _channels[channelName]?.unsubscribe();
    _channels.remove(channelName);
    _listeners.remove(channelName);
  }

  /// Unsubscribe from all channels
  void unsubscribeAll() {
    for (final channel in _channels.values) {
      channel.unsubscribe();
    }
    _channels.clear();
    _listeners.clear();
  }

  /// Get list of active channel names
  List<String> get activeChannels => List.unmodifiable(_channels.keys);

  /// Check if a channel is active
  bool isChannelActive(String channelName) => _channels.containsKey(channelName);

  /// Handle incoming Postgres change events
  void _handlePostgresChange(
    dynamic payload,
    Function(Map<String, dynamic>) onInsert,
    Function(Map<String, dynamic>) onUpdate,
    Function(Map<String, dynamic>) onDelete,
  ) {
    switch (payload.eventType) {
      case PostgresChangeEvent.insert:
        if (payload.newRecord != null) {
          onInsert(payload.newRecord!);
        }
        break;
      case PostgresChangeEvent.update:
        if (payload.newRecord != null) {
          onUpdate(payload.newRecord!);
        }
        break;
      case PostgresChangeEvent.delete:
        if (payload.oldRecord != null) {
          onDelete(payload.oldRecord!);
        }
        break;
      default:
        break;
    }
  }

  /// Build a unique channel name
  String _buildChannelName(
    String table,
    String? filterColumn,
    dynamic filterValue,
  ) {
    if (filterColumn != null && filterValue != null) {
      return '${table}_${filterColumn}_$filterValue';
    }
    return table;
  }
}
