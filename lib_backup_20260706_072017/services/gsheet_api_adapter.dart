import 'employee_api.dart';
import 'gsheet_data_source.dart';
import '../constants/app_constants.dart';
import '../models/models.dart';

/// GSheetApiAdapter — live implementation of [EmployeeApi] that reads
/// Google Sheets via the public CSV export endpoint.
///
/// This is a thin adapter around the existing [GSheetDataSource] class.
/// All the heavy lifting (CSV parsing, JSONP fallback, timeout) stays
/// in [GSheetDataSource]. The adapter just maps method calls to the
/// right (sheetName, gid) pair.
class GSheetApiAdapter implements EmployeeApi {
  final GSheetDataSource _ds;

  GSheetApiAdapter({GSheetDataSource? dataSource})
      : _ds = dataSource ?? GSheetDataSource();

  @override
  Future<List<Map<String, dynamic>>> fetchAllActive() {
    return _ds.fetchSheet(
      sheetName: AppConstants.sheetAll,
      gid: AppConstants.sheetAllGid,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> fetchAllInactive() {
    return _ds.fetchSheet(
      sheetName: AppConstants.sheetExtra,
      gid: AppConstants.sheetExtraGid,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> fetchAllArrivals() {
    return _ds.fetchSheet(
      sheetName: AppConstants.sheetAagman,
      gid: AppConstants.sheetAagmanGid,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> fetchAllDepartures() {
    return _ds.fetchSheet(
      sheetName: AppConstants.sheetPrasthan,
      gid: AppConstants.sheetPrasthanGid,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> fetchHob(int year) {
    switch (year) {
      case 2025:
        return _ds.fetchSheet(
          sheetName: AppConstants.sheetHob2025,
          gid: AppConstants.sheetHob2025Gid,
        );
      case 2026:
        return _ds.fetchSheet(
          sheetName: AppConstants.sheetHob2026,
          gid: AppConstants.sheetHob2026Gid,
        );
      default:
        throw ArgumentError('Unsupported HOB year: $year (only 2025/2026)');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchAllBasicPay() {
    return _ds.fetchSheet(
      sheetName: AppConstants.sheetBasicPay,
      gid: AppConstants.sheetBasicPayGid,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> fetchAllRelations() {
    // Sambadh sheet — GID '0' means the real GID hasn't been configured yet.
    // Skip fetch gracefully (returns empty) until a real GID is set.
    if (AppConstants.sheetSambadhGid == '0') {
      return Future.value(const <Map<String, dynamic>>[]);
    }
    return _ds.fetchSheet(
      sheetName: AppConstants.sheetSambadh,
      gid: AppConstants.sheetSambadhGid,
    );
  }

  @override
  Future<List<Employee>> searchEmployees(String query) async {
    // Server-side search not supported by the CSV endpoint — the
    // repository will do in-memory search instead.
    return const [];
  }

  @override
  Future<DashboardStats?> fetchDashboardStats() async {
    // Server-side stats not supported by the CSV endpoint.
    return null;
  }

  @override
  void dispose() {
    _ds.dispose();
  }
}
