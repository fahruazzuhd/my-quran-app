import 'package:dio/dio.dart';
import 'package:my_quran/core/utils/failure.dart';
import 'package:my_quran/data/datasources/remote/quran_remote_datasource.dart';
import 'package:my_quran/data/models/reciter_model.dart';
import 'package:my_quran/domain/entities/reciter.dart';
import 'package:my_quran/domain/entities/surah.dart';
import 'package:my_quran/domain/entities/surah_recitation.dart';
import 'package:my_quran/domain/repositories/quran_repository.dart';

class QuranRepositoryImpl implements QuranRepository {
  QuranRepositoryImpl(this._remoteDataSource);

  final QuranRemoteDataSource _remoteDataSource;

  ReciterModel? _cachedRecitersLookup(String id, List<Reciter> reciters) {
    for (final r in reciters) {
      if (r.id == id) return ReciterModel(id: r.id, name: r.name, englishName: r.englishName);
    }
    return null;
  }

  @override
  Future<({List<Surah>? data, Failure? failure})> getSurahList() async {
    try {
      final list = await _remoteDataSource.fetchSurahList();
      return (data: list, failure: null);
    } on DioException catch (e) {
      return (data: null, failure: Failure(_dioMessage(e)));
    } catch (e) {
      return (data: null, failure: Failure(e.toString()));
    }
  }

  @override
  Future<({List<Reciter>? data, Failure? failure})> getAudioReciters() async {
    try {
      final list = await _remoteDataSource.fetchAudioReciters();
      return (data: list, failure: null);
    } on DioException catch (e) {
      return (data: null, failure: Failure(_dioMessage(e)));
    } catch (e) {
      return (data: null, failure: Failure(e.toString()));
    }
  }

  @override
  Future<({SurahRecitation? data, Failure? failure})> getSurahRecitation({
    required int surahNumber,
    required String reciterId,
  }) async {
    try {
      final recitersResult = await getAudioReciters();
      if (recitersResult.failure != null) {
        return (data: null, failure: recitersResult.failure);
      }
      final reciter = _cachedRecitersLookup(
        reciterId,
        recitersResult.data ?? [],
      );
      if (reciter == null) {
        return (data: null, failure: const Failure('Reciter not found'));
      }

      final detail = await _remoteDataSource.fetchSurahAudio(
        surahNumber: surahNumber,
        reciterId: reciterId,
      );
      if (detail.ayahs.isEmpty) {
        return (data: null, failure: const Failure('No audio available'));
      }
      return (data: detail.toEntity(reciter), failure: null);
    } on DioException catch (e) {
      return (data: null, failure: Failure(_dioMessage(e)));
    } catch (e) {
      return (data: null, failure: Failure(e.toString()));
    }
  }

  String _dioMessage(DioException e) {
    final status = e.response?.statusCode;
    final msg = e.message ?? 'Network error';
    if (status != null) return 'Error $status: $msg';
    return msg;
  }
}
