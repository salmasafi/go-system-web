import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/migration/migration_service.dart';
import '../../../../../core/services/dio_helper.dart';
import '../../../../../core/services/endpoints.dart';
import '../../../../../core/supabase/supabase_client.dart';
import '../../../../../core/supabase/storage_service.dart';
import '../../../../../core/supabase/supabase_error_handler.dart';
import '../../../../../core/utils/error_handler.dart';
import '../../model/supplier_model.dart';

/// Interface for supplier data operations
abstract class SupplierRepositoryInterface {
  Future<List<Suppliers>> getAllSuppliers();
  Future<Suppliers?> getSupplierById(String id);
  Future<Suppliers> createSupplier({
    required String username,
    required String email,
    required String phoneNumber,
    required String address,
    required String companyName,
    String? countryId,
    String? cityId,
    File? imageFile,
  });
  Future<Suppliers> updateSupplier({
    required String id,
    required String username,
    required String email,
    required String phoneNumber,
    required String address,
    required String companyName,
    String? countryId,
    String? cityId,
    File? imageFile,
  });
  Future<void> deleteSupplier(String id);
}

/// Supplier repository using Supabase as the primary data source.
class SupplierRepository implements SupplierRepositoryInterface {
  final SupabaseClient _client = SupabaseClientWrapper.instance;
  final StorageService _storage = StorageService(SupabaseClientWrapper.instance);

  @override
  Future<List<Suppliers>> getAllSuppliers() async {
    try {
      log('SupplierRepository: Fetching all suppliers');

      final response = await _client
          .from('suppliers')
          .select('''
            *,
            country:country_id(*),
            city:city_id(*)
          ''')
          .order('username');

      final suppliers = (response as List)
          .map((json) => _mapSupabaseToSuppliers(json))
          .toList();

      log('SupplierRepository: Fetched ${suppliers.length} suppliers');
      return suppliers;
    } catch (e) {
      log('SupplierRepository: Error fetching suppliers - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<Suppliers?> getSupplierById(String id) async {
    try {
      log('SupplierRepository: Fetching supplier by id: $id');

      final response = await _client
          .from('suppliers')
          .select('''
            *,
            country:country_id(*),
            city:city_id(*)
          ''')
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;

      return _mapSupabaseToSuppliers(response);
    } catch (e) {
      log('SupplierRepository: Error fetching supplier - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<Suppliers> createSupplier({
    required String username,
    required String email,
    required String phoneNumber,
    required String address,
    required String companyName,
    String? countryId,
    String? cityId,
    File? imageFile,
  }) async {
    try {
      log('SupplierRepository: Creating supplier: $username');

      // Upload image if provided
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await _storage.uploadImage(
          file: imageFile,
          folder: 'suppliers',
          fileName: '${username.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.jpg',
          maxWidth: 800,
        );
      }

      final response = await _client
          .from('suppliers')
          .insert({
            'username': username,
            'email': email,
            'phone_number': phoneNumber,
            'address': address,
            'company_name': companyName,
            'country_id': countryId,
            'city_id': cityId,
            'image': imageUrl,
          })
          .select('''
            *,
            country:country_id(*),
            city:city_id(*)
          ''')
          .single();

      log('SupplierRepository: Created supplier successfully');
      return _mapSupabaseToSuppliers(response);
    } catch (e) {
      log('SupplierRepository: Error creating supplier - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<Suppliers> updateSupplier({
    required String id,
    required String username,
    required String email,
    required String phoneNumber,
    required String address,
    required String companyName,
    String? countryId,
    String? cityId,
    File? imageFile,
  }) async {
    try {
      log('SupplierRepository: Updating supplier: $id');

      // Get current supplier to check for image update
      final current = await getSupplierById(id);

      // Upload new image if provided
      String? imageUrl;
      if (imageFile != null) {
        // Delete old image if exists
        if (current?.image != null && current!.image!.isNotEmpty) {
          try {
            final oldPath = current.image!.split('/').last;
            await _storage.deleteImage('suppliers/$oldPath');
          } catch (e) {
            log('SupplierRepository: Failed to delete old image - $e');
          }
        }

        imageUrl = await _storage.uploadImage(
          file: imageFile,
          folder: 'suppliers',
          fileName: '${username.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.jpg',
          maxWidth: 800,
        );
      }

      final updateData = {
        'username': username,
        'email': email,
        'phone_number': phoneNumber,
        'address': address,
        'company_name': companyName,
        'country_id': countryId,
        'city_id': cityId,
        if (imageUrl != null) 'image': imageUrl,
      };

      final response = await _client
          .from('suppliers')
          .update(updateData)
          .eq('id', id)
          .select('''
            *,
            country:country_id(*),
            city:city_id(*)
          ''')
          .single();

      log('SupplierRepository: Updated supplier successfully');
      return _mapSupabaseToSuppliers(response);
    } catch (e) {
      log('SupplierRepository: Error updating supplier - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> deleteSupplier(String id) async {
    try {
      log('SupplierRepository: Deleting supplier: $id');

      // Get supplier to delete image if exists
      final supplier = await getSupplierById(id);
      if (supplier?.image != null && supplier!.image!.isNotEmpty) {
        try {
          final imagePath = supplier.image!.split('/').last;
          await _storage.deleteImage('suppliers/$imagePath');
        } catch (e) {
          log('SupplierRepository: Failed to delete image - $e');
        }
      }

      await _client.from('suppliers').delete().eq('id', id);

      log('SupplierRepository: Deleted supplier successfully');
    } catch (e) {
      log('SupplierRepository: Error deleting supplier - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  /// Map Supabase response to Suppliers model
  Suppliers _mapSupabaseToSuppliers(Map<String, dynamic> json) {
    final countryData = json['country'] as Map<String, dynamic>?;
    final cityData = json['city'] as Map<String, dynamic>?;

    return Suppliers(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number']?.toString() ?? '',
      address: json['address'] ?? '',
      companyName: json['company_name'] ?? '',
      image: json['image'] ?? '',
      countryId: countryData != null
          ? CountryId(
              id: countryData['id'] ?? '',
              name: countryData['name'] ?? '',
              isDefault: countryData['is_default'] ?? false,
              v: countryData['version'] ?? 1,
            )
          : null,
      cityId: cityData != null
          ? CityId(
              id: cityData['id'] ?? '',
              name: cityData['name'] ?? '',
              shipingCost: cityData['shipping_cost'] ?? 0,
              country: cityData['country_id'] ?? '',
              v: cityData['version'] ?? 1,
            )
          : null,
      v: json['version'] ?? 1,
    );
  }
}

