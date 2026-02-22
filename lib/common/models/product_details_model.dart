import 'package:hexacom_user/common/models/overall_rating_model.dart';
import 'package:hexacom_user/common/models/product_model.dart';

class ProductDetailsModel {
  Product? product;
  List<Product>? relatedProducts;
  OverallRating? overallRating;

  ProductDetailsModel({this.product, this.relatedProducts, this.overallRating});

  ProductDetailsModel.fromJson(Map<String, dynamic> json) {
    product =
    json['product'] != null ?  Product.fromJson(json['product']) : null;
    if (json['related_products'] != null) {
      relatedProducts = <Product>[];
      json['related_products'].forEach((v) {
        relatedProducts!.add(Product.fromJson(v));
      });
    }
    overallRating = json['overall_rating'] != null ? OverallRating.fromJson(json['overall_rating']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (product != null) {
      data['product'] = product!.toJson();
    }
    if (relatedProducts != null) {
      data['related_products'] =
          relatedProducts!.map((v) => v.toJson()).toList();
    }
    if (overallRating != null) {
      data['overall_rating'] = overallRating!.toJson();
    }
    return data;
  }
}
