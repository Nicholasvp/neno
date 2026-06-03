import 'package:equatable/equatable.dart';

import '../../../data/models/movement.dart';

abstract class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();
  @override
  List<Object?> get props => [];
}

class AnalyticsSubscribed extends AnalyticsEvent {
  const AnalyticsSubscribed();
}

class AnalyticsUpdated extends AnalyticsEvent {
  const AnalyticsUpdated(this.movements);
  final List<Movement> movements;
  @override
  List<Object?> get props => [movements];
}
