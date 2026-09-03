/// JSON helpers shared by feature models and remote datasources.
library;

int jsonInt(dynamic value, [int fallback = 0]) {
  return jsonIntOrNull(value) ?? fallback;
}

int? jsonIntOrNull(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value');
}

String jsonMoney(dynamic value) {
  if (value == null) return '0.00';
  if (value is num) return value.toStringAsFixed(2);
  return value.toString();
}

String jsonDate(dynamic value) {
  if (value == null) return '';
  final raw = value.toString();
  return raw.length >= 10 ? raw.substring(0, 10) : raw;
}

List<T> jsonList<T>(
  Map<String, dynamic>? data,
  T Function(Map<String, dynamic>) parse,
) {
  final rows = data?['data'] as List<dynamic>? ?? const [];
  return rows.map((e) => parse(e as Map<String, dynamic>)).toList();
}
