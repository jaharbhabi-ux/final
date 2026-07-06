import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart' as csv;
import '../constants/app_constants.dart';
// Conditional import: web uses <script> JSONP, mobile gets a no-op stub.
import 'jsonp_fetcher_stub.dart'
    if (dart.library.html) 'jsonp_fetcher_web.dart' as jsonp;

/// गूगल शीट्स डेटा स्रोत - Data Source Layer
///
/// Fetches Google Sheets via the gviz/tq endpoint. Uses GID-based URLs
/// (works for both published and unpublished sheets).
///
/// On mobile/desktop: direct HTTP GET (no CORS).
/// On web: tries HTTP first; if CORS blocks it, falls back to JSONP via
/// <script> tag injection (bypasses CORS entirely).
class GSheetDataSource {
  final http.Client _client;

  GSheetDataSource({http.Client? client}) : _client = client ?? http.Client();

  /// Build the gviz/tq CSV URL for a given GID.
  ///
  /// A cache-busting timestamp (`&_=<ms>`) is appended so that Google's
  /// gviz endpoint and any intermediate browser/CDN cache always returns
  /// the LIVE sheet data. Without this, edits made directly in Google
  /// Sheets can take several minutes (or until a hard refresh) to appear
  /// in the app — which is the root cause of the "edited data not
  /// updating" bug.
  String _gvizCsvUrl(String gid) {
    final bust = DateTime.now().millisecondsSinceEpoch;
    return '${AppConstants.gsheetsBaseUrl}/${AppConstants.spreadsheetId}/gviz/tq'
        '?gid=$gid&tqx=out:csv&_=$bust';
  }

  /// Fetch a sheet by GID, parse to list of maps.
  ///
  /// Strategy:
  ///  1. Try gviz/tq CSV endpoint via HTTP (works on mobile/desktop).
  ///  2. On web, if CORS blocks it, fall back to JSONP via <script> tag
  ///     injection — this is the standard CORS bypass technique.
  Future<List<Map<String, dynamic>>> fetchSheet({
    required String sheetName,
    required String gid,
    bool useGid = true,
  }) async {
    // ── Phase 1: Try HTTP GET to gviz/tq CSV endpoint ──
    try {
      final url = _gvizCsvUrl(gid);
      final response = await _client
          .get(
            Uri.parse(url),
            // Force fresh data — never use a cached response.
            // Both the OS HTTP stack (mobile/desktop) and the browser
            // XHR stack (web) honour these headers.
            headers: const {
              'Cache-Control': 'no-cache, no-store, must-revalidate',
              'Pragma': 'no-cache',
              'Expires': '0',
            },
          )
          .timeout(AppConstants.requestTimeout);

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        return _parseCsvToMaps(response.body);
      }
    } catch (_) {
      // On web this is almost always a CORS block.
      // On mobile/desktop, rethrow so the caller sees the real error.
      if (!kIsWeb) rethrow;
      // On web, fall through to JSONP.
    }

    // ── Phase 2: JSONP via <script> tag (web only, true CORS bypass) ──
    if (kIsWeb) {
      return jsonp.JsonpFetcher.fetch(
        gid,
        AppConstants.spreadsheetId,
        AppConstants.gsheetsBaseUrl,
        AppConstants.requestTimeout,
      );
    }

    return [];
  }

  /// Fetch all sheets in parallel.
  Future<Map<String, List<Map<String, dynamic>>>> fetchAllSheets() async {
    final futures = AppConstants.allSheets.map((sheet) {
      return fetchSheet(
        sheetName: sheet['name']!,
        gid: sheet['gid']!,
      ).then((data) => MapEntry(sheet['name']!, data));
    });

    final results = await Future.wait(futures);
    return Map.fromEntries(results);
  }

  /// Parse CSV text → List<Map<String, dynamic>> using the csv package.
  List<Map<String, dynamic>> _parseCsvToMaps(String csvData) {
    try {
      final rows = const csv.CsvToListConverter(
        eol: '\n',
        shouldParseNumbers: false,
      ).convert(csvData);
      if (rows.isEmpty) return [];

      final headers = rows.first
          .map((e) => e?.toString().trim() ?? '')
          .toList();
      if (headers.every((h) => h.isEmpty)) return [];

      final out = <Map<String, dynamic>>[];
      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        final map = <String, dynamic>{};
        for (int c = 0; c < headers.length; c++) {
          if (headers[c].isEmpty) continue;
          map[headers[c]] = c < row.length ? (row[c]?.toString() ?? '') : '';
        }
        out.add(map);
      }
      return out;
    } catch (_) {
      return _parseCsvToMapsManual(csvData);
    }
  }

  /// Manual fallback parser.
  List<Map<String, dynamic>> _parseCsvToMapsManual(String csvData) {
    final lines = const LineSplitter().convert(csvData);
    if (lines.isEmpty) return [];

    final headers = _parseCsvLine(lines.first);
    if (headers.isEmpty) return [];

    return lines.skip(1).map((line) {
      final cells = _parseCsvLine(line);
      final map = <String, dynamic>{};
      for (int i = 0; i < headers.length; i++) {
        map[headers[i]] = i < cells.length ? cells[i] : '';
      }
      return map;
    }).toList();
  }

  List<String> _parseCsvLine(String line) {
    final cells = <String>[];
    bool inQuotes = false;
    StringBuffer currentCell = StringBuffer();

    for (int i = 0; i < line.length; i++) {
      final char = line[i];

      if (char == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          currentCell.write('"');
          i++;
        } else {
          inQuotes = !inQuotes;
        }
      } else if (char == ',' && !inQuotes) {
        cells.add(currentCell.toString().trim());
        currentCell = StringBuffer();
      } else {
        currentCell.write(char);
      }
    }

    cells.add(currentCell.toString().trim());
    return cells;
  }

  /// Utility method to clean PNO/badge numbers
  static String cleanNumber(dynamic value) {
    return value
            ?.toString()
            .replaceAll('.0', '')
            .replaceAll(RegExp(r'\s+'), '')
            .trim() ??
        '';
  }

  /// सभी Map entries में से __ prefixed internal keys हटाएँ
  static Map<String, dynamic> stripInternalKeys(Map<String, dynamic> map) {
    return Map.fromEntries(
      map.entries.where((e) => !e.key.startsWith('__')),
    );
  }

  void dispose() {
    _client.close();
  }
}