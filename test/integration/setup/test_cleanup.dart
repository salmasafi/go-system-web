import 'package:supabase_flutter/supabase_flutter.dart';
import 'test_environment.dart';

/// Truncate specified tables in the test database
Future<void> truncateIntegrationTables(List<String> tableNames) async {
  if (!TestEnvironment.runIntegrationTests) return;

  final client = Supabase.instance.client;

  for (final tableName in tableNames) {
    try {
      // Use Supabase RPC to truncate table if available
      await client.rpc('truncate_table', params: {'table_name': tableName});
    } catch (e) {
      // Fallback: delete all records
      await client.from(tableName).delete().neq('id', '');
    }
  }
}

/// Clean up test data for a specific entity
Future<void> cleanupTestData(String table, {String? createdAfter}) async {
  if (!TestEnvironment.runIntegrationTests) return;

  final client = Supabase.instance.client;

  var query = client.from(table).delete();

  if (createdAfter != null) {
    query = query.gt('created_at', createdAfter);
  }

  await query;
}

/// Reset test database to clean state
Future<void> resetTestDatabase() async {
  if (!TestEnvironment.runIntegrationTests) return;

  final tables = [
    'adjustments',
    'products',
    'customers',
    'purchases',
    'warehouses',
    'suppliers',
    'categories',
    'brands',
    'units',
    'taxes',
    'currencies',
    'cities',
    'countries',
    'coupons',
    'discounts',
    'expenses',
    'expense_categories',
    'payment_methods',
    'permissions',
    'points',
    'popups',
    'reasons',
    'redeem_points',
    'roles',
    'transfers',
    'variations',
    'zones',
    'cashiers',
    'departments',
    'print_labels',
  ];

  await truncateIntegrationTables(tables);
}