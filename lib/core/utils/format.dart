import 'package:intl/intl.dart';

final _egp = NumberFormat('#,##0.##', 'en');
final _day = DateFormat('d/MM/yyyy');
final _iso = DateFormat('yyyy-MM-dd');

String formatMoney(String? raw) {
  final n = double.tryParse(raw ?? '') ?? 0;
  return _egp.format(n);
}

String formatEgp(String? raw) => '${formatMoney(raw)} ج.م';

String formatDate(DateTime date) => _iso.format(date);

String displayDate(String iso) {
  final parsed = DateTime.tryParse(iso);
  if (parsed == null) return iso;
  return _day.format(parsed);
}

String rangeLabel(DateTime? from, DateTime? to) {
  if (from == null && to == null) return 'كل الفترات';
  final a = from == null ? '…' : _day.format(from);
  final b = to == null ? '…' : _day.format(to);
  return 'من $a إلى $b';
}
