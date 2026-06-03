import 'package:equatable/equatable.dart';
import 'package:hive_ce/hive.dart';

class Movement extends Equatable {
  const Movement({
    required this.id,
    required this.timestamp,
    this.notes,
    this.intensity,
  });

  final String id;
  final DateTime timestamp;
  final String? notes;
  final int? intensity;

  Movement copyWith({
    String? id,
    DateTime? timestamp,
    String? notes,
    int? intensity,
  }) {
    return Movement(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      notes: notes ?? this.notes,
      intensity: intensity ?? this.intensity,
    );
  }

  @override
  List<Object?> get props => [id, timestamp, notes, intensity];
}

class MovementAdapter extends TypeAdapter<Movement> {
  @override
  final int typeId = 0;

  @override
  Movement read(BinaryReader reader) {
    final id = reader.readString();
    final ts = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    final hasNotes = reader.readBool();
    final notes = hasNotes ? reader.readString() : null;
    final hasIntensity = reader.readBool();
    final intensity = hasIntensity ? reader.readInt() : null;
    return Movement(
      id: id,
      timestamp: ts,
      notes: notes,
      intensity: intensity,
    );
  }

  @override
  void write(BinaryWriter writer, Movement obj) {
    writer.writeString(obj.id);
    writer.writeInt(obj.timestamp.millisecondsSinceEpoch);
    writer.writeBool(obj.notes != null);
    if (obj.notes != null) writer.writeString(obj.notes!);
    writer.writeBool(obj.intensity != null);
    if (obj.intensity != null) writer.writeInt(obj.intensity!);
  }
}
