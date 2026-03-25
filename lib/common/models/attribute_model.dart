/// Simple model for product attribute (id + name). Used in search filter.
class AttributeModel {
  final int id;
  final String? name;

  AttributeModel({required this.id, this.name});

  factory AttributeModel.fromJson(Map<String, dynamic> json) {
    return AttributeModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      name: json['name']?.toString(),
    );
  }
}
