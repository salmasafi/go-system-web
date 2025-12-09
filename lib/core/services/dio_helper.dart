import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:systego/core/services/endpoints.dart';
import 'package:systego/core/services/session_helper.dart';
import 'cache_helper.dart';

class DioHelper {
  static late Dio dio;

  static void init() {
    dio = Dio(
      BaseOptions(
        baseUrl: EndPoint.baseUrl,
        receiveDataWhenStatusError: true,
        // connectTimeout: const Duration(seconds: 20),
        // receiveTimeout: const Duration(seconds: 20),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            log('🚨 Unauthorized — broadcasting sessionExpired');
            await CacheHelper.clearAllData();
            SessionManager.notifySessionExpired();
          }
          return handler.next(e);
        },
      ),
    );
  }

  static Future<Response> getData({
    required String url,
    Map<String, dynamic>? query,
    String? lang = 'en',
    String? token,
  }) async {
    final String? token = CacheHelper.getData(key: 'token');

    dio.options.headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
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
    String? token,
  }) async {
    final String? token = CacheHelper.getData(key: 'token');

    dio.options.headers = {
      'Content-Type': data is FormData
          ? 'multipart/form-data'
          : 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final uri = Uri.parse(
      dio.options.baseUrl + url,
    ).replace(queryParameters: query);
    log('🔗 Full Request URL: $uri');
    log('🔗 Full Request Response: $data');

    return await dio.post(url, data: data, queryParameters: query);
  }

  static Future<Response> putData({
    required String url,
    Map<String, dynamic>? data,
    Map<String, dynamic>? query,
    String? token,
    String lang = 'en',
    bool isFormData = false,
  }) async {
    final String? token = CacheHelper.getData(key: 'token');

    dio.options.headers = {
      'Content-Type': isFormData
          ? 'application/x-www-form-urlencoded'
          : 'application/json',
      'lang': lang,
      if (token != null) 'Authorization': 'Bearer $token',
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
    String? token,
  }) async {
    final String? token = CacheHelper.getData(key: 'token');

    dio.options.headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
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
    String? token,
  }) async {
    final String? token = CacheHelper.getData(key: 'token');

    dio.options.headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
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
