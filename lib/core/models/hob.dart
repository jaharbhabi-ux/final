import '../constants/app_constants.dart';

/// एचओबी मॉडल - HOB (Headquarters Order Book) Model
class Hob {
  final String pno;
  final String hobNumber;
  final String date;
  final String description;
  final String otherDetails;

  const Hob({
    this.pno = '',
    this.hobNumber = '',
    this.date = '',
    this.description = '',
    this.otherDetails = '',
  });

  factory Hob.fromMap(Map<String, dynamic> map) {
    return Hob(
      pno: _val(map, [AppConstants.keyPno, 'PNO']),
      hobNumber: _val(map, [
        AppConstants.keyHobNumber,
        'पु०ओबी संख्या',
        'पु0ओबी संख्या',
        'HOB संख्या',
      ]),
      date: _val(map, [AppConstants.keyDate]),
      description: _val(map, [AppConstants.keyDescription]),
      otherDetails: _val(map, [AppConstants.keyOtherDetails, 'अन्य विवरण']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      AppConstants.keyPno: pno,
      AppConstants.keyHobNumber: hobNumber,
      AppConstants.keyDate: date,
      AppConstants.keyDescription: description,
      AppConstants.keyOtherDetails: otherDetails,
    };
  }

  Hob copyWith({
    String? pno,
    String? hobNumber,
    String? date,
    String? description,
    String? otherDetails,
  }) {
    return Hob(
      pno: pno ?? this.pno,
      hobNumber: hobNumber ?? this.hobNumber,
      date: date ?? this.date,
      description: description ?? this.description,
      otherDetails: otherDetails ?? this.otherDetails,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Hob &&
          other.pno == pno &&
          other.hobNumber == hobNumber &&
          other.date == date &&
          other.description == description &&
          other.otherDetails == otherDetails;

  @override
  int get hashCode => Object.hash(pno, hobNumber, date, description, otherDetails);

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
