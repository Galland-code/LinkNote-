import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/question.dart';

@HiveType(typeId: 5)
class QuestionAdapter extends TypeAdapter<Question> {
  @override
  final int typeId = 5;

  @override
  Question read(BinaryReader reader) {
    final id = reader.readString();
    final source = reader.readString();
    final content = reader.readString();
    final optionsLength = reader.readInt();
    final options = List<String>.generate(
      optionsLength,
      (_) => reader.readString(),
    );
    final correctOptionIndex = reader.readString();
    final type = reader.readString();
    final difficulty = reader.readString();
    final sourceId = reader.readInt();
    final wrongAnswer = reader.readString();
    final category = reader.readString();

    return Question(
      id: id,
      source: source,
      content: content,
      options: options,
      correctOptionIndex: correctOptionIndex,
      type: type,
      difficulty: difficulty,
      sourceId: sourceId,
      wrongAnswer: wrongAnswer,
      category: category,
    );
  }

  @override
  void write(BinaryWriter writer, Question obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.source);
    writer.writeString(obj.content);
    writer.writeInt(obj.options?.length ?? 0);
    for (var option in obj.options ?? []) {
      writer.writeString(option);
    }
    writer.writeString(obj.correctOptionIndex);
    writer.writeString(obj.type);
    writer.writeString(obj.difficulty);
    writer.writeInt(obj.sourceId);
    writer.writeString(obj.wrongAnswer ?? '');
    writer.writeString(obj.category);
  }
}
