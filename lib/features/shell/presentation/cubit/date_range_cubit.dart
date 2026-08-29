import 'package:flutter_bloc/flutter_bloc.dart';

import 'date_range_state.dart';

export 'date_range_state.dart';

class DateRangeCubit extends Cubit<DateRange> {
  DateRangeCubit() : super(const DateRange());

  void setRange(DateTime? from, DateTime? to) =>
      emit(DateRange(from: from, to: to));

  void clear() => emit(const DateRange());
}
