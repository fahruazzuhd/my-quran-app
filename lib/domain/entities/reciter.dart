import 'package:equatable/equatable.dart';

class Reciter extends Equatable {
  const Reciter({
    required this.id,
    required this.name,
    required this.englishName,
  });

  final String id;
  final String name;
  final String englishName;

  @override
  List<Object?> get props => [id, name, englishName];
}
