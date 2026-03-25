import 'package:hexacom_user/data/datasource/remote/exception/api_error_handler.dart';
import 'package:hexacom_user/common/models/api_response_model.dart';
import 'package:hexacom_user/data/datasource/remote/dio/dio_client.dart';
import 'package:hexacom_user/utill/app_constants.dart';

class LoyaltyRepo {
  final DioClient? dioClient;

  LoyaltyRepo({required this.dioClient});

  Future<ApiResponseModel> getLoyalty() async {
    try {
      final response = await dioClient!.get(AppConstants.customerLoyaltyUri);
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponseModel> getLoyaltyHistory({int page = 1, int perPage = 15}) async {
    try {
      final response = await dioClient!.get(
        AppConstants.customerLoyaltyHistoryUri,
        queryParameters: {'page': page, 'per_page': perPage},
      );
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }
}
