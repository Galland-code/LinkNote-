import 'package:hive/hive.dart';

part 'note_model.g.dart'; // 这个文件将由 build_runner 自动生成

@HiveType(typeId: 2)
class Note {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String content;

  @HiveField(3)
  String date;

  @HiveField(4)
  String? icon;

  @HiveField(5)
  String? category;

  @HiveField(6)
  String userId;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    this.icon,
    this.category,
    required this.userId,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'].toString(),
      title: json['title'],
      content: json['content'],
      date: json['date'],
      icon: json['icon'],
      category: json['category'],
      userId: json['userId'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date,
      'icon': icon,
      'category': category,
      'userId': userId,
    };
  }
}
