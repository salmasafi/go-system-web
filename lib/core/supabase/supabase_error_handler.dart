import 'package:supabase_flutter/supabase_flutter.dart';

/// Unified error handler for Supabase-related exceptions
/// Provides user-friendly error messages in both Arabic and English
class SupabaseErrorHandler {
  /// Handle any Supabase-related error and return a user-friendly message
  static String handleError(dynamic error, {String? context}) {
    if (error is PostgrestException) {
      return _handlePostgrestError(error);
    } else if (error is AuthException) {
      return _handleAuthError(error);
    } else if (error is StorageException) {
      return _handleStorageError(error);
    } else if (error.toString().contains('Realtime')) {
      return _handleRealtimeError(error);
    } else if (error is Exception) {
      return error.toString();
    }
    return 'حدث خطأ غير متوقع | An unexpected error occurred';
  }

  /// Handle PostgreSQL/Postgrest errors
  static String _handlePostgrestError(PostgrestException error) {
    final code = error.code;
    final message = error.message;

    // Common PostgreSQL error codes
    switch (code) {
      // Connection/Auth errors
      case 'PGRST301':
        return 'انتهت صلاحية الجلسة | Session expired. Please login again.';
      case 'PGRST302':
        return 'غير مصرح | Not authorized. Please check your permissions.';

      // Constraint violations
      case '23505':
        return 'هذا السجل موجود مسبقاً | This record already exists (duplicate entry).';
      case '23503':
        return 'البيانات المرتبطة غير موجودة | Related data not found (foreign key violation).';
      case '23514':
        return 'القيمة غير صالحة | Invalid value (check constraint violation).';
      case '23502':
        return 'قيمة مطلوبة مفقودة | Required value is missing (not null violation).';

      // Data errors
      case '22001':
        return 'البيانات طويلة جداً | Data too long for the field.';
      case '22P02':
        return 'تنسيق البيانات غير صالح | Invalid data format.';
      case '22003':
        return 'الرقم خارج النطاق | Numeric value out of range.';
      case '22007':
        return 'تاريخ/وقت غير صالح | Invalid date/time format.';

      // Not found
      case 'PGRST116':
        return 'السجل غير موجود | Record not found.';

      // Schema cache errors - column/table not found in schema
      case 'PGRST204':
        if (message.contains('column')) {
          return 'عمود الجدول غير موجود في قاعدة البيانات | Database column not found. Please contact support.';
        }
        return 'خطأ في هيكل قاعدة البيانات | Database schema error. Please contact support.';

      // Default - return the original message
      default:
        return 'خطأ في قاعدة البيانات | Database error: $message';
    }
  }

  /// Handle authentication errors
  static String _handleAuthError(AuthException error) {
    final message = error.message.toLowerCase();

    if (message.contains('invalid login credentials')) {
      return 'بيانات الدخول غير صحيحة | Invalid login credentials.';
    } else if (message.contains('user not found')) {
      return 'المستخدم غير موجود | User not found.';
    } else if (message.contains('email not confirmed')) {
      return 'لم يتم تأكيد البريد الإلكتروني | Email not confirmed.';
    } else if (message.contains('invalid email')) {
      return 'بريد إلكتروني غير صالح | Invalid email format.';
    } else if (message.contains('password')) {
      return 'كلمة المرور ضعيفة أو غير صحيحة | Password is weak or incorrect.';
    } else if (message.contains('rate limit')) {
      return 'محاولات كثيرة جداً، يرجى المحاولة لاحقاً | Too many attempts. Please try again later.';
    }

    return 'خطأ في المصادقة | Authentication error: ${error.message}';
  }

  /// Handle storage errors
  static String _handleStorageError(StorageException error) {
    final message = error.message.toLowerCase();

    if (message.contains('not found')) {
      return 'الملف غير موجود | File not found.';
    } else if (message.contains('unauthorized') || message.contains('forbidden')) {
      return 'غير مصرح بالوصول للملف | Unauthorized access to file.';
    } else if (message.contains('too large') || message.contains('size')) {
      return 'حجم الملف كبير جداً | File size is too large.';
    } else if (message.contains('bucket')) {
      return 'حاوية التخزين غير موجودة | Storage bucket not found.';
    }

    return 'خطأ في التخزين | Storage error: ${error.message}';
  }

  /// Handle realtime/WebSocket errors
  static String _handleRealtimeError(dynamic error) {
    final message = error.toString().toLowerCase();

    if (message.contains('connection') || message.contains('websocket')) {
      return 'فشل الاتصال بالخادم | Connection failed. Please check your internet connection.';
    } else if (message.contains('timeout')) {
      return 'انتهت مهلة الاتصال | Connection timed out.';
    } else if (message.contains('unauthorized')) {
      return 'غير مصرح بالوصول للتحديثات الفورية | Unauthorized access to real-time updates.';
    }

    return 'خطأ في التحديثات الفورية | Real-time error: ${error.toString()}';
  }

  /// Get error type for programmatic handling
  static ErrorType getErrorType(dynamic error) {
    if (error is PostgrestException) {
      if (error.code == '23505') return ErrorType.duplicate;
      if (error.code == '23503') return ErrorType.foreignKey;
      if (error.code == 'PGRST301') return ErrorType.unauthorized;
      if (error.code == 'PGRST116') return ErrorType.notFound;
      return ErrorType.database;
    } else if (error is AuthException) {
      return ErrorType.auth;
    } else if (error is StorageException) {
      return ErrorType.storage;
    } else if (error.toString().contains('Realtime')) {
      return ErrorType.realtime;
    }
    return ErrorType.unknown;
  }
}

/// Error types for programmatic error handling
enum ErrorType {
  database,
  auth,
  storage,
  realtime,
  duplicate,
  foreignKey,
  notFound,
  unauthorized,
  unknown,
}

/// Custom exception class for application-specific errors
class AppException implements Exception {
  final String message;
  final ErrorType type;
  final dynamic originalError;

  AppException({
    required this.message,
    this.type = ErrorType.unknown,
    this.originalError,
  });

  @override
  String toString() => message;
}
