
import 'package:hexacom_user/common/enums/data_source_enum.dart';
import 'package:hexacom_user/common/enums/product_filter_type_enum.dart';
import 'package:hexacom_user/common/models/api_response_model.dart';
import 'package:hexacom_user/common/models/review_body_model.dart';
import 'package:hexacom_user/common/reposotories/data_sync_repo.dart';
import 'package:hexacom_user/data/datasource/remote/exception/api_error_handler.dart';
import 'package:hexacom_user/helper/product_helper.dart';
import 'package:hexacom_user/utill/app_constants.dart';
import 'package:image_picker/image_picker.dart';

class ProductRepo extends DataSyncRepo{

  ProductRepo({required super.dioClient, required super.sharedPreferences});

  Future<ApiResponseModel<T>> getLatestProductList<T>(int offset, int limit, ProductFilterType? filterType, {required DataSourceEnum source}) async {

    return  await fetchData<T>('${AppConstants.latestProductUri}?limit=$limit&&offset=$offset${filterType != null ? '&sort_by=${ProductHelper.getProductFilterTypeValue(filterType)}' : ''}', source);
  }

  Future<ApiResponseModel<T>> getOfferProductList<T>({required DataSourceEnum source}) async {
    return await fetchData<T>(AppConstants.offerProductUri, source);

  }


  Future<ApiResponseModel> getProductDetails(String productID) async {
    try {
      final response = await dioClient.get(
        '${AppConstants.productDetailsUri}$productID',
      );
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponseModel> searchProduct(String productId) async {
    try {
      final response = await dioClient.get(
        '${AppConstants.searchProductUri}$productId',
      );
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponseModel> submitReview(ReviewBodyModel reviewBody, List<XFile>? files) async {
    try {
      final response = await dioClient.postMultipart(AppConstants.reviewUri, data: reviewBody.toJson(), files: files, fileKey: files != null ? 'attachment' : null);
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponseModel> submitDeliveryManReview(ReviewBodyModel reviewBody) async {
    try {
      final response = await dioClient.post(AppConstants.deliverManReviewUri, data: reviewBody);
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponseModel> getProductReviewList(int? productID, int? offset) async {
    try {
      final response = await dioClient.get('${AppConstants.productReviewUri}$productID?limit=10&offset=${offset ?? 1}');
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponseModel<T>> getFlashSale<T>(int offset,{
    required DataSourceEnum source,
    int? rating,
    double? priceLow,
    double? priceHigh,
    String? shortBy,
    List<int>? categoryIds,
  }) async {
    String url = '${AppConstants.flashSale}?limit=15&&offset=$offset';

    if(rating != null) {
      url = '$url&rating=${rating+1}';
    }

    if(priceLow != null && priceHigh != null){
      url = '$url&price_low=$priceLow&price_high=$priceHigh';
    }

    if(categoryIds != null && categoryIds.isNotEmpty) {
      url = '$url&category_ids=$categoryIds';
    }
    if(shortBy != null) {
      url = '$url&sort_by=$shortBy';
    }

    return  await fetchData<T>(url, source);
  }

  Future<ApiResponseModel<T>> getNewArrivalProducts<T>(int offset, {required DataSourceEnum source}) async {
    return await fetchData(AppConstants.newArrivalProducts, source);
  }

}
