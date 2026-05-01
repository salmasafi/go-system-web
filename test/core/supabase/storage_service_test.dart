import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:GoSystem/core/supabase/storage_service.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockSupabaseStorageClient extends Mock implements SupabaseStorageClient {}
class MockStorageFileApi extends Mock implements StorageFileApi {}
class MockFile extends Mock implements File {}

void main() {
  late StorageService storageService;
  late MockSupabaseClient mockClient;
  late MockSupabaseStorageClient mockStorageClient;
  late MockStorageFileApi mockFileApi;
  late MockFile mockFile;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockStorageClient = MockSupabaseStorageClient();
    mockFileApi = MockStorageFileApi();
    mockFile = MockFile();

    when(() => mockClient.storage).thenReturn(mockStorageClient);
    when(() => mockStorageClient.from(any())).thenReturn(mockFileApi);

    storageService = StorageService(mockClient);
  });

  group('StorageService Tests', () {
    test('uploadImage uploads file and returns public URL', () async {
      final folder = 'products';
      final fileName = 'test.jpg';
      final publicUrl = 'https://supabase.com/test.jpg';

      when(() => mockFile.absolute).thenReturn(mockFile);
      when(() => mockFile.path).thenReturn('/path/to/test.jpg');
      when(() => mockFileApi.upload(any(), any()))
          .thenAnswer((_) async => 'unique_path.jpg');
      when(() => mockFileApi.getPublicUrl(any())).thenReturn(publicUrl);

      final result = await storageService.uploadImage(
        file: mockFile,
        folder: folder,
        fileName: fileName,
      );

      expect(result, publicUrl);
      verify(() => mockFileApi.upload(any(that: contains(folder)), any())).called(1);
    });

    test('deleteImage removes file from storage', () async {
      final path = 'products/test.jpg';
      when(() => mockFileApi.remove(any())).thenAnswer((_) async => []);

      await storageService.deleteImage(path);

      verify(() => mockFileApi.remove([path])).called(1);
    });

    test('getPublicUrl returns URL for given path', () {
      final path = 'products/test.jpg';
      final publicUrl = 'https://supabase.com/$path';
      when(() => mockFileApi.getPublicUrl(path)).thenReturn(publicUrl);

      final result = storageService.getPublicUrl(path);

      expect(result, publicUrl);
    });

    test('validateImage throws exception for large file', () async {
      when(() => mockFile.length()).thenAnswer((_) async => 10 * 1024 * 1024); // 10MB
      
      expect(
        () => storageService.validateImage(file: mockFile),
        throwsException,
      );
    });

    test('validateImage throws exception for invalid extension', () async {
      when(() => mockFile.length()).thenAnswer((_) async => 1024);
      when(() => mockFile.path).thenReturn('test.pdf');

      expect(
        () => storageService.validateImage(file: mockFile),
        throwsException,
      );
    });
  });
}
