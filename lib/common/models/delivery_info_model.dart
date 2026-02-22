class DeliveryInfoModel {
  int? _id;
  String? _name;
  DeliveryChargeSetup? _deliveryChargeSetup;
  List<DeliveryChargeByArea>? _deliveryChargeByArea;

  DeliveryInfoModel(
      {int? id,
        String? name,
        DeliveryChargeSetup? deliveryChargeSetup,
        List<DeliveryChargeByArea>? deliveryChargeByArea
      }) {
    if (id != null) {
      _id = id;
    }
    if (name != null) {
      _name = name;
    }
    if (deliveryChargeSetup != null) {
      _deliveryChargeSetup = deliveryChargeSetup;
    }
    if (deliveryChargeByArea != null) {
      _deliveryChargeByArea = deliveryChargeByArea;
    }
  }

  int? get id => _id;
  set id(int? id) => _id = id;
  String? get name => _name;
  set name(String? name) => _name = name;
  DeliveryChargeSetup? get deliveryChargeSetup => _deliveryChargeSetup;
  set deliveryChargeSetup(DeliveryChargeSetup? deliveryChargeSetup) =>
      _deliveryChargeSetup = deliveryChargeSetup;
  List<DeliveryChargeByArea>? get deliveryChargeByArea => _deliveryChargeByArea;
  set deliveryChargeByArea(List<DeliveryChargeByArea>? deliveryChargeByArea) =>
      _deliveryChargeByArea = deliveryChargeByArea;

  DeliveryInfoModel.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _name = json['name'];
    _deliveryChargeSetup = json['delivery_charge_setup'] != null
        ? DeliveryChargeSetup.fromJson(json['delivery_charge_setup'])
        : null;
    if (json['delivery_charge_by_area'] != null) {
      _deliveryChargeByArea = <DeliveryChargeByArea>[];
      json['delivery_charge_by_area'].forEach((v) {
        _deliveryChargeByArea!.add(DeliveryChargeByArea.fromJson(Map<String, dynamic>.from(v as Map)));
      });
    }
    // Backend may return "areas" (id, name_en, name_ar, delivery_charge) when using areas table
    if (json['areas'] != null && (_deliveryChargeByArea == null || _deliveryChargeByArea!.isEmpty)) {
      _deliveryChargeByArea = <DeliveryChargeByArea>[];
      for (final v in json['areas'] as List) {
        final map = v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};
        _deliveryChargeByArea!.add(DeliveryChargeByArea.fromJson({
          'id': map['id'],
          'branch_id': map['branch_id'],
          'area_name': map['name_en'] ?? map['name_ar'],
          'name_en': map['name_en'],
          'name_ar': map['name_ar'],
          'delivery_charge': map['delivery_charge'],
        }));
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = _id;
    data['name'] = _name;
    if (_deliveryChargeSetup != null) {
      data['delivery_charge_setup'] = _deliveryChargeSetup!.toJson();
    }
    if (_deliveryChargeByArea != null) {
      data['delivery_charge_by_area'] =
          _deliveryChargeByArea!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DeliveryChargeSetup {
  int? _id;
  int? _branchId;
  String? _deliveryChargeType;
  double? _deliveryChargePerKilometer;
  double? _minimumDeliveryCharge;
  double? _minimumDistanceForFreeDelivery;
  double? _fixedDeliveryCharge;
  String? _createdAt;
  String? _updatedAt;

  DeliveryChargeSetup(
      {int? id,
        int? branchId,
        String? deliveryChargeType,
        double? deliveryChargePerKilometer,
        double? minimumDeliveryCharge,
        double? minimumDistanceForFreeDelivery,
        double? fixedDeliveryCharge,
        String? createdAt,
        String? updatedAt}) {
    if (id != null) {
      _id = id;
    }
    if (branchId != null) {
      _branchId = branchId;
    }
    if (deliveryChargeType != null) {
      _deliveryChargeType = deliveryChargeType;
    }
    if (deliveryChargePerKilometer != null) {
      _deliveryChargePerKilometer = deliveryChargePerKilometer;
    }
    if (minimumDeliveryCharge != null) {
      _minimumDeliveryCharge = minimumDeliveryCharge;
    }
    if (minimumDistanceForFreeDelivery != null) {
      _minimumDistanceForFreeDelivery = minimumDistanceForFreeDelivery;
    }
    if (fixedDeliveryCharge != null) {
      _fixedDeliveryCharge = fixedDeliveryCharge;
    }
    if (createdAt != null) {
      _createdAt = createdAt;
    }
    if (updatedAt != null) {
      _updatedAt = updatedAt;
    }
  }

  int? get id => _id;
  set id(int? id) => _id = id;
  int? get branchId => _branchId;
  set branchId(int? branchId) => _branchId = branchId;
  String? get deliveryChargeType => _deliveryChargeType;
  set deliveryChargeType(String? deliveryChargeType) =>
      _deliveryChargeType = deliveryChargeType;
  double? get deliveryChargePerKilometer => _deliveryChargePerKilometer;
  set deliveryChargePerKilometer(double? deliveryChargePerKilometer) =>
      _deliveryChargePerKilometer = deliveryChargePerKilometer;
  double? get minimumDeliveryCharge => _minimumDeliveryCharge;
  set minimumDeliveryCharge(double? minimumDeliveryCharge) =>
      _minimumDeliveryCharge = minimumDeliveryCharge;
  double? get minimumDistanceForFreeDelivery => _minimumDistanceForFreeDelivery;
  set minimumDistanceForFreeDelivery(double? minimumDistanceForFreeDelivery) =>
      _minimumDistanceForFreeDelivery = minimumDistanceForFreeDelivery;
  double? get fixedDeliveryCharge => _fixedDeliveryCharge;
  set fixedDeliveryCharge(double? fixedDeliveryCharge) =>
      _fixedDeliveryCharge = fixedDeliveryCharge;
  String? get createdAt => _createdAt;
  set createdAt(String? createdAt) => _createdAt = createdAt;
  String? get updatedAt => _updatedAt;
  set updatedAt(String? updatedAt) => _updatedAt = updatedAt;

  DeliveryChargeSetup.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _branchId = json['branch_id'];
    _deliveryChargeType = json['delivery_charge_type'];
    _deliveryChargePerKilometer = double.tryParse(json['delivery_charge_per_kilometer'].toString());
    _minimumDeliveryCharge = double.tryParse(json['minimum_delivery_charge'].toString());
    _minimumDistanceForFreeDelivery = double.tryParse(json['minimum_distance_for_free_delivery'].toString());
    _fixedDeliveryCharge = double.tryParse(json['fixed_delivery_charge'].toString());
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = _id;
    data['branch_id'] = _branchId;
    data['delivery_charge_type'] = _deliveryChargeType;
    data['delivery_charge_per_kilometer'] = _deliveryChargePerKilometer;
    data['minimum_delivery_charge'] = _minimumDeliveryCharge;
    data['minimum_distance_for_free_delivery'] =
        _minimumDistanceForFreeDelivery;
    data['fixed_delivery_charge'] = _fixedDeliveryCharge;
    data['created_at'] = _createdAt;
    data['updated_at'] = _updatedAt;
    return data;
  }
}

class DeliveryChargeByArea {
  int? _id;
  int? _branchId;
  String? _areaName;
  String? _nameEn;
  String? _nameAr;
  double? _deliveryCharge;
  String? _createdAt;
  String? _updatedAt;

  DeliveryChargeByArea(
      {int? id,
        int? branchId,
        String? areaName,
        String? nameEn,
        String? nameAr,
        double? deliveryCharge,
        String? createdAt,
        String? updatedAt}) {
    if (id != null) {
      _id = id;
    }
    if (branchId != null) {
      _branchId = branchId;
    }
    if (areaName != null) {
      _areaName = areaName;
    }
    if (nameEn != null) {
      _nameEn = nameEn;
    }
    if (nameAr != null) {
      _nameAr = nameAr;
    }
    if (deliveryCharge != null) {
      _deliveryCharge = deliveryCharge;
    }
    if (createdAt != null) {
      _createdAt = createdAt;
    }
    if (updatedAt != null) {
      _updatedAt = updatedAt;
    }
  }

  int? get id => _id;
  set id(int? id) => _id = id;
  int? get branchId => _branchId;
  set branchId(int? branchId) => _branchId = branchId;
  String? get areaName => _areaName;
  set areaName(String? areaName) => _areaName = areaName;
  String? get nameEn => _nameEn;
  set nameEn(String? v) => _nameEn = v;
  String? get nameAr => _nameAr;
  set nameAr(String? v) => _nameAr = v;
  double? get deliveryCharge => _deliveryCharge;
  set deliveryCharge(double? deliveryCharge) => _deliveryCharge = deliveryCharge;
  String? get createdAt => _createdAt;
  set createdAt(String? createdAt) => _createdAt = createdAt;
  String? get updatedAt => _updatedAt;
  set updatedAt(String? updatedAt) => _updatedAt = updatedAt;

  DeliveryChargeByArea.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _branchId = json['branch_id'];
    _areaName = json['area_name']?.toString() ?? json['name_en']?.toString() ?? json['name_ar']?.toString();
    _nameEn = json['name_en']?.toString();
    _nameAr = json['name_ar']?.toString();
    _deliveryCharge = double.tryParse(json['delivery_charge'].toString());
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = _id;
    data['branch_id'] = _branchId;
    data['area_name'] = _areaName;
    data['delivery_charge'] = _deliveryCharge;
    data['created_at'] = _createdAt;
    data['updated_at'] = _updatedAt;
    return data;
  }
}
