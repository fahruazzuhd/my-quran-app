import 'package:my_quran/domain/entities/reciter.dart';

class ReciterModel extends Reciter {
  const ReciterModel({
    required super.id,
    required super.name,
    required super.englishName,
  });

  factory ReciterModel.fromJson(Map<String, dynamic> json) {
    return ReciterModel(
      id: json['identifier'] as String,
      name: json['name'] as String? ?? '',
      englishName: json['englishName'] as String? ?? '',
    );
  }
}
