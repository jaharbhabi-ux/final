import '../models/models.dart';

/// Employee API — abstract contract for the data source layer.
///
/// Implemented by:
///   • [GSheetApiAdapter] — live, fetches Google Sheets CSV exports.
///     Wraps the existing [GSheetDataSource] class.
///   • [GasEmployeeApi] — future, fetches via Google Apps Script web app.
///     Currently a stub that throws [UnimplementedError].
///
/// The repository depends ONLY on this abstraction — never on a concrete
/// data source. Swapping backends is a one-line DI change.
///
/// CONTRACT: PNO is the master key. Every method that fetches a single
/// employee's sub-records takes [pno]. Badge Number is never a parameter
/// (it's only accepted by [searchEmployees] as part of the free-text query).
abstract class EmployeeApi {
  /// ALL sheet — active employees only. Returns raw row maps (not yet
  /// parsed into models). The repository owns parsing + caching.
  Future<List<Map<String, dynamic>>> fetchAllActive();

  /// EXTRA sheet — inactive employees only.
  Future<List<Map<String, dynamic>>> fetchAllInactive();

  /// Aagman sheet — every arrival record.
  Future<List<Map<String, dynamic>>> fetchAllArrivals();

  /// Prasthan sheet — every departure record.
  Future<List<Map<String, dynamic>>> fetchAllDepartures();

  /// HOB sheet for the given year (2025 or 2026).
  Future<List<Map<String, dynamic>>> fetchHob(int year);

  /// Basic Pay sheet — every row.
  Future<List<Map<String, dynamic>>> fetchAllBasicPay();

  /// Sambadh sheet — every relation row.
  Future<List<Map<String, dynamic>>> fetchAllRelations();

  /// Optional: free-text search via backend (server-side).
  /// Default implementation returns empty — the repository falls back
  /// to in-memory search.
  Future<List<Employee>> searchEmployees(String query) async => const [];

  /// Optional: precomputed dashboard stats (server-side).
  /// Default returns null — the repository computes stats in-memory.
  Future<DashboardStats?> fetchDashboardStats() async => null;

  /// Release resources held by this API instance (HTTP clients, etc.).
  /// Implementations should close any open connections.
  void dispose();
}
