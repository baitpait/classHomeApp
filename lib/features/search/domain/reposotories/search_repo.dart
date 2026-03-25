
import 'dart:convert';

import 'package:hexacom_user/data/datasource/remote/dio/dio_client.dart';
import 'package:hexacom_user/data/datasource/remote/exception/api_error_handler.dart';
import 'package:hexacom_user/common/models/api_response_model.dart';
import 'package:hexacom_user/utill/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchRepo {
  final DioClient? dioClient;
  final SharedPreferences? sharedPreferences;
  SearchRepo({required this.dioClient, required this.sharedPreferences});

  Future<ApiResponseModel> getSearchProductList({
    required int offset,
    String? query,
    List<int>? categoryIds,
    List<int>? tagIds,
    List<int>? attributeIds,
    int? rating,
    double? priceLow,
    double? priceHigh,
    String? shortBy,
    bool inStockOnly = false,
  }) async {

    String url = '${AppConstants.searchUri}?limit=10&offset=$offset';

    if (query != null && query.isNotEmpty) {
      url = '$url&name=${Uri.encodeComponent(query)}';
    }

    if (rating != null) {
      url = '$url&rating=${rating + 1}';
    }

    if (priceLow != null && priceHigh != null) {
      url = '$url&price_low=$priceLow&price_high=$priceHigh';
    }

    if (categoryIds != null && categoryIds.isNotEmpty) {
      url = '$url&category_ids=${Uri.encodeComponent(jsonEncode(categoryIds))}';
    }
    if (tagIds != null && tagIds.isNotEmpty) {
      url = '$url&tag_ids=${tagIds.join(',')}';
    }
    if (attributeIds != null && attributeIds.isNotEmpty) {
      url = '$url&attribute_ids=${attributeIds.join(',')}';
    }
    if (shortBy != null) {
      url = '$url&sort_by=$shortBy';
    }
    if (inStockOnly) {
      url = '$url&in_stock_only=1';
    }

    try {
      final response = await dioClient!.get(url);
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponseModel> getTags() async {
    try {
      final response = await dioClient!.get(AppConstants.tagsUri);
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponseModel> getAttributes() async {
    try {
      final response = await dioClient!.get(AppConstants.attributesUri);
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  // for save home address
  Future<void> saveSearchAddress(String searchAddress) async {
    try {
      List<String> searchKeywordList = sharedPreferences!.getStringList(AppConstants.searchAddress) ?? [];
      if (!searchKeywordList.contains(searchAddress)) {
        searchKeywordList.add(searchAddress);
      }
      await sharedPreferences!.setStringList(AppConstants.searchAddress, searchKeywordList);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeSearchAddressByName(String searchAddress) async {
    try {
      List<String> searchKeywordList = sharedPreferences!.getStringList(AppConstants.searchAddress) ?? [];
      searchKeywordList.remove(searchAddress);
      await sharedPreferences!.setStringList(AppConstants.searchAddress, searchKeywordList);
    } catch (e) {
      rethrow;
    }
  }

  List<String> getSearchAddress() {
    return sharedPreferences!.getStringList(AppConstants.searchAddress) ?? [];
  }

  Future<bool> clearSearchAddress() async {
    return sharedPreferences!.setStringList(AppConstants.searchAddress, []);
  }
}
