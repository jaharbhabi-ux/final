import '../constants/app_constants.dart';

/// प्रस्थान मॉडल - Prasthan (Departure) Model
///
/// Same shape as Aagman ( Arrival / Departure rows share the same
/// sheet structure). Kept as a separate class for type safety —
/// mixing Aagman and Prasthan lists would be a runtime bug.
class Prasthan {
  final String serialNo;
  final String pno;
  final String employeeName;
  final String orderNumber;
  final String fileNumber;
  final String fromWhere;
  final String toWhere;
  final String otherDetails;

  const Prasthan({
    this.serialNo = '',
    this.pno = '',
    this.employeeName = '',
    this.orderNumber = '',
    this.fileNumber = '',
    this.fromWhere = '',
    this.toWhere = '',
    this.otherDetails = '',
  });

  factory Prasthan.fromMap(Map<String, dynamic> map) {
    return Prasthan(
      serialNo: _val(map, [
        AppConstants.keySerialNo,
        'क्र.सं.',
        'Sl No',
        'S.No.',
      ]),
      pno: _val(map, [AppConstants.keyPno, 'PNO']),
      employeeName: _val(map, ['मु0आ0 का नाम', AppConstants.keyName]),
      orderNumber: _val(map, [
        AppConstants.keyOrderNumber,
        'आदेश सं0 व दिनांक',
        'आदेश संख्या',
      ]),
      fileNumber: _val(map, [AppConstants.keyFileNumber]),
      fromWhere: _val(map, [AppConstants.keyFromWhere]),
      toWhere: _val(map, [AppConstants.keyToWhere]),
      otherDetails: _val(map, [AppConstants.keyOtherDetails, 'विवरण']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      AppConstants.keySerialNo: serialNo,
      AppConstants.keyPno: pno,
      'मु0आ0 का नाम': employeeName,
      AppConstants.keyOrderNumber: orderNumber,
      AppConstants.keyFileNumber: fileNumber,
      AppConstants.keyFromWhere: fromWhere,
      AppConstants.keyToWhere: toWhere,
      AppConstants.keyOtherDetails: otherDetails,
    };
  }

  Prasthan copyWith({
    String? serialNo,
    String? pno,
    String? employeeName,
    String? orderNumber,
    String? fileNumber,
    String? fromWhere,
    String? toWhere,
    String? otherDetails,
  }) {
    return Prasthan(
      serialNo: serialNo ?? this.serialNo,
      pno: pno ?? this.pno,
      employeeName: employeeName ?? this.employeeName,
      orderNumber: orderNumber ?? this.orderNumber,
      fileNumber: fileNumber ?? this.fileNumber,
      fromWhere: fromWhere ?? this.fromWhere,
      toWhere: toWhere ?? this.toWhere,
      otherDetails: otherDetails ?? this.otherDetails,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Prasthan &&
          other.serialNo == serialNo &&
          other.pno == pno &&
          other.employeeName == employeeName &&
          other.orderNumber == orderNumber &&
          other.fileNumber == fileNumber &&
          other.fromWhere == fromWhere &&
          other.toWhere == toWhere &&
          other.otherDetails == otherDetails;

  @override
  int get hashCode => Object.hash(
        serialNo,
        pno,
        employeeName,
        orderNumber,
        fileNumber,
        fromWhere,
        toWhere,
        otherDetails,
      );

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
