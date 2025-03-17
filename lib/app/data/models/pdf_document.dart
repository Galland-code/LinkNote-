class PdfDocument {
  final int id;
  final String? category;
  final String fileName;
  final String filePath;
  final DateTime uploadTime;
  final int userId;

  PdfDocument({
    required this.id,
    this.category,
    required this.fileName,
    required this.filePath,
    required this.uploadTime,
    required this.userId,
  });

  factory PdfDocument.fromJson(Map<String, dynamic> json) {
    return PdfDocument(
      id: json['id'],
      category: json['category'],
      fileName: json['fileName'],
      filePath: json['filePath'],
      uploadTime: DateTime.parse(json['uploadTime']),
      userId: json['userId'],
    );
  }
}
