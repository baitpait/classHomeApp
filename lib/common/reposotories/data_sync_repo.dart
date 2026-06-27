import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:hexacom_user/common/enums/data_source_enum.dart';
import 'package:hexacom_user/common/enums/local_caches_type_enum.dart';
import 'package:hexacom_user/common/models/api_response_model.dart';
import 'package:hexacom_user/data/datasource/local/cache_response.dart';
import 'package:hexacom_user/data/datasource/remote/dio/dio_client.dart';
import 'package:hexacom_user/data/datasource/remote/exception/api_error_handler.dart';
import 'package:hexacom_user/di_container.dart';
import 'package:hexacom_user/helper/db_helper.dart';
import 'package:hexacom_user/utill/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';


class DataSyncRepo {
  final DioClient dioClient;
  final SharedPreferences? sharedPreferences;

  DataSyncRepo({required this.dioClient, required this.sharedPreferences});

  Future<ApiResponseModel<T>> fetchData<T>(String uri, DataSourceEnum source) async {
    try {
      return source == DataSourceEnum.client || _isACachesDisable() ? await _fetchFromClient<T>(uri) : await _fetchFromLocalCache<T>(uri);
    } catch (e) {
      debugPrint('DataSyncRepo: ===> $source $e ($uri)');

      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponseModel<T>> _fetchFromClient<T>(String uri) async {
    final response = await dioClient.get(uri);

    // Guard against unexpected HTML responses (e.g. Flutter web index.html instead of JSON API)
    final contentType = response.headers.value('content-type') ?? '';
    final body = response.data;
    if (contentType.contains('text/html') || (body is String && body.trimLeft().startsWith('<!DOCTYPE html'))) {
      throw const FormatException('Unexpected HTML response from API. Please check baseUrl and endpoint.');
    }

    final cacheData = CacheResponseCompanion(
      endPoint: Value(_localeAwareKey(uri)),
      header: Value(jsonEncode(dioClient.dio?.options.headers)),
      response: Value(jsonEncode(response.data)),
    );

    if (kIsWeb && _isWebCachesActive()) {
      _cacheResponseWeb(_localeAwareKey(uri), cacheData);
    }

    if(!kIsWeb && _isAppCachesActive()) {
      await DbHelper.insertOrUpdate(id: _localeAwareKey(uri), data: cacheData);
    }

    return ApiResponseModel.withSuccess(response as T);
  }

  /// مفتاح الكاش يضم اللغة لمنع عرض بيانات لغة سابقة بعد التبديل.
  /// مثال: `/api/v1/categories::ar`
  String _localeAwareKey(String uri) {
    final locale = sharedPreferences?.getString(AppConstants.languageCode)
        ?? AppConstants.languages[0].languageCode
        ?? 'ar';
    return '$uri::$locale';
  }

  bool _isWebCachesActive()=> (AppConstants.cachesType == LocalCachesTypeEnum.all || AppConstants.cachesType == LocalCachesTypeEnum.web);
  bool _isAppCachesActive()=> (AppConstants.cachesType == LocalCachesTypeEnum.all || AppConstants.cachesType == LocalCachesTypeEnum.app);
  bool _isACachesDisable() => AppConstants.cachesType == LocalCachesTypeEnum.none;

  void _cacheResponseWeb(String key, CacheResponseCompanion cacheData) {
    final cacheJson = CacheResponseData(
      id: 0,
      endPoint: cacheData.endPoint.value,
      header: cacheData.header.value,
      response: cacheData.response.value,
    ).toJson();
    sharedPreferences?.setString(key, jsonEncode(cacheJson));
  }

  Future<ApiResponseModel<T>> _fetchFromLocalCache<T>(String uri) async {
    CacheResponseData? cacheData;
    final key = _localeAwareKey(uri);

    if (kIsWeb) {
      final cachedJson = sharedPreferences?.getString(key);
      if (cachedJson != null) {
        cacheData = CacheResponseData.fromJson(jsonDecode(cachedJson));
      }
    } else {
      cacheData = await database.getCacheResponseById(key);
    }

    if (cacheData != null) {
      return ApiResponseModel.withSuccess(cacheData as T);
    } else {
      return ApiResponseModel.withError("No local data found for $key");
    }
  }
}
