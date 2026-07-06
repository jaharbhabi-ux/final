import '../constants/app_constants.dart';

/// मूल वेतन मॉडल - Basic Pay Model
///
/// Stores every salary field present on the Basic Pay sheet.
/// Common fields are typed for direct access; every other column
/// (present or future) flows into [additionalFields] and survives
/// round-trip serialization. This satisfies the spec:
/// "Store every salary field. Do not hide unknown fields. Allow future expansion."
class BasicPay {
  /// Master key — joins to Employee.pno. Never null.
  final String pno;

  /// Common typed fields (may be empty string if column absent / cell blank).
  final String effectiveDate;
  final String basicPay;
  final String scale;
  final String gradePay;
  final String daPercent;
  final String hra;
  final String transportAllowance;
  final String total;
  final String incrementMonth;

  /// Forward-compat: every unknown sheet column lands here.
  /// Round-trip safe — `fromMap(toMap())` preserves all keys.
  final Map<String, dynamic> additionalFields;

  BasicPay({
    required this.pno,
    this.effectiveDate = '',
    this.basicPay = '',
    this.scale = '',
    this.gradePay = '',
    this.daPercent = '',
    this.hra = '',
    this.transportAllowance = '',
    this.total = '',
    this.incrementMonth = '',
    Map<String, dynamic>? additionalFields,
  }) : additionalFields = additionalFields ?? {};

  /// Known typed keys — used to separate typed fields from additionalFields.
  static const Set<String> _knownKeys = {
    AppConstants.keyPno,
    AppConstants.keyBasicPay,
    AppConstants.keyIncrementMonth,
    'वेतन वृद्धि माह',
    'Scale',
    'स्केल',
    'Grade Pay',
    'ग्रेड वेतन',
    'DA',
    'महागध्यता',
    'HRA',
    'घर किराया भत्ता',
    'TA',
    'यात्रा भत्ता',
    'Total',
    'कुल',
    'Effective Date',
    'प्रभावी तिथि',
    'PNO',
  };

  factory BasicPay.fromMap(Map<String, dynamic> map) {
    // Capture unknown columns BEFORE extracting typed fields.
    final extras = <String, dynamic>{};
    map.forEach((key, value) {
      if (key.startsWith('__')) return; // skip internal tags
      if (_knownKeys.contains(key)) return;
      if (value == null) return;
      final s = value.toString();
      if (s.isEmpty) return;
      extras[key] = value;
    });

    return BasicPay(
      pno: _val(map, [AppConstants.keyPno, 'PNO']),
      effectiveDate: _val(map, ['Effective Date', 'प्रभावी तिथि']),
      basicPay: _val(map, [AppConstants.keyBasicPay]),
      scale: _val(map, ['Scale', 'स्केल']),
      gradePay: _val(map, ['Grade Pay', 'ग्रेड वेतन']),
      daPercent: _val(map, ['DA', 'महागध्यता', 'DA%']),
      hra: _val(map, ['HRA', 'घर किराया भत्ता']),
      transportAllowance: _val(map, ['TA', 'यात्रा भत्ता', 'Transport Allowance']),
      total: _val(map, ['Total', 'कुल']),
      incrementMonth: _val(map, [
        AppConstants.keyIncrementMonth,
        'वेतन वृद्धि माह',
      ]),
      additionalFields: extras,
    );
  }

  Map<String, dynamic> toMap() {
    final out = <String, dynamic>{
      AppConstants.keyPno: pno,
      if (effectiveDate.isNotEmpty) 'Effective Date': effectiveDate,
      if (basicPay.isNotEmpty) AppConstants.keyBasicPay: basicPay,
      if (scale.isNotEmpty) 'Scale': scale,
      if (gradePay.isNotEmpty) 'Grade Pay': gradePay,
      if (daPercent.isNotEmpty) 'DA': daPercent,
      if (hra.isNotEmpty) 'HRA': hra,
      if (transportAllowance.isNotEmpty) 'TA': transportAllowance,
      if (total.isNotEmpty) 'Total': total,
      if (incrementMonth.isNotEmpty)
        AppConstants.keyIncrementMonth: incrementMonth,
    };
    out.addAll(additionalFields);
    return out;
  }

  /// All field labels + values (typed first, then extras) for table rendering.
  /// Used by the Salary section to render a dynamic full-width table.
  List<MapEntry<String, String>> get allFields {
    final typed = <MapEntry<String, String>>[
      if (effectiveDate.isNotEmpty)
        MapEntry('प्रभावी तिथि', effectiveDate),
      if (basicPay.isNotEmpty) MapEntry('मूल वेतन', basicPay),
      if (scale.isNotEmpty) MapEntry('स्केल', scale),
      if (gradePay.isNotEmpty) MapEntry('ग्रेड वेतन', gradePay),
      if (daPercent.isNotEmpty) MapEntry('DA%', daPercent),
      if (hra.isNotEmpty) MapEntry('HRA', hra),
      if (transportAllowance.isNotEmpty)
        MapEntry('यात्रा भत्ता', transportAllowance),
      if (total.isNotEmpty) MapEntry('कुल', total),
      if (incrementMonth.isNotEmpty)
        MapEntry('वृद्धि माह', incrementMonth),
    ];
    final extras = additionalFields.entries
        .where((e) => e.value?.toString().isNotEmpty ?? false)
        .map((e) => MapEntry(e.key, e.value.toString()))
        .toList();
    return [...typed, ...extras];
  }

  static String _val(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      if (map.containsKey(key)) {
        final v = map[key]?.toString().trim() ?? '';
        if (v.isNotEmpty) return v;
      }
    }
    return '';
  }
}
