import 'package:my_quran/core/utils/failure.dart';
import 'package:my_quran/domain/entities/reciter.dart';
import 'package:my_quran/domain/repositories/quran_repository.dart';

class GetAudioReciters {
  GetAudioReciters(this._repository);

  final QuranRepository _repository;

  Future<({List<Reciter>? data, Failure? failure})> call() =>
      _repository.getAudioReciters();
}
