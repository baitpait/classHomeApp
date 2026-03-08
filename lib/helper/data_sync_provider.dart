import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:hexacom_user/common/enums/data_source_enum.dart';
import 'package:hexacom_user/common/models/api_response_model.dart';
import 'package:hexacom_user/data/datasource/local/cache_response.dart';
import 'package:hexacom_user/helper/api_checker_helper.dart';

class DataSyncProvider {
  /// Generic method to fetch data from local and remote sources
 static Future<void> fetchAndSyncData({
    required Future<ApiResponseModel<CacheResponseData>> Function() fetchFromLocal,
    required Future<ApiResponseModel<Response>> Function() fetchFromClient,
    required Function(dynamic, DataSourceEnum source) onResponse,
  }) async {

    final localFuture = fetchFromLocal();
    final clientFuture = fetchFromClient();

    final localResponse = await localFuture;
    if (localResponse.isSuccess) {
      onResponse(jsonDecode(localResponse.response!.response), DataSourceEnum.local);
    }

    final clientResponse = await clientFuture;
    if (clientResponse.isSuccess) {
      onResponse(clientResponse.response?.data, DataSourceEnum.client);
    } else {
      ApiCheckerHelper.checkApi(clientResponse);
    }

  }
}
