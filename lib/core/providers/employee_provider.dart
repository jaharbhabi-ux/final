import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../repositories/employee_repository.dart';

/// Employee Provider - Provider State Management
///
/// DEBUG VERSION: adds comprehensive search logging so we can see
/// exactly why PNO search fails but badge search succeeds.
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

      try {
        await _repository.loadRemainingData(forceRefresh: forceRefresh);
      } catch (_) {}
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
  ///
  /// DEBUG: prints comprehensive info about what's being searched and
  /// what's found, so we can diagnose the "PNO search fails but badge
  /// search works" issue.
  void searchEmployeeByField(String query, String field) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      searchEmployee('');
      return;
    }

    _searchQuery = trimmed;
    _error = '';

    final all = _repository.getAllEmployees();

    if (kDebugMode) {
      print('');
      print('═══════════════════════════════════════════════════════════════');
      print('[SEARCH-DEBUG] field=$field  query=^$trimmed^  totalEmployees=${all.length}');
      print('═══════════════════════════════════════════════════════════════');

      // Count employees with empty PNO / empty badge
      final emptyPno = all.where((e) => e.pno.trim().isEmpty).length;
      final emptyBadge = all.where((e) => e.badgeNumber.trim().isEmpty).length;
      print('[SEARCH-DEBUG] Employees with EMPTY pno: $emptyPno / ${all.length}');
      print('[SEARCH-DEBUG] Employees with EMPTY badge: $emptyBadge / ${all.length}');

      // If searching by PNO, also try badge — and vice versa — for cross-check
      if (field == 'pno') {
        final pnoMatches = all.where((emp) {
          final v = emp.pno.replaceAll('.0', '').trim();
          return v.contains(trimmed);
        }).toList();
        final badgeMatches = all.where((emp) {
          final v = emp.badgeNumber.replaceAll('.0', '').trim();
          return v.contains(trimmed);
        }).toList();
        print('[SEARCH-DEBUG] PNO contains "$trimmed": ${pnoMatches.length} matches');
        print('[SEARCH-DEBUG] Badge contains "$trimmed": ${badgeMatches.length} matches (cross-check)');

        // Show first 3 PNO matches
        for (int i = 0; i < pnoMatches.length && i < 3; i++) {
          final e = pnoMatches[i];
          print('[SEARCH-DEBUG]   PNO match[$i]: pno=^${e.pno}^ badge=^${e.badgeNumber}^ name=^${e.name}^');
        }
        // Show first 3 badge matches (cross-check)
        for (int i = 0; i < badgeMatches.length && i < 3; i++) {
          final e = badgeMatches[i];
          print('[SEARCH-DEBUG]   Badge match[$i]: pno=^${e.pno}^ badge=^${e.badgeNumber}^ name=^${e.name}^');
        }
      } else if (field == 'badge') {
        final badgeMatches = all.where((emp) {
          final v = emp.badgeNumber.replaceAll('.0', '').trim();
          return v.contains(trimmed);
        }).toList();
        final pnoMatches = all.where((emp) {
          final v = emp.pno.replaceAll('.0', '').trim();
          return v.contains(trimmed);
        }).toList();
        print('[SEARCH-DEBUG] Badge contains "$trimmed": ${badgeMatches.length} matches');
        print('[SEARCH-DEBUG] PNO contains "$trimmed": ${pnoMatches.length} matches (cross-check)');

        for (int i = 0; i < badgeMatches.length && i < 3; i++) {
          final e = badgeMatches[i];
          print('[SEARCH-DEBUG]   Badge match[$i]: pno=^${e.pno}^ badge=^${e.badgeNumber}^ name=^${e.name}^');
        }
      }

      // SPECIAL: if query is 112512734, find Sachin by name
      if (trimmed == '112512734' || trimmed == '679') {
        final sachinByName = all.where((e) => e.name.contains('सचिन कुमार')).toList();
        print('[SEARCH-DEBUG] Sachin by name "सचिन कुमार": ${sachinByName.length} matches');
        for (int i = 0; i < sachinByName.length && i < 5; i++) {
          final e = sachinByName[i];
          print('[SEARCH-DEBUG]   Sachin[$i]: pno=^${e.pno}^ badge=^${e.badgeNumber}^ name=^${e.name}^');
        }
      }

      print('═══════════════════════════════════════════════════════════════');
      print('');
    }

    _searchResults = all.where((emp) {
      final value = field == 'badge'
          ? emp.badgeNumber.replaceAll('.0', '').trim()
          : emp.pno.replaceAll('.0', '').trim();
      return value.contains(trimmed);
    }).toList();

    if (kDebugMode) {
      print('[SEARCH-DEBUG] FINAL results for field=$field query=$trimmed: ${_searchResults.length}');
      if (_searchResults.isNotEmpty) {
        print('[SEARCH-DEBUG]   first: pno=^${_searchResults.first.pno}^ badge=^${_searchResults.first.badgeNumber}^ name=^${_searchResults.first.name}^');
      }
    }

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
      await _repository.loadRemainingData();
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
