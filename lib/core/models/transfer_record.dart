import 'aagman.dart';
import 'prasthan.dart';

/// स्थानांतरण रिकॉर्ड - Transfer Record Model
///
/// Lightweight wrapper that unifies [Aagman] (arrival) and [Prasthan]
/// (departure) into a single transfer-like row for the Profile screen's
/// Transfer section. The wrapper holds a reference to the source record
/// so the UI can drill back if needed.
///
/// Sorting: spec says "newest first". The repository sorts by
/// [orderNumber] lexicographically (the order number embeds the date).
class TransferRecord {
  final String pno;
  final TransferDirection direction; // arrival or departure
  final String orderNumber;
  final String fileNumber;
  final String fromLocation;
  final String toLocation;
  final String otherDetails;

  /// Original record (for debugging / drill-down).
  final Aagman? _aagmanSource;
  final Prasthan? _prasthanSource;

  const TransferRecord._({
    required this.pno,
    required this.direction,
    this.orderNumber = '',
    this.fileNumber = '',
    this.fromLocation = '',
    this.toLocation = '',
    this.otherDetails = '',
    Aagman? aagmanSource,
    Prasthan? prasthanSource,
  })  : _aagmanSource = aagmanSource,
        _prasthanSource = prasthanSource;

  factory TransferRecord.fromAagman(Aagman a) => TransferRecord._(
        pno: a.pno,
        direction: TransferDirection.arrival,
        orderNumber: a.orderNumber,
        fileNumber: a.fileNumber,
        fromLocation: a.fromWhere,
        toLocation: a.toWhere,
        otherDetails: a.otherDetails,
        aagmanSource: a,
      );

  factory TransferRecord.fromPrasthan(Prasthan p) => TransferRecord._(
        pno: p.pno,
        direction: TransferDirection.departure,
        orderNumber: p.orderNumber,
        fileNumber: p.fileNumber,
        fromLocation: p.fromWhere,
        toLocation: p.toWhere,
        otherDetails: p.otherDetails,
        prasthanSource: p,
      );

  /// Hindi label for the direction — आगमन / प्रस्थान.
  String get directionLabel =>
      direction == TransferDirection.arrival ? 'आगमन' : 'प्रस्थान';

  /// Either source record, if you need to read fields this wrapper
  /// doesn't expose.
  dynamic get source => _aagmanSource ?? _prasthanSource;

  TransferRecord copyWith({
    String? pno,
    TransferDirection? direction,
    String? orderNumber,
    String? fileNumber,
    String? fromLocation,
    String? toLocation,
    String? otherDetails,
  }) {
    return TransferRecord._(
      pno: pno ?? this.pno,
      direction: direction ?? this.direction,
      orderNumber: orderNumber ?? this.orderNumber,
      fileNumber: fileNumber ?? this.fileNumber,
      fromLocation: fromLocation ?? this.fromLocation,
      toLocation: toLocation ?? this.toLocation,
      otherDetails: otherDetails ?? this.otherDetails,
      aagmanSource: _aagmanSource,
      prasthanSource: _prasthanSource,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransferRecord &&
          other.pno == pno &&
          other.direction == direction &&
          other.orderNumber == orderNumber &&
          other.fileNumber == fileNumber &&
          other.fromLocation == fromLocation &&
          other.toLocation == toLocation &&
          other.otherDetails == otherDetails;

  @override
  int get hashCode => Object.hash(
        pno,
        direction,
        orderNumber,
        fileNumber,
        fromLocation,
        toLocation,
        otherDetails,
      );
}

enum TransferDirection { arrival, departure }
