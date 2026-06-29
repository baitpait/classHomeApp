import 'package:hexacom_user/common/models/product_model.dart';

class PlaceOrderModel {
  List<Cart>? _cart;
  double? _couponDiscountAmount;
  String? _couponDiscountTitle;
  double? _orderAmount;
  String? _orderType;
  int? _deliveryAddressId;
  String? _paymentMethod;
  String? _orderNote;
  String? _couponCode;
  int? _branchId;
  double? _distance;
  String? _transactionReference;
  int? _selectedDeliveryArea;
  String? _bringChangeAmount;
  String? _isGuest;
  String? _customerId;
  String? _paymentPlatform;
  String? _callBack;
  int? _loyaltyPointsUsed;

  PlaceOrderModel copyWith({String? paymentMethod, String? transactionReference}) {
    _paymentMethod = paymentMethod;
    _transactionReference = transactionReference;
    return this;
  }

  PlaceOrderModel(
      {required List<Cart> cart,
        required double? couponDiscountAmount,
        required String couponDiscountTitle,
        required String? couponCode,
        required double orderAmount,
        required int? deliveryAddressId,
        required String? orderType,
        required String? paymentMethod,
        required int? branchId,
        required String orderNote,
        required double distance,
        String? transactionReference,
        int? selectedDeliveryArea,
        String? bringChangeAmount,
        String? isGuest,
        String? customerId,
        String? paymentPlatform,
        String? callBack,
        int? loyaltyPointsUsed,
      }) {
    _cart = cart;
    _couponDiscountAmount = couponDiscountAmount;
    _couponDiscountTitle = couponDiscountTitle;
    _orderAmount = orderAmount;
    _orderType = orderType;
    _deliveryAddressId = deliveryAddressId;
    _paymentMethod = paymentMethod;
    _orderNote = orderNote;
    _couponCode = couponCode;
    _branchId = branchId;
    _distance = distance;
    _transactionReference = transactionReference;
    _selectedDeliveryArea = selectedDeliveryArea;
    _bringChangeAmount = bringChangeAmount;
    _isGuest = isGuest;
    _customerId = customerId;
    _paymentPlatform = paymentPlatform;
    _callBack = callBack;
    _loyaltyPointsUsed = loyaltyPointsUsed ?? 0;
  }

  List<Cart>? get cart => _cart;
  double? get couponDiscountAmount => _couponDiscountAmount;
  String? get couponDiscountTitle => _couponDiscountTitle;
  double? get orderAmount => _orderAmount;
  String? get orderType => _orderType;
  int? get deliveryAddressId => _deliveryAddressId;
  String? get paymentMethod => _paymentMethod;
  String? get orderNote => _orderNote;
  String? get couponCode => _couponCode;
  int? get branchId => _branchId;
  double? get distance => _distance;
  String? get transactionReference => _transactionReference;
  int? get selectedDeliveryArea => _selectedDeliveryArea;
  String? get bringChangeAmount => _bringChangeAmount;
  String? get isGuest => _isGuest;
  String? get customerId => _customerId;
  String? get paymentPlatform => _paymentPlatform;
  String? get callBack => _callBack;
  int? get loyaltyPointsUsed => _loyaltyPointsUsed;

  PlaceOrderModel.fromJson(Map<String, dynamic> json) {
    if (json['cart'] != null) {
      _cart = [];
      json['cart'].forEach((v) {
        _cart!.add(Cart.fromJson(v));
      });
    }
    _couponDiscountAmount = json['coupon_discount_amount'];
    _couponDiscountTitle = json['coupon_discount_title'];
    _orderAmount = json['order_amount'];
    _orderType = json['order_type'];
    _deliveryAddressId = json['delivery_address_id'];
    _paymentMethod = json['payment_method'];
    _orderNote = json['order_note'];
    _couponCode = json['coupon_code'];
    _branchId = json['branch_id'];
    _distance = json['distance'];
    _selectedDeliveryArea = json['selected_delivery_area'];
    _bringChangeAmount = json['bring_change_amount'];
    _isGuest = json['is_guest'];
    _customerId = json['customer_id'];
    _paymentPlatform = json['payment_platform'];
    _callBack = json['callback'];
    _loyaltyPointsUsed = json['loyalty_points_used'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (_cart != null) {
      data['cart'] = _cart!.map((v) => v.toJson()).toList();
    }
    data['coupon_discount_amount'] = _couponDiscountAmount;
    data['coupon_discount_title'] = _couponDiscountTitle;
    data['order_amount'] = _orderAmount;
    data['order_type'] = _orderType;
    data['delivery_address_id'] = _deliveryAddressId;
    data['payment_method'] = _paymentMethod;
    data['order_note'] = _orderNote;
    data['coupon_code'] = _couponCode;
    data['branch_id'] = _branchId;
    data['distance'] = _distance;
    data['selected_delivery_area'] = selectedDeliveryArea;
    if(_transactionReference != null) {
      data['transaction_reference'] = _transactionReference;
    }
    data['bring_change_amount'] = _bringChangeAmount;
    data['customer_id'] = _customerId;
    data['is_guest'] = _isGuest;
    data['payment_platform'] = _paymentPlatform;
    data['callback'] = _callBack;
    if (_loyaltyPointsUsed != null && _loyaltyPointsUsed! > 0) {
      data['loyalty_points_used'] = _loyaltyPointsUsed;
    }
    return data;
  }
}

class Cart {
  String? _productId;
  String? _price;
  String? _variant;
  List<Variation>? _variation;
  double? _discountAmount;
  int? _quantity;
  double? _taxAmount;
  Map<String, dynamic>? _areaCalc;

  Cart(
      String productId,
        String price,
        String variant,
        List<Variation>? variation,
        double? discountAmount,
        int? quantity,
        double? taxAmount,
        {Map<String, dynamic>? areaCalc}) {
    _productId = productId;
    _price = price;
    _variant = variant;
    _variation = variation;
    _discountAmount = discountAmount;
    _quantity = quantity;
    _taxAmount = taxAmount;
    _areaCalc = areaCalc;
  }

  String? get productId => _productId;
  String? get price => _price;
  String? get variant => _variant;
  List<Variation>? get variation => _variation;
  double? get discountAmount => _discountAmount;
  int? get quantity => _quantity;
  double? get taxAmount => _taxAmount;
  Map<String, dynamic>? get areaCalc => _areaCalc;

  Cart.fromJson(Map<String, dynamic> json) {
    _productId = json['product_id'];
    _price = json['price'];
    _variant = json['variant'];
    if (json['variation'] != null) {
      _variation = [];
      json['variation'].forEach((v) {
        _variation!.add(Variation.fromJson(v));
      });
    }
    _discountAmount = json['discount_amount'];
    _quantity = json['quantity'];
    _taxAmount = json['tax_amount'];
    if (json['area_calc'] != null) {
      _areaCalc = Map<String, dynamic>.from(json['area_calc']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['product_id'] = _productId;
    data['price'] = _price;
    data['variant'] = _variant;
    if (_variation != null) {
      data['variation'] = _variation!.map((v) => v.toJson()).toList();
    }
    data['discount_amount'] = _discountAmount;
    data['quantity'] = _quantity;
    data['tax_amount'] = _taxAmount;
    if (_areaCalc != null) {
      data['area_calc'] = _areaCalc;
    }
    return data;
  }
}
