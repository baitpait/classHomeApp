import 'package:hexacom_user/common/models/cart_model.dart';
import 'package:hexacom_user/common/models/product_model.dart';
import 'package:hexacom_user/helper/price_converter_helper.dart';

class CartHelper{
  static CartModel? getCartModel(Product product, {List<int>? variationIndexList, int? quantity}){
    CartModel? cartModel;
    List<Variation> variation = [];

    int? stock = 0;
    List variationList = [];

    double? price = product.price;
    stock = product.totalStock;

    for(int index = 0; index < (product.choiceOptions?.length ?? 0); index++) {
      if((product.choiceOptions?[index].options?.isNotEmpty ?? false) && (variationIndexList?.isNotEmpty ?? false)) {

        variationList.add(product.choiceOptions?[index].options?[variationIndexList![index]].replaceAll(' ', ''));

      }
    }

    String variationType = '';
    bool isFirst = true;


    for (var variation in variationList) {
      if(isFirst) {
        variationType = '$variationType$variation';
        isFirst = false;
      }else {
        variationType = '$variationType-$variation';
      }
    }

    for(Variation variationValue in product.variations!) {
      if(variationValue.type == variationType) {
        price = variationValue.price;
        variation.add(variationValue);
        stock = variationValue.stock;
        break;
      }
    }

    double discountedPrice = PriceConverterHelper.convertWithDiscount(price, product.discount, product.discountType) ?? 0;
    double? discountAmount = (price! - PriceConverterHelper.convertWithDiscount(price, product.discount, product.discountType)!);
    double? taxAmount = discountedPrice - PriceConverterHelper.convertWithDiscount(discountedPrice, product.tax, product.taxType)!;

    cartModel = CartModel(
      product.id, price, discountedPrice, variation,
      discountAmount, quantity ?? 1, taxAmount,
      stock, product,
    );

    return cartModel;
  }

  static int getCartItemCount(List<CartModel?> cartList) {
    int item = 0;
    for(CartModel? cart in cartList) {
      item = item + (cart?.quantity ?? 0);
    }
    return item;
  }



}
