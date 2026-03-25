import 'dart:async';
import 'package:hexacom_user/common/models/place_order_model.dart';
import 'package:hexacom_user/common/models/api_response_model.dart';
import 'package:hexacom_user/common/models/cart_model.dart';
import 'package:hexacom_user/common/models/order_details_model.dart';
import 'package:hexacom_user/common/models/order_model.dart';
import 'package:hexacom_user/common/models/reorder_details_model.dart';
import 'package:hexacom_user/common/models/response_model.dart';
import 'package:hexacom_user/features/order/domain/reposotories/order_repo.dart';
import 'package:hexacom_user/features/track/providers/order_map_provider.dart';
import 'package:hexacom_user/helper/api_checker_helper.dart';
import 'package:hexacom_user/helper/order_helper.dart';
import 'package:hexacom_user/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class OrderProvider extends ChangeNotifier {
  final OrderRepo? orderRepo;
  OrderProvider({required this.orderRepo});

  List<OrderModel>? _runningOrderList;
  List<OrderModel>? _historyOrderList;
  List<OrderDetailsModel>? _orderDetails;
  OrderModel? _trackModel;
  ResponseModel? _responseModel;
  bool _isLoading = false;
  bool _showCancelled = false;
  int? _reOrderIndex;
  List<CartModel> _reOrderCartList = [];
  ReOrderDetailsModel? _reOrderDetailsModel;
  final String _orderType = 'delivery';
  int? _selectedAreaID;
  Timer? _timer;
  double? _deliveryCharge;
  int? _lastExpectedPointsForSuccess;

  List<OrderModel>? get runningOrderList => _runningOrderList;
  List<OrderModel>? get historyOrderList => _historyOrderList;
  List<OrderDetailsModel>? get orderDetails => _orderDetails;
  OrderModel? get trackModel => _trackModel;
  ResponseModel? get responseModel => _responseModel;
  bool get isLoading => _isLoading;
  bool get showCancelled => _showCancelled;
  int? get getReOrderIndex => _reOrderIndex;
  List<CartModel> get reOrderCartList => _reOrderCartList;
  ReOrderDetailsModel? get reOrderDetailsModel => _reOrderDetailsModel;
  String? get orderType => _orderType;
  int? get selectedAreaID => _selectedAreaID;
  double? get deliveryCharge => _deliveryCharge;
  int? get lastExpectedPointsForSuccess => _lastExpectedPointsForSuccess;

  void setLastExpectedPointsForSuccess(int? value) {
    _lastExpectedPointsForSuccess = value;
  }

  set setReorderIndex(int value) {
    _reOrderIndex = value;
  }


  Future<void> getOrderList(BuildContext context) async {
    ApiResponseModel apiResponse = await orderRepo!.getOrderList();
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _runningOrderList = [];
      _historyOrderList = [];
      final raw = apiResponse.response!.data;
      List<dynamic> list = <dynamic>[];
      if (raw is List) {
        list = raw;
      } else if (raw is Map<String, dynamic>) {
        if (raw['orders'] is List) {
          list = raw['orders'] as List<dynamic>;
        } else if (raw['data'] is List) {
          list = raw['data'] as List<dynamic>;
        }
      }
      for (final item in list) {
        try {
          final orderMap = item is Map<String, dynamic> ? item : Map<String, dynamic>.from(item as Map);
          final orderModel = OrderModel.fromJson(orderMap);
          final status = orderModel.orderStatus?.toLowerCase();
          if (status == 'pending' ||
              status == 'processing' ||
              status == 'out_for_delivery' ||
              status == 'confirmed') {
            _runningOrderList!.add(orderModel);
          } else if (status == 'delivered' ||
              status == 'returned' ||
              status == 'failed' ||
              status == 'canceled' ||
              status == 'cancelled') {
            _historyOrderList!.add(orderModel);
          } else {
            _historyOrderList!.add(orderModel);
          }
        } catch (_) {
          continue;
        }
      }
    } else {
      ApiCheckerHelper.checkApi(apiResponse);
    }
    notifyListeners();
  }

  Future<List<OrderDetailsModel>?> getOrderDetails(String orderID, {String? phoneNumber}) async {
    _orderDetails = null;
    _isLoading = true;
    _showCancelled = false;

    ApiResponseModel apiResponse = await orderRepo!.getOrderDetails(orderID, phoneNumber);
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _orderDetails = [];
      apiResponse.response!.data.forEach((orderDetail) => _orderDetails!.add(OrderDetailsModel.fromJson(orderDetail)));
    } else {
      _orderDetails = [];
      ApiCheckerHelper.checkApi(apiResponse);
    }
    _isLoading = false;
    notifyListeners();
    return _orderDetails;
  }

  Future<ResponseModel> trackOrder(String? orderID, OrderModel? orderModel, BuildContext context, bool fromTracking, {String? phoneNumber, bool isUpdate = true}) async {
    _trackModel = null;
    ResponseModel responseModel;
    if(!fromTracking) {
      _orderDetails = null;
    }
    _showCancelled = false;
    if(orderModel == null) {
      _isLoading = true;
      if(isUpdate){
        notifyListeners();
      }

      ApiResponseModel apiResponse = await orderRepo!.trackOrder(orderID, phoneNumber);
      if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
        final data = _unwrapOrderResponse(apiResponse.response!.data);
        _trackModel = OrderModel.fromJson(data);
        responseModel = ResponseModel(true, apiResponse.response!.data.toString());
      } else {
        _orderDetails = [];
        _trackModel = OrderModel();
        responseModel = ResponseModel(false, ApiCheckerHelper.getError(apiResponse).errors?.first.message);
        ApiCheckerHelper.checkApi(apiResponse);
      }
      _isLoading = false;
      notifyListeners();
    }else {
      _trackModel = orderModel;
      responseModel = ResponseModel(true, 'Successful');
    }
    return responseModel;
  }

  Future<ResponseModel?> getTrackOrder(String? orderID, OrderModel? orderModel, bool fromTracking) async {
    _trackModel = null;
    _responseModel = null;
    if(!fromTracking) {
      _orderDetails = null;
    }
    _showCancelled = false;
    if(orderModel == null) {
      _isLoading = true;
      ApiResponseModel apiResponse = await orderRepo!.trackOrder(orderID, orderModel?.deliveryAddress?.contactPersonNumber);
      if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
        final data = _unwrapOrderResponse(apiResponse.response!.data);
        _trackModel = OrderModel.fromJson(data);
        _responseModel = ResponseModel(true, apiResponse.response!.data.toString());
      } else {
        _responseModel = ResponseModel(false, ApiCheckerHelper.getError(apiResponse).errors?.first.message);
        ApiCheckerHelper.checkApi(apiResponse);
      }
    }else {
      _trackModel = orderModel;
      _responseModel = ResponseModel(true, 'Successful');
    }
    _isLoading = false;
    if(fromTracking){
      notifyListeners();
    }
    return _responseModel;
  }

  Future<void> placeOrder(BuildContext context, PlaceOrderModel placeOrderBody, Function callback) async {
    _isLoading = true;
    notifyListeners();
    ApiResponseModel apiResponse = await orderRepo!.placeOrder(placeOrderBody);
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      String? message = apiResponse.response!.data['message'];
      String orderID = apiResponse.response!.data['order_id'].toString();
      callback(context, true, message, orderID);
    } else {

      callback(context, false, ApiCheckerHelper.getError(apiResponse).errors![0].message, '-1');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> cancelOrder(String orderID, Function callback) async {
    _isLoading = true;
    notifyListeners();
    ApiResponseModel apiResponse = await orderRepo!.cancelOrder(orderID);
    _isLoading = false;
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      OrderModel? orderModel;
      if(_runningOrderList != null){
        for (var order in _runningOrderList!) {
          if(order.id.toString() == orderID) {
            orderModel = order;
          }
        }
        _runningOrderList!.remove(orderModel);
      }

      _showCancelled = true;
      callback(apiResponse.response!.data['message'], true, orderID);
    } else {

      callback(ApiCheckerHelper.getError(apiResponse).errors?.first.message, false, '-1');
    }
    notifyListeners();
  }

  Future<void> setPlaceOrderData(String placeOrder)async{
    await orderRepo?.setPlaceOrder(placeOrder);
  }

  String? getPlaceOrderData(){
    return orderRepo?.getPlaceOrder();
  }

  Future<void> clearPlaceOrderData()async{
    await orderRepo!.clearPlaceOrder();
    _lastExpectedPointsForSuccess = null;
  }

  Future<List<CartModel>?> reorderProduct(String orderId) async {
    _isLoading = true;
    notifyListeners();

    ApiResponseModel apiResponse = await orderRepo!.getReorderData(orderId);

    if(apiResponse.response != null && apiResponse.response?.statusCode == 200 && apiResponse.response?.data != null) {
      _reOrderCartList = [];

       _reOrderDetailsModel = ReOrderDetailsModel.fromMap(apiResponse.response?.data);

       if(_reOrderDetailsModel != null) {
         _reOrderCartList = OrderHelper.getReorderCartData(reOrderDetailsModel: _reOrderDetailsModel!);
       }
    }

    _isLoading = false;
    notifyListeners();

    return _reOrderCartList;

  }

  void setAreaID({int? areaID, bool isUpdate = true, bool isReload = false}) {
    if(isReload){
      _selectedAreaID = null;
    }else{
      _selectedAreaID = areaID!;
    }
    if(isUpdate){
      notifyListeners();
    }
  }
  void clearPrevData({bool isUpdate = false}) {
    _trackModel = null;
    _isLoading = false;
    if(isUpdate){
      notifyListeners();
    }
  }



  void setDeliveryCharge(double? charge, {bool notify = true}) {
    _deliveryCharge = charge;
    if(notify) {
      notifyListeners();
    }
  }

  /// Unwraps track-order API response so OrderModel.fromJson gets a single order map.
  Map<String, dynamic> _unwrapOrderResponse(dynamic data) {
    if (data == null) return <String, dynamic>{};
    if (data is Map<String, dynamic>) {
      if (data['data'] is Map) return Map<String, dynamic>.from(data['data'] as Map);
      if (data['order'] is Map) return Map<String, dynamic>.from(data['order'] as Map);
      return data;
    }
    if (data is Map) return Map<String, dynamic>.from(data);
    if (data is List && data.isNotEmpty && data.first is Map) {
      return Map<String, dynamic>.from(data.first as Map);
    }
    return <String, dynamic>{};
  }

}