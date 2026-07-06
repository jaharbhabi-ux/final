/// पूर्व नियुक्ति - Previous Posting Model
///
/// Parsed from the multiline cell on the ALL/EXTRA sheet
/// (`AppConstants.keyPreviousPostings`). The raw cell value looks like:
///
///     "पुलिस लाइन, कानपुर | 2010-08-01 | 2015-06-30
///      स्थानीय पुलिस, लखनऊ | 2015-07-01 | वर्तमान"
///
/// Rows separated by `\n` (Excel ALT+ENTER), fields separated by `|`.
/// The `to` value may be a sentinel meaning "present":
///   - "वर्तमान", "Current", "Present", "Till Date", "से लगातार"
/// In that case [toDate] is null and [duration] is computed up to today.
class PreviousPosting {
  final String pno;
  final String location;
  final String fromDateRaw;
  final String toDateRaw;

  /// Parsed 'to' date — null when the cell value means "present".
  /// Repository sets this after parsing.
  final DateTime? toDate;

  /// Human-readable duration (e.g. "5 वर्ष 2 माह"). Computed by the
  /// repository's DurationCalculator and cached here for display.
  final String duration;

  const PreviousPosting({
    required this.pno,
    this.location = '',
    this.fromDateRaw = '',
    this.toDateRaw = '',
    this.toDate,
    this.duration = '',
  });

  /// True when the raw 'to' value means "still serving here".
  bool get isPresent => _presentTokens.contains(toDateRaw.trim().toLowerCase());

  static const Set<String> _presentTokens = {
    'वर्तमान',
    'current',
    'present',
    'till date',
    'से लगातार',
    '',
  };

  PreviousPosting copyWith({
    String? pno,
    String? location,
    String? fromDateRaw,
    String? toDateRaw,
    DateTime? toDate,
    String? duration,
  }) {
    return PreviousPosting(
      pno: pno ?? this.pno,
      location: location ?? this.location,
      fromDateRaw: fromDateRaw ?? this.fromDateRaw,
      toDateRaw: toDateRaw ?? this.toDateRaw,
      toDate: toDate ?? this.toDate,
      duration: duration ?? this.duration,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PreviousPosting &&
          other.pno == pno &&
          other.location == location &&
          other.fromDateRaw == fromDateRaw &&
          other.toDateRaw == toDateRaw &&
          other.duration == duration;

  @override
  int get hashCode => Object.hash(pno, location, fromDateRaw, toDateRaw, duration);

  // ──────────────────────────────────────────────
  //  Multiline-cell parser
  //  Used by EmployeeRepository to split the raw
  //  `previousPostings` cell value into List<PreviousPosting>.
  // ──────────────────────────────────────────────

  /// Parse a multiline cell value into rows.
  /// Each row: `location | from | to` (whitespace-trimmed).
  /// Rows with all three fields empty are dropped.
  /// Rows with fewer than 3 fields are accepted — missing fields become ''.
  static List<PreviousPosting> parseCell({
    required String pno,
    required String cellValue,
  }) {
    if (cellValue.trim().isEmpty) return const [];

    final lines = cellValue.split(RegExp(r'\r?\n'));
    final out = <PreviousPosting>[];
    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      final parts = line.split('|').map((s) => s.trim()).toList();
      while (parts.length < 3) {
        parts.add('');
      }
      final location = parts[0];
      final from = parts[1];
      final to = parts[2];
      if (location.isEmpty && from.isEmpty && to.isEmpty) continue;
      out.add(PreviousPosting(
        pno: pno,
        location: location,
        fromDateRaw: from,
        toDateRaw: to,
      ));
    }
    return out;
  }
}
