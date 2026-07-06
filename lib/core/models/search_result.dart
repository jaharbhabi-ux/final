/// Search result wrapper — captures the query, the matched employees,
/// and per-employee match metadata (which field matched). Returned by
/// the repository's search API in addition to the plain list getter.
class SearchResult {
  final String query;
  final List<SearchMatch> matches;

  /// Wall-clock duration of the search (for debug / telemetry).
  final Duration searchDuration;

  const SearchResult({
    required this.query,
    this.matches = const [],
    this.searchDuration = Duration.zero,
  });

  int get totalCount => matches.length;

  factory SearchResult.empty(String query) =>
      SearchResult(query: query, matches: const [], searchDuration: Duration.zero);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchResult &&
          other.query == query &&
          _listEquals(other.matches, matches);

  @override
  int get hashCode => Object.hash(query, Object.hashAll(matches));

  static bool _listEquals(List<SearchMatch> a, List<SearchMatch> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// One match inside a [SearchResult]. Carries the matched employee plus
/// which field triggered the match — the UI can highlight the right
/// field on the card.
class SearchMatch {
  final String pno;
  final String name;
  final String badgeNumber;
  final String post;
  final bool isActive;

  /// Which field matched: 'pno', 'badgeNumber', or 'name'.
  final String matchedField;

  /// The substring that matched (lowercased original).
  final String matchedValue;

  const SearchMatch({
    required this.pno,
    required this.name,
    required this.badgeNumber,
    required this.post,
    required this.isActive,
    required this.matchedField,
    required this.matchedValue,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchMatch &&
          other.pno == pno &&
          other.matchedField == matchedField &&
          other.matchedValue == matchedValue;

  @override
  int get hashCode => Object.hash(pno, matchedField, matchedValue);
}
