import 'package:hive/hive.dart';

part 'achievement_model.g.dart'; // 这个文件将由 build_runner 自动生成

@HiveType(typeId: 1)
class Achievement {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String icon;

  @HiveField(3)
  String description;

  @HiveField(4)
  String date;

  @HiveField(5)
  int value;

  @HiveField(6)
  String? criteria;

  Achievement({
    required this.id,
    required this.title,
    required this.icon,
    required this.description,
    required this.date,
    required this.value,
    this.criteria,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'].toString(),
      title: json['title'],
      icon: json['icon'],
      description: json['description'],
      date: json['date'],
      value: json['value'],
      criteria: json['criteria'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'icon': icon,
      'description': description,
      'date': date,
      'value': value,
      'criteria': criteria,
    };
  }
}
