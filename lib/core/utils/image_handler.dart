// lib/core/utils/image_helper.dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

class ImageHelper {
  /// Convert image file to base64 string
  static String encodeImageToBase64(File imageFile) {
    try {
      final bytes = imageFile.readAsBytesSync();
      return base64Encode(bytes);
    } catch (e) {
      throw Exception('Failed to encode image: $e');
    }
  }

  /// Convert multiple images to base64 strings
  static List<String> encodeImagesToBase64(List<File> imageFiles) {
    return imageFiles.map((file) => encodeImageToBase64(file)).toList();
  }

  /// Decode base64 string to image bytes
  static Uint8List decodeBase64ToImage(String base64String) {
    try {
      return base64Decode(base64String);
    } catch (e) {
      throw Exception('Failed to decode image: $e');
    }
  }

  /// Get file size in MB
  static double getFileSizeInMB(File file) {
    final bytes = file.lengthSync();
    return bytes / (1024 * 1024);
  }

  /// Check if file size is within limit (default 5MB)
  static bool isFileSizeValid(File file, {double maxSizeMB = 5.0}) {
    return getFileSizeInMB(file) <= maxSizeMB;
  }

  /// Validate image file
  static bool isValidImage(File file) {
    final validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
    final path = file.path.toLowerCase();
    return validExtensions.any((ext) => path.endsWith(ext));
  }
}