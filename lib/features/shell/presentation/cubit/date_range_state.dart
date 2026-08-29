import 'package:shatbha/core/core.dart';

class DateRange {
  const DateRange({this.from, this.to});
  final DateTime? from;
  final DateTime? to;

  String? get fromIso => from == null ? null : formatDate(from!);
  String? get toIso => to == null ? null : formatDate(to!);
}
