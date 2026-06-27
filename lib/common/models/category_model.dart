class CategoryModel {
  int? _id;
  String? _name;
  int? _parentId;
  int? _position;
  int? _displayOrder;
  int? _status;
  String? _createdAt;
  String? _updatedAt;
  String? _image;
  String? _banner;
  int? _totalProductQuantity;

  CategoryModel(
      {int? id,
        String? name,
        int? parentId,
        int? position,
        int? displayOrder,
        int? status,
        String? createdAt,
        String? updatedAt,
        String? image,
        String? banner,
        int? totalProductQuantity,
      }) {
    _id = id;
    _name = name;
    _parentId = parentId;
    _position = position;
    _displayOrder = displayOrder;
    _status = status;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _image = image;
    _banner = banner;
    _totalProductQuantity = totalProductQuantity;
  }

  int? get id => _id;
  String? get name => _name;
  int? get parentId => _parentId;
  int? get position => _position;
  int? get displayOrder => _displayOrder;
  int? get status => _status;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  String? get image => _image;
  String? get banner => _banner;
  int? get totalProductQuantity => _totalProductQuantity;

  /// من API `products_count` — تصنيفات بلا منتجات لا تُعرض في الرئيسية/المتجر.
  bool get hasProductsForStoreDisplay => (totalProductQuantity ?? 0) > 0;

  CategoryModel.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _name = json['name'];
    _parentId = json['parent_id'];
    _position = json['position'];
    _displayOrder = json['display_order'] is int
        ? json['display_order'] as int
        : int.tryParse('${json['display_order']}');
    _status = json['status'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
    _image = json['image_fullpath'];
    if(json['banner_image_fullpath']!=null){
      _banner = json['banner_image_fullpath'];
    }
    _totalProductQuantity = int.tryParse('${json['products_count']}');

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = _id;
    data['name'] = _name;
    data['parent_id'] = _parentId;
    data['position'] = _position;
    data['display_order'] = _displayOrder;
    data['status'] = _status;
    data['created_at'] = _createdAt;
    data['updated_at'] = _updatedAt;
    data['image'] = _image;
    data['banner_image'] = _banner;
    data['products_count'] = _totalProductQuantity;
    return data;
  }
}
