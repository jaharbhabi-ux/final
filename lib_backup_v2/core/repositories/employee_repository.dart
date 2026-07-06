import 'package:flutter/foundation.dart' show kDebugMode;

import '../models/models.dart';
import '../services/employee_api.dart';
import '../services/gsheet_api_adapter.dart';
import '../services/gas_employee_api.dart';
import '../services/csv_cache_service.dart';
import '../utils/duration_calculator.dart';
import '../constants/app_constants.dart';

/// कर्मचारी रिपॉजिटरी - Repository Pattern
///
/// PNO is the master key. All joins use PNO. Badge Number is never used
/// internally — only the search path accepts it as a search term.
///
/// Backend-agnostic: depends on the [EmployeeApi] abstraction. The
/// concrete implementation ([GSheetApiAdapter] today, [GasEmployeeApi]
/// tomorrow) is injected via the constructor. Swapping backends is a
/// one-line DI change.
///
/// Caching strategy:
///   • Raw sheet maps live in [CsvCacheService] (1-hour TTL).
///   • Parsed model lists are cached here per-sheet and invalidated only
///     when the underlying sheet is refetched. This eliminates the
///     "re-parse entire sheet on every profile open" hot path.
///   • Per-PNO aggregations are NOT cached (cheap to assemble from
///     already-cached parsed lists).
class EmployeeRepository {
  final EmployeeApi _api;
  final CsvCacheService _cache;

  // Parsed-list caches — one per sheet. Null = stale / never built.
  List<Employee>? _cachedAllEmployees;
  List<Aagman>? _cachedAagman;
  List<Prasthan>? _cachedPrasthan;
  List<Hob>? _cachedHob2025;
  List<Hob>? _cachedHob2026;
  List<BasicPay>? _cachedBasicPay;
  List<Relation>? _cachedRelations;

  /// Default constructor — uses [GSheetApiAdapter] (live Google Sheets
  /// CSV export). Pass [api] to swap to [GasEmployeeApi] or a mock.
  EmployeeRepository({
    EmployeeApi? api,
    CsvCacheService? cache,
  })  : _api = api ?? GSheetApiAdapter(),
        _cache = cache ?? CsvCacheService();

  // Backward-compatible constructor aliases (preserve old call sites).
  factory EmployeeRepository.withGSheet({
    GSheetApiAdapter? adapter,
    CsvCacheService? cache,
  }) {
    return EmployeeRepository(api: adapter ?? GSheetApiAdapter(), cache: cache);
  }

  factory EmployeeRepository.withGas({
    GasEmployeeApi? api,
    CsvCacheService? cache,
  }) {
    return EmployeeRepository(api: api ?? GasEmployeeApi(), cache: cache);
  }

  // ──────────────────────────────────────────────
  //  Cache invalidation
  // ──────────────────────────────────────────────
  void _invalidateAll() {
    _cachedAllEmployees = null;
    _cachedAagman = null;
    _cachedPrasthan = null;
    _cachedHob2025 = null;
    _cachedHob2026 = null;
    _cachedBasicPay = null;
    _cachedRelations = null;
  }

  // ──────────────────────────────────────────────
  //  Data Loading
  // ──────────────────────────────────────────────

  /// Load every sheet in parallel. Use [loadEssentialData] +
  /// [loadRemainingData] for the recommended two-phase load.
  Future<void> loadAllData({bool forceRefresh = false}) async {
    if (!forceRefresh && _cache.isValid) return;

    // Fire all 8 fetches in parallel via the API abstraction.
    final results = await Future.wait([
      _api.fetchAllActive(),
      _api.fetchAllInactive(),
      _api.fetchAllArrivals(),
      _api.fetchAllDepartures(),
      _api.fetchHob(2025),
      _api.fetchHob(2026),
      _api.fetchAllBasicPay(),
      _api.fetchAllRelations(),
    ]);

    final rawData = {
      AppConstants.sheetAll: results[0],
      AppConstants.sheetExtra: results[1],
      AppConstants.sheetAagman: results[2],
      AppConstants.sheetPrasthan: results[3],
      AppConstants.sheetHob2025: results[4],
      AppConstants.sheetHob2026: results[5],
      AppConstants.sheetBasicPay: results[6],
      AppConstants.sheetSambadh: results[7],
    };
    _cache.setData(_dropPlaceholderSheets(rawData));
    _invalidateAll();
  }

  /// Phase 1: fetch ALL + EXTRA only — enough for dashboard + search.
  ///
  /// IMPORTANT: uses `CsvCacheService.merge()` (NOT `setData()`) so that
  /// previously-loaded sub-sheets (aagman / prasthan / hob / basicpay /
  /// sambadh) are NOT wiped while the essential sheets refresh. Wiping
  /// them here was the root cause of "newly added/edited sheet data not
  /// appearing" — Phase 2 runs in the background without a
  /// `notifyListeners()` call, so the UI was left looking at an empty
  /// sub-sheet cache until the next manual refresh.
  Future<void> loadEssentialData({bool forceRefresh = false}) async {
    if (!forceRefresh && _cache.isValid && _cachedAllEmployees != null) return;

    final results = await Future.wait([
      _api.fetchAllActive(),
      _api.fetchAllInactive(),
    ]);
    _cache.merge({
      AppConstants.sheetAll: results[0],
      AppConstants.sheetExtra: results[1],
    });
    _cachedAllEmployees = null; // only essential cache is stale
  }

  /// Phase 2: fetch remaining sheets in the background.
  Future<void> loadRemainingData({bool forceRefresh = false}) async {
    final remaining = [
      AppConstants.sheetAagman,
      AppConstants.sheetPrasthan,
      AppConstants.sheetHob2025,
      AppConstants.sheetHob2026,
      AppConstants.sheetBasicPay,
      AppConstants.sheetSambadh,
    ];

    final alreadyPresent = remaining.every((name) {
      if (AppConstants.placeholderSheets.contains(name)) return true;
      return _cache.get(name).isNotEmpty;
    });
    if (!forceRefresh && alreadyPresent && _cache.isValid) return;

    // Fetch each remaining sheet via the API abstraction.
    // Sambadh is skipped at the API layer if its GID is still placeholder.
    final fetches = <Future<MapEntry<String, List<Map<String, dynamic>>>>>[
      _api.fetchAllArrivals().then((d) => MapEntry(AppConstants.sheetAagman, d)),
      _api.fetchAllDepartures().then((d) => MapEntry(AppConstants.sheetPrasthan, d)),
      _api.fetchHob(2025).then((d) => MapEntry(AppConstants.sheetHob2025, d)),
      _api.fetchHob(2026).then((d) => MapEntry(AppConstants.sheetHob2026, d)),
      _api.fetchAllBasicPay().then((d) => MapEntry(AppConstants.sheetBasicPay, d)),
      _api.fetchAllRelations().then((d) => MapEntry(AppConstants.sheetSambadh, d)),
    ];

    final results = await Future.wait(fetches);
    for (final entry in results) {
      if (entry.value.isEmpty &&
          AppConstants.placeholderSheets.contains(entry.key)) continue;
      _cache.setPartialData({entry.key: entry.value});
    }
    // Invalidate only the sub-sheet caches, keep ALL+EXTRA intact.
    _cachedAagman = null;
    _cachedPrasthan = null;
    _cachedHob2025 = null;
    _cachedHob2026 = null;
    _cachedBasicPay = null;
    _cachedRelations = null;
  }

  /// Strip placeholder sheets from a raw fetch result so they don't
  /// pollute the cache with empty lists.
  Map<String, List<Map<String, dynamic>>> _dropPlaceholderSheets(
      Map<String, List<Map<String, dynamic>>> input) {
    return Map.fromEntries(input.entries.where(
        (e) => !AppConstants.placeholderSheets.contains(e.key)));
  }

  // ──────────────────────────────────────────────
  //  Search — partial + case-insensitive on PNO, Badge, Name.
  // ──────────────────────────────────────────────

  /// Synchronous in-memory search. Partial match on PNO, Badge, Name.
  /// Case-insensitive. Whitespace-normalized for robustness.
  List<Employee> searchEmployee(String query) {
    final q = _normalize(query);
    if (q.isEmpty) return [];

    return _getAllEmployees().where((emp) {
      final pno = _normalize(emp.pno);
      final badge = _normalize(emp.badgeNumber);
      final name = _normalize(emp.name);
      // Partial contains on all three fields.
      return pno.contains(q) || badge.contains(q) || name.contains(q);
    }).toList();
  }

  // ──────────────────────────────────────────────
  //  Employee aggregation (PNO-keyed)
  // ──────────────────────────────────────────────

  /// Build the full profile aggregate for a PNO. Returns null if PNO
  /// not found in either ALL or EXTRA sheet.
  EmployeeProfile? getEmployeeProfile(String pno) {
    final cleanPno = _normalize(pno);
    if (cleanPno.isEmpty) return null;

    final employee = _getAllEmployees().firstWhere(
      (e) => _normalize(e.pno) == cleanPno,
      orElse: () => Employee(pno: '', badgeNumber: '', name: ''),
    );
    if (employee.pno.isEmpty) return null;

    return EmployeeProfile(
      employee: employee,
      aagman: _getAagmanForEmployee(cleanPno),
      prasthan: _getPrasthanForEmployee(cleanPno),
      hob2025: _getHob2025ForEmployee(cleanPno),
      hob2026: _getHob2026ForEmployee(cleanPno),
      basicPay: _getBasicPayForEmployee(cleanPno),
      relations: _getRelationsForEmployee(cleanPno),
      previousPostings: _parsePreviousPostings(employee),
    );
  }

  /// Backward-compatible API: returns the same Map shape the old
  /// provider consumed. Prefer [getEmployeeProfile] going forward.
  @Deprecated('Use getEmployeeProfile() instead. Kept for transition.')
  Map<String, dynamic> getEmployeeDetails(String pno) {
    final profile = getEmployeeProfile(pno);
    if (profile == null) {
      return const {
        'aagman': <Aagman>[],
        'prasthan': <Prasthan>[],
        'hob': <Hob>[],
        'basicPay': <BasicPay>[],
        'relations': <Relation>[],
      };
    }
    return {
      'aagman': profile.aagman,
      'prasthan': profile.prasthan,
      'hob': [...profile.hob2025, ...profile.hob2026],
      'basicPay': profile.basicPay,
      'relations': profile.relations,
    };
  }

  // ──────────────────────────────────────────────
  //  Dashboard counts
  // ──────────────────────────────────────────────

  List<Employee> getAllEmployees() => _getAllEmployees();

  /// ALL sheet employees only — used for HCCP/LHCCP counting.
  /// NEVER mixes with EXTRA.
  List<Employee> getAllSheetEmployees() {
    return _getAllEmployees()
        .where((e) => e.sourceSheet == AppConstants.sheetAll)
        .toList();
  }

  /// Total employees = ALL sheet only.
  int get totalEmployees =>
      _getAllEmployees().where((e) => e.isActive).length;

  int get activeEmployees =>
      _getAllEmployees().where((e) => e.isActive).length;

  int get inactiveEmployees =>
      _getAllEmployees().where((e) => !e.isActive).length;

  /// HCCP count from ALL sheet only.
  int get hccpCount {
    int count = 0;
    for (final e in getAllSheetEmployees()) {
      final post = e.post.trim().toUpperCase();
      if (post == 'HCCP' || post == 'मुख्य आरक्षी नागरिक पुलिस') count++;
    }
    return count;
  }

  /// LHCCP count from ALL sheet only.
  int get lhccpCount {
    int count = 0;
    for (final e in getAllSheetEmployees()) {
      final post = e.post.trim().toUpperCase();
      if (post == 'LHCCP' || post == 'महिला मुख्य आरक्षी नागरिक पुलिस') count++;
    }
    return count;
  }

  /// Classification breakdown — `Map<designation, count>` from ALL sheet.
  /// Used by the dashboard classification panel.
  Map<String, int> get classification {
    final out = <String, int>{};
    for (final e in getAllSheetEmployees()) {
      final key = e.post.trim().isEmpty ? 'अन्य' : e.post.trim();
      out[key] = (out[key] ?? 0) + 1;
    }
    return out;
  }

  /// Aagman rows only up to the first row with empty serialNo.
  /// Used by all dashboard counts + classification filters so
  /// archived sections (which sit past a blank row in the source
  /// sheet) don't inflate the numbers.
  List<Aagman> getValidAagman() {
    final all = getAllAagman();
    final out = <Aagman>[];
    for (final a in all) {
      if (a.serialNo.trim().isEmpty) break;
      out.add(a);
    }
    return out;
  }

  /// Prasthan rows only up to the first row with empty serialNo.
  List<Prasthan> getValidPrasthan() {
    final all = getAllPrasthan();
    final out = <Prasthan>[];
    for (final p in all) {
      if (p.serialNo.trim().isEmpty) break;
      out.add(p);
    }
    return out;
  }
  int get aagmanCount => getValidAagman().length;
  int get prasthanCount => getValidPrasthan().length;
  int get hobCount => _getAllHob2025().length + _getAllHob2026().length;

  // Star-category counts (DG/BJD/BR prefix on order number)
  int get aagmanDgCount => getValidAagman()
      .where((a) => getStarCategory(a.orderNumber) == 'मुख्यालय')
      .length;
  int get aagmanBjdCount => getValidAagman()
      .where((a) => getStarCategory(a.orderNumber) == 'ज़ोन')
      .length;
  int get aagmanBrCount => getValidAagman()
      .where((a) => getStarCategory(a.orderNumber) == 'परिक्षेत्र')
      .length;
  int get prasthanDgCount => getValidPrasthan()
      .where((p) => getStarCategory(p.orderNumber) == 'मुख्यालय')
      .length;
  int get prasthanBjdCount => getValidPrasthan()
      .where((p) => getStarCategory(p.orderNumber) == 'ज़ोन')
      .length;
  int get prasthanBrCount => getValidPrasthan()
      .where((p) => getStarCategory(p.orderNumber) == 'परिक्षेत्र')
      .length;

  // ──────────────────────────────────────────────
  //  Background refresh
  // ──────────────────────────────────────────────

  Future<void> refreshInBackground() async {
    try {
      await loadAllData(forceRefresh: true);
    } catch (_) {
      // Silent — background refresh should never crash the UI.
    }
  }

  // ──────────────────────────────────────────────
  //  Public accessors for parsed sub-sheet lists (cached).
  //  Exposed so the TransferClassificationPage can read them without
  //  re-parsing.
  //
  //  NOTE: For Aagman / Prasthan, only rows up to the FIRST COMPLETE
  //  BLANK LINE are returned. The source Google Sheet has multiple
  //  sections separated by blank rows (Table 1 → blank → Table 2 → …);
  //  only the first section is the live data. Subsequent sections are
  //  archived / supplementary and should NOT inflate dashboard counts
  //  or appear in the Transfer Classification list.
  // ──────────────────────────────────────────────

  /// Trims a raw sheet's row list to the first contiguous block of
  /// non-empty rows. A "complete blank line" is a row where every
  /// cell value is empty after trimming. The first such blank row
  /// terminates the section; everything after it is dropped.
  ///
  /// Leading blank rows (if any) are also skipped so we always start
  /// from the first real data row.
  static List<Map<String, dynamic>> _takeUntilFirstBlankRow(
      List<Map<String, dynamic>> rows) {
    final out = <Map<String, dynamic>>[];
    bool foundData = false;
    for (final row in rows) {
      final values = row.values;
      final bool isEmpty =
          values.isEmpty || values.every((v) => v == null || v.toString().trim().isEmpty);
      if (isEmpty) {
        if (foundData) {
          // We've already seen real data and now hit a complete blank
          // line → stop. Everything beyond is a different section.
          break;
        }
        // Leading blank row — skip.
        continue;
      }
      foundData = true;
      out.add(row);
    }
    return out;
  }

  List<Aagman> getAllAagman() {
    if (_cachedAagman != null) return _cachedAagman!;
    final rawData = _cache.get(AppConstants.sheetAagman);
    // Only consider the first section (up to first complete blank line).
    final data = _takeUntilFirstBlankRow(rawData);
    _cachedAagman = data
        .map((e) => Aagman.fromMap(e))
        .where((a) => a.pno.isNotEmpty || a.orderNumber.isNotEmpty)
        .toList();
    return _cachedAagman!;
  }

  List<Prasthan> getAllPrasthan() {
    if (_cachedPrasthan != null) return _cachedPrasthan!;
    final rawData = _cache.get(AppConstants.sheetPrasthan);
    // Only consider the first section (up to first complete blank line).
    final data = _takeUntilFirstBlankRow(rawData);
    _cachedPrasthan = data
        .map((e) => Prasthan.fromMap(e))
        .where((p) => p.pno.isNotEmpty || p.orderNumber.isNotEmpty)
        .toList();
    return _cachedPrasthan!;
  }

  List<Hob> getAllHob2025() => _getAllHob2025();
  List<Hob> getAllHob2026() => _getAllHob2026();

  List<BasicPay> getAllBasicPay() {
    if (_cachedBasicPay != null) return _cachedBasicPay!;
    final data = _cache.get(AppConstants.sheetBasicPay);
    _cachedBasicPay = data
        .map((e) => BasicPay.fromMap(e))
        .where((b) => b.pno.isNotEmpty)
        .toList();
    return _cachedBasicPay!;
  }

  List<Relation> getAllRelations() {
    if (_cachedRelations != null) return _cachedRelations!;
    final data = _cache.get(AppConstants.sheetSambadh);
    _cachedRelations = data
        .map((e) => Relation.fromMap(e))
        .where((r) => r.pno.isNotEmpty)
        .toList();
    return _cachedRelations!;
  }

  // ──────────────────────────────────────────────
  //  Star classification (DG / BJD / BR prefix on order number)
  // ──────────────────────────────────────────────

  String getStarCategory(String orderNumber) {
    final o = orderNumber.trim().toUpperCase();
    if (o.startsWith('डीजी-')) return 'मुख्यालय';
    if (o.startsWith('बीजैड-')) return 'ज़ोन';
    if (o.startsWith('बीआर-')) return 'परिक्षेत्र';
    return 'अन्य';
  }

  // ──────────────────────────────────────────────
  //  Private helpers
  // ──────────────────────────────────────────────

  List<Employee> _getAllEmployees() {
    if (_cachedAllEmployees != null) return _cachedAllEmployees!;

    final all = _cache.get(AppConstants.sheetAll);
    final extra = _cache.get(AppConstants.sheetExtra);

    if (kDebugMode) {
      print('R1: ALL sheet rows=${all.length}, EXTRA sheet rows=${extra.length}');
    }

    _cachedAllEmployees = [
      ..._mapToEmployees(all, AppConstants.sheetAll, AppConstants.statusActive),
      ..._mapToEmployees(
          extra, AppConstants.sheetExtra, AppConstants.statusInactive),
    ];
    return _cachedAllEmployees!;
  }

  List<Hob> _getAllHob2025() {
    if (_cachedHob2025 != null) return _cachedHob2025!;
    final data = _cache.get(AppConstants.sheetHob2025);
    _cachedHob2025 = data
        .map((e) => Hob.fromMap(e))
        .where((h) => h.pno.isNotEmpty || (h.hobNumber.isNotEmpty && h.date.isNotEmpty))
        .toList();
    return _cachedHob2025!;
  }

  List<Hob> _getAllHob2026() {
    if (_cachedHob2026 != null) return _cachedHob2026!;
    final data = _cache.get(AppConstants.sheetHob2026);
    _cachedHob2026 = data
        .map((e) => Hob.fromMap(e))
        .where((h) => h.pno.isNotEmpty || (h.hobNumber.isNotEmpty && h.date.isNotEmpty))
        .toList();
    return _cachedHob2026!;
  }

  List<Aagman> _getAagmanForEmployee(String cleanPno) =>
      getAllAagman().where((a) => _normalize(a.pno) == cleanPno).toList();

  List<Prasthan> _getPrasthanForEmployee(String cleanPno) =>
      getAllPrasthan().where((p) => _normalize(p.pno) == cleanPno).toList();

  List<Hob> _getHob2025ForEmployee(String cleanPno) =>
      _getAllHob2025().where((h) => _normalize(h.pno) == cleanPno).toList();

  List<Hob> _getHob2026ForEmployee(String cleanPno) =>
      _getAllHob2026().where((h) => _normalize(h.pno) == cleanPno).toList();

  List<BasicPay> _getBasicPayForEmployee(String cleanPno) =>
      getAllBasicPay().where((b) => _normalize(b.pno) == cleanPno).toList();

  List<Relation> _getRelationsForEmployee(String cleanPno) =>
      getAllRelations().where((r) => _normalize(r.pno) == cleanPno).toList();

  /// Parse the multiline `previousPostings` cell on the employee row
  /// into a typed [List<PreviousPosting>], with auto-duration computed
  /// via [DurationCalculator]. Honors "वर्तमान / से लगातार / Present" sentinels.
  List<PreviousPosting> _parsePreviousPostings(Employee employee) {
    final raw = employee.previousPostings;
    final parsed = PreviousPosting.parseCell(
      pno: employee.pno,
      cellValue: raw,
    );
    // If the multiline cell was empty, fall back to the standalone
    // कब से / कब तक columns (single-row case).
    if (parsed.isEmpty &&
        (employee.fromDate.isNotEmpty || employee.toDate.isNotEmpty)) {
      final fallback = <PreviousPosting>[
        PreviousPosting(
          pno: employee.pno,
          location: employee.currentPosting,
          fromDateRaw: employee.fromDate,
          toDateRaw: employee.toDate,
        ),
      ];
      return fallback
          .map(DurationCalculator.withComputedDuration)
          .toList(growable: false);
    }
    return parsed
        .map(DurationCalculator.withComputedDuration)
        .toList(growable: false);
  }

  /// Map raw sheet rows to Employee instances. Tags each row with its
  /// source sheet + active/inactive status. Does NOT silently fall back
  /// to positional column indices — if the Hindi header is missing, the
  /// field stays empty (fail-safe, not fail-silent).
  List<Employee> _mapToEmployees(
    List<Map<String, dynamic>> rows,
    String sourceSheet,
    String status,
  ) {
    final out = <Employee>[];
    for (final row in rows) {
      // Skip rows that have no PNO AND no Name AND no Badge — they're
      // empty sheet rows, not real employees.
      final pno = _clean(row[AppConstants.keyPno]);
      final name = (row[AppConstants.keyName]?.toString() ?? '').trim();
      final badge = _clean(row[AppConstants.keyBadge]);
      if (pno.isEmpty && name.isEmpty && badge.isEmpty) continue;

      final tagged = Map<String, dynamic>.from(row);
      tagged[AppConstants.tagSourceSheet] = sourceSheet;
      tagged[AppConstants.tagStatus] = status;

      out.add(Employee.fromMap(tagged));
    }
    return out;
  }

  /// Whitespace-strip + lowercase. Used for PNO / Badge / Name comparison.
  /// Lowercasing is safe because PNOs are numeric and Badge Numbers are
  /// documented as case-insensitive in the field.
  static String _normalize(dynamic value) {
    return value
            ?.toString()
            .replaceAll('.0', '')
            .replaceAll(RegExp(r'\s+'), '')
            .toLowerCase()
            .trim() ??
        '';
  }

  /// Whitespace-strip only (no lowercase). Used when reading raw sheet
  /// values for tagging.
  static String _clean(dynamic value) {
    return value
            ?.toString()
            .replaceAll('.0', '')
            .replaceAll(RegExp(r'\s+'), '')
            .trim() ??
        '';
  }
}

/// Aggregate root — one per PNO. Returned by [getEmployeeProfile].
/// The profile screen consumes this single object instead of unpacking
/// a Map<String, dynamic>.
class EmployeeProfile {
  final Employee employee;
  final List<Aagman> aagman;
  final List<Prasthan> prasthan;
  final List<Hob> hob2025;
  final List<Hob> hob2026;
  final List<BasicPay> basicPay;
  final List<Relation> relations;
  final List<PreviousPosting> previousPostings;

  const EmployeeProfile({
    required this.employee,
    this.aagman = const [],
    this.prasthan = const [],
    this.hob2025 = const [],
    this.hob2026 = const [],
    this.basicPay = const [],
    this.relations = const [],
    this.previousPostings = const [],
  });

  /// Combined HOB list (2025 first, then 2026) for display.
  List<Hob> get allHob => [...hob2025, ...hob2026];

  /// Combined transfer-like list (Aagman = arrival, Prasthan = departure),
  /// wrapped as [TransferRecord] for type safety. Newest first by
  /// orderNumber (lexicographic — order number embeds the date).
  List<TransferRecord> get transfers {
    final out = <TransferRecord>[
      for (final a in aagman) TransferRecord.fromAagman(a),
      for (final p in prasthan) TransferRecord.fromPrasthan(p),
    ];
    out.sort((a, b) => b.orderNumber.compareTo(a.orderNumber));
    return out;
  }
}
