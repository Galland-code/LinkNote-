import 'package:hive/hive.dart';
import '../models/daily_task.dart';

@HiveType(typeId: 3)
class DailyTaskAdapter extends TypeAdapter<DailyTask> {
  @override
  DailyTask read(BinaryReader reader) {
    final id = reader.readString();
    final title = reader.readString();
    final description = reader.readString();
    final points = reader.readInt();
    final isCompleted = reader.readBool();
    final completedAt =
        reader.readBool()
            ? DateTime.fromMillisecondsSinceEpoch(reader.readInt())
            : null;

    return DailyTask(
      id: id,
      title: title,
      description: description,
      points: points,
      isCompleted: isCompleted,
      completedAt: completedAt,
    );
  }

  @override
  void write(BinaryWriter writer, DailyTask obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeString(obj.description ?? '');
    writer.writeInt(obj.points);
    writer.writeBool(obj.isCompleted);
    writer.writeBool(obj.completedAt != null);
    if (obj.completedAt != null) {
      writer.writeInt(obj.completedAt!.millisecondsSinceEpoch);
    }
  }
    @override
  int get typeId => 3; 
}
