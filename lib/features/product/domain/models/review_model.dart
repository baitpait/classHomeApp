class ReviewModel {
  String? responseCode;
  String? message;
  int? totalSize;
  int? limit;
  int? offset;
  List<Review>? reviews;
  List<String>? errors;

  ReviewModel(
      {this.responseCode,
        this.message,
        this.totalSize,
        this.limit,
        this.offset,
        this.reviews,
        this.errors});

  ReviewModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['response_code'];
    message = json['message'];
    totalSize = json['total_size'];
    limit = _asInt(json['limit']);
    offset = _asInt(json['offset']);
    if (json['data'] is List) {
      reviews = <Review>[];
      (json['data'] as List).forEach((v) {
        reviews!.add(Review.fromJson(v));
      });
    }
    errors = _asStringList(json['errors']);
  }

  static int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static List<String> _asStringList(dynamic value) {
    if (value == null) return <String>[];
    if (value is List) {
      return value
          .map((e) {
            if (e == null) return null;
            if (e is String) return e;
            if (e is Map && e['message'] != null) return e['message'].toString();
            return e.toString();
          })
          .whereType<String>()
          .toList();
    }
    return <String>[value.toString()];
  }
}

class Review {
  int? id;
  int? productId;
  int? userId;
  String? comment;
  List<String>? attachment;
  int? rating;
  int? orderId;
  Customer? customer;
  String? createdAt;
  String? updatedAt;

  Review(
      {this.id,
        this.productId,
        this.userId,
        this.comment,
        this.attachment,
        this.rating,
        this.orderId,
        this.customer,
        this.createdAt,
        this.updatedAt});

  Review.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productId = json['product_id'];
    userId = json['user_id'];
    comment = json['comment'];
    attachment = (json['attachment'] is List)
        ? (json['attachment'] as List).map((e) => e.toString()).toList()
        : <String>[];
    rating = json['rating'];
    orderId = json['order_id'];
    customer = json['customer'] != null
        ? Customer.fromJson(json['customer'])
        : null;
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
}

class Customer {
  int? id;
  String? fName;
  String? lName;
  String? email;
  String? image;
  int? isPhoneVerified;
  String? emailVerifiedAt;
  String? createdAt;
  String? updatedAt;
  String? emailVerificationToken;
  String? phone;
  String? cmFirebaseToken;
  String? temporaryToken;
  int? loginHitCount;
  int? isTempBlocked;
  String? tempBlockTime;
  String? loginMedium;
  String? imageFullpath;

  Customer(
      {this.id,
        this.fName,
        this.lName,
        this.email,
        this.image,
        this.isPhoneVerified,
        this.emailVerifiedAt,
        this.createdAt,
        this.updatedAt,
        this.emailVerificationToken,
        this.phone,
        this.cmFirebaseToken,
        this.temporaryToken,
        this.loginHitCount,
        this.isTempBlocked,
        this.tempBlockTime,
        this.loginMedium,
        this.imageFullpath});

  Customer.fromJson(Map<String, dynamic> json) {
    id = _asInt(json['id']);
    fName = json['f_name'];
    lName = json['l_name'];
    email = json['email'];
    image = json['image'];
    isPhoneVerified = _asInt(json['is_phone_verified']);
    emailVerifiedAt = json['email_verified_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    emailVerificationToken = json['email_verification_token'];
    phone = json['phone'];
    cmFirebaseToken = json['cm_firebase_token'];
    temporaryToken = json['temporary_token'];
    loginHitCount = _asInt(json['login_hit_count']);
    isTempBlocked = _asInt(json['is_temp_blocked']);
    tempBlockTime = json['temp_block_time'];
    loginMedium = json['login_medium'];
    imageFullpath = json['image_fullpath'];
  }

  static int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}
