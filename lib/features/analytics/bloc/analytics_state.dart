import 'package:equatable/equatable.dart';

import '../../../data/models/movement.dart';

class DayBucket extends Equatable {
  const DayBucket({required this.date, required this.count});
  final DateTime date;
  final int count;
  @override
  List<Object?> get props => [date, count];
}

class HourBucket extends Equatable {
  const HourBucket({required this.hour, required this.count});
  final int hour;
  final int count;
  @override
  List<Object?> get props => [hour, count];
}

enum AnalyticsStatus { initial, loading, loaded, empty }

class AnalyticsState extends Equatable {
  const AnalyticsState({
    this.status = AnalyticsStatus.initial,
    this.movements = const [],
    this.last7Days = const [],
    this.hourDistribution = const [],
    this.averageDaily = 0,
    this.averageIntervalMinutes = 0,
    this.streakDays = 0,
  });

  final AnalyticsStatus status;
  final List<Movement> movements;
  final List<DayBucket> last7Days;
  final List<HourBucket> hourDistribution;
  final double averageDaily;
  final double averageIntervalMinutes;
  final int streakDays;

  AnalyticsState copyWith({
    AnalyticsStatus? status,
    List<Movement>? movements,
    List<DayBucket>? last7Days,
    List<HourBucket>? hourDistribution,
    double? averageDaily,
    double? averageIntervalMinutes,
    int? streakDays,
  }) {
    return AnalyticsState(
      status: status ?? this.status,
      movements: movements ?? this.movements,
      last7Days: last7Days ?? this.last7Days,
      hourDistribution: hourDistribution ?? this.hourDistribution,
      averageDaily: averageDaily ?? this.averageDaily,
      averageIntervalMinutes: averageIntervalMinutes ?? this.averageIntervalMinutes,
      streakDays: streakDays ?? this.streakDays,
    );
  }

  @override
  List<Object?> get props => [
        status,
        movements,
        last7Days,
        hourDistribution,
        averageDaily,
        averageIntervalMinutes,
        streakDays,
      ];
}
