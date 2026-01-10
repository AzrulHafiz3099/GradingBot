import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CacheService {
  static final CacheService _instance = CacheService._internal();
  late SharedPreferences _prefs;
  final Map<String, _CacheEntry> _memoryCache = {};
  static const Duration _defaultTTL = Duration(minutes: 30);

  factory CacheService() {
    return _instance;
  }

  CacheService._internal();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Cache score distribution data
  Future<void> cacheScoreDistribution(
    String classId,
    String examId,
    List<Map<String, dynamic>> data,
  ) async {
    final key = 'score_dist_${classId}_$examId';
    final jsonData = jsonEncode(data);
    
    await _prefs.setString(key, jsonData);
    _memoryCache[key] = _CacheEntry(
      data,
      DateTime.now().add(_defaultTTL),
    );
  }

  /// Get cached score distribution
  Future<List<Map<String, dynamic>>?> getCachedScoreDistribution(
    String classId,
    String examId,
  ) async {
    final key = 'score_dist_${classId}_$examId';
    
    // Check memory cache first
    if (_memoryCache.containsKey(key)) {
      final entry = _memoryCache[key]!;
      if (entry.isValid()) {
        return entry.data as List<Map<String, dynamic>>?;
      } else {
        _memoryCache.remove(key);
      }
    }

    // Check persistent storage
    final jsonData = _prefs.getString(key);
    if (jsonData != null) {
      try {
        final decoded = jsonDecode(jsonData) as List;
        final data = List<Map<String, dynamic>>.from(decoded);
        
        // Restore to memory cache
        _memoryCache[key] = _CacheEntry(
          data,
          DateTime.now().add(_defaultTTL),
        );
        
        return data;
      } catch (e) {
        print('Error decoding cached data: $e');
      }
    }

    return null;
  }

  /// Cache completion analytics
  Future<void> cacheCompletionAnalytics(
    String classId,
    String examId,
    Map<String, dynamic> data,
  ) async {
    final key = 'completion_${classId}_$examId';
    final jsonData = jsonEncode(data);
    
    await _prefs.setString(key, jsonData);
    _memoryCache[key] = _CacheEntry(
      data,
      DateTime.now().add(_defaultTTL),
    );
  }

  /// Get cached completion analytics
  Future<Map<String, dynamic>?> getCachedCompletionAnalytics(
    String classId,
    String examId,
  ) async {
    final key = 'completion_${classId}_$examId';
    
    if (_memoryCache.containsKey(key)) {
      final entry = _memoryCache[key]!;
      if (entry.isValid()) {
        return entry.data as Map<String, dynamic>?;
      } else {
        _memoryCache.remove(key);
      }
    }

    final jsonData = _prefs.getString(key);
    if (jsonData != null) {
      try {
        final data = jsonDecode(jsonData) as Map<String, dynamic>;
        
        _memoryCache[key] = _CacheEntry(
          data,
          DateTime.now().add(_defaultTTL),
        );
        
        return data;
      } catch (e) {
        print('Error decoding cached data: $e');
      }
    }

    return null;
  }

  /// Cache exam summary students
  Future<void> cacheExamSummary(
    String classId,
    String examId,
    List<Map<String, dynamic>> students,
  ) async {
    final key = 'exam_summary_${classId}_$examId';
    final jsonData = jsonEncode(students);
    
    await _prefs.setString(key, jsonData);
    _memoryCache[key] = _CacheEntry(
      students,
      DateTime.now().add(_defaultTTL),
    );
  }

  /// Get cached exam summary
  Future<List<Map<String, dynamic>>?> getCachedExamSummary(
    String classId,
    String examId,
  ) async {
    final key = 'exam_summary_${classId}_$examId';
    
    if (_memoryCache.containsKey(key)) {
      final entry = _memoryCache[key]!;
      if (entry.isValid()) {
        return entry.data as List<Map<String, dynamic>>?;
      } else {
        _memoryCache.remove(key);
      }
    }

    final jsonData = _prefs.getString(key);
    if (jsonData != null) {
      try {
        final decoded = jsonDecode(jsonData) as List;
        final data = List<Map<String, dynamic>>.from(decoded);
        
        _memoryCache[key] = _CacheEntry(
          data,
          DateTime.now().add(_defaultTTL),
        );
        
        return data;
      } catch (e) {
        print('Error decoding cached data: $e');
      }
    }

    return null;
  }

  /// Clear all cache
  Future<void> clearAll() async {
    await _prefs.clear();
    _memoryCache.clear();
  }

  /// Clear specific cache
  Future<void> clearCache(String key) async {
    await _prefs.remove(key);
    _memoryCache.remove(key);
  }

  /// Clear cache for a specific class
  Future<void> clearClassCache(String classId) async {
    final keysToRemove = _prefs.getKeys()
        .where((key) => key.contains('_${classId}_'))
        .toList();
    
    for (final key in keysToRemove) {
      await _prefs.remove(key);
      _memoryCache.remove(key);
    }
  }
}

class _CacheEntry {
  final dynamic data;
  final DateTime expiresAt;

  _CacheEntry(this.data, this.expiresAt);

  bool isValid() {
    return DateTime.now().isBefore(expiresAt);
  }
}
