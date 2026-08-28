import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/format.dart';

class DateRange {
  const DateRange({this.from, this.to});
  final DateTime? from;
  final DateTime? to;

  String? get fromIso => from == null ? null : formatDate(from!);
  String? get toIso => to == null ? null : formatDate(to!);
}

class DateRangeCubit extends Cubit<DateRange> {
  DateRangeCubit() : super(const DateRange());

  void setRange(DateTime? from, DateTime? to) => emit(DateRange(from: from, to: to));

  void clear() => emit(const DateRange());
}
