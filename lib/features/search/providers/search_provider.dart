import 'package:hexacom_user/common/enums/search_short_by_enum.dart';
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
  SearchShortBy? _selectedSearchShotBy;
  final TextEditingController _searchController = TextEditingController();
  ProductModel? _searchProductModel;
  int _rating = -1;

  double? get lowerValue => _lowerValue;
  double? get upperValue => _upperValue;
  bool get isSearch => _isSearch;
  Set<int> get selectCategoryList => _selectCategoryList;
  List<String> get historyList => _historyList;
  ProductModel? get productSuggestionModel => _productSuggestionModel;
  TextEditingController  get searchController=> _searchController;
  SearchShortBy? get selectedSearchShotBy => _selectedSearchShotBy;
  int get rating => _rating;


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
    int? rating,
    double? priceLow,
    double? priceHigh,
    SearchShortBy? shortBy,
    bool isUpdate = false,
  }) async {

    if(offset == 1) {
      _searchProductModel = null;

      if(isUpdate) {
        notifyListeners();
      }

    }

    ApiResponseModel apiResponse = await searchRepo!.getSearchProductList(
      offset: offset,
      query: query, categoryIds: categoryIds,
      priceHigh: priceHigh, priceLow: priceLow, rating: rating,
      shortBy: getShortByValue(shortBy),
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
print('=====product length==============${_searchProductModel?.products?.length}');
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

  void resetSearchFilterData(BuildContext context, bool fromFlashSales, {bool isUpdate = false, bool fromInitState = false}) async{
    setRating(-1, isUpdate: isUpdate);
    selectCategoryListAdd(-1, isClear: true, isUpdate: isUpdate);
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
      case null:
        break;
    }

    return value;
  }

  void showProductFilter(Size size, BuildContext context, {bool fromFlashSales = false}){
    FlashSaleProvider flashSaleProvider = Provider.of<FlashSaleProvider>(context, listen: false);

    double width = (size.width - Dimensions.webScreenWidth) / 2;

    RenderBox renderBox = context.findRenderObject() as RenderBox;
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
                      onClearTap: ()=> resetSearchFilterData(context, fromFlashSales, isUpdate: true),
                      canFiltered: fromFlashSales ? ProductFilterHelper.canFlashSalesFilter() : ProductFilterHelper.canProductFilter(),
                      onSubmitTap: (){
                        if(fromFlashSales){
                          flashSaleProvider.getFlashSaleProducts(
                              1, false,
                              rating: rating == -1 ? null : rating,
                              priceLow: lowerValue,
                              priceHigh: upperValue,
                              categoryIds: selectCategoryList.toList(),
                              shortBy: getShortByValue(selectedSearchShotBy)
                          );
                        }else{
                          searchProduct(
                            offset: 1,
                            query: _searchController.text,
                            rating: rating == -1 ? null : rating,
                            priceLow: lowerValue,
                            priceHigh: upperValue,
                            categoryIds: selectCategoryList.toList(),
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
