 class SignUpModel {
  String? fName;
  String? lName;
  String? phone;
  String? email;
  String? password;
  /// Optional. When set, user gets default type until admin approves this type.
  int? userTypeId;

  SignUpModel({this.fName, this.lName, this.phone, this.email='', this.password, this.userTypeId});

  SignUpModel.fromJson(Map<String, dynamic> json) {
    fName = json['f_name'];
    lName = json['l_name'];
    phone = json['phone'];
    email = json['email'];
    password = json['password'];
    userTypeId = json['user_type_id'] != null ? int.tryParse(json['user_type_id'].toString()) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['f_name'] = fName;
    data['l_name'] = lName;
    data['phone'] = phone;
    data['email'] = email;
    data['password'] = password;
    if (userTypeId != null) {
      data['user_type_id'] = userTypeId;
    }
    return data;
  }
}
