import 'package:hive/hive.dart';
import '../models/quiz_challenge.dart';

@HiveType(typeId: 6)
class QuizChallengeAdapter extends TypeAdapter<QuizChallenge> {
  @override
  QuizChallenge read(BinaryReader reader) {
    final id = reader.readString();
    final title = reader.readString();
    final source = reader.readString();
    final levelsLength = reader.readInt();
    final levels = List<QuizLevel>.generate(levelsLength, (_) => reader.read());
    final createdAt = DateTime.fromMillisecondsSinceEpoch(reader.readInt());

    return QuizChallenge(
      id: id,
      title: title,
      source: source,
      levels: levels,
      createdAt: createdAt,
    );
  }

  @override
  void write(BinaryWriter writer, QuizChallenge obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeString(obj.source);
    writer.writeInt(obj.levels.length);
    for (var level in obj.levels) {
      writer.write(level);
    }
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
  }

  @override
  int get typeId => 6; 

}
