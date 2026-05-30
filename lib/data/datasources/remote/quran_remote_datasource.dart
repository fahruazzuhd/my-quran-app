import 'package:dio/dio.dart';
import 'package:my_quran/data/models/reciter_model.dart';
import 'package:my_quran/data/models/surah_detail_model.dart';
import 'package:my_quran/data/models/surah_model.dart';

abstract class QuranRemoteDataSource {
  Future<List<SurahModel>> fetchSurahList();

  Future<List<ReciterModel>> fetchAudioReciters();

  Future<SurahDetailModel> fetchSurahAudio({
    required int surahNumber,
    required String reciterId,
  });
}

class QuranRemoteDataSourceImpl implements QuranRemoteDataSource {
  QuranRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<SurahModel>> fetchSurahList() async {
    final response = await _dio.get<Map<String, dynamic>>('/surah');
    final data = response.data?['data'] as List<dynamic>? ?? [];
    return data
        .map((e) => SurahModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ReciterModel>> fetchAudioReciters() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/edition',
      queryParameters: {
        'format': 'audio',
        'type': 'versebyverse',
      },
    );
    final data = response.data?['data'] as List<dynamic>? ?? [];
    return data
        .map((e) => ReciterModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<SurahDetailModel> fetchSurahAudio({
    required int surahNumber,
    required String reciterId,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/surah/$surahNumber/$reciterId',
    );
    final data = response.data?['data'] as Map<String, dynamic>? ?? {};
    return SurahDetailModel.fromJson(data);
  }
}
