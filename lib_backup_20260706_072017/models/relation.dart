import '../constants/app_constants.dart';

/// सम्बन्ध मॉडल - Relation (Sambadh sheet) Model
///
/// Represents one row on the Sambadh sheet — a single family/relation
/// record for an employee. Multiple rows per PNO are common
/// (Father, Mother, Spouse, Children, Nominee, etc.).
///
/// Joins to Employee via [pno] (master key). Never via Badge.
class Relation {
  /// Master key — joins to Employee.pno. Never null.
  final String pno;

  /// Relation type — e.g. पिता / माता / पत्नी / पुत्र / पुत्री / नामिनी.
  final String relationType;

  /// Name of the related person.
  final String name;

  /// Contact number (may be blank).
  final String contact;

  /// Forward-compat: every unknown sheet column lands here.
  final Map<String, dynamic> additionalFields;

  Relation({
    required this.pno,
    this.relationType = '',
    this.name = '',
    this.contact = '',
    Map<String, dynamic>? additionalFields,
  }) : additionalFields = additionalFields ?? {};

  static const Set<String> _knownKeys = {
    AppConstants.keyPno,
    'PNO',
    AppConstants.keyRelationType,
    AppConstants.keyRelationName,
    AppConstants.keyRelationContact,
  };

  factory Relation.fromMap(Map<String, dynamic> map) {
    final extras = <String, dynamic>{};
    map.forEach((key, value) {
      if (key.startsWith('__')) return;
      if (_knownKeys.contains(key)) return;
      if (value == null) return;
      final s = value.toString();
      if (s.isEmpty) return;
      extras[key] = value;
    });

    return Relation(
      pno: _val(map, [AppConstants.keyPno, 'PNO']),
      relationType: _val(map, [
        AppConstants.keyRelationType,
        'संबंध',
        'Relation',
      ]),
      name: _val(map, [
        AppConstants.keyRelationName,
        AppConstants.keyName,
        'Name',
      ]),
      contact: _val(map, [
        AppConstants.keyRelationContact,
        'मोबाइल',
        AppConstants.keyMobile,
        'Contact',
        'Phone',
      ]),
      additionalFields: extras,
    );
  }

  Map<String, dynamic> toMap() {
    final out = <String, dynamic>{
      AppConstants.keyPno: pno,
      if (relationType.isNotEmpty) AppConstants.keyRelationType: relationType,
      if (name.isNotEmpty) AppConstants.keyRelationName: name,
      if (contact.isNotEmpty) AppConstants.keyRelationContact: contact,
    };
    out.addAll(additionalFields);
    return out;
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
