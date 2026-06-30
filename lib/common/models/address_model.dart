class AddressModel {
  int? id;
  String? addressType;
  String? contactPersonNumber;
  String? address;
  String? city;
  int? areaId;
  String? latitude;
  String? longitude;
  String? createdAt;
  String? updatedAt;
  int? userId;
  String? method;
  String? contactPersonName;
  String? streetNumber;
  String? floorNumber;
  String? houseNumber;

  AddressModel({this.id,
    this.addressType,
    this.contactPersonNumber,
    this.address,
    this.city,
    this.areaId,
    this.latitude,
    this.longitude,
    this.createdAt,
    this.updatedAt,
    this.userId,
    this.method,
    this.contactPersonName,
    this.houseNumber,
    this.floorNumber,
    this.streetNumber,
  });

  AddressModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    addressType = json['address_type'];
    contactPersonNumber = json['contact_person_number'];
    address = json['address'];
    city = json['city'];
    areaId = json['area_id'] is int ? json['area_id'] : int.tryParse('${json['area_id']}');
    latitude = json['latitude'];
    longitude = json['longitude'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    userId = json['user_id'];
    method = json['_method'];
    contactPersonName = json['contact_person_name'];
    streetNumber = json['road'];
    floorNumber = json['floor'];
    houseNumber = json['house'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['address_type'] = addressType ?? 'Other';
    data['contact_person_number'] = contactPersonNumber;
    data['address'] = address;
    data['city'] = city;
    data['area_id'] = areaId;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['user_id'] = userId;
    data['_method'] = method;
    data['contact_person_name'] = contactPersonName;
    data['road'] = streetNumber;
    data['house'] = houseNumber;
    data['floor'] = floorNumber;
    return data;
  }
}
