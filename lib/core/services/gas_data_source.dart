import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/models.dart';

/// Google Apps Script Data Source - Data Source Layer
///
/// STUB-ish: full method bodies are written, but [EmployeeRepository.useGas]
/// is currently `false` so this class is never instantiated at runtime.
/// When the Apps Script backend is deployed, flip the flag and inject
/// an instance via the repository constructor.
///
/// CONTRACT: PNO is the master key. Every method takes PNO — never Badge.
/// Badge Number is for initial search only, per spec.
class GasDataSource {
  final http.Client _client;
  final String _baseUrl;

  GasDataSource({
    http.Client? client,
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? AppConstants.gasBaseUrl;

  /// Search employees by free-text query (matches PNO / Badge / Name).
  Future<List<Employee>> searchEmployee(String query) async {
    try {
      final url = Uri.parse('$_baseUrl?action=searchEmployee')
          .replace(queryParameters: {'query': query});
      final response =
          await _client.get(url).timeout(AppConstants.requestTimeout);
      if (response.statusCode != 200) return [];

      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data['success'] != true) return [];
      final list = data['data'] as List<dynamic>? ?? [];
      return list
          .map((j) => Employee.fromMap(
              _convertJsonToMap(j as Map<String, dynamic>)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Dashboard stats — precomputed server-side for speed.
  Future<DashboardStats> getDashboardStats() async {
    try {
      final url = Uri.parse('$_baseUrl?action=getDashboardStats');
      final response =
          await _client.get(url).timeout(AppConstants.requestTimeout);
      if (response.statusCode != 200) return DashboardStats.empty();
      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data['success'] != true) return DashboardStats.empty();
      final statsData = data['data'] as Map<String, dynamic>? ?? {};
      return DashboardStats.fromJson(statsData);
    } catch (_) {
      return DashboardStats.empty();
    }
  }

  /// Get full employee record (ALL or EXTRA sheet) by PNO.
  Future<Employee> getEmployeeByPno(String pno) async {
    try {
      final url = Uri.parse('$_baseUrl?action=getEmployeeByPno')
          .replace(queryParameters: {'pno': pno});
      final response =
          await _client.get(url).timeout(AppConstants.requestTimeout);
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (data['success'] == true) {
          final employeeData = data['data'] as Map<String, dynamic>? ?? {};
          return Employee.fromMap(_convertJsonToMap(employeeData));
        }
      }
      throw Exception('Employee not found for PNO: $pno');
    } catch (_) {
      throw Exception('Employee not found for PNO: $pno');
    }
  }

  /// Aagman (arrival) records for a PNO.
  Future<List<Aagman>> getAagmanByPno(String pno) async {
    try {
      final url = Uri.parse('$_baseUrl?action=getAagmanByPno')
          .replace(queryParameters: {'pno': pno});
      final response =
          await _client.get(url).timeout(AppConstants.requestTimeout);
      if (response.statusCode != 200) return [];
      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data['success'] != true) return [];
      final list = data['data'] as List<dynamic>? ?? [];
      return list
          .map((j) => Aagman.fromMap(j as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Prasthan (departure) records for a PNO.
  Future<List<Prasthan>> getPrasthanByPno(String pno) async {
    try {
      final url = Uri.parse('$_baseUrl?action=getPrasthanByPno')
          .replace(queryParameters: {'pno': pno});
      final response =
          await _client.get(url).timeout(AppConstants.requestTimeout);
      if (response.statusCode != 200) return [];
      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data['success'] != true) return [];
      final list = data['data'] as List<dynamic>? ?? [];
      return list
          .map((j) => Prasthan.fromMap(j as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// HOB records for a PNO across both 2025 + 2026 sheets.
  Future<List<Hob>> getHobByPno(String pno) async {
    try {
      final url = Uri.parse('$_baseUrl?action=getHobByPno')
          .replace(queryParameters: {'pno': pno});
      final response =
          await _client.get(url).timeout(AppConstants.requestTimeout);
      if (response.statusCode != 200) return [];
      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data['success'] != true) return [];
      final list = data['data'] as List<dynamic>? ?? [];
      return list.map((j) => Hob.fromMap(j as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Basic Pay history for a PNO.
  Future<List<BasicPay>> getBasicPayByPno(String pno) async {
    try {
      final url = Uri.parse('$_baseUrl?action=getBasicPayByPno')
          .replace(queryParameters: {'pno': pno});
      final response =
          await _client.get(url).timeout(AppConstants.requestTimeout);
      if (response.statusCode != 200) return [];
      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data['success'] != true) return [];
      final list = data['data'] as List<dynamic>? ?? [];
      return list
          .map((j) => BasicPay.fromMap(j as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Sambadh (relation) records for a PNO.
  Future<List<Relation>> getRelationsByPno(String pno) async {
    try {
      final url = Uri.parse('$_baseUrl?action=getRelationsByPno')
          .replace(queryParameters: {'pno': pno});
      final response =
          await _client.get(url).timeout(AppConstants.requestTimeout);
      if (response.statusCode != 200) return [];
      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data['success'] != true) return [];
      final list = data['data'] as List<dynamic>? ?? [];
      return list
          .map((j) => Relation.fromMap(j as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Convert GAS API JSON response to format expected by existing fromMap() methods.
  /// Maps every field currently consumed by Employee.fromMap — no silent drops.
  Map<String, dynamic> _convertJsonToMap(Map<String, dynamic> json) {
    final map = <String, dynamic>{};

    // Identity
    if (json.containsKey('pno')) map[AppConstants.keyPno] = json['pno'];
    if (json.containsKey('badgeNumber')) {
      map[AppConstants.keyBadge] = json['badgeNumber'];
    }
    if (json.containsKey('ehrms')) map[AppConstants.keyEHRMS] = json['ehrms'];

    // Header display
    if (json.containsKey('name')) map[AppConstants.keyName] = json['name'];
    if (json.containsKey('post') || json.containsKey('designation')) {
      map[AppConstants.keyPost] = json['post'] ?? json['designation'];
    }
    if (json.containsKey('currentPosting')) {
      map[AppConstants.keyCurrentPosting] = json['currentPosting'];
    }
    if (json.containsKey('status')) map[AppConstants.tagStatus] = json['status'];

    // Personal
    if (json.containsKey('fatherName')) {
      map[AppConstants.keyFatherName] = json['fatherName'];
    }
    if (json.containsKey('nomineeDetails') || json.containsKey('nominee')) {
      map[AppConstants.keyNomineeName] =
          json['nomineeDetails'] ?? json['nominee'];
    }
    if (json.containsKey('caste')) map[AppConstants.keyCaste] = json['caste'];
    if (json.containsKey('subCaste')) {
      map[AppConstants.keySubCaste] = json['subCaste'];
    }
    if (json.containsKey('dateOfBirth')) {
      map[AppConstants.keyDob] = json['dateOfBirth'];
    }
    if (json.containsKey('dateOfJoining') ||
        json.containsKey('recruitmentDate')) {
      map[AppConstants.keyRecruitmentDate] =
          json['dateOfJoining'] ?? json['recruitmentDate'];
    }
    if (json.containsKey('homeDistrict')) {
      map[AppConstants.keyHomeDistrict] = json['homeDistrict'];
    }
    if (json.containsKey('districtPosting')) {
      map[AppConstants.keyDistrictPosting] = json['districtPosting'];
    }
    if (json.containsKey('address')) {
      map[AppConstants.keyAddress] = json['address'];
    }
    if (json.containsKey('educationalQualification') ||
        json.containsKey('qualification')) {
      map[AppConstants.keyQualification] =
          json['educationalQualification'] ?? json['qualification'];
    }
    if (json.containsKey('mobileNumber') || json.containsKey('mobile')) {
      map[AppConstants.keyMobile] = json['mobileNumber'] ?? json['mobile'];
    }

    // Service
    if (json.containsKey('promotionDetails') || json.containsKey('promotion')) {
      map[AppConstants.keyPromotion] =
          json['promotionDetails'] ?? json['promotion'];
    }

    // Awards
    if (json.containsKey('goodEntry')) {
      map[AppConstants.keyGoodEntry] = json['goodEntry'];
    }
    if (json.containsKey('cashReward')) {
      map[AppConstants.keyCashReward] = json['cashReward'];
    }
    if (json.containsKey('medals') || json.containsKey('awards')) {
      map[AppConstants.keyMedal] = json['medals'] ?? json['awards'];
    }
    if (json.containsKey('integrity')) {
      map[AppConstants.keyIntegrity] = json['integrity'];
    }
    if (json.containsKey('criminalCase')) {
      map[AppConstants.keyOtherDetails] = json['criminalCase'];
    }

    // Punishments (multiline preserved)
    if (json.containsKey('minorPunishment') ||
        json.containsKey('punishmentDetails')) {
      map[AppConstants.keyMinorPunishment] =
          json['minorPunishment'] ?? json['punishmentDetails'];
    }

    // Free text (multiline preserved)
    if (json.containsKey('remark') || json.containsKey('remarks')) {
      map[AppConstants.keyRemark] = json['remark'] ?? json['remarks'];
    }
    if (json.containsKey('otherDetails')) {
      map[AppConstants.keyOtherDetails] = json['otherDetails'];
    }

    // Previous posting (raw multiline cell + from/to columns)
    if (json.containsKey('previousPostings')) {
      map[AppConstants.keyPreviousPostings] = json['previousPostings'];
    }
    if (json.containsKey('fromDate')) {
      map[AppConstants.keyFromDate] = json['fromDate'];
    }
    if (json.containsKey('toDate')) {
      map[AppConstants.keyToDate] = json['toDate'];
    }

    // Pass-through any unknown keys for forward compatibility.
    json.forEach((key, value) {
      if (!map.containsKey(key) && !key.startsWith('_')) {
        map[key] = value;
      }
    });

    return map;
  }

  void dispose() {
    _client.close();
  }
}
