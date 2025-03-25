import 'serviceCategory.dart';
import 'serviceVariant.dart';

class Service {
  final String id;
  final String title;
  final String description;
  final int price;
  final String image;
  final bool isActive;
  final int duration;
  final ServiceCategory category;
  final List<ServiceVariant>? variants;

  Service(
      {
      required this.id,
      required this.title,
      required this.description,
      required this.price,
      required this.image,
      required this.isActive,
      required this.duration,
      required this.category,
      this.variants
      });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      price: json['price'],
      image: json['image'],
      isActive: json['isActive'],
      duration: json['duration'],
      category: ServiceCategory.fromJson(json['category']),
      variants: (json['variants'] != null)
          ? List<ServiceVariant>.from(
              json['variants']
                  .map((variant) => ServiceVariant.fromJson(variant)),
            )
          : null,
    );
  }
}