/// Simple model for product tag (id + name). Used in search filter.
class TagModel {
  final int id;
  final String? name;

  TagModel({required this.id, this.name});

  factory TagModel.fromJson(Map<String, dynamic> json) {
    return TagModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      name: json['name']?.toString(),
    );
  }
}
