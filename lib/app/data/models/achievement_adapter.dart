
import 'package:hive/hive.dart';
import '../models/achievement.dart';

@HiveType(typeId: 2)
class AchievementAdapter extends TypeAdapter<Achievement> {
  @override
  final int typeId = 2;

  @override
  Achievement read(BinaryReader reader) {
    final id = reader.readString();
    final title = reader.readString();
    final description = reader.readString();
    final iconPath = reader.readString();
    final isUnlocked = reader.readBool();

    DateTime? unlockedAt;
    final hasUnlockedAt = reader.readBool();
    if (hasUnlockedAt) {
      unlockedAt = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    }

    final value = reader.readString();

    return Achievement(
      id: id,
      title: title,
      description: description,
      iconPath: iconPath,
      isUnlocked: isUnlocked,
      unlockedAt: unlockedAt,
      value: value,
    );
  }

  @override
  void write(BinaryWriter writer, Achievement obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeString(obj.description);
    writer.writeString(obj.iconPath);
    writer.writeBool(obj.isUnlocked);

    writer.writeBool(obj.unlockedAt != null);
    if (obj.unlockedAt != null) {
      writer.writeInt(obj.unlockedAt!.millisecondsSinceEpoch);
    }

    writer.writeString(obj.value);
  }
}