import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';

class GasWriteService {
  /// Each request gets a fresh client — no shared state, no dispose bugs.
  Future<bool> addHobEntry({
    required String pno,
    required String hobNumber,
    required String date,
    required String description,
    String badge = '',
    String post = '',
    String name = '',
    String otherDetails = '',
  }) async {
    try {
      final client = http.Client();
      final response = await client.post(
        Uri.parse(AppConstants.gasBaseUrl),
        headers: {'Content-Type': 'text/plain'},
        body: json.encode({
          'action': 'addHob',
          'token': AppConstants.apiToken,
          'pno': pno,
          'hobNumber': hobNumber,
          'date': date,
          'description': description,
          'year': _yearFromDate(date),
          'badge': badge,
          'post': post,
          'name': name,
          'otherDetails': otherDetails,
        }),
      ).timeout(AppConstants.requestTimeout);
      client.close();
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
    } catch (e) {
      print('GAS addHob error: $e');
    }
    return false;
  }

  Future<bool> addBasicPayEntry({
    required String pno,
    required String incrementMonth,
    required String basicPay,
    String badge = '',
    String post = '',
    String name = '',
  }) async {
    try {
      final client = http.Client();
      final response = await client.post(
        Uri.parse(AppConstants.gasBaseUrl),
        headers: {'Content-Type': 'text/plain'},
        body: json.encode({
          'action': 'addBasicPay',
          'token': AppConstants.apiToken,
          'pno': pno,
          'incrementMonth': incrementMonth,
          'basicPay': basicPay,
          'badge': badge,
          'post': post,
          'name': name,
        }),
      ).timeout(AppConstants.requestTimeout);
      client.close();
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
    } catch (e) {
      print('GAS addBasicPay error: $e');
    }
    return false;
  }

  Future<bool> updateEmployee(Map<String, String> data) async {
    try {
      final client = http.Client();
      final response = await client.post(
        Uri.parse(AppConstants.gasBaseUrl),
        headers: {'Content-Type': 'text/plain'},
        body: json.encode({'action': 'updateEmployee', 'token': AppConstants.apiToken, ...data}),
      ).timeout(AppConstants.requestTimeout);
      client.close();
      if (response.statusCode == 200) {
        final r = json.decode(response.body);
        print('GAS updateEmployee response: ${response.body}');
        return r['success'] == true;
      }
    } catch (e) {
      print('GAS updateEmployee error: $e');
    }
    return false;
  }

  Future<bool> addNewEmployee(Map<String, String> data) async {
    try {
      final client = http.Client();
      final response = await client.post(
        Uri.parse(AppConstants.gasBaseUrl),
        headers: {'Content-Type': 'text/plain'},
        body: json.encode({'action': 'addNewEmployee', 'token': AppConstants.apiToken, ...data}),
      ).timeout(AppConstants.requestTimeout);
      client.close();
      if (response.statusCode == 200) {
        final r = json.decode(response.body);
        print('GAS addNewEmployee response: ${response.body}');
        return r['success'] == true;
      }
    } catch (e) {
      print('GAS addNewEmployee error: $e');
    }
    return false;
  }

  static int _yearFromDate(String dateStr) {
    final parts = dateStr.split(RegExp(r'[/\-.]'));
    if (parts.length == 3) {
      final y = int.tryParse(parts[2].trim());
      if (y == 2025) return 2025;
      if (y == 2026) return 2026;
    }
    return DateTime.now().year;
  }
}