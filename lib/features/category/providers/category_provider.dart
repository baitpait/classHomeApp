import 'dart:convert';
import 'dart:math' as math;

import 'package:hexacom_user/common/enums/data_source_enum.dart';
import 'package:hexacom_user/common/models/api_response_model.dart';
import 'package:hexacom_user/common/models/category_model.dart';
import 'package:hexacom_user/common/models/feature_category_model.dart';
import 'package:hexacom_user/common/models/product_model.dart';
import 'package:hexacom_user/data/datasource/local/cache_response.dart';
import 'package:hexacom_user/features/category/domain/reposotories/category_repo.dart';
import 'package:hexacom_user/helper/api_checker_helper.dart';
import 'package:flutter/material.dart';
import 'package:hexacom_user/helper/data_sync_provider.dart';
import 'package:hexacom_user/utill/app_constants.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryRepo categoryRepo;

  CategoryProvider({required this.categoryRepo});

  List<CategoryModel>? _categoryList;
  List<CategoryModel>? _subCategoryList;
  List<Product>? _categoryProductList;
  bool _pageFirstIndex = true;
  bool _pageLastIndex = false;
  int _categoryIndex = 0;
  int _categorySelectedIndex = -1;
  CategoryModel? _selectedCategoryModel;
  List<CategoryModel>? _popularCategoryModel;
  List<CategoryModel>? get  popularCategoryModel => _popularCategoryModel;

  Map<int, List<Product>>? _homeNonFeaturedPreviews;
  bool _homeNonFeaturedPreloadInFlight = false;



  List<CategoryModel>? get categoryList => _categoryList;
  Map<int, List<Product>>? get homeNonFeaturedPreviews => _homeNonFeaturedPreviews;
  bool get isHomeNonFeaturedPreloadInFlight => _homeNonFeaturedPreloadInFlight;
  List<CategoryModel>? get subCategoryList => _subCategoryList;
  List<Product>? get categoryProductList => _categoryProductList;
  bool get pageFirstIndex => _pageFirstIndex;
  bool get pageLastIndex => _pageLastIndex;
  int get categoryIndex => _categoryIndex;
  int get categorySelectedIndex => _categorySelectedIndex;
  CategoryModel? get selectedCategoryModel => _selectedCategoryModel;



  Future<void> getCategoryList(bool reload) async {
    _subCategoryList = null;

    if (_categoryList == null || reload) {
      _homeNonFeaturedPreviews = null;
      await DataSyncProvider.fetchAndSyncData(
        fetchFromLocal: () => categoryRepo.getCategoryList<CacheResponseData>(source: DataSourceEnum.local),
        fetchFromClient: () => categoryRepo.getCategoryList(source: DataSourceEnum.client),
        onResponse: (data, _) {
          _categoryList = [];
          data.forEach((category) => _categoryList!.add(CategoryModel.fromJson(category)));
          notifyListeners();
        },
      );
    }
  }

  /// Fetches up to [AppConstants.homeNonFeaturedCategoryProductMax] products per non-featured category for home sections.
  Future<void> preloadHomeNonFeaturedProductPreviews() async {
    if (_homeNonFeaturedPreloadInFlight) return;
    if (_categoryList == null || _categoryList!.isEmpty) {
      _homeNonFeaturedPreviews = {};
      notifyListeners();
      return;
    }

    _homeNonFeaturedPreloadInFlight = true;
    final featuredIds = _featureCategoryModel?.featuredData
            ?.map((f) => f.category?.id)
            .whereType<int>()
            .toSet() ??
        <int>{};
    final ids = _categoryList!
        .where((c) => c.hasProductsForStoreDisplay)
        .map((c) => c.id)
        .whereType<int>()
        .where((id) => !featuredIds.contains(id))
        .toList();

    final previews = <int, List<Product>>{};
    final chunk = AppConstants.homeCategoryProductFetchConcurrency;
    final limit = AppConstants.homeNonFeaturedCategoryProductMax;

    try {
      for (var i = 0; i < ids.length; i += chunk) {
        final end = math.min(i + chunk, ids.length);
        final slice = ids.sublist(i, end);
        final partial = await Future.wait(
          slice.map((id) async {
            final list = await categoryRepo.getCategoryProductsPreview(id.toString(), limit);
            return MapEntry(id, list);
          }),
        );
        for (final e in partial) {
          previews[e.key] = e.value;
        }
      }
      _homeNonFeaturedPreviews = previews;
      notifyListeners();
    } finally {
      _homeNonFeaturedPreloadInFlight = false;
    }
  }

  Future<void> getSubCategoryList(int categoryID, {int? subCategoryId}) async {
    _subCategoryList = null;
    ApiResponseModel apiResponse = await categoryRepo.getSubCategoryList(categoryID.toString());
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _subCategoryList= [];
      apiResponse.response!.data.forEach((category) => _subCategoryList!.add(CategoryModel.fromJson(category)));
      getCategoryProductList(subCategoryId ?? categoryID);
    } else {
      ApiCheckerHelper.checkApi(apiResponse);
    }
    notifyListeners();
  }

  FeatureCategoryModel? _featureCategoryModel;
  FeatureCategoryModel? get  featureCategoryMode => _featureCategoryModel;

  void getCategoryProductList(int? categoryID) async {
    _categoryProductList = null;
    notifyListeners();
    ApiResponseModel apiResponse = await categoryRepo.getCategoryProductList(categoryID.toString());

    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _categoryProductList = [];
      apiResponse.response!.data.forEach((category) => _categoryProductList!.add(Product.fromJson(category)));
      notifyListeners();
    } else {
      ApiCheckerHelper.checkApi(apiResponse);
    }
  }




  updateProductCurrentIndex(int index, int totalLength) {
    if(index > 0) {
      _pageFirstIndex = false;
      notifyListeners();
    }else{
      _pageFirstIndex = true;
      notifyListeners();
    }
    if(index + 1  == totalLength) {
      _pageLastIndex = true;
      notifyListeners();
    }else {
      _pageLastIndex = false;
      notifyListeners();
    }
  }

  void changeIndex(int selectedIndex, {bool notify = true}) {
    _categoryIndex = selectedIndex;
    if(notify) {
      notifyListeners();
    }
  }

  void changeSelectedIndex(int selectedIndex, {bool notify = true}) {
    _categorySelectedIndex = selectedIndex;
    if(notify) {
      notifyListeners();
    }
  }


  Future<void> getFeatureCategories(bool reload, {bool isUpdate = true}) async {
    if (reload) {
      _featureCategoryModel = null;
      _homeNonFeaturedPreviews = null;
      if (isUpdate) {
        notifyListeners();
      }
    }

    if (_featureCategoryModel == null) {
      await DataSyncProvider.fetchAndSyncData(
        fetchFromLocal: () => categoryRepo.getFeatureCategories<CacheResponseData>(source: DataSourceEnum.local),
        fetchFromClient: () => categoryRepo.getFeatureCategories(source: DataSourceEnum.client),
        onResponse: (data, type) {
          _featureCategoryModel = FeatureCategoryModel.fromJson(jsonEncode(data));
          notifyListeners();
        },
      );
    }
  }

  void selectCategoryById(int? id, {bool isUpdate = false}) {
    _selectedCategoryModel = _categoryList?.firstWhere((categoryModel) => categoryModel.id == id);

    if(isUpdate) {
      notifyListeners();
    }
  }

  Future<void> getPopularCategories(bool reload, {bool isUpdate = true}) async {
    if(reload) {
      _popularCategoryModel = null;

      if(isUpdate) {
        notifyListeners();
      }
    }

    if(_popularCategoryModel == null) {

      DataSyncProvider.fetchAndSyncData(
        fetchFromLocal: ()=> categoryRepo.getPopularCategories<CacheResponseData>(source: DataSourceEnum.local),
        fetchFromClient: ()=> categoryRepo.getPopularCategories(source: DataSourceEnum.client),
        onResponse: (data, type){
          _popularCategoryModel = [];
          data.forEach((category) => _popularCategoryModel!.add(CategoryModel.fromJson(category)));
          notifyListeners();
        },
      );
    }

  }


}
