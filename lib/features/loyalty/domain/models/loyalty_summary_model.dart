/// Summary from GET /api/v1/customer/loyalty: points, level, total_spent, levels.
class LoyaltySummaryModel {
  final bool loyaltyPointsEnabled;
  final int points;
  final String level;
  final double totalSpent;
  final double redemptionValuePerPoint;
  final Map<String, dynamic>? levels;

  LoyaltySummaryModel({
    required this.loyaltyPointsEnabled,
    required this.points,
    required this.level,
    required this.totalSpent,
    required this.redemptionValuePerPoint,
    this.levels,
  });

  factory LoyaltySummaryModel.fromJson(Map<String, dynamic> json) {
    final pts = json['points'];
    final spent = json['total_spent'];
    final redemption = json['redemption_value_per_point'];
    return LoyaltySummaryModel(
      loyaltyPointsEnabled: json['loyalty_points_enabled'] == true,
      points: pts is int ? pts : int.tryParse('$pts') ?? 0,
      level: json['level']?.toString() ?? 'bronze',
      totalSpent: spent is num ? (spent as num).toDouble() : (double.tryParse('$spent') ?? 0),
      redemptionValuePerPoint: redemption is num ? (redemption as num).toDouble() : (double.tryParse('$redemption') ?? 0.5),
      levels: json['levels'] != null && json['levels'] is Map
          ? Map<String, dynamic>.from(json['levels'] as Map)
          : null,
    );
  }

  /// Ordered level keys by min_spent ascending (bronze, silver, gold).
  List<MapEntry<String, Map<String, dynamic>>> get levelsOrdered {
    if (levels == null || levels!.isEmpty) return [];
    final list = levels!.entries
        .map((e) => MapEntry(e.key, Map<String, dynamic>.from((e.value as Map?) ?? {})))
        .where((e) => e.value['min_spent'] != null)
        .toList();
    list.sort((a, b) {
      final aMin = (a.value['min_spent'] is num) ? (a.value['min_spent'] as num).toDouble() : 0;
      final bMin = (b.value['min_spent'] is num) ? (b.value['min_spent'] as num).toDouble() : 0;
      return aMin.compareTo(bMin);
    });
    return list;
  }

  /// Next level key and min_spent for progress; null if already at top.
  MapEntry<String, double>? get nextLevelEntry {
    final ordered = levelsOrdered;
    if (ordered.isEmpty) return null;
    for (final e in ordered) {
      final minSpent = (e.value['min_spent'] is num) ? (e.value['min_spent'] as num).toDouble() : 0.0;
      if (minSpent > totalSpent) return MapEntry(e.key, minSpent);
    }
    return null;
  }
}
