import 'package:hive/hive.dart';
import '../models/pdf_document.dart';

@HiveType(typeId: 4)
class PdfDocumentAdapter extends TypeAdapter<PdfDocument> {
  @override
  PdfDocument read(BinaryReader reader) {
    final id = reader.readInt();
    final category = reader.readString();
    final fileName = reader.readString();
    final filePath = reader.readString();
    final uploadTime = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    final userId = reader.readInt();

    return PdfDocument(
      id: id,
      category: category,
      fileName: fileName,
      filePath: filePath,
      uploadTime: uploadTime,
      userId: userId,
    );
  }

  @override
  void write(BinaryWriter writer, PdfDocument obj) {
    writer.writeInt(obj.id);
    writer.writeString(obj.category ?? '');
    writer.writeString(obj.fileName ?? '');
    writer.writeString(obj.filePath ?? '');
    writer.writeInt(obj.uploadTime.millisecondsSinceEpoch);
    writer.writeInt(obj.userId);
  }

  @override
  int get typeId => 4;
}
