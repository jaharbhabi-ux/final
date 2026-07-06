/// CSV डेटा कैश सर्विस - In-Memory Cache Service
/// सारा डेटा मेमोरी में कैश करता है, instant search के लिए
class CsvCacheService {
  static final CsvCacheService _instance = CsvCacheService._internal();
  factory CsvCacheService() => _instance;
  CsvCacheService._internal();

  Map<String, List<Map<String, dynamic>>> _cache = {};
  DateTime? _lastRefreshTime;
  bool _isInitialized = false;

  /// कैश में डेटा सेट करें — REPLACE semantics.
  ///
  /// ⚠️ This WIPES any previously-cached sheets that are not present in
  /// [data]. Use [merge] / [replaceSheet] when you only want to refresh a
  /// subset of sheets without losing the rest (e.g. when `loadEssentialData`
  /// refreshes ALL+EXTRA but the sub-sheets are still valid for a few more
  /// seconds until `loadRemainingData` runs).
  void setData(Map<String, List<Map<String, dynamic>>> data) {
    _cache = Map.of(data);
    _lastRefreshTime = DateTime.now();
    _isInitialized = true;
  }

  /// मर्ज करें — existing sheets NOT in [data] are preserved.
  /// Use this for partial refreshes (e.g. Phase-1 essential load).
  void merge(Map<String, List<Map<String, dynamic>>> data) {
    _cache = {..._cache, ...data};
    _lastRefreshTime = DateTime.now();
    _isInitialized = true;
  }

  /// Replace a SINGLE sheet in the cache. Other sheets are preserved.
  /// This is the safest per-sheet refresh primitive.
  void replaceSheet(String key, List<Map<String, dynamic>> rows) {
    _cache[key] = rows;
    _lastRefreshTime = DateTime.now();
    _isInitialized = true;
  }

  /// आंशिक डेटा मौजूदा कैश में मर्ज करें (background load के लिए)
  void setPartialData(Map<String, List<Map<String, dynamic>>> data) {
    _cache.addAll(data);
    _lastRefreshTime = DateTime.now();
  }

  /// किसी specific sheet का डेटा पाएँ
  List<Map<String, dynamic>> get(String sheetKey) {
    return _cache[sheetKey] ?? [];
  }

  /// पूरा कैश पाएँ
  Map<String, List<Map<String, dynamic>>> get allData =>
      Map.unmodifiable(_cache);

  /// कैश में डेटा है या नहीं
  bool get isInitialized => _isInitialized;

  /// आखिरी बार कब refresh किया
  DateTime? get lastRefreshTime => _lastRefreshTime;

  /// कैश को साफ़ करें
  void clear() {
    _cache = {};
    _lastRefreshTime = null;
    _isInitialized = false;
  }

  /// कैश की साइज़
  int get totalSheets => _cache.length;

  int get totalRows {
    int count = 0;
    for (final data in _cache.values) {
      count += data.length;
    }
    return count;
  }

  /// कैश वैलिड है या नहीं (1 घंटे तक वैलिड)
  bool get isValid {
    if (!_isInitialized || _lastRefreshTime == null) return false;
    return DateTime.now().difference(_lastRefreshTime!) <
        const Duration(hours: 1);
  }
}
