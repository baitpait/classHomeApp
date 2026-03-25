/// Single entry from GET /api/v1/customer/loyalty/history (paginated).
class LoyaltyLogModel {
  final int? id;
  final int points;
  final String? type;
  final String? description;
  final int? orderId;
  final String? createdAt;

  LoyaltyLogModel({
    this.id,
    required this.points,
    this.type,
    this.description,
    this.orderId,
    this.createdAt,
  });

  factory LoyaltyLogModel.fromJson(Map<String, dynamic> json) {
    final pts = json['points'];
    return LoyaltyLogModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}'),
      points: pts is int ? pts : int.tryParse('$pts') ?? 0,
      type: json['type']?.toString(),
      description: json['description']?.toString(),
      orderId: json['order_id'] is int ? json['order_id'] : int.tryParse('${json['order_id']}'),
      createdAt: json['created_at']?.toString(),
    );
  }

  bool get isEarn => points > 0;
}
