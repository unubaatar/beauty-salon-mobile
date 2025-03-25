import '../models/workerLevel.dart';

class Worker {
  final String id;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String avatar;
  final Workerlevel level;

  Worker(
      {required this.id,
      required this.firstName,
      required this.lastName,
      required this.phone,
      required this.email,
      required this.avatar,
      required this.level});

  factory Worker.fromJson(Map<String, dynamic> json) {
    return Worker(
        id: json['_id'],
        firstName: json['firstName'],
        lastName: json['lastName'],
        phone: json['phone'],
        email: json['email'],
        avatar: json['avatar'],
        level: Workerlevel.fromJson(json['level']));
  }
}