class ReviewModel {
  String? responseCode;
  String? message;
  int? totalSize;
  String? limit;
  String? offset;
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
    limit = json['limit'];
    offset = json['offset'];
    if (json['data'] != null) {
      reviews = <Review>[];
      json['data'].forEach((v) {
        reviews!.add(Review.fromJson(v));
      });
    }
    errors = json['errors'].cast<String>();
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
    attachment = json['attachment'].cast<String>();
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
    id = json['id'];
    fName = json['f_name'];
    lName = json['l_name'];
    email = json['email'];
    image = json['image'];
    isPhoneVerified = json['is_phone_verified'];
    emailVerifiedAt = json['email_verified_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    emailVerificationToken = json['email_verification_token'];
    phone = json['phone'];
    cmFirebaseToken = json['cm_firebase_token'];
    temporaryToken = json['temporary_token'];
    loginHitCount = json['login_hit_count'];
    isTempBlocked = json['is_temp_blocked'];
    tempBlockTime = json['temp_block_time'];
    loginMedium = json['login_medium'];
    imageFullpath = json['image_fullpath'];
  }
}
