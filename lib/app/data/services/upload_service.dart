import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart' hide FormData;
import 'package:http/http.dart';
import 'package:http/http.dart' as http;

class UploadService {
  final dio.Dio _dio = dio.Dio();

  // 上传 PDF 文件的函数
  Future<void> uploadPDF(File file, int userId) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://82.157.18.189:8080/linknote/api/files/upload'),
      );

      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      request.fields['userid'] = userId.toString(); // 将用户 ID 添加到请求字段

      // 发送请求
      var response = await request.send();

      // 处理响应
      if (response.statusCode == 200) {
        print("文件上传成功");
      } else {
        final responseBody = await response.stream.bytesToString(); // 获取响应体
        print('响应: ${response.statusCode} - $responseBody');
        throw Exception('文件上传失败，状态码: ${response.statusCode}');
      }
    } catch (e) {
      print("文件上传失败，错误信息：$e");
      // 处理异常
    }
  }
}
