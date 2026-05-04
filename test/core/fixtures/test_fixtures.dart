import 'mock_data_generator.dart';

final class TestFixtures {
  TestFixtures._();

  static final Map<String, Map<String, dynamic>> _cache = {};

  static Map<String, dynamic> brand() =>
      _cache.putIfAbsent('brand', MockDataGenerator.generateBrand);

  static Map<String, dynamic> category() =>
      _cache.putIfAbsent('category', MockDataGenerator.generateCategory);

  static Map<String, dynamic> product() =>
      _cache.putIfAbsent('product', MockDataGenerator.generateProduct);

  static void clearCache() => _cache.clear();
}