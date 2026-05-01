// data/models/product_model.dart
// Assuming this is the existing or new model file. I've extended it to include all fields from the API body,
// with fromJson and toJson methods. Adjust if you have an existing partial model.

import 'dart:io';

import 'package:flutter/material.dart';

class ProductToAdd {
  final String name;
  final String image;
  final List<String> categoryId;
  final String brandId;
  final String unit;
  final double price;
  final String description;
  final bool expAbility; // Note: camelCase for Dart convention
  final int minimumQuantitySale;
  final int lowStock;
  final double wholePrice;
  final int startQuantity; // Note: corrected spelling from 'start_quantaty'
  final String taxesId;
  final bool productHasImei;
  final bool showQuantity;
  final int maximumToShow;
  final List<String> galleryProduct;

  ProductToAdd({
    required this.name,
    required this.image,
    required this.categoryId,
    required this.brandId,
    required this.unit,
    required this.price,
    required this.description,
    required this.expAbility,
    required this.minimumQuantitySale,
    required this.lowStock,
    required this.wholePrice,
    required this.startQuantity,
    required this.taxesId,
    required this.productHasImei,
    required this.showQuantity,
    required this.maximumToShow,
    required this.galleryProduct,
  });

  factory ProductToAdd.fromJson(Map<String, dynamic> json) {
    return ProductToAdd(
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      categoryId: (json['categoryId'] as List<dynamic>?)?.cast<String>() ?? [],
      brandId: json['brandId'] ?? '',
      unit: json['unit'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] ?? '',
      expAbility: json['exp_ability'] ?? false,
      minimumQuantitySale: json['minimum_quantity_sale'] ?? 1,
      lowStock: json['low_stock'] ?? 0,
      wholePrice: (json['whole_price'] as num?)?.toDouble() ?? 0.0,
      startQuantity: json['start_quantaty'] ?? 0, // Note: keep original key for fromJson
      taxesId: json['taxesId'] ?? '',
      productHasImei: json['product_has_imei'] ?? false,
      showQuantity: json['show_quantity'] ?? false,
      maximumToShow: json['maximum_to_show'] ?? 0,
      galleryProduct: (json['gallery_product'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image': image,
      'categoryId': categoryId,
      'brandId': brandId,
      'unit': unit,
      'price': price,
      'description': description,
      'exp_ability': expAbility,
      'minimum_quantity_sale': minimumQuantitySale,
      'low_stock': lowStock,
      'whole_price': wholePrice,
      'start_quantaty': startQuantity, // Note: use original snake_case for API
      'taxesId': taxesId,
      'product_has_imei': productHasImei,
      'show_quantity': showQuantity,
      'maximum_to_show': maximumToShow,
      'gallery_product': galleryProduct,
    };
  }
}

