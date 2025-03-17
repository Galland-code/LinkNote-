import 'package:hive/hive.dart';
import '../models/user_model.dart';

@HiveType(typeId: 0) // 确保 typeId 是唯一的
class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  int get typeId => 0;
  @override
  UserModel read(BinaryReader reader) {
    return UserModel(
      id: reader.read() as int?,
      username: reader.readString(),
      email: reader.readString(),
      password: reader.readString(), 
      createdAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      avatarIndex: reader.read(),
      level: reader.readInt(),
      experiencePoints: reader.readInt(),
      updatedAt:
          reader.read() != null
              ? DateTime.fromMillisecondsSinceEpoch(reader.readInt())
              : null,
      lastLogin:
          reader.read() != null
              ? DateTime.fromMillisecondsSinceEpoch(reader.readInt())
              : null,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer.write(obj.id);
    writer.writeString(obj.username);
    writer.writeString(obj.email);
    writer.writeString(obj.password);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
    writer.write(obj.avatarIndex);
    writer.writeInt(obj.level);
    writer.writeInt(obj.experiencePoints);
    writer.write(obj.updatedAt?.millisecondsSinceEpoch);
    writer.write(obj.lastLogin?.millisecondsSinceEpoch);
  }
}
