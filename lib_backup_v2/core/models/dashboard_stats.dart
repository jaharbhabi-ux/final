import 'dart:convert';

/// Dashboard Statistics Model
///
/// Pure value object holding every count the dashboard needs.
/// Repository exposes counts as inline getters (hot path); this model
/// is used for snapshot serialization (Apps Script response, local
/// persistence, debugging).
class DashboardStats {
  final int totalEmployees; // ALL sheet only
  final int activeCount; // ALL sheet only
  final int inactiveCount; // EXTRA sheet only
  final int hccpCount; // ALL where पद = HCCP
  final int lhccpCount; // ALL where पद = LHCCP
  final int arrivalCount; // Aagman sheet row count
  final int departureCount; // Prasthan sheet row count

  /// Per-designation breakdown from the ALL sheet.
  /// Keys are the raw designation strings (Hindi or English) as they
  /// appear on the sheet. Values are row counts.
  final Map<String, int> classification;

  const DashboardStats({
    this.totalEmployees = 0,
    this.activeCount = 0,
    this.inactiveCount = 0,
    this.hccpCount = 0,
    this.lhccpCount = 0,
    this.arrivalCount = 0,
    this.departureCount = 0,
    this.classification = const {},
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalEmployees: json['totalEmployees'] as int? ?? 0,
      activeCount: json['activeCount'] as int? ?? 0,
      inactiveCount: json['inactiveCount'] as int? ?? 0,
      hccpCount: json['hccpCount'] as int? ?? 0,
      lhccpCount: json['lhccpCount'] as int? ?? 0,
      arrivalCount: json['arrivalCount'] as int? ?? 0,
      departureCount: json['departureCount'] as int? ?? 0,
      classification: _parseMap(json['classification']),
    );
  }

  factory DashboardStats.empty() => const DashboardStats();

  Map<String, dynamic> toJson() => {
        'totalEmployees': totalEmployees,
        'activeCount': activeCount,
        'inactiveCount': inactiveCount,
        'hccpCount': hccpCount,
        'lhccpCount': lhccpCount,
        'arrivalCount': arrivalCount,
        'departureCount': departureCount,
        'classification': classification,
      };

  String toJsonString() => jsonEncode(toJson());

  DashboardStats copyWith({
    int? totalEmployees,
    int? activeCount,
    int? inactiveCount,
    int? hccpCount,
    int? lhccpCount,
    int? arrivalCount,
    int? departureCount,
    Map<String, int>? classification,
  }) {
    return DashboardStats(
      totalEmployees: totalEmployees ?? this.totalEmployees,
      activeCount: activeCount ?? this.activeCount,
      inactiveCount: inactiveCount ?? this.inactiveCount,
      hccpCount: hccpCount ?? this.hccpCount,
      lhccpCount: lhccpCount ?? this.lhccpCount,
      arrivalCount: arrivalCount ?? this.arrivalCount,
      departureCount: departureCount ?? this.departureCount,
      classification: classification ?? this.classification,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DashboardStats &&
          other.totalEmployees == totalEmployees &&
          other.activeCount == activeCount &&
          other.inactiveCount == inactiveCount &&
          other.hccpCount == hccpCount &&
          other.lhccpCount == lhccpCount &&
          other.arrivalCount == arrivalCount &&
          other.departureCount == departureCount &&
          _mapEquals(other.classification, classification);

  @override
  int get hashCode => Object.hash(
        totalEmployees,
        activeCount,
        inactiveCount,
        hccpCount,
        lhccpCount,
        arrivalCount,
        departureCount,
        Object.hashAll(classification.entries
            .map((e) => Object.hash(e.key, e.value))),
      );

  static Map<String, int> _parseMap(dynamic input) {
    if (input is! Map) return const {};
    final out = <String, int>{};
    input.forEach((key, value) {
      if (value is int) {
        out[key.toString()] = value;
      } else if (value is num) {
        out[key.toString()] = value.toInt();
      }
    });
    return out;
  }

  static bool _mapEquals(Map<String, int> a, Map<String, int> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (a[key] != b[key]) return false;
    }
    return true;
  }
}
