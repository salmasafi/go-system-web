import 'dart:developer';

import 'package:dio/dio.dart';

class DioHelper {
  static String? _token;
  static late Dio dio;

  static void init(String? token) {
    _token = token;
    dio = Dio(
      BaseOptions(
        baseUrl: 'https://Bcknd.systego.net',
        receiveDataWhenStatusError: true,
        connectTimeout: const Duration(seconds: 80),
        receiveTimeout: const Duration(seconds: 80),
        headers: {'Content-Type': 'application/json'},
      ),
    );
  }

  static Future<Response> getData({
    required String url,
    Map<String, dynamic>? query,
    String? lang = 'en',
    //String? token,
  }) async {
    dio.options.headers = {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };

    final uri = Uri.parse(
      dio.options.baseUrl + url,
    ).replace(queryParameters: query);
    log('🔗 Full Request URL: $uri');

    return await dio.get(url, queryParameters: query);
  }

  static Future<Response> postData({
    required dynamic data,
    required String url,
    Map<String, dynamic>? query,
    // String? token,
  }) async {
    dio.options.headers = {
      'Content-Type': data is FormData
          ? 'multipart/form-data'
          : 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };

    final uri = Uri.parse(
      dio.options.baseUrl + url,
    ).replace(queryParameters: query);
    log('🔗 Full Request URL: $uri');

    return await dio.post(url, data: data, queryParameters: query);
  }

  static Future<Response> putData({
    required String url,
    Map<String, dynamic>? data,
    Map<String, dynamic>? query,
    // String? token,
    String lang = 'en',
    bool isFormData = false,
  }) async {
    dio.options.headers = {
      'Content-Type': isFormData
          ? 'application/x-www-form-urlencoded'
          : 'application/json',
      'lang': lang,
      if (_token != null) 'Authorization': 'Bearer $_token',
    };

    return await dio.put(
      url,
      data: isFormData ? FormData.fromMap(data ?? {}) : data,
      queryParameters: query,
    );
  }

  static Future<Response> patchData({
    Map<String, dynamic>? query,
    required String url,
    Map<String, dynamic>? data,
    // String? token,
  }) async {
    dio.options.headers = {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };

    final uri = Uri.parse(
      dio.options.baseUrl + url,
    ).replace(queryParameters: query);
    log('🔗 Full Request URL: $uri');

    return await dio.patch(url, data: data, queryParameters: query);
  }

  static Future<Response> deleteData({
    required String url,
    Map<String, dynamic>? query,
    //String? token,
  }) async {
    dio.options.headers = {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };

    final uri = Uri.parse(
      dio.options.baseUrl + url,
    ).replace(queryParameters: query);
    log('🔗 Full Request URL: $uri');

    return await dio.delete(url, queryParameters: query);
  }

  static void printResponse(Response response) {
    log('📊 Response Status: ${response.statusCode}');
    log('📊 Response Data: ${response.data}');
    log('📊 Response Headers: ${response.headers}');
  }
}
