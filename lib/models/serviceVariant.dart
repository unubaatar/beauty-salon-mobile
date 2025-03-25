// import "./service.dart";

class ServiceVariant {
  final String id;
  // final Service service;
  final String title;
  final String body;
  final int price;
  final int duration;

  ServiceVariant({
    required this.id,
    // required this.service,
    required this.title,
    required this.body,
    required this.price,
    required this.duration,
  });

  factory ServiceVariant.fromJson(Map<String, dynamic> json) {
    return ServiceVariant(
        id: json['_id'],
        // service: Service.fromJson(json['service']),
        title: json['title'],
        body: json['body'],
        price: json['price'],
        duration: json['duration']);
  }
}