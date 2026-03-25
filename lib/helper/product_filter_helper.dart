import 'package:hexacom_user/common/models/product_model.dart';
import 'package:hexacom_user/features/flash_sale/domain/models/flash_sale_model.dart';
import 'package:hexacom_user/features/flash_sale/providers/flash_sale_provider.dart';
import 'package:hexacom_user/features/search/providers/search_provider.dart';
import 'package:hexacom_user/main.dart';
import 'package:provider/provider.dart';

class ProductFilterHelper{
  static bool isProductFiltered(){
    final SearchProvider searchProvider = Provider.of<SearchProvider>(Get.context!, listen: false);
    ProductModel? productModel = searchProvider.searchProductModel;

    if (productModel?.sortedLowestPrice == null && productModel?.sortedHighPrice == null && productModel?.rating == null &&
        productModel?.categoryIds == null && productModel?.sortedBy == null && searchProvider.selectedTagIds.isEmpty &&
        searchProvider.selectedAttributeIds.isEmpty && !searchProvider.inStockOnly) {
      return false;
    }else{
      return true;
    }
  }

  static bool canProductFilter(){
    SearchProvider searchProvider = Provider.of<SearchProvider>(Get.context!, listen: false);
    ProductModel? productModel = searchProvider.searchProductModel;

    if(productModel?.sortedLowestPrice == null && productModel?.sortedHighPrice == null && productModel?.rating == null &&
        productModel?.categoryIds == null && productModel?.sortedBy == null){
      return true;
    }else if(productModel?.sortedLowestPrice != searchProvider.lowerValue){
      return true;
    }else if(productModel?.sortedHighPrice != searchProvider.upperValue){

      return true;
    }else if(productModel?.sortedBy != searchProvider.getShortByValue(searchProvider.selectedSearchShotBy)){
      return true;
    }else if(productModel?.rating != searchProvider.rating){
      return true;
    }else if(!(searchProvider.selectCategoryList.containsAll(productModel?.categoryIds ?? {}) && searchProvider.selectCategoryList.length == productModel?.categoryIds?.length)){
      return true;
    }else if(searchProvider.selectedTagIds.isNotEmpty){
      return true;
    } else if (searchProvider.inStockOnly) {
      return true;
    } else if (searchProvider.selectedAttributeIds.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  static bool isFlashSalesFiltered() {
    FlashSaleModel? flashSaleProvider = Provider.of<FlashSaleProvider>(Get.context!, listen: false).flashSaleModel;

    if(flashSaleProvider?.sortedLowestPrice == null && flashSaleProvider?.sortedHighPrice == null && flashSaleProvider?.rating == null &&
        flashSaleProvider?.categoryIds == null && flashSaleProvider?.sortedBy == null){
      return false;
    }else{
      return true;
    }
  }

  static bool canFlashSalesFilter(){
    SearchProvider searchProvider = Provider.of<SearchProvider>(Get.context!, listen: false);
    FlashSaleModel? flashSaleProvider = Provider.of<FlashSaleProvider>(Get.context!, listen: false).flashSaleModel;

    if(flashSaleProvider?.sortedLowestPrice == null && flashSaleProvider?.sortedHighPrice == null && flashSaleProvider?.rating == null &&
        flashSaleProvider?.categoryIds == null && flashSaleProvider?.sortedBy == null){
      return true;
    }else if(flashSaleProvider?.sortedLowestPrice != searchProvider.lowerValue){
      return true;
    }else if(flashSaleProvider?.sortedHighPrice != searchProvider.upperValue){

      return true;
    }else if(flashSaleProvider?.sortedBy != searchProvider.getShortByValue(searchProvider.selectedSearchShotBy)){
      return true;
    }else if(flashSaleProvider?.rating != searchProvider.rating){
      return true;
    }else if(!(searchProvider.selectCategoryList.containsAll(flashSaleProvider?.categoryIds ?? {}) && searchProvider.selectCategoryList.length == flashSaleProvider?.categoryIds?.length)){
      return true;
    }else{
      return false;
    }
  }

}