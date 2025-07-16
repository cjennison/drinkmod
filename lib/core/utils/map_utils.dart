/// Utility functions for working with Maps, especially converting LinkedMaps from Hive
class MapUtils {
  /// Deep convert LinkedMap to Map<String, dynamic> recursively
  /// This is needed because Hive returns LinkedMap<dynamic, dynamic> which causes type errors
  static Map<String, dynamic> deepConvertMap(dynamic value) {
    if (value is Map) {
      final result = <String, dynamic>{};
      for (final entry in value.entries) {
        final key = entry.key?.toString() ?? '';
        final val = entry.value;
        
        if (val is Map) {
          result[key] = deepConvertMap(val);
        } else if (val is List) {
          result[key] = deepConvertList(val);
        } else {
          result[key] = val;
        }
      }
      return result;
    } else if (value is Map<String, dynamic>) {
      // Already the right type, but check nested values
      final result = <String, dynamic>{};
      for (final entry in value.entries) {
        final val = entry.value;
        if (val is Map && val is! Map<String, dynamic>) {
          result[entry.key] = deepConvertMap(val);
        } else if (val is List) {
          result[entry.key] = deepConvertList(val);
        } else {
          result[entry.key] = val;
        }
      }
      return result;
    } else {
      return value as Map<String, dynamic>;
    }
  }

  /// Deep convert List with LinkedMaps to proper List
  static List<dynamic> deepConvertList(List<dynamic> list) {
    return list.map((item) {
      if (item is Map) {
        return deepConvertMap(item);
      } else if (item is List) {
        return deepConvertList(item);
      } else {
        return item;
      }
    }).toList();
  }

  /// Convert a list of maps, ensuring all are properly typed
  static List<Map<String, dynamic>> deepConvertMapList(List<dynamic> list) {
    return list
        .where((item) => item is Map)
        .map((item) => deepConvertMap(item))
        .toList();
  }
}
