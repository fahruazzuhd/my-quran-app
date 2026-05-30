import 'package:get_it/get_it.dart';
import 'package:my_quran/core/audio/audio_player_service.dart';
import 'package:my_quran/core/network/dio_client.dart';
import 'package:my_quran/data/datasources/remote/quran_remote_datasource.dart';
import 'package:my_quran/data/repositories/quran_repository_impl.dart';
import 'package:my_quran/domain/repositories/quran_repository.dart';
import 'package:my_quran/domain/usecases/get_audio_reciters.dart';
import 'package:my_quran/domain/usecases/get_surah_list.dart';
import 'package:my_quran/domain/usecases/get_surah_recitation.dart';
import 'package:my_quran/presentation/controllers/home_controller.dart';
import 'package:my_quran/presentation/controllers/player_controller.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // Core
  sl.registerLazySingleton(DioClient.new);
  sl.registerLazySingleton<AudioPlayerService>(AudioPlayerService.new);

  // Data
  sl.registerLazySingleton<QuranRemoteDataSource>(
    () => QuranRemoteDataSourceImpl(sl<DioClient>().dio),
  );
  sl.registerLazySingleton<QuranRepository>(
    () => QuranRepositoryImpl(sl()),
  );

  // Domain
  sl.registerLazySingleton(() => GetSurahList(sl()));
  sl.registerLazySingleton(() => GetAudioReciters(sl()));
  sl.registerLazySingleton(() => GetSurahRecitation(sl()));

  // Presentation — factories so each route gets fresh controllers
  sl.registerFactory(
    () => HomeController(
      getSurahList: sl(),
      getAudioReciters: sl(),
      getSurahRecitation: sl(),
      audioPlayerService: sl(),
    ),
  );
  sl.registerLazySingleton(
    () => PlayerController(
      audioPlayerService: sl(),
    ),
  );
}
