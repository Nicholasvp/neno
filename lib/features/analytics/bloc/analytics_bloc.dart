import 'dart:async';

import 'package:bloc/bloc.dart';

import '../../../data/models/movement.dart';
import '../../../data/repositories/movement_repository.dart';
import 'analytics_event.dart';
import 'analytics_state.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  AnalyticsBloc({required MovementRepository repository})
      : _repository = repository,
        super(const AnalyticsState()) {
    on<AnalyticsSubscribed>(_onSubscribed);
    on<AnalyticsUpdated>(_onUpdated);
  }

  final MovementRepository _repository;
  StreamSubscription? _subscription;

  Future<void> _onSubscribed(
    AnalyticsSubscribed event,
    Emitter<AnalyticsState> emit,
  ) async {
    await _subscription?.cancel();
    final current = _repository.getAll();
    _emitAnalytics(emit, current);
    _subscription = _repository.watch().listen(
          (list) => add(AnalyticsUpdated(list)),
        );
  }

  void _emitAnalytics(Emitter<AnalyticsState> emit, List<Movement> movements) {
    if (movements.isEmpty) {
      emit(state.copyWith(
        status: AnalyticsStatus.empty,
        movements: const [],
        last7Days: const [],
        hourDistribution: const [],
        averageDaily: 0,
        averageIntervalMinutes: 0,
        streakDays: 0,
      ));
      return;
    }
    emit(state.copyWith(
      status: AnalyticsStatus.loaded,
      movements: movements,
      last7Days: _computeLast7Days(movements),
      hourDistribution: _computeHourDistribution(movements),
      averageDaily: _computeAverageDaily(movements),
      averageIntervalMinutes: _computeAverageInterval(movements),
      streakDays: _computeStreak(movements),
    ));
  }

  void _onUpdated(AnalyticsUpdated event, Emitter<AnalyticsState> emit) {
    _emitAnalytics(emit, event.movements);
  }

  List<DayBucket> _computeLast7Days(List<Movement> movements) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final result = <DayBucket>[];
    for (int i = 6; i >= 0; i--) {
      final day = today.subtract(Duration(days: i));
      final count = movements.where((m) {
        return m.timestamp.year == day.year &&
            m.timestamp.month == day.month &&
            m.timestamp.day == day.day;
      }).length;
      result.add(DayBucket(date: day, count: count));
    }
    return result;
  }

  List<HourBucket> _computeHourDistribution(List<Movement> movements) {
    final counts = List<int>.filled(24, 0);
    for (final m in movements) {
      counts[m.timestamp.hour]++;
    }
    return [
      for (int h = 0; h < 24; h++) HourBucket(hour: h, count: counts[h]),
    ];
  }

  double _computeAverageDaily(List<Movement> movements) {
    if (movements.isEmpty) return 0;
    final byDay = <String, int>{};
    for (final m in movements) {
      final key = '${m.timestamp.year}-${m.timestamp.month}-${m.timestamp.day}';
      byDay[key] = (byDay[key] ?? 0) + 1;
    }
    final total = byDay.values.fold<int>(0, (a, b) => a + b);
    return total / byDay.length;
  }

  double _computeAverageInterval(List<Movement> movements) {
    if (movements.length < 2) return 0;
    final sorted = [...movements]..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    int totalMinutes = 0;
    for (int i = 1; i < sorted.length; i++) {
      totalMinutes += sorted[i].timestamp.difference(sorted[i - 1].timestamp).inMinutes;
    }
    return totalMinutes / (sorted.length - 1);
  }

  int _computeStreak(List<Movement> movements) {
    if (movements.isEmpty) return 0;
    final dates = movements
        .map((m) => DateTime(m.timestamp.year, m.timestamp.month, m.timestamp.day))
        .toSet();
    final now = DateTime.now();
    var day = DateTime(now.year, now.month, now.day);
    int streak = 0;
    while (dates.contains(day)) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
