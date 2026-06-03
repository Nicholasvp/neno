import 'package:equatable/equatable.dart';
import 'package:hive_ce/hive.dart';

class PregnancyProfile extends Equatable {
  const PregnancyProfile({
    this.name,
    required this.dueDate,
  });

  final String? name;
  final DateTime dueDate;

  DateTime get lastMenstrualPeriod =>
      dueDate.subtract(const Duration(days: 280));

  int get currentWeek {
    final today = DateTime.now();
    final days = today.difference(lastMenstrualPeriod).inDays;
    if (days < 0) return 0;
    return (days / 7).floor();
  }

  int get currentWeekDays {
    final today = DateTime.now();
    final days = today.difference(lastMenstrualPeriod).inDays;
    if (days < 0) return 0;
    return days % 7;
  }

  int get daysUntilDue {
    final today = DateTime.now();
    final diff = dueDate.difference(today).inDays;
    return diff < 0 ? 0 : diff;
  }

  double get progress {
    final today = DateTime.now();
    final total = dueDate.difference(lastMenstrualPeriod).inDays;
    final elapsed = today.difference(lastMenstrualPeriod).inDays;
    if (total <= 0) return 0;
    final progress = elapsed / total;
    return progress.clamp(0.0, 1.0);
  }

  String get trimester {
    final week = currentWeek;
    if (week < 13) return '1º trimestre';
    if (week < 27) return '2º trimestre';
    return '3º trimestre';
  }

  PregnancyProfile copyWith({
    String? name,
    DateTime? dueDate,
  }) {
    return PregnancyProfile(
      name: name ?? this.name,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  @override
  List<Object?> get props => [name, dueDate];
}

class PregnancyProfileAdapter extends TypeAdapter<PregnancyProfile> {
  @override
  final int typeId = 1;

  @override
  PregnancyProfile read(BinaryReader reader) {
    final hasName = reader.readBool();
    final name = hasName ? reader.readString() : null;
    final dueMs = reader.readInt();
    return PregnancyProfile(
      name: name,
      dueDate: DateTime.fromMillisecondsSinceEpoch(dueMs),
    );
  }

  @override
  void write(BinaryWriter writer, PregnancyProfile obj) {
    writer.writeBool(obj.name != null);
    if (obj.name != null) writer.writeString(obj.name!);
    writer.writeInt(obj.dueDate.millisecondsSinceEpoch);
  }
}
