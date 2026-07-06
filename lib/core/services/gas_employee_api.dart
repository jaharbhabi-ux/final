import 'employee_api.dart';
import 'gas_data_source.dart';
import '../models/models.dart';

/// GasEmployeeApi — future implementation of [EmployeeApi] that reads
/// via a Google Apps Script web app.
///
/// STATUS: STUB. Every fetch method throws [UnimplementedError].
/// When the Apps Script backend is deployed, replace the bodies with
/// real calls to [GasDataSource] (which is already written + PNO-keyed
/// in this refactor).
///
/// CONTRACT: PNO is the master key. The underlying [GasDataSource]
/// already enforces this — all its methods take PNO, never Badge.
class GasEmployeeApi implements EmployeeApi {
  final GasDataSource _ds;

  GasEmployeeApi({GasDataSource? dataSource})
      : _ds = dataSource ?? GasDataSource();

  @override
  Future<List<Map<String, dynamic>>> fetchAllActive() {
    // TODO: implement via GasDataSource once Apps Script is deployed.
    throw UnimplementedError('GasEmployeeApi.fetchAllActive not wired');
  }

  @override
  Future<List<Map<String, dynamic>>> fetchAllInactive() {
    throw UnimplementedError('GasEmployeeApi.fetchAllInactive not wired');
  }

  @override
  Future<List<Map<String, dynamic>>> fetchAllArrivals() {
    throw UnimplementedError('GasEmployeeApi.fetchAllArrivals not wired');
  }

  @override
  Future<List<Map<String, dynamic>>> fetchAllDepartures() {
    throw UnimplementedError('GasEmployeeApi.fetchAllDepartures not wired');
  }

  @override
  Future<List<Map<String, dynamic>>> fetchHob(int year) {
    throw UnimplementedError('GasEmployeeApi.fetchHob not wired');
  }

  @override
  Future<List<Map<String, dynamic>>> fetchAllBasicPay() {
    throw UnimplementedError('GasEmployeeApi.fetchAllBasicPay not wired');
  }

  @override
  Future<List<Map<String, dynamic>>> fetchAllRelations() {
    throw UnimplementedError('GasEmployeeApi.fetchAllRelations not wired');
  }

  @override
  Future<List<Employee>> searchEmployees(String query) {
    return _ds.searchEmployee(query);
  }

  @override
  Future<DashboardStats?> fetchDashboardStats() async {
    return _ds.getDashboardStats();
  }

  @override
  void dispose() {
    _ds.dispose();
  }

  /// Convenience getter — exposes the underlying data source so callers
  /// can use the PNO-keyed per-employee methods (getEmployeeByPno,
  /// getAagmanByPno, etc.) once Apps Script is live.
  GasDataSource get dataSource => _ds;
}
