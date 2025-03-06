import 'package:hive/hive.dart';
import '../models/question.dart';

// Hive适配器ID需要唯一
@HiveType(typeId: 0)
class QuestionAdapter extends TypeAdapter<Question> {
  @override
  final int typeId = 0;

  @override
  Question read(BinaryReader reader) {
    final id = reader.readString();
    final source = reader.readString();
    final content = reader.readString();
    final optionsLength = reader.readInt();
    final options = <String>[];

    for (var i = 0; i < optionsLength; i++) {
      options.add(reader.readString());
    }

    final correctOptionIndex = reader.readInt();

    return Question(
      id: id,
      source: source,
      content: content,
      options: options,
      correctOptionIndex: correctOptionIndex,
    );
  }

  @override
  void write(BinaryWriter writer, Question obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.source);
    writer.writeString(obj.content);
    writer.writeInt(obj.options.length);

    for (var option in obj.options) {
      writer.writeString(option);
    }

    writer.writeInt(obj.correctOptionIndex);
  }
}
