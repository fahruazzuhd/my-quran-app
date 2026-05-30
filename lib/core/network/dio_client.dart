import 'package:dio/dio.dart';
import 'package:my_quran/core/constants/api_constants.dart';

class DioClient {
  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
          'Accept-Encoding': 'gzip',
        },
      ),
    );
  }

  late final Dio _dio;

  Dio get dio => _dio;
}
