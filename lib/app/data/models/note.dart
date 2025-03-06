class Note {
  final String id;
  final String title;
  final String content;
  final String category;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String userId;
  final bool isNewLocally;      // 新增字段：标记是否为本地新建
  final bool isModifiedLocally; // 新增字段：标记是否在本地被修改
  final bool isDeletedLocally;  // 新增字段：标记是否在本地被删除
  final bool isSynced;          // 新增字段：标记是否已与服务器同步

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.createdAt,
    this.updatedAt,
    required this.userId,
    this.isNewLocally = false,
    this.isModifiedLocally = false,
    this.isDeletedLocally = false,
    this.isSynced = false,
  });

  // 创建本地新笔记的工厂方法
  factory Note.localNew({
    required String id,
    required String title,
    required String content,
    required String category,
    required String userId,
  }) {
    return Note(
      id: id,
      title: title,
      content: content,
      category: category,
      createdAt: DateTime.now(),
      userId: userId,
      isNewLocally: true,
      isSynced: false,
    );
  }

  // 标记为本地修改的笔记
  Note copyWithModified({
    String? title,
    String? content,
    String? category,
  }) {
    return Note(
      id: this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      createdAt: this.createdAt,
      updatedAt: DateTime.now(),
      userId: this.userId,
      isNewLocally: this.isNewLocally,
      isModifiedLocally: true,
      isDeletedLocally: this.isDeletedLocally,
      isSynced: false,
    );
  }

  // 标记为本地删除的笔记
  Note copyWithDeleted() {
    return Note(
      id: this.id,
      title: this.title,
      content: this.content,
      category: this.category,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt,
      userId: this.userId,
      isNewLocally: this.isNewLocally,
      isModifiedLocally: this.isModifiedLocally,
      isDeletedLocally: true,
      isSynced: false,
    );
  }

  // 标记为已同步的笔记
  Note copyWithSynced() {
    return Note(
      id: this.id,
      title: this.title,
      content: this.content,
      category: this.category,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt,
      userId: this.userId,
      isNewLocally: false,
      isModifiedLocally: false,
      isDeletedLocally: false,
      isSynced: true,
    );
  }

  // 从JSON创建
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      category: json['category'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      userId: json['userId'],
      isSynced: true,
    );
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'userId': userId,
    };
  }
}
