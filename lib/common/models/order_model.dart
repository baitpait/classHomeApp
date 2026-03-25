import 'package:hexacom_user/common/models/product_model.dart';

class OrderModel {
  int? _id;
  int? _userId;
  double? _orderAmount;
  double? _couponDiscountAmount;
  String? _couponDiscountTitle;
  String? _paymentStatus;
  String? _orderStatus;
  double? _totalTaxAmount;
  String? _paymentMethod;
  String? _transactionReference;
  int? _deliveryAddressId;
  String? _createdAt;
  String? _updatedAt;
  int? _deliveryManId;
  double? _deliveryCharge;
  String? _orderNote;
  List<int>? _addOnIds;
  List<Details>? _details;
  DeliveryMan? _deliveryMan;
  int? _detailsCount;
  String? _orderType;
  int? _deliverymanReviewCount;
  DeliveryAddress? _deliveryAddress;
  double? _extraDiscount;
  int? _totalQuantity;
  int? _branchId;
  double? _bringChangeAmount;

  OrderModel(
      {int? id,
        int? userId,
        double? orderAmount,
        double? couponDiscountAmount,
        String? couponDiscountTitle,
        String? paymentStatus,
        String? orderStatus,
        double? totalTaxAmount,
        String? paymentMethod,
        String? transactionReference,
        int? deliveryAddressId,
        String? createdAt,
        String? updatedAt,
        String? checked,
        int? deliveryManId,
        double? deliveryCharge,
        String? orderNote,
        List<int>? addOnIds,
        List<Details>? details,
        DeliveryMan? deliveryMan,
        int? detailsCount,
        String? orderType,
        int? deliveryManReviewCount,
        DeliveryAddress? deliveryAddress,
        double? extraDiscount,
        int? totalQuantity,
        int? branchId,
        double? bringChangeAmount,
      }) {
    _id = id;
    _userId = userId;
    _orderAmount = orderAmount;
    _couponDiscountAmount = couponDiscountAmount;
    _couponDiscountTitle = couponDiscountTitle;
    _paymentStatus = paymentStatus;
    _orderStatus = orderStatus;
    _totalTaxAmount = totalTaxAmount;
    _paymentMethod = paymentMethod;
    _transactionReference = transactionReference;
    _deliveryAddressId = deliveryAddressId;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _deliveryManId = deliveryManId;
    _deliveryCharge = deliveryCharge;
    _orderNote = orderNote;
    _addOnIds = addOnIds;
    _details = details;
    _deliveryMan = deliveryMan;
    _detailsCount = detailsCount;
    _orderType = orderType;
    _deliverymanReviewCount = deliveryManReviewCount;
    _deliveryAddress = deliveryAddress;
    _extraDiscount = extraDiscount;
    _totalQuantity = totalQuantity;
    _branchId = branchId;
    _bringChangeAmount = bringChangeAmount;
  }

  int? get id => _id;
  int? get userId => _userId;
  double? get orderAmount => _orderAmount;
  double? get couponDiscountAmount => _couponDiscountAmount;
  String? get couponDiscountTitle => _couponDiscountTitle;
  String? get paymentStatus => _paymentStatus;
  String? get orderStatus => _orderStatus;
  double? get totalTaxAmount => _totalTaxAmount;
  // ignore: unnecessary_getters_setters
  String? get paymentMethod => _paymentMethod;
  // ignore: unnecessary_getters_setters
  set paymentMethod(String? method) => _paymentMethod = method;
  String? get transactionReference => _transactionReference;
  int? get deliveryAddressId => _deliveryAddressId;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  int? get deliveryManId => _deliveryManId;
  double? get deliveryCharge => _deliveryCharge;
  String? get orderNote => _orderNote;
  List<int>? get addOnIds => _addOnIds;
  List<Details>? get details => _details;
  DeliveryMan? get deliveryMan => _deliveryMan;
  int? get detailsCount => _detailsCount;
  String? get orderType => _orderType;
  int? get deliveryManReviewCount => _deliverymanReviewCount;
  DeliveryAddress? get deliveryAddress => _deliveryAddress;
  double? get extraDiscount => _extraDiscount;
  int? get totalQuantity => _totalQuantity;
  int? get branchId => _branchId;
  double? get bringChangeAmount => _bringChangeAmount;

  OrderModel.fromJson(Map<String, dynamic> json) {
    _id = json['id'] is int ? json['id'] : int.tryParse('${json['id']}');
    _userId = json['user_id'] is int ? json['user_id'] : int.tryParse('${json['user_id']}');
    _orderAmount = _toDouble(json['order_amount']);
    _couponDiscountAmount = _toDouble(json['coupon_discount_amount']);
    _couponDiscountTitle = json['coupon_discount_title']?.toString();
    _paymentStatus = json['payment_status']?.toString();
    _orderStatus = json['order_status']?.toString();
    _totalTaxAmount = _toDouble(json['total_tax_amount']);
    _paymentMethod = json['payment_method']?.toString();
    _transactionReference = json['transaction_reference']?.toString();
    _deliveryAddressId = json['delivery_address_id'] is int ? json['delivery_address_id'] : int.tryParse('${json['delivery_address_id']}');
    _createdAt = json['created_at']?.toString();
    _updatedAt = json['updated_at']?.toString();
    _deliveryManId = json['delivery_man_id'] is int ? json['delivery_man_id'] : int.tryParse('${json['delivery_man_id']}');
    _deliveryCharge = _toDouble(json['delivery_charge']);
    _orderNote = json['order_note'];
    _detailsCount = _toInt(json['details_count']);
    if (json['add_on_ids'] != null && json['add_on_ids'] is List) {
      _addOnIds = (json['add_on_ids'] as List)
          .map((e) => e is int ? e : int.tryParse('$e'))
          .whereType<int>()
          .toList();
    }
    if (json['details'] != null && json['details'] is List) {
      _details = [];
      for (final v in json['details']) {
        try {
          if (v is Map<String, dynamic>) {
            _details!.add(Details.fromJson(v));
          } else if (v is Map) {
            _details!.add(Details.fromJson(Map<String, dynamic>.from(v)));
          }
        } catch (_) {}
      }
    }
    try {
      _deliveryMan = json['delivery_man'] != null && json['delivery_man'] is Map
          ? DeliveryMan.fromJson(Map<String, dynamic>.from(json['delivery_man']))
          : null;
    } catch (_) {
      _deliveryMan = null;
    }
    _orderType = json['order_type']?.toString();
    _deliverymanReviewCount = json['deliveryman_review_count'] is int ? json['deliveryman_review_count'] : int.tryParse('${json['deliveryman_review_count']}');
    try {
      _deliveryAddress = json['delivery_address'] != null && json['delivery_address'] is Map
          ? DeliveryAddress.fromJson(Map<String, dynamic>.from(json['delivery_address']))
          : null;
    } catch (_) {
      _deliveryAddress = null;
    }

    try{
      _extraDiscount = double.parse(json['extra_discount']);
    }catch(e){
      _extraDiscount = json['extra_discount'];
    }
    _totalQuantity = int.tryParse('${json['total_quantity']}');
    _branchId = _toInt(json['branch_id']);
    _bringChangeAmount = _toDouble(json['bring_change_amount']);
  }

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = _id;
    data['user_id'] = _userId;
    data['order_amount'] = _orderAmount;
    data['coupon_discount_amount'] = _couponDiscountAmount;
    data['coupon_discount_title'] = _couponDiscountTitle;
    data['payment_status'] = _paymentStatus;
    data['order_status'] = _orderStatus;
    data['total_tax_amount'] = _totalTaxAmount;
    data['payment_method'] = _paymentMethod;
    data['transaction_reference'] = _transactionReference;
    data['delivery_address_id'] = _deliveryAddressId;
    data['created_at'] = _createdAt;
    data['updated_at'] = _updatedAt;
    data['delivery_man_id'] = _deliveryManId;
    data['delivery_charge'] = _deliveryCharge;
    data['order_note'] = _orderNote;
    data['add_on_ids'] = _addOnIds;
    data['details_count'] = _detailsCount;
    if (_details != null) {
      data['details'] = _details!.map((v) => v.toJson()).toList();
    }
    if (_deliveryMan != null) {
      data['delivery_man'] = _deliveryMan!.toJson();
    }
    data['order_type'] = _orderType;
    data['deliveryman_review_count'] = _deliverymanReviewCount;
    if (_deliveryAddress != null) {
      data['delivery_address'] = _deliveryAddress!.toJson();
    }
    data['extra_discount'] = _extraDiscount;
    data['total_quantity'] = _totalQuantity;
    data['bring_change_amount'] = _bringChangeAmount;
    return data;
  }
}

class Details {
  int? _id;
  int? _productId;
  int? _orderId;
  double? _price;
  String? _variation;
  double? _discountOnProduct;
  String? _discountType;
  int? _quantity;
  double? _taxAmount;
  String? _createdAt;
  String? _updatedAt;
  String? _addOnIds;
  String? _variant;

  Details(
      {int? id,
        int? productId,
        int? orderId,
        double? price,
        String? productDetails,
        String? variation,
        double? discountOnProduct,
        String? discountType,
        int? quantity,
        double? taxAmount,
        String? createdAt,
        String? updatedAt,
        String? addOnIds,
        String? variant}) {
    _id = id;
    _productId = productId;
    _orderId = orderId;
    _price = price;
    _variation = variation;
    _discountOnProduct = discountOnProduct;
    _discountType = discountType;
    _quantity = quantity;
    _taxAmount = taxAmount;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _addOnIds = addOnIds;
    _variant = variant;
  }

  int? get id => _id;
  int? get productId => _productId;
  int? get orderId => _orderId;
  double? get price => _price;
  String? get variation => _variation;
  double? get discountOnProduct => _discountOnProduct;
  String? get discountType => _discountType;
  int? get quantity => _quantity;
  double? get taxAmount => _taxAmount;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  String? get addOnIds => _addOnIds;
  String? get variant => _variant;

  Details.fromJson(Map<String, dynamic> json) {
    _id = _numToInt(json['id']);
    _productId = _numToInt(json['product_id']);
    _orderId = _numToInt(json['order_id']);
    _price = _numToDouble(json['price']);
    _variation = json['variation']?.toString();
    _discountOnProduct = _numToDouble(json['discount_on_product']) ?? 0;
    _discountType = json['discount_type']?.toString();
    _quantity = _numToInt(json['quantity']);
    _taxAmount = _numToDouble(json['tax_amount']) ?? 0;
    _createdAt = json['created_at']?.toString();
    _updatedAt = json['updated_at']?.toString();
    _addOnIds = json['add_on_ids']?.toString();
    _variant = json['variant']?.toString();
  }

  static int? _numToInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  static double? _numToDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = _id;
    data['product_id'] = _productId;
    data['order_id'] = _orderId;
    data['price'] = _price;
    data['variation'] = _variation;
    data['discount_on_product'] = _discountOnProduct;
    data['discount_type'] = _discountType;
    data['quantity'] = _quantity;
    data['tax_amount'] = _taxAmount;
    data['created_at'] = _createdAt;
    data['updated_at'] = _updatedAt;
    data['add_on_ids'] = _addOnIds;
    data['variant'] = _variant;
    return data;
  }
}

class DeliveryMan {
  int? _id;
  String? _fName;
  String? _lName;
  String? _phone;
  String? _email;
  String? _identityNumber;
  String? _identityType;
  String? _identityImage;
  String? _image;
  String? _password;
  String? _createdAt;
  String? _updatedAt;
  String? _authToken;
  List<Rating>? _rating;

  DeliveryMan(
      {int? id,
        String? fName,
        String? lName,
        String? phone,
        String? email,
        String? identityNumber,
        String? identityType,
        String? identityImage,
        String? image,
        String? password,
        String? createdAt,
        String? updatedAt,
        String? authToken,
        List<Rating>? rating}) {
    _id = id;
    _fName = fName;
    _lName = lName;
    _phone = phone;
    _email = email;
    _identityNumber = identityNumber;
    _identityType = identityType;
    _identityImage = identityImage;
    _image = image;
    _password = password;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _authToken = authToken;
    _rating = rating;
  }

  int? get id => _id;
  String? get fName => _fName;
  String? get lName => _lName;
  String? get phone => _phone;
  String? get email => _email;
  String? get identityNumber => _identityNumber;
  String? get identityType => _identityType;
  String? get identityImage => _identityImage;
  String? get image => _image;
  String? get password => _password;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  String? get authToken => _authToken;
  List<Rating>? get rating => _rating;

  DeliveryMan.fromJson(Map<String, dynamic> json) {
    _id = _deliveryManToInt(json['id']);
    _fName = json['f_name'];
    _lName = json['l_name'];
    _phone = json['phone'];
    _email = json['email'];
    _identityNumber = json['identity_number'];
    _identityType = json['identity_type'];
    _identityImage = json['identity_image'];
    _image = json['image'];
    _password = json['password'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
    _authToken = json['auth_token'];
    if (json['rating'] != null && json['rating'] is List) {
      _rating = [];
      for (final v in json['rating']) {
        try {
          _rating!.add(Rating.fromJson(Map<String, dynamic>.from(v as Map)));
        } catch (_) {}
      }
    }
  }

  static int? _deliveryManToInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = _id;
    data['f_name'] = _fName;
    data['l_name'] = _lName;
    data['phone'] = _phone;
    data['email'] = _email;
    data['identity_number'] = _identityNumber;
    data['identity_type'] = _identityType;
    data['identity_image'] = _identityImage;
    data['image'] = _image;
    data['password'] = _password;
    data['created_at'] = _createdAt;
    data['updated_at'] = _updatedAt;
    data['auth_token'] = _authToken;
    if (_rating != null) {
      data['rating'] = _rating!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
class DeliveryAddress {
  int? _id;
  String? _addressType;
  String? _contactPersonNumber;
  String? _address;
  String? _city;
  String? _latitude;
  String? _longitude;
  String? _createdAt;
  String? _updatedAt;
  int? _userId;
  String? _contactPersonName;

  DeliveryAddress(
      {int? id,
        String? addressType,
        String? contactPersonNumber,
        String? address,
        String? city,
        String? latitude,
        String? longitude,
        String? createdAt,
        String? updatedAt,
        int? userId,
        String? contactPersonName}) {
    _id = id;
    _addressType = addressType;
    _contactPersonNumber = contactPersonNumber;
    _address = address;
    _city = city;
    _latitude = latitude;
    _longitude = longitude;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _userId = userId;
    _contactPersonName = contactPersonName;
  }

  int? get id => _id;
  String? get addressType => _addressType;
  String? get contactPersonNumber => _contactPersonNumber;
  String? get address => _address;
  String? get city => _city;
  String? get latitude => _latitude;
  String? get longitude => _longitude;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  int? get userId => _userId;
  String? get contactPersonName => _contactPersonName;

  DeliveryAddress.fromJson(Map<String, dynamic> json) {
    _id = _addrToInt(json['id']);
    _addressType = json['address_type'];
    _contactPersonNumber = json['contact_person_number'];
    _address = json['address'];
    _city = json['city'];
    _latitude = json['latitude'];
    _longitude = json['longitude'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
    _userId = _addrToInt(json['user_id']);
    _contactPersonName = json['contact_person_name'];
  }

  static int? _addrToInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = _id;
    data['address_type'] = _addressType;
    data['contact_person_number'] = _contactPersonNumber;
    data['address'] = _address;
    data['city'] = _city;
    data['latitude'] = _latitude;
    data['longitude'] = _longitude;
    data['created_at'] = _createdAt;
    data['updated_at'] = _updatedAt;
    data['user_id'] = _userId;
    data['contact_person_name'] = _contactPersonName;
    return data;
  }
}