import 'package:hive/hive.dart';
import '../models/note.dart';

@HiveType(typeId: 1)
class NoteAdapter extends TypeAdapter<Note> {
  @override
  final int typeId = 1;

  @override
  Note read(BinaryReader reader) {
    final id = reader.readString();
    final title = reader.readString();
    final content = reader.readString();
    final category = reader.readString();
    final createdAt = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    
    // 读取updatedAt（可能为null）
    final hasUpdatedAt = reader.readBool();
    final updatedAt = hasUpdatedAt 
        ? DateTime.fromMillisecondsSinceEpoch(reader.readInt()) 
        : null;
    
    final userId = reader.readString();
    
    // 读取同步状态标记
    final isNewLocally = reader.readBool();
    final isModifiedLocally = reader.readBool();
    final isDeletedLocally = reader.readBool();
    final isSynced = reader.readBool();
    
    return Note(
      id: id,
      title: title,
      content: content,
      category: category,
      createdAt: createdAt,
      updatedAt: updatedAt,
      userId: userId,
      isNewLocally: isNewLocally,
      isModifiedLocally: isModifiedLocally,
      isDeletedLocally: isDeletedLocally,
      isSynced: isSynced,
    );
  }

  @override
  void write(BinaryWriter writer, Note obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeString(obj.content);
    writer.writeString(obj.category);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
    
    // 写入updatedAt（可能为null）
    writer.writeBool(obj.updatedAt != null);
    if (obj.updatedAt != null) {
      writer.writeInt(obj.updatedAt!.millisecondsSinceEpoch);
    }
    
    writer.writeString(obj.userId);
    
    // 写入同步状态标记
    writer.writeBool(obj.isNewLocally);
    writer.writeBool(obj.isModifiedLocally);
    writer.writeBool(obj.isDeletedLocally);
    writer.writeBool(obj.isSynced);
  }
}
