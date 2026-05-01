import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_error_handler.dart';

/// Service for handling file storage operations with Supabase Storage.
class StorageService {
  final SupabaseClient _client;
  final String _bucketName = 'system-assets';

  StorageService(this._client);

  /// Upload an image to Supabase Storage with optional compression
  ///
  /// [file] - The image file to upload
  /// [folder] - The folder path (products, brands, categories, admins)
  /// [fileName] - The original file name
  /// [maxWidth] - Maximum width for image compression (optional)
  /// [quality] - JPEG quality for compression (0-100, default 85)
  ///
  /// Returns the public URL of the uploaded image
  Future<String> uploadImage({
    required File file,
    required String folder,
    required String fileName,
    int? maxWidth,
    int quality = 85,
  }) async {
    try {
      // Process the image (compress if needed)
      File processedFile = file;
      if (maxWidth != null) {
        processedFile = await _compressImage(file, maxWidth, quality);
      }

      // Generate unique file name with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = fileName.split('.').last.toLowerCase();
      final uniqueFileName = '$folder/${timestamp}_$fileName';

      // Upload to Supabase Storage
      await _client.storage
          .from(_bucketName)
          .upload(uniqueFileName, processedFile);

      // Get and return public URL
      return _client.storage.from(_bucketName).getPublicUrl(uniqueFileName);
    } catch (e) {
      throw SupabaseErrorHandler.handleError(e);
    }
  }

  /// Delete an image from Supabase Storage
  ///
  /// [path] - The full path of the file to delete
  Future<void> deleteImage(String path) async {
    try {
      await _client.storage.from(_bucketName).remove([path]);
    } catch (e) {
      throw SupabaseErrorHandler.handleError(e);
    }
  }

  /// Delete multiple images from Supabase Storage
  ///
  /// [paths] - List of file paths to delete
  Future<void> deleteImages(List<String> paths) async {
    if (paths.isEmpty) return;

    try {
      await _client.storage.from(_bucketName).remove(paths);
    } catch (e) {
      throw SupabaseErrorHandler.handleError(e);
    }
  }

  /// Get public URL for an existing file
  ///
  /// [path] - The path of the file in storage
  String getPublicUrl(String path) {
    return _client.storage.from(_bucketName).getPublicUrl(path);
  }

  /// Validate image file before upload
  ///
  /// [file] - The file to validate
  /// [maxSizeBytes] - Maximum allowed file size in bytes (default 5MB)
  /// [allowedExtensions] - List of allowed file extensions
  ///
  /// Returns true if valid, throws exception if invalid
  Future<bool> validateImage({
    required File file,
    int maxSizeBytes = 5 * 1024 * 1024, // 5MB default
    List<String> allowedExtensions = const ['jpg', 'jpeg', 'png', 'webp'],
  }) async {
    // Check file size
    final fileSize = await file.length();
    if (fileSize > maxSizeBytes) {
      throw Exception(
        'File size exceeds maximum allowed (${maxSizeBytes ~/ (1024 * 1024)}MB)',
      );
    }

    // Check file extension
    final extension = file.path.split('.').last.toLowerCase();
    if (!allowedExtensions.contains(extension)) {
      throw Exception(
        'Invalid file format. Allowed: ${allowedExtensions.join(', ')}',
      );
    }

    return true;
  }

  /// Compress image to reduce file size
  ///
  /// [file] - The image file to compress
  /// [maxWidth] - Maximum width for the output image
  /// [quality] - JPEG quality (0-100)
  Future<File> _compressImage(File file, int maxWidth, int quality) async {
    try {
      // First try flutter_image_compress for better performance
      final tempDir = await getTemporaryDirectory();
      final targetPath =
          '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        minWidth: maxWidth,
        quality: quality,
      );

      if (compressedFile != null) {
        return File(compressedFile.path);
      }

      // Fallback to image package if flutter_image_compress fails
      return await _compressWithImagePackage(file, maxWidth, quality, targetPath);
    } catch (e) {
      // If compression fails, return original file
      return file;
    }
  }

  /// Fallback compression using image package
  Future<File> _compressWithImagePackage(
    File file,
    int maxWidth,
    int quality,
    String targetPath,
  ) async {
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) {
      return file;
    }

    // Resize if width exceeds maxWidth
    img.Image resized = image;
    if (image.width > maxWidth) {
      resized = img.copyResize(
        image,
        width: maxWidth,
        height: (image.height * maxWidth ~/ image.width),
      );
    }

    // Encode as JPEG with specified quality
    final compressedBytes = img.encodeJpg(resized, quality: quality);
    final compressedFile = File(targetPath);
    await compressedFile.writeAsBytes(compressedBytes);

    return compressedFile;
  }
}
