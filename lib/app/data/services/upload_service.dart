import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart' hide FormData;

class UploadService {
  final dio.Dio _dio = dio.Dio();

  // 上传 PDF 文件的函数
  Future<void> uploadPDF(File file, String userId) async {
    try {
      // 使用 dio 的 FormData
      dio.FormData formData = dio.FormData.fromMap({
        'file': await dio.MultipartFile.fromFile(file.path),  // 上传的文件
        'userid': userId,  // 用户 ID
      });

      // 发送 POST 请求到文件上传接口
      final response = await _dio.post(
        'http://82.157.18.189:8080/linknote/api/files/upload',
        data: formData,
      );

      // 检查响应结果
      if (response.statusCode == 200) {
        print("文件上传成功");
        // 处理上传成功后的逻辑
      } else {
        print("文件上传失败：${response.statusMessage}");
        // 处理上传失败的逻辑
      }
    } catch (e) {
      print("文件上传失败，错误信息：$e");
      // 处理异常
    }
  }
}
