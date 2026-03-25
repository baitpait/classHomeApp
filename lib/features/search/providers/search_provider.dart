import 'package:hexacom_user/common/enums/search_short_by_enum.dart';
import 'package:hexacom_user/common/models/attribute_model.dart';
import 'package:hexacom_user/common/models/tag_model.dart';
import 'package:flutter/material.dart';
import 'package:hexacom_user/common/models/api_response_model.dart';
import 'package:hexacom_user/common/models/product_model.dart';
import 'package:hexacom_user/features/flash_sale/providers/flash_sale_provider.dart';
import 'package:hexacom_user/features/search/widgets/product_filter_bottom_sheet_widget.dart';
import 'package:hexacom_user/features/search/domain/reposotories/search_repo.dart';
import 'package:hexacom_user/helper/api_checker_helper.dart';
import 'package:hexacom_user/helper/product_filter_helper.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:provider/provider.dart';


class SearchProvider with ChangeNotifier {
  final SearchRepo? searchRepo;

  SearchProvider({required this.searchRepo});

  double? _lowerValue;
  double? _upperValue;
  List<String> _historyList = [];
  ProductModel? _productSuggestionModel ;
  bool _isSearch = true;
  Set<int> _selectCategoryList = {};
  Set<int> _selectedTagIds = {};
  Set<int> _selectedAttributeIds = {};
  List<TagModel>? _tagList;
  List<AttributeModel>? _attributeList;
  SearchShortBy? _selectedSearchShotBy;
  final TextEditingController _searchController = TextEditingController();
  ProductModel? _searchProductModel;
  int _rating = -1;
  bool _inStockOnly = false;

  double? get lowerValue => _lowerValue;
  double? get upperValue => _upperValue;
  bool get isSearch => _isSearch;
  Set<int> get selectCategoryList => _selectCategoryList;
  Set<int> get selectedTagIds => _selectedTagIds;
  Set<int> get selectedAttributeIds => _selectedAttributeIds;
  List<TagModel>? get tagList => _tagList;
  List<AttributeModel>? get attributeList => _attributeList;
  List<String> get historyList => _historyList;
  ProductModel? get productSuggestionModel => _productSuggestionModel;
  TextEditingController get searchController => _searchController;
  SearchShortBy? get selectedSearchShotBy => _selectedSearchShotBy;
  int get rating => _rating;
  bool get inStockOnly => _inStockOnly;


 void setSearchText(String stringText){
   _searchController.text = stringText;
 }

  void changeSearchStatus(){
    _isSearch = !_isSearch;
    notifyListeners();
  }


  void setLowerAndUpperValue(double? lower, double? upper, {bool isUpdate = true}) {
    _lowerValue = lower;
    _upperValue = upper;

    if(isUpdate) {
      notifyListeners();
    }
  }


  ProductModel? get searchProductModel => _searchProductModel;




  Future<void> searchProduct({
    required int offset,
    String? query,
    List<int>? categoryIds,
    List<int>? tagIds,
    List<int>? attributeIds,
    int? rating,
    double? priceLow,
    double? priceHigh,
    SearchShortBy? shortBy,
    bool isUpdate = false,
  }) async {

    if (offset == 1) {
      _searchProductModel = null;

      if (isUpdate) {
        notifyListeners();
      }
    }

    ApiResponseModel apiResponse = await searchRepo!.getSearchProductList(
      offset: offset,
      query: query,
      categoryIds: categoryIds,
      tagIds: tagIds,
      attributeIds: attributeIds,
      priceHigh: priceHigh,
      priceLow: priceLow,
      rating: rating,
      shortBy: getShortByValue(shortBy),
      inStockOnly: _inStockOnly,
    );
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {

      if(offset == 1){
        _searchProductModel = ProductModel.fromJson(apiResponse.response?.data);
      } else {
        _searchProductModel!.totalSize = ProductModel.fromJson(apiResponse.response?.data).totalSize;
        _searchProductModel!.offset = ProductModel.fromJson(apiResponse.response?.data).offset;
        _searchProductModel!.products!.addAll(ProductModel.fromJson(apiResponse.response?.data).products!);
      }


    } else {
      _searchProductModel = ProductModel(products: []);
      ApiCheckerHelper.checkApi(apiResponse);
    }
    notifyListeners();
  }

  void getHistoryList() {
    _historyList = [];
    _historyList.addAll(searchRepo!.getSearchAddress());
  }

  void saveSearchAddress(String searchAddress) async {
    if (!_historyList.contains(searchAddress)) {
      _historyList.add(searchAddress);
      searchRepo!.saveSearchAddress(searchAddress);
      notifyListeners();
    }
  }

  void removeSearchAddressByName(String searchAddress) async {

    _historyList.remove(searchAddress);
    searchRepo!.removeSearchAddressByName(searchAddress);
    notifyListeners();
  }

  void clearSearchAddress() async {
    searchRepo!.clearSearchAddress();
    _historyList = [];
    notifyListeners();
  }


  void setRating(int rate, {bool isUpdate = true}) {
    _rating = rate;

    if(isUpdate) {
      notifyListeners();
    }

  }

 void selectCategoryListAdd(int index, {bool isClear = false, bool isUpdate = true}) {
    if(isClear) {
      _selectCategoryList = {};
    }else{
      if(_selectCategoryList.contains(index)) {
        _selectCategoryList.remove(index);
      }else {
        _selectCategoryList.add(index);
      }
    }

    if(isUpdate) {
      notifyListeners();
    }
  }

  void toggleTag(int tagId, {bool isUpdate = true}) {
    if (tagId <= 0) return;
    if (_selectedTagIds.contains(tagId)) {
      _selectedTagIds.remove(tagId);
    } else {
      _selectedTagIds.add(tagId);
    }
    if (isUpdate) notifyListeners();
  }

  void clearSelectedTags({bool isUpdate = true}) {
    _selectedTagIds = {};
    if (isUpdate) notifyListeners();
  }

  void toggleAttribute(int attributeId, {bool isUpdate = true}) {
    if (attributeId <= 0) return;
    if (_selectedAttributeIds.contains(attributeId)) {
      _selectedAttributeIds.remove(attributeId);
    } else {
      _selectedAttributeIds.add(attributeId);
    }
    if (isUpdate) notifyListeners();
  }

  void clearSelectedAttributes({bool isUpdate = true}) {
    _selectedAttributeIds = {};
    if (isUpdate) notifyListeners();
  }

  Future<void> loadTags() async {
    if (_tagList != null) return;
    final apiResponse = await searchRepo!.getTags();
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      final list = apiResponse.response!.data as List?;
      _tagList = list?.map((e) => TagModel.fromJson(e as Map<String, dynamic>)).toList() ?? [];
    } else {
      _tagList = [];
    }
    notifyListeners();
  }

  Future<void> loadAttributes() async {
    if (_attributeList != null) return;
    final apiResponse = await searchRepo!.getAttributes();
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      final list = apiResponse.response!.data as List?;
      _attributeList = list?.map((e) => AttributeModel.fromJson(e as Map<String, dynamic>)).toList() ?? [];
    } else {
      _attributeList = [];
    }
    notifyListeners();
  }

  void setInStockOnly(bool value, {bool isUpdate = true}) {
    _inStockOnly = value;
    if (isUpdate) notifyListeners();
  }

  void resetSearchFilterData(BuildContext context, bool fromFlashSales, {bool isUpdate = false, bool fromInitState = false}) async {
    setRating(-1, isUpdate: isUpdate);
    selectCategoryListAdd(-1, isClear: true, isUpdate: isUpdate);
    clearSelectedTags(isUpdate: isUpdate);
    clearSelectedAttributes(isUpdate: isUpdate);
    setInStockOnly(false, isUpdate: isUpdate);
    setSelectShortBy(null, isUpdate: isUpdate);

    if(!fromInitState){
      if(fromFlashSales){
        FlashSaleProvider flashSaleProvider = Provider.of<FlashSaleProvider>(context, listen: false);
        flashSaleProvider.getFlashSaleProducts(1, false);
        setLowerAndUpperValue(flashSaleProvider.flashSaleModel?.productLowestPrice ??  0, flashSaleProvider.flashSaleModel?.productHighPrice ??  1, isUpdate: isUpdate);
      }else{
        await searchProduct(offset: 1);
        setLowerAndUpperValue(searchProductModel?.productLowestPrice ??  0, searchProductModel?.productHighPrice ??  1, isUpdate: isUpdate);
      }
    }

  }

  void setSelectShortBy(SearchShortBy? shortBy, {bool isUpdate = true}) {
    _selectedSearchShotBy = shortBy;
    if(isUpdate) {
      notifyListeners();
    }

  }

  String? getShortByValue(SearchShortBy? shortBy) {
    String? value;
    switch(shortBy) {
      case SearchShortBy.newArrivals:
        value = 'new_arrival';
        break;
      case SearchShortBy.offerProducts:
        value = 'offer_product';
        break;
      case SearchShortBy.priceLowToHigh:
        value = 'price_low_to_high';
        break;
      case SearchShortBy.priceHighToLow:
        value = 'price_high_to_low';
        break;
      case SearchShortBy.aToz:
        value = 'a_to_z';
        break;
      case SearchShortBy.zToa:
        value = 'z_to_a';
        break;
      case SearchShortBy.topRated:
        value = 'top_rated';
        break;
      case SearchShortBy.bestSelling:
        value = 'best_selling';
        break;
      case null:
        break;
    }

    return value;
  }

  Future<void> showProductFilter(Size size, BuildContext context, {bool fromFlashSales = false}) async {
    if (!fromFlashSales) {
      await loadTags();
      await loadAttributes();
    }

    if (!context.mounted) return;
    FlashSaleProvider flashSaleProvider = Provider.of<FlashSaleProvider>(context, listen: false);

    double width = (size.width - Dimensions.webScreenWidth) / 2;

    RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final searchBarPosition = renderBox.localToGlobal(Offset.zero);

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => Stack(children: [
        Positioned(
          top: searchBarPosition.dy + (fromFlashSales ? (renderBox.size.height + 5) : size.height * 0.1),
          right: width + Dimensions.paddingSizeSmall,
          child: Material(
            color: Colors.transparent,
            elevation: 0,
            borderRadius: BorderRadius.circular(30),
            child: Consumer<SearchProvider>(builder: (context, searchProvider,_) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 360,
                  constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.7),
                  decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      boxShadow: [BoxShadow(
                        color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha:0.05),
                        offset: const Offset(0, 5),
                        spreadRadius: 0,
                        blurRadius: 15,
                      )]
                  ),
                  child: ProductFilterBottomSheetWidget(
                      sliderMax: fromFlashSales ? flashSaleProvider.flashSaleModel?.productHighPrice : searchProductModel?.productHighPrice,
                      sliderMin: fromFlashSales ? flashSaleProvider.flashSaleModel?.productLowestPrice : searchProductModel?.productLowestPrice,
                      searchMaxPrice: fromFlashSales ? flashSaleProvider.flashSaleModel?.sortedHighPrice : searchProductModel?.sortedHighPrice,
                      searchMinPrice: fromFlashSales ? flashSaleProvider.flashSaleModel?.sortedLowestPrice : searchProductModel?.sortedLowestPrice,
                      onClearTap: () => resetSearchFilterData(context, fromFlashSales, isUpdate: true),
                      canFiltered: fromFlashSales ? ProductFilterHelper.canFlashSalesFilter() : ProductFilterHelper.canProductFilter(),
                      tagList: fromFlashSales ? null : tagList,
                      attributeList: fromFlashSales ? null : attributeList,
                      onSubmitTap: () {
                        if(fromFlashSales){
                          flashSaleProvider.getFlashSaleProducts(
                              1, false,
                              rating: rating == -1 ? null : rating,
                              priceLow: lowerValue,
                              priceHigh: upperValue,
                              categoryIds: selectCategoryList.toList(),
                              shortBy: getShortByValue(selectedSearchShotBy)
                          );
                        } else {
                          searchProduct(
                            offset: 1,
                            query: _searchController.text,
                            rating: rating == -1 ? null : rating,
                            priceLow: lowerValue,
                            priceHigh: upperValue,
                            categoryIds: selectCategoryList.toList(),
                            tagIds: selectedTagIds.isEmpty ? null : selectedTagIds.toList(),
                            attributeIds: selectedAttributeIds.isEmpty ? null : selectedAttributeIds.toList(),
                            shortBy: selectedSearchShotBy,
                            isUpdate: true,
                          );
                        }
                        Navigator.pop(context);
                      }
                  ),
                ),
              ],
            )),
          ),
        ),

      ]),
    );
  }

  void getSuggestionList(String text, {bool isUpdate = true}) async{
    _productSuggestionModel = null;

    ApiResponseModel apiResponse = await searchRepo!.getSearchProductList(offset: 1, query: text);

    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _productSuggestionModel = ProductModel.fromJson(apiResponse.response?.data);

    } else {
      _productSuggestionModel = ProductModel(products: []);
      ApiCheckerHelper.checkApi(apiResponse);
    }

    if(isUpdate){
      notifyListeners();
    }
  }


}
