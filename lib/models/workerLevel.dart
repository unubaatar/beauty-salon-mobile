import '../models/workerLevel.dart';

class Workerlevel {
  final String id;
  final String image;
  final String description;
  final String level;
  final bool isActive;

  Workerlevel({
    required this.id,
    required this.image,
    required this.description,
    required this.level,
    required this.isActive,
  });

    factory Workerlevel.fromJson(Map<String, dynamic> json) {
    return Workerlevel(
        id: json['_id'],
        image: json['image'],
        description: json['description'],
        level: json['level'],
        isActive: json['isActive']);
  }
}