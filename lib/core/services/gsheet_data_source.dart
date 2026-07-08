import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import 'jsonp_fetcher_stub.dart' if (dart.library.html) 'jsonp_fetcher_web.dart'
    as jsonp;

/// Google Sheets Data Source
///
/// FIX HISTORY:
/// 1. Manual state-machine parser â€” handles multiline cells (newlines inside quotes)
/// 2. Cache-busting URL â€” prevents stale data from Google CDN / browser cache
/// 3. Key normalization â€” strips BOM, zero-width spaces, and trims all header
///    keys so they EXACTLY match AppConstants.key* values.
///    This fixes the "PNO search returns 0 results but badge search works" bug
///    caused by invisible Unicode characters in CSV headers.
class GSheetDataSource {
  final http.Client _client;

  GSheetDataSource({http.Client? client}) : _client = client ?? http.Client();

  /// gviz/tq CSV URL with cache-buster timestamp.
  String _gvizCsvUrl(String gid) {
    final bust = DateTime.now().millisecondsSinceEpoch;
    return '${AppConstants.gsheetsBaseUrl}/${AppConstants.spreadsheetId}/gviz/tq'
        '?gid=$gid&tqx=out:csv&_=$bust';
  }

  Future<List<Map<String, dynamic>>> fetchSheet({
    required String sheetName,
    required String gid,
    bool useGid = true,
  }) async {
    // Phase 1: HTTP GET
    try {
      final url = _gvizCsvUrl(gid);
      final response = await _client
          .get(Uri.parse(url))
          .timeout(AppConstants.requestTimeout);

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final parsed = _parseCsvToMaps(response.body);
        if (parsed.isNotEmpty) return parsed;
      }
    } catch (e) {
      if (!kIsWeb) rethrow;
    }

    // Phase 2: JSONP fallback (web only)
    if (kIsWeb) {
      try {
        final result = await jsonp.JsonpFetcher.fetch(
          gid,
          AppConstants.spreadsheetId,
          AppConstants.gsheetsBaseUrl,
          AppConstants.requestTimeout,
        );
        return result;
      } catch (_) {
        return [];
      }
    }

    return [];
  }

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

  /// Normalize a CSV header key:
  ///   - Strip BOM (\uFEFF)
  ///   - Strip zero-width spaces (\u200B, \u200C, \u200D, \u2060, \uFEFF)
  ///   - Strip other invisible Unicode formatting chars
  ///   - Trim leading/trailing whitespace
  ///
  /// This is CRITICAL because Google Sheets gviz/tq sometimes inserts
  /// invisible characters into CSV headers, causing map key lookups like
  /// `map[AppConstants.keyPno]` to return null even though the visible
  /// text looks identical.
  String _normalizeKey(String key) {
    return key
        .replaceAll('\uFEFF', '') // BOM
        .replaceAll('\u200B', '') // Zero-width space
        .replaceAll('\u200C', '') // Zero-width non-joiner
        .replaceAll('\u200D', '') // Zero-width joiner
        .replaceAll('\u2060', '') // Word joiner
        .replaceAll('\u00A0', ' ') // Non-breaking space â†’ regular space
        .replaceAll('\u202F', ' ') // Narrow no-break space
        .replaceAll('\u2009', ' ') // Thin space
        .replaceAll('\u200A', ' ') // Hair space
        .replaceAll('\u2800', '') // Braille pattern blank
        .trim();
  }

  /// Parse CSV to List<Map>. ALWAYS uses the robust state-machine parser
  /// with key normalization.
  List<Map<String, dynamic>> _parseCsvToMaps(String csvData) {
    return _parseCsvToMapsManual(csvData);
  }

  /// Robust manual CSV parser:
  ///   - State machine that respects quote boundaries
  ///   - Handles multiline cells (newlines inside quoted strings)
  ///   - Handles both \n and \r\n line endings
  ///   - Handles escaped quotes ("")
  ///   - Handles empty trailing columns
  ///   - NORMALIZES all header keys (strips invisible Unicode chars)
  List<Map<String, dynamic>> _parseCsvToMapsManual(String csvData) {
    final List<List<String>> allRows = <List<String>>[];
    final List<String> currentRow = <String>[];
    final StringBuffer currentCell = StringBuffer();
    bool inQuotes = false;
    // Once the first non-blank (header) row is seen, subsequent blank rows
    // are PRESERVED. These act as section separators (live data → blank row
    // → archived section) in sheets like Aagman / Prasthan. The repository's
    // _takeUntilFirstBlankRow() relies on them to stop counting. Leading
    // blank rows (before the header) are still dropped so the header stays
    // correct.
    bool headerSeen = false;
    int i = 0;

    while (i < csvData.length) {
      final ch = csvData[i];

      if (inQuotes) {
        if (ch == '"') {
          if (i + 1 < csvData.length && csvData[i + 1] == '"') {
            currentCell.write('"');
            i += 2;
            continue;
          }
          inQuotes = false;
          i++;
          continue;
        }
        currentCell.write(ch);
        i++;
        continue;
      }

      // Not in quotes
      if (ch == '"') {
        inQuotes = true;
        i++;
        continue;
      }
      if (ch == ',') {
        currentRow.add(currentCell.toString().trim());
        currentCell.clear();
        i++;
        continue;
      }
      if (ch == '\r') {
        // Skip \r â€” let \n handle the row break
        i++;
        continue;
      }
      if (ch == '\n') {
        currentRow.add(currentCell.toString().trim());
        currentCell.clear();
        if (currentRow.any((s) => s.isNotEmpty)) {
          allRows.add(List<String>.from(currentRow));
          headerSeen = true;
        } else if (headerSeen) {
          // Preserve mid/end-of-sheet blank rows as section separators.
          allRows.add(List<String>.from(currentRow));
        }
        currentRow.clear();
        i++;
        continue;
      }
      currentCell.write(ch);
      i++;
    }

    // Flush last cell + last row
    if (currentCell.isNotEmpty || currentRow.isNotEmpty) {
      currentRow.add(currentCell.toString().trim());
      if (currentRow.any((s) => s.isNotEmpty)) {
        allRows.add(List<String>.from(currentRow));
        headerSeen = true;
      } else if (headerSeen) {
        allRows.add(List<String>.from(currentRow));
      }
    }

    if (allRows.isEmpty) return [];

    // Step 2: First row = headers â€” NORMALIZE each header key
    final rawHeaders = allRows.first;
    final headers = rawHeaders.map((h) => _normalizeKey(h)).toList();

    // Debug: print first few headers with their code units to detect
    // any remaining invisible characters.
    if (kDebugMode) {
      print('[PARSE] tokenized ${allRows.length} rows, ${headers.length} cols');
      for (int h = 0; h < headers.length && h < 5; h++) {
        final codes = headers[h].codeUnits.take(20).toList();
        print(
            '[PARSE] header[$h] = ${jsonEncode(headers[h])}  codeUnits=$codes');
      }
    }

    // Step 3: Build maps with NORMALIZED keys
    final out = <Map<String, dynamic>>[];
    for (int r = 1; r < allRows.length; r++) {
      final row = allRows[r];
      final map = <String, dynamic>{};
      for (int c = 0; c < headers.length; c++) {
        final h = headers[c];
        if (h.isEmpty) continue;
        // If duplicate headers exist, later values overwrite earlier ones.
        // This is the correct behavior for Google Sheets CSV exports.
        map[h] = c < row.length ? row[c] : '';
      }
      // Keep every row, INCLUDING blank ones that act as section separators
      // (live data → blank row → archived section). The repository's
      // _takeUntilFirstBlankRow() stops counting at the first fully-blank
      // row; leading blank rows were already dropped during tokenization so
      // the header row (allRows[0]) is always the real header.
      out.add(map);
    }

    return out;
  }

  /// Legacy single-line parser â€” kept for compatibility.
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

  static String cleanNumber(dynamic value) {
    return value
            ?.toString()
            .replaceAll('.0', '')
            .replaceAll(RegExp(r'\s+'), '')
            .trim() ??
        '';
  }

  static Map<String, dynamic> stripInternalKeys(Map<String, dynamic> map) {
    return Map.fromEntries(
      map.entries.where((e) => !e.key.startsWith('__')),
    );
  }

  void dispose() {
    _client.close();
  }
}
