import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../repositories/employee_repository.dart';

/// कर्मचारी प्रोवाइडर - Provider State Management
///
/// Single source of truth for the UI. Wraps [EmployeeRepository] and
/// exposes:
///   • loading state machine
///   • search query + results
///   • selected employee's full [EmployeeProfile] (typed aggregate)
///   • dashboard counts (delegated to repository, cached)
class EmployeeProvider extends ChangeNotifier {
  final EmployeeRepository _repository;

  // Loading state
  bool _isLoading = false;
  bool _isSearching = false;
  bool _isInitialLoadDone = false;
  String _error = '';

  // Search state
  String _searchQuery = '';
  List<Employee> _searchResults = [];
  List<Employee> _filteredResults = [];

  // Selected employee + typed profile aggregate
  Employee? _selectedEmployee;
  EmployeeProfile? _selectedProfile;

  EmployeeProvider() : _repository = EmployeeRepository();

  // ──────────────────────────────────────────────
  //  Getters — loading
  // ──────────────────────────────────────────────
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  bool get isInitialLoadDone => _isInitialLoadDone;
  String get error => _error;

  // ──────────────────────────────────────────────
  //  Getters — search
  // ──────────────────────────────────────────────
  String get searchQuery => _searchQuery;
  List<Employee> get searchResults => _searchResults;
  List<Employee> get filteredResults => _filteredResults;

  // ──────────────────────────────────────────────
  //  Getters — selected
  // ──────────────────────────────────────────────
  Employee? get selectedEmployee => _selectedEmployee;
  EmployeeProfile? get selectedProfile => _selectedProfile;

  // Convenience accessors for backward compatibility with old UI code
  List<Aagman> get employeeAagman => _selectedProfile?.aagman ?? const [];
  List<Prasthan> get employeePrasthan => _selectedProfile?.prasthan ?? const [];
  List<Hob> get employeeHob => _selectedProfile?.allHob ?? const [];
  List<BasicPay> get employeeBasicPayList =>
      _selectedProfile?.basicPay ?? const [];
  BasicPay? get employeeBasicPay =>
      _selectedProfile?.basicPay.isNotEmpty == true
          ? _selectedProfile!.basicPay.first
          : null;
  List<Relation> get employeeRelations =>
      _selectedProfile?.relations ?? const [];

  // ──────────────────────────────────────────────
  //  Dashboard getters (delegated to repo, cached)
  // ──────────────────────────────────────────────
  int get totalEmployees => _repository.totalEmployees;
  int get activeEmployees => _repository.activeEmployees;
  int get inactiveEmployees => _repository.inactiveEmployees;
  int get hccpCount => _repository.hccpCount;
  int get lhccpCount => _repository.lhccpCount;
  int get aagmanCount => _repository.aagmanCount;
  int get prasthanCount => _repository.prasthanCount;
  int get hobCount => _repository.hobCount;
  Map<String, int> get classification => _repository.classification;

  int get aagmanDgCount => _repository.aagmanDgCount;
  int get aagmanBjdCount => _repository.aagmanBjdCount;
  int get aagmanBrCount => _repository.aagmanBrCount;
  int get prasthanDgCount => _repository.prasthanDgCount;
  int get prasthanBjdCount => _repository.prasthanBjdCount;
  int get prasthanBrCount => _repository.prasthanBrCount;

  // ──────────────────────────────────────────────
  //  Data loading
  // ──────────────────────────────────────────────

  Future<void> loadAllData({bool forceRefresh = false}) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // Phase 1: essential sheets (ALL + EXTRA) for instant dashboard.
      // Wrapped in an overall safety timeout so the loading screen
      // NEVER hangs forever — even if CORS blocks HTTP and JSONP
      // both fail silently on web, the user sees an error + retry.
      await _repository.loadEssentialData(forceRefresh: forceRefresh)
          .timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw TimeoutException(
            'डेटा लोड टाइमआउट — इंटरनेट कनेक्शन जाँचें',
          );
        },
      );
      _isInitialLoadDone = true;
      _isLoading = false;
      notifyListeners();

      // Phase 2: remaining sheets in background.
      //
      // IMPORTANT: we `await` Phase 2 (instead of fire-and-forget) and
      // call `notifyListeners()` when it finishes. Previously Phase 2 was
      // unawaited and the UI never knew when sub-sheet data (aagman /
      // prasthan / hob / basicpay / sambadh) became available, so newly
      // added/edited rows in those sheets would NOT appear without an
      // app restart. Now the UI re-renders as soon as the refresh is
      // actually complete.
      try {
        await _repository.loadRemainingData(forceRefresh: forceRefresh);
      } catch (_) {
        // Background load failure — dashboard is already visible.
        // Sub-sheet data (aagman, prasthan, etc.) will just be empty.
      }
      notifyListeners();
    } catch (e) {
      _error = 'डेटा लोड करने में त्रुटि: ${e.toString()}';
      _isInitialLoadDone = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshInBackground() async {
    try {
      await _repository.refreshInBackground();
      notifyListeners();
    } catch (_) {}
  }

  // ──────────────────────────────────────────────
  //  Search — partial + case-insensitive on PNO / Badge / Name.
  // ──────────────────────────────────────────────

  void searchEmployee(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      _searchQuery = '';
      _searchResults = [];
      _filteredResults = [];
      _selectedEmployee = null;
      notifyListeners();
      return;
    }

    _searchQuery = trimmed;
    _error = '';
    _searchResults = _repository.searchEmployee(trimmed);
    _filteredResults = List.from(_searchResults);
    notifyListeners();
  }

  /// Field-specific search: 'pno' or 'badge'.
  /// Used by dashboard smart search (5+ digits → PNO, 1-4 digits → badge).
  void searchEmployeeByField(String query, String field) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      searchEmployee('');
      return;
    }

    _searchQuery = trimmed;
    _error = '';

    final all = _repository.getAllEmployees();
    _searchResults = all.where((emp) {
      final value = field == 'badge'
          ? emp.badgeNumber.replaceAll('.0', '').trim()
          : emp.pno.replaceAll('.0', '').trim();
      return value.contains(trimmed);
    }).toList();

    _filteredResults = List.from(_searchResults);
    notifyListeners();
  }

  /// Filter transfer records by order-number prefix (DG/BJD/BR).
  /// Used by the TransferClassificationPage.
  List<dynamic> getTransferRecordsByOrderPrefix(String prefix, bool isAagman) {
    final records =
        isAagman ? _repository.getValidAagman() : _repository.getValidPrasthan();
    return records.where((record) {
      if (record is Aagman) return record.orderNumber.startsWith(prefix);
      if (record is Prasthan) return record.orderNumber.startsWith(prefix);
      return false;
    }).toList();
  }

  void filterSearchResults({
    String? sourceSheet,
    String? status,
    String? post,
  }) {
    _filteredResults = _searchResults.where((emp) {
      if (sourceSheet != null && emp.sourceSheet != sourceSheet) return false;
      if (status != null && emp.status != status) return false;
      if (post != null &&
          !emp.post.toLowerCase().contains(post.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();
    notifyListeners();
  }

  void filterByAagmanCategory(String category) {
    final aagmanEmployees = _repository
        .getAllAagman()
        .where((a) => _repository.getStarCategory(a.orderNumber) == category)
        .map((a) => a.pno)
        .toSet();
    _filteredResults =
        _searchResults.where((emp) => aagmanEmployees.contains(emp.pno)).toList();
    notifyListeners();
  }

  void filterByPrasthanCategory(String category) {
    final prasthanEmployees = _repository
        .getAllPrasthan()
        .where((p) => _repository.getStarCategory(p.orderNumber) == category)
        .map((p) => p.pno)
        .toSet();
    _filteredResults = _searchResults
        .where((emp) => prasthanEmployees.contains(emp.pno))
        .toList();
    notifyListeners();
  }

  // ──────────────────────────────────────────────
  //  Employee selection (PNO-keyed, returns typed profile)
  // ──────────────────────────────────────────────

  Future<void> selectEmployee(Employee employee) async {
    _selectedEmployee = employee;
    _selectedProfile = null;
    _isSearching = true;
    notifyListeners();

    try {
      // Ensure sub-sheets are loaded. loadRemainingData is idempotent —
      // its internal guard prevents re-fetching sheets that are already
      // cached. Do NOT call loadAllData here — that would re-fetch ALL
      // + EXTRA unnecessarily (regression we're fixing).
      await _repository.loadRemainingData();

      // Build typed profile aggregate (sync, in-memory after cache hit).
      _selectedProfile = _repository.getEmployeeProfile(employee.pno);
    } catch (e) {
      _error = 'विवरण लोड करने में त्रुटि: ${e.toString()}';
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  void clearSelection() {
    _selectedEmployee = null;
    _selectedProfile = null;
    _searchResults = [];
    _filteredResults = [];
    _searchQuery = '';
    _error = '';
    notifyListeners();
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }

  Future<void> forceReload() async {
    await loadAllData(forceRefresh: true);
  }

  /// Get all employees (for profile navigation between siblings).
  List<Employee> getAllEmployees() => _repository.getAllEmployees();
}