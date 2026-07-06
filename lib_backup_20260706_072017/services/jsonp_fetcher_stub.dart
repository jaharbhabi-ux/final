/// JSONP fetcher — stub for mobile/desktop platforms.
///
/// On non-web platforms, CORS is not an issue (native HTTP stack).
/// This stub returns an empty list so the JSONP path is a no-op.
class JsonpFetcher {
  static Future<List<Map<String, dynamic>>> fetch(
    String gid,
    String spreadsheetId,
    String gsheetsBaseUrl,
    Duration timeout,
  ) async {
    return [];
  }
}