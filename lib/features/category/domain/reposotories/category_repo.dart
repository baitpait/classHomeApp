import 'package:hexacom_user/common/enums/data_source_enum.dart';
import 'package:hexacom_user/common/models/api_response_model.dart';
import 'package:hexacom_user/common/models/product_model.dart';
import 'package:hexacom_user/common/reposotories/data_sync_repo.dart';
import 'package:hexacom_user/data/datasource/remote/exception/api_error_handler.dart';
import 'package:hexacom_user/utill/app_constants.dart';

class CategoryRepo extends DataSyncRepo{
  CategoryRepo({required super.dioClient, required super.sharedPreferences});

  Future<ApiResponseModel<T>> getCategoryList<T>({required DataSourceEnum source}) async {
    return await fetchData<T>(AppConstants.categoryUri, source);

  }

  Future<ApiResponseModel> getSubCategoryList(String parentID) async {
    try {
      final response = await dioClient.get(
        '${AppConstants.subCategoryUri}$parentID',
      );
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponseModel> getCategoryProductList(String categoryID) async {
    try {
      final response = await dioClient.get(
        '${AppConstants.categoryProductUri}$categoryID',
      );
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  /// Active products for home preview, capped at [maxCount] (no provider state).
  Future<List<Product>> getCategoryProductsPreview(
    String categoryId,
    int maxCount,
  ) async {
    try {
      final res = await getCategoryProductList(categoryId);
      if (!res.isSuccess || res.response == null) return [];
      final data = res.response!.data;
      if (data is! List) return [];
      final out = <Product>[];
      for (final e in data) {
        if (e is! Map) continue;
        final p = Product.fromJson(Map<String, dynamic>.from(e));
        if (p.status != true) continue;
        out.add(p);
        if (out.length >= maxCount) break;
      }
      return out;
    } catch (_) {
      return [];
    }
  }
  Future<ApiResponseModel<T>> getFeatureCategories<T>({required DataSourceEnum source}) async {
    return await fetchData<T>(AppConstants.featureCategory, source);

  }

  Future<ApiResponseModel<T>> getPopularCategories<T>({required DataSourceEnum source}) async {
    return await fetchData<T>(AppConstants.popularCategory, source);

  }

}