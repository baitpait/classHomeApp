import 'package:hexacom_user/common/models/api_response_model.dart';
import 'package:hexacom_user/common/models/order_details_model.dart';
import 'package:hexacom_user/common/models/response_model.dart';
import 'package:hexacom_user/common/models/review_body_model.dart';
import 'package:hexacom_user/common/reposotories/product_repo.dart';
import 'package:hexacom_user/features/product/domain/models/review_model.dart';
import 'package:hexacom_user/helper/api_checker_helper.dart';
import 'package:hexacom_user/helper/file_validation_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/main.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class RateReviewProvider extends ChangeNotifier {
  final ProductRepo? productRepo;
  RateReviewProvider({required this.productRepo});


  bool _isLoading = false;
  List<int> _ratingList = [];
  List<String> _reviewList = [];
  List<bool> _loadingList = [];
  List<bool> _submitList = [];
  ReviewModel? _productReviewList;
  int _deliveryManRating = 0;
  final double _avgRatting = 0.0;
  final double _totalRatting = 0.0;
  final List<int> _starList = [];
  List<ProductWiseReview> _productWiseReview = [];
  List<XFile>? _imageFiles;


  bool get isLoading => _isLoading;
  List<int> get ratingList => _ratingList;
  List<String> get reviewList => _reviewList;
  List<bool> get loadingList => _loadingList;
  List<bool> get submitList => _submitList;
  int get deliveryManRating => _deliveryManRating;
  ReviewModel? get productReviewList => _productReviewList;
  double get avgRatting => _avgRatting;
  double get totalRatting => _totalRatting;
  List<int> get starList => _starList;
  List<ProductWiseReview> get productWiseReview => _productWiseReview;
  List<XFile>? get imageFiles => _imageFiles;

  set setProductReviewList(List<ReviewModel>? list)=> _productReviewList = null;




  void initRatingData(List<OrderDetailsModel> orderDetailsList) {
    _ratingList = [];
    _reviewList = [];
    _loadingList = [];
    _submitList = [];
    _deliveryManRating = 0;
    _imageFiles = [];
    _productWiseReview = [];
    for (int i = 0; i < orderDetailsList.length; i++) {
      _ratingList.add(0);
      _reviewList.add('');
      _loadingList.add(false);
      _submitList.add(false);
    }
  }

  void setRating(int index, int rate) {
    _ratingList[index] = rate;
    notifyListeners();
  }

  void setReview(int index, String review) {
    _reviewList[index] = review;
  }

  void setDeliveryManRating(int rate) {
    _deliveryManRating = rate;
    notifyListeners();
  }

  Future<ResponseModel> submitProductReview(int index, ReviewBodyModel reviewBody) async {
    _loadingList[index] = true;
    notifyListeners();

    ApiResponseModel response = await productRepo!.submitReview(reviewBody, _imageFiles);
    ResponseModel responseModel;
    if (response.response != null && response.response!.statusCode == 200) {
      _submitList[index] = true;
      responseModel = ResponseModel(true, getTranslated('review_submit_successfully', Get.context!));
      notifyListeners();
    } else {

      responseModel = ResponseModel(false, ApiCheckerHelper.getError(response).errors?.first.message);
    }
    _loadingList[index] = false;
    notifyListeners();
    return responseModel;
  }

  Future<ResponseModel> submitDeliveryManReview(ReviewBodyModel reviewBody) async {
    _isLoading = true;
    notifyListeners();
    ResponseModel responseModel;
    // Delivery man review feature is disabled in this project.
    _deliveryManRating = 0;
    responseModel = ResponseModel(false, getTranslated('delivery_man_review_disabled', Get.context!));
    _isLoading = false;
    notifyListeners();
    return responseModel;
  }

  Future<void> getProductReviews(int? productID, int? offset) async {
    _isLoading = true;
    notifyListeners();

    ApiResponseModel response = await productRepo!.getProductReviewList(productID, offset);
    if (response.response != null && response.response!.statusCode == 200) {
      if(offset == 1){
        _productReviewList = ReviewModel.fromJson(response.response.data);
      }else{
        _productReviewList?.offset = ReviewModel.fromJson(response.response.data).offset;
        _productReviewList?.totalSize = ReviewModel.fromJson(response.response.data).totalSize;
        _productReviewList?.reviews?.addAll(ReviewModel.fromJson(response.response.data).reviews!);
      }

    } else {
      ApiCheckerHelper.checkApi(response);
    }
    _isLoading = false;
    notifyListeners();
  }



  void setProductWiseRating (int productId, int rating, {List<OrderDetailsModel>? orderDetailsList}){
    if(orderDetailsList != null && orderDetailsList.isNotEmpty){
      for(OrderDetailsModel order in orderDetailsList){
        _productWiseReview.add(ProductWiseReview(order.productId!, -1, []));
      }
    }
  }

  void pickImage(BuildContext context, bool isRemove, int productId) async {
    if(isRemove) {
      _imageFiles = [];
    }else {
      try{
        final pickedImage = await FileValidationHelper.validateAndPickImage(context: context, source: ImageSource.gallery);
        if(pickedImage != null){
          for(ProductWiseReview productWiseReview in _productWiseReview){
            if(productWiseReview.productId == productId){
              if(!productWiseReview.image!.contains(pickedImage)){
                productWiseReview.image!.add(pickedImage);
              }
            }
          }
          _imageFiles?.add(pickedImage);
        }
      }catch(error) {
        debugPrint('$error');
      }
    }
    notifyListeners();
  }


  void removeImage(int index , int productId){
    for(ProductWiseReview productWiseReview in _productWiseReview){
      if(productWiseReview.productId == productId){
        productWiseReview.image!.removeAt(index);
      }
    }
    _imageFiles!.removeAt(index);
    notifyListeners();
  }

}

class ProductWiseReview {
  int productId;
  int rating;
  List<XFile>? image;

  ProductWiseReview(this.productId, this.rating, this.image);

  @override
  String toString() {
    String imageString = (image == null || image!.isEmpty)
        ? 'No images'
        : image!.map((file) => file.path).join(', ');

    return 'ProductWiseReview(productId: $productId, rating: $rating, image: $imageString)';
  }
}