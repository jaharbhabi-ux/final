import '../models/previous_posting.dart';

/// Duration calculator — pure utility, no Flutter dependencies.
/// Computes human-readable Hindi duration strings for Previous Posting
/// rows, handling "present" sentinels.
///
/// All date parsing is defensive — if the format is unrecognized the
/// duration becomes '—' (em dash), never crashes.
class DurationCalculator {
  DurationCalculator._();

  /// Try several Hindi / English date formats and return the first parse
  /// that succeeds. Returns null if none match.
  static DateTime? tryParse(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return null;

    // YYYY-MM-DD
    final iso = RegExp(r'^(\d{4})-(\d{1,2})-(\d{1,2})$').firstMatch(s);
    if (iso != null) {
      final y = int.tryParse(iso.group(1)!);
      final m = int.tryParse(iso.group(2)!);
      final d = int.tryParse(iso.group(3)!);
      if (y != null && m != null && d != null) {
        return _safeDate(y, m, d);
      }
    }

    // DD-MM-YYYY or DD/MM/YYYY
    final dmy = RegExp(r'^(\d{1,2})[-/](\d{1,2})[-/](\d{4})$').firstMatch(s);
    if (dmy != null) {
      final d = int.tryParse(dmy.group(1)!);
      final m = int.tryParse(dmy.group(2)!);
      final y = int.tryParse(dmy.group(3)!);
      if (y != null && m != null && d != null) {
        return _safeDate(y, m, d);
      }
    }

    // DD.MM.YYYY
    final dot = RegExp(r'^(\d{1,2})\.(\d{1,2})\.(\d{4})$').firstMatch(s);
    if (dot != null) {
      final d = int.tryParse(dot.group(1)!);
      final m = int.tryParse(dot.group(2)!);
      final y = int.tryParse(dot.group(3)!);
      if (y != null && m != null && d != null) {
        return _safeDate(y, m, d);
      }
    }

    return null;
  }

  static DateTime? _safeDate(int y, int m, int d) {
    if (m < 1 || m > 12) return null;
    if (d < 1 || d > 31) return null;
    try {
      return DateTime(y, m, d);
    } catch (_) {
      return null;
    }
  }

  /// Compute duration between two raw date strings. If `toRaw` is a
  /// "present" sentinel, uses DateTime.now() as the end.
  static String between(String fromRaw, String toRaw) {
    final from = tryParse(fromRaw);
    if (from == null) return '—';

    final DateTime to;
    if (_isPresent(toRaw)) {
      to = DateTime.now();
    } else {
      final parsed = tryParse(toRaw);
      if (parsed == null) return '—';
      to = parsed;
    }

    if (!to.isAfter(from)) return '—';

    final years = to.year - from.year;
    final months = to.month - from.month;
    final days = to.day - from.day;

    int y = years;
    int m = months;
    int d = days;
    if (d < 0) {
      m -= 1;
      final prevMonth = DateTime(to.year, to.month, 0);
      d += prevMonth.day;
    }
    if (m < 0) {
      y -= 1;
      m += 12;
    }

    final parts = <String>[];
    if (y > 0) parts.add('$y वर्ष');
    if (m > 0) parts.add('$m माह');
    if (d > 0 && y == 0 && m < 6) parts.add('$d दिन');
    return parts.isEmpty ? '< 1 दिन' : parts.join(' ');
  }

  static bool _isPresent(String raw) {
    const tokens = {
      'वर्तमान',
      'current',
      'present',
      'till date',
      'से लगातार',
      '',
    };
    return tokens.contains(raw.trim().toLowerCase());
  }

  /// Attach computed duration + parsed toDate to a [PreviousPosting].
  /// Returns a new instance (immutable update).
  static PreviousPosting withComputedDuration(PreviousPosting p) {
    final durationStr = between(p.fromDateRaw, p.toDateRaw);
    final DateTime? toDate;
    if (_isPresent(p.toDateRaw)) {
      toDate = null;
    } else {
      toDate = tryParse(p.toDateRaw);
    }
    return p.copyWith(duration: durationStr, toDate: toDate);
  }
}
