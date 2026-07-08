/// JSONP fetcher — web-only implementation using <script> tag injection.
///
/// The Google Visualization API wraps its response in a callback:
///   `google.visualization.Query.setResponse({...})`
/// We ask it to use a custom callback name via `tqx=responseHandler:...`,
/// then register that function globally and inject a <script> tag.
/// Since <script> tags are not subject to CORS, this always works.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:js' as js;

class JsonpFetcher {
  static Future<List<Map<String, dynamic>>> fetch(
    String gid,
    String spreadsheetId,
    String gsheetsBaseUrl,
    Duration timeout,
  ) async {
    final completer = Completer<List<Map<String, dynamic>>>();
    final cbName = '_gvizCb${gid}_${DateTime.now().millisecondsSinceEpoch}';

    // Register the global callback that Google will invoke.
    js.context[cbName] = (response) {
      if (completer.isCompleted) return;
      try {
        final jsonString = js.context.callMethod('JSON.stringify', [response]);
        final data = json.decode(jsonString as String) as Map<String, dynamic>;

        if (data['status'] != 'ok') {
          completer.complete([]);
          return;
        }

        final table = data['table'] as Map<String, dynamic>?;
        if (table == null) {
          completer.complete([]);
          return;
        }

        final cols = table['cols'] as List<dynamic>? ?? [];
        final dataRows = table['rows'] as List<dynamic>? ?? [];

        final headers = <String>[];
        for (final col in cols) {
          final colMap = col as Map<String, dynamic>;
          headers.add((colMap['label'] ?? '').toString());
        }

        final result = <Map<String, dynamic>>[];
        for (final row in dataRows) {
          final rowMap = row as Map<String, dynamic>;
          final cells = rowMap['c'] as List<dynamic>? ?? [];
          final map = <String, dynamic>{};

          for (int i = 0; i < headers.length; i++) {
            if (i < cells.length && cells[i] != null) {
              final cellMap = cells[i] as Map<String, dynamic>?;
              if (cellMap != null) {
                final formatted = cellMap['f'];
                map[headers[i]] =
                    formatted?.toString() ?? cellMap['v']?.toString() ?? '';
              } else {
                map[headers[i]] = '';
              }
            } else {
              map[headers[i]] = '';
            }
          }
          result.add(map);
        }

        completer.complete(result);
      } catch (_) {
        if (!completer.isCompleted) completer.complete([]);
      }
    };

    // Build the JSONP URL.
    // A cache-busting timestamp (`&_=<ms>`) is appended so the browser
    // never serves a cached <script> response — same reason as the HTTP
    // path in GSheetDataSource.
    final bust = DateTime.now().millisecondsSinceEpoch;
    final url = '$gsheetsBaseUrl/$spreadsheetId/gviz/tq'
        '?gid=$gid&tqx=out:json;responseHandler:$cbName&_=$bust';

    // Create and inject the <script> tag.
    final script = html.ScriptElement();
    script.src = url;

    // Error handler — network failure, DNS error, etc.
    script.onError.listen((_) {
      if (!completer.isCompleted) completer.complete([]);
    });

    html.document.head?.append(script);

    try {
      return await completer.future.timeout(
        timeout,
        onTimeout: () => <Map<String, dynamic>>[],
      );
    } finally {
      // Always clean up.
      script.remove();
      try {
        js.context.deleteProperty(cbName);
      } catch (_) {}
    }
  }
}
