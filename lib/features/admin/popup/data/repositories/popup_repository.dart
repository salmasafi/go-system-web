import 'dart:developer';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/supabase/supabase_client.dart';
import '../../../../../core/supabase/supabase_error_handler.dart';
import '../../model/popup_model.dart';

/// Interface for popup data operations
abstract class PopupRepositoryInterface {
  Future<List<PopupModel>> getAllPopups();
  Future<void> createPopup({
    required String titleAr,
    required String titleEn,
    required String descriptionAr,
    required String descriptionEn,
    required String link,
    String? imagePath,
  });
  Future<void> updatePopup({
    required String popupId,
    required String titleAr,
    required String titleEn,
    required String descriptionAr,
    required String descriptionEn,
    required String link,
    String? imagePath,
  });
  Future<void> deletePopup(String popupId);
}

/// Repository implementation using Supabase for popups
class PopupRepository implements PopupRepositoryInterface {
  final _PopupSupabaseDataSource _dataSource = _PopupSupabaseDataSource();

  @override
  Future<List<PopupModel>> getAllPopups() => _dataSource.getAllPopups();

  @override
  Future<void> createPopup({
    required String titleAr,
    required String titleEn,
    required String descriptionAr,
    required String descriptionEn,
    required String link,
    String? imagePath,
  }) => _dataSource.createPopup(
        titleAr: titleAr,
        titleEn: titleEn,
        descriptionAr: descriptionAr,
        descriptionEn: descriptionEn,
        link: link,
        imagePath: imagePath,
      );

  @override
  Future<void> updatePopup({
    required String popupId,
    required String titleAr,
    required String titleEn,
    required String descriptionAr,
    required String descriptionEn,
    required String link,
    String? imagePath,
  }) => _dataSource.updatePopup(
        popupId: popupId,
        titleAr: titleAr,
        titleEn: titleEn,
        descriptionAr: descriptionAr,
        descriptionEn: descriptionEn,
        link: link,
        imagePath: imagePath,
      );

  @override
  Future<void> deletePopup(String popupId) => _dataSource.deletePopup(popupId);
}

/// Supabase implementation for Popup data source
class _PopupSupabaseDataSource implements PopupRepositoryInterface {
  final SupabaseClient _client = SupabaseClientWrapper.instance;
  static const String _table = 'popups';

  @override
  Future<List<PopupModel>> getAllPopups() async {
    try {
      log('PopupSupabase: Fetching all popups');
      final response = await _client
          .from(_table)
          .select()
          .order('created_at', ascending: false);
      return (response as List)
          .map((json) => _mapSupabaseToPopupModel(json))
          .toList();
    } catch (e) {
      log('PopupSupabase: Error fetching popups - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> createPopup({
    required String titleAr,
    required String titleEn,
    required String descriptionAr,
    required String descriptionEn,
    required String link,
    String? imagePath,
  }) async {
    try {
      log('PopupSupabase: Creating popup');

      String? imageUrl;
      if (imagePath != null) {
        final file = File(imagePath);
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${file.uri.pathSegments.last}';
        await _client.storage.from('popups').upload(fileName, file);
        imageUrl = _client.storage.from('popups').getPublicUrl(fileName);
      }

      await _client.from(_table).insert({
        'title_ar': titleAr,
        'title_en': titleEn,
        'description_ar': descriptionAr,
        'description_en': descriptionEn,
        'link': link,
        'image_url': imageUrl,
      });
    } catch (e) {
      log('PopupSupabase: Error creating popup - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> updatePopup({
    required String popupId,
    required String titleAr,
    required String titleEn,
    required String descriptionAr,
    required String descriptionEn,
    required String link,
    String? imagePath,
  }) async {
    try {
      log('PopupSupabase: Updating popup: $popupId');

      String? imageUrl;
      if (imagePath != null) {
        final file = File(imagePath);
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${file.uri.pathSegments.last}';
        await _client.storage.from('popups').upload(fileName, file);
        imageUrl = _client.storage.from('popups').getPublicUrl(fileName);
      }

      final updates = {
        'title_ar': titleAr,
        'title_en': titleEn,
        'description_ar': descriptionAr,
        'description_en': descriptionEn,
        'link': link,
      };

      if (imageUrl != null) {
        updates['image_url'] = imageUrl;
      }

      await _client.from(_table).update(updates).eq('id', popupId);
    } catch (e) {
      log('PopupSupabase: Error updating popup - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> deletePopup(String popupId) async {
    try {
      log('PopupSupabase: Deleting popup: $popupId');
      await _client.from(_table).delete().eq('id', popupId);
    } catch (e) {
      log('PopupSupabase: Error deleting popup - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  PopupModel _mapSupabaseToPopupModel(Map<String, dynamic> json) {
    return PopupModel(
      id: json['id'] ?? '',
      titleAr: json['title_ar'] ?? '',
      titleEn: json['title_en'] ?? '',
      descriptionAr: json['description_ar'] ?? '',
      descriptionEn: json['description_en'] ?? '',
      image: json['image_url'],
      link: json['link'] ?? '',
      version: json['version'] ?? 1,
    );
  }
}

/// Dio implementation for Popup data source (legacy)}
