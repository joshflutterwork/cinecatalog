/// Small readers for TMDB JSON, which is loose about nulls: missing strings,
/// empty dates (`""`) and ints sent as doubles all happen in practice.
extension TmdbJson on Map<String, dynamic> {
  int requireInt(String key) => (this[key] as num).toInt();

  int intOr(String key, [int fallback = 0]) =>
      (this[key] as num?)?.toInt() ?? fallback;

  int? intOrNull(String key) => (this[key] as num?)?.toInt();

  double doubleOr(String key, [double fallback = 0]) =>
      (this[key] as num?)?.toDouble() ?? fallback;

  String stringOr(String key, [String fallback = '']) =>
      this[key] as String? ?? fallback;

  /// Null for a missing or blank value, so widgets can test `!= null`.
  String? stringOrNull(String key) {
    final value = this[key] as String?;
    return value == null || value.trim().isEmpty ? null : value;
  }

  /// `"2010-07-15"`, or null when missing, empty or malformed.
  DateTime? dateOrNull(String key) {
    final value = this[key] as String?;
    return value == null || value.isEmpty ? null : DateTime.tryParse(value);
  }

  /// A list of objects, empty when the key is missing.
  List<Map<String, dynamic>> objects(String key) =>
      (this[key] as List<dynamic>? ?? const []).cast<Map<String, dynamic>>();

  /// A nested object such as `credits` from `append_to_response`, empty when
  /// TMDB left it out.
  Map<String, dynamic> object(String key) =>
      this[key] as Map<String, dynamic>? ?? const {};
}
